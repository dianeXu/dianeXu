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

#import "dianeXuCoord.h"

#import "OsiriXAPI/ViewerController.h"
#import "OsiriXAPI/DCMView.h"
#import "OsiriXAPI/DCMPix.h"
#import "OsiriXAPI/Roi.h"

#include "itkCastImageFilter.h"
#include "itkConnectedThresholdImageFilter.h"
#include "itkVTKImageExport.h"
#include "itkVtkImageExportBase.h"

#include "vtkImageImport.h"
#include "vtkContourFilter.h"
#include "vtkImageData.h"
#include "vtkPolyData.h"
#include "vtkPolyDataConnectivityFilter.h"


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

//vtk pipeline
typedef opITK::VTKImageExport<OutputImageType> ImageExportType;

/**
 * This function will connect the given itk::VTKImageExport filter to the given vtkImageImport filter.
 */
template <typename ITK_Exporter, typename VTK_Importer>
void ConnectPipelines(ITK_Exporter exporter, VTK_Importer* importer)
{
    importer->SetUpdateInformationCallback(exporter->GetUpdateInformationCallback());
    importer->SetPipelineModifiedCallback(exporter->GetPipelineModifiedCallback());
    importer->SetWholeExtentCallback(exporter->GetWholeExtentCallback());
    importer->SetSpacingCallback(exporter->GetSpacingCallback());
    importer->SetOriginCallback(exporter->GetOriginCallback());
    importer->SetScalarTypeCallback(exporter->GetScalarTypeCallback());
    importer->SetNumberOfComponentsCallback(exporter->GetNumberOfComponentsCallback());
    importer->SetPropagateUpdateExtentCallback(exporter->GetPropagateUpdateExtentCallback());
    importer->SetUpdateDataCallback(exporter->GetUpdateDataCallback());
    importer->SetDataExtentCallback(exporter->GetDataExtentCallback());
    importer->SetBufferPointerCallback(exporter->GetBufferPointerCallback());
    importer->SetCallbackUserData(exporter->GetCallbackUserData());
}


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
-(NSMutableArray*) start3dRegionGrowingAt:(long)slice withSeedPoint:(NSPoint)seed usingRoiName:(NSString*)name andRoiColor:(NSColor*)color withAlgorithm:(int)algorithmIndex lowerThreshold:(float)lowerThreshold upperThreshold:(float)upperThreshold outputResolution:(long)roiResolution {
    NSLog(@"dianeXu: Starting 3D region growing.");
    
    //init resulting model array
    NSMutableArray* modelArray = [NSMutableArray new];
    
    // define seed for the ITK filter
    ImageType::IndexType index;
    index[0] = (long)seed.x;
    index[1] = (long)seed.y;
    index[2] = [[segViewer imageView] curImage];
    
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
            return nil;
            break;
    }
    
    // TODO: If output to another viewer is required, setup resampler
    
    castFilter->SetInput(segmentationFilter->GetOutput()); // convert float to char
    
    NSLog(@"dianeXu: Starting 3d region growing.");
    try {
        castFilter->Update();
    } catch (opITK::ExceptionObject &excep){
        NSLog(@"dianeXu: Region growing failed. Sorry.");
        return nil;
    }
    
    NSLog(@"dianeXu: Creating ROI from segmentation Data.");
    
    long i,x;
    long startSlice, endSlice;
    OutputImageType::Pointer frameImage = castFilter->GetOutput();
    frameImage->Update();
    
    if (slice == -1) {
        startSlice = 0;
        endSlice = [[segViewer pixList] count];
    } else {
        startSlice = slice;
        endSlice = startSlice+1;
    }

    // ITK to VTK pipeline setup
    ImageExportType::Pointer itkExport = ImageExportType::New();
    itkExport->SetInput(frameImage);
    
    vtkImageImport* vtkImport = vtkImageImport::New();
    ConnectPipelines(itkExport, vtkImport);
    vtkImport->Update();
    
    int dataExtent[6];
    vtkImport->GetDataExtent(dataExtent);
    
    for (i = startSlice; i < endSlice; i++) {
        long imageSize = (dataExtent[1]+1) * (dataExtent[3]+1);
        unsigned char* image2dData = (unsigned char*)malloc(imageSize),*tmpPtr;
        vtkImageImport* image2d;
        DCMPix* curPix = [[segViewer pixList] objectAtIndex:i];
        
        memcpy(image2dData, ((unsigned char*)vtkImport->GetOutput()->GetScalarPointer())+(i*imageSize), imageSize);
        
        image2d = vtkImageImport::New();
        image2d->SetWholeExtent(0, dataExtent[1], 0, dataExtent[3], 0, 0);
        image2d->SetDataExtentToWholeExtent();
        image2d->SetDataScalarTypeToUnsignedChar();
        image2d->SetImportVoidPointer(image2dData);
        
        tmpPtr = image2dData;
        for (x = 0; x < [curPix pwidth]; x++) {
            tmpPtr[x] = 0;
        }
        tmpPtr = image2dData + ([curPix pwidth]) * ([curPix pheight]-1);
        for (x = 0; x < [curPix pwidth]; x++) {
            tmpPtr[x] = 0;
        }
        tmpPtr = image2dData;
        for (x = 0; x < [curPix pheight]; x++) {
            *tmpPtr = 0;
            tmpPtr += [curPix pwidth];
        }
        tmpPtr = image2dData + [curPix pwidth]-1;
        for (x = 0; x < [curPix pheight]; x++) {
            *tmpPtr = 0;
            tmpPtr += [curPix pwidth];
        }
        
        //VTK Contour Filter
    
        vtkContourFilter* isoContour = vtkContourFilter::New();
        isoContour->SetValue(0, 1);
        isoContour->SetInput((vtkDataObject*)image2d->GetOutput());
        isoContour->Update();
        
        image2d->GetDataExtent(dataExtent);
        
        vtkPolyDataConnectivityFilter *filter = vtkPolyDataConnectivityFilter::New();
        filter->SetColorRegions(1);
        filter->SetExtractionModeToLargestRegion();
        filter->SetInput(isoContour->GetOutput());
        
        vtkPolyDataConnectivityFilter *filter2 = vtkPolyDataConnectivityFilter::New();
        filter2->SetColorRegions(1);
        filter2->SetExtractionModeToLargestRegion();
        filter2->SetInput(filter->GetOutput());
        
        vtkPolyData* output = filter2->GetOutput();
        output->Update();
        
        if (output->GetNumberOfLines() > 3) {
            long ii;
            ROI* newSegROI = [segViewer newROI: tCPolygon];
            NSMutableArray* roiPoints = [newSegROI points];
            
            for (ii = 0; ii < output->GetNumberOfLines(); ii+=2) {
                double p[3];
                output->GetPoint(ii,p);
                [roiPoints addObject:[segViewer newPoint:p[0] :p[1]]];
            }
            ii--;
            if (ii >= output->GetNumberOfLines()) {
                ii-=2;
            }
            for ( ; ii >= 0; ii-=2) {
                double p[3];
                output->GetPoint(ii,p);
                [roiPoints addObject:[segViewer newPoint:p[0] :p[1]]];
            }
            
            #define MAXPOINTS 100
    
            if ([roiPoints count] > MAXPOINTS) {
                long newRoiResolution = [roiPoints count] / MAXPOINTS;
                newRoiResolution++;
                if (newRoiResolution > roiResolution) {
                    roiResolution = newRoiResolution;
                }
            }
            if (roiResolution != 1 && roiResolution > 0) {
                long total = [roiPoints count];
                long zz;
                for (ii = total-1; ii >= 0; ii -= roiResolution) {
                    for (zz = 0; zz < roiResolution-1 ; zz++) {
                        if ([roiPoints count] > 3 && ii-zz >= 0) {
                            [roiPoints removeObjectAtIndex:ii-zz];
                        }
                    }
                }
            }
            
            NSMutableArray* roiSeriesList;
            NSMutableArray* roiImageList;
                
            roiSeriesList = [segViewer roiList];
            
            roiImageList = [roiSeriesList objectAtIndex: i];

            [newSegROI setName:name];
            [roiImageList addObject:newSegROI];
            [[segViewer imageView] roiSet];
            [segViewer needsDisplayUpdate];
            
            //add points to output model
            double pixelSpacings[3];
            pixelSpacings[0] = [[[segViewer pixList] objectAtIndex:0] pixelSpacingX];
            pixelSpacings[1] = [[[segViewer pixList] objectAtIndex:0] pixelSpacingY];
            pixelSpacings[2] = [[[segViewer pixList] objectAtIndex:0] sliceThickness];
            for (MyPoint* currentPoint in roiPoints) {
                dianeXuCoord* newCoord = [dianeXuCoord new];
                [newCoord setXValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:currentPoint.x*pixelSpacings[0]] decimalValue]]];
                [newCoord setYValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:currentPoint.y*pixelSpacings[1]] decimalValue]]];
                [newCoord setZValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:i*pixelSpacings[2]] decimalValue]]];
                [modelArray addObject:newCoord];
            }
            // clean up
            isoContour->Delete();
            filter->Delete();
            filter2->Delete();
        }
        // more cleanup
        image2d->Delete();
        free(image2dData);
    }
    // even more cleanup
    vtkImport->Delete();
    NSLog(@"dianeXu: Region growing finished. Yay!");
    return modelArray;
}

/*
 * Custom dealloc to get rid of ITK objects.
 */
-(void)dealloc {
    [segImageWrapper dealloc];
    [super dealloc];
}

@end
