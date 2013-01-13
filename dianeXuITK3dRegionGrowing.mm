//
//  dianeXuITK3dRegionGrowing.mm
//  This file is part of dianeXu <http://www.dianeXu.com>.
//
//  dianeXu is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  dianeXu is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with dianeXu.  If not, see <http://www.gnu.org/licenses/>.
//
//  Copyright (c) 2012 Dipl.Ing.(FH) Björn Schwarz <beegz@dianeXu.com>. All rights reserved.
//

#import "dianeXuITK3dRegionGrowing.h"

#import "OsiriXAPI/ViewerController.h"
#import "OsiriXAPI/DCMView.h"
#import "OsiriXAPI/DCMPix.h"
#import "OsiriXAPI/Roi.h"

#include "itkCastImageFilter.h"
#include "itkConnectedThresholdImageFilter.h"

#pragma mark typedefs
/*
 * begin typedef section
 */

// char output image
typedef unsigned char OutputPixelType;
typedef opITK::Image<OutputPixelType,3> OutputImageType;

// type caster
typedef opITK::CastImageFilter<ImageType, OutputImageType> CastingFilterType;

// filters
typedef opITK::ConnectedThresholdImageFilter<ImageType, ImageType> ConnectedThresholdFilterType;
typedef opITK::ImageToImageFilter<ImageType, ImageType> SegmentationInterfaceType;


#pragma mark class implementation
@implementation dianeXuITK3dRegionGrowing

/*
 * Initializes the class with a viewer for segmentation
 */
-(id) initWithViewer:(ViewerController*)viewer {
    self = [super init];
    if (self) {
        segViewer = viewer;
        
        segImageWrapper = [[dianeXuITKImageWrapper alloc] initWithViewer:segViewer andSlice:-1];
        ImageType::Pointer tmpImage = [segImageWrapper image];
        outOrigin = tmpImage->GetOrigin();
        outSpacing = tmpImage->GetSpacing();
        outSize[0] = [[[segViewer pixList] objectAtIndex:0] pwidth];
        outSize[1] = [[[segViewer pixList] objectAtIndex:0] pheight];
        outSize[2] = [[segViewer pixList] count];
        NSLog(@"dianeXu: Initialized 3D region growing segmentation.");
    } else {
        NSLog(@"dianeXu: Init of 3D region growing segmentation failed.");
    }
    return self;
}

/*
 * Perform the 3d region growing and return a ROI to the viewer
 */
-(void) start3dRegionGrowingAt:(long)slice withSeedPoint:(NSPoint)seed usingRoiName:(NSString*)name andRoiColor:(NSColor*)color withAlgorithm:(int)algorithmIndex lowerThreshold:(float)lowerThreshold upperThreshold:(float)upperThreshold {
    NSLog(@"dianeXu: Starting 3D region growing.");
    
    //float volume;
    
    // define seed for the ITK filter
    ImageType::IndexType index;
    index[0] = (long)seed.x;
    index[1] = (long)seed.y;
    if (slice == -1) { // if 3d segmentation is happening, use the currently shown image's index
        index[2] = [[segViewer imageView] curImage];
    } else {
        index[2] = 0;
    }
    
    CastingFilterType::Pointer castFilter = CastingFilterType::New();
    
    ConnectedThresholdFilterType::Pointer thresholdFilter = 0L;
    SegmentationInterfaceType::Pointer segmentationFilter = 0L;
    
    // prepare segmentation algorithm
    switch (algorithmIndex) {
        case 0:
            NSLog(@"dianeXu: Using connected threshold ITK filter.");
            thresholdFilter = ConnectedThresholdFilterType::New();
            thresholdFilter->SetLower(lowerThreshold);
            thresholdFilter->SetUpper(upperThreshold);
            thresholdFilter->SetReplaceValue(255);
            thresholdFilter->SetSeed(index);
            thresholdFilter->SetInput([segImageWrapper image]);
            segmentationFilter = thresholdFilter;
            break;
            
        default:
            NSLog(@"dianeXu: Requested ITK filter unknown or not yet implemented. Aborting segmentation.");
            return;
            break;
    }
    
    // TODO: If output to another viewer is required, setup resampler
    
    castFilter->SetInput(segmentationFilter->GetOutput()); // convert float to char
    
    NSLog(@"dianeXu: Starting 3d region growing.");
    try {
        castFilter->Update();
    } catch (opITK::ExceptionObject &excep){
        NSLog(@"dianeXu: Region growing failed. Sorry.");
        return;
    }
    
    NSString* roiAnnotation = [[NSString alloc] initWithFormat:@"Segmentation ROI"];
    
    unsigned char* buffer = castFilter->GetOutput()->GetBufferPointer();
    
    NSLog(@"dianeXu: Creating ROI from segmentation Data");
    
    if (slice == -1) { // ROI for 3d segmentation
        unsigned long i;
        
        RGBColor roiColor;
        roiColor.red = [color redComponent] * 65535;
        roiColor.blue = [color blueComponent] * 65535;
        roiColor.green = [color greenComponent] * 65535;
        
        for (i = 0; i < [[segViewer pixList] count]; i++) {
            int bufferHeight = [[[segViewer pixList] objectAtIndex:i] pheight];
            int bufferWidth = [[[segViewer pixList] objectAtIndex:i] pwidth];
            
            ROI* newSegROI = [[ROI alloc] initWithTexture:buffer textWidth:bufferWidth textHeight:bufferHeight textName:roiAnnotation positionX:0 positionY:0 spacingX:[[[segViewer imageView] curDCM] pixelSpacingX] spacingY:[[[segViewer imageView] curDCM] pixelSpacingY] imageOrigin:NSMakePoint([[[segViewer imageView] curDCM] originX], [[[segViewer imageView] curDCM] originY])];
            [newSegROI setComments:@"Comment"];
            
            if ([newSegROI reduceTextureIfPossible] == NO) { // roi isn't empty
                [[[segViewer roiList] objectAtIndex:i] addObject:newSegROI];
                // TODO: add notification center
                
                [newSegROI setColor:roiColor];
                [newSegROI setROIMode:ROI_selected];
                // TODO: add notification center
            }
            [newSegROI setSliceThickness:[[[segViewer imageView] curDCM] sliceThickness]];
            [newSegROI release];
            buffer += bufferHeight*bufferWidth;
        }
        
    } else {
        // single slices not yet supported
    }
    
    
    
}

/*
 * Custom dealloc to get rid of ITK objects.
 */
-(void)dealloc {
    [segImageWrapper dealloc];
    [super dealloc];
}

@end
