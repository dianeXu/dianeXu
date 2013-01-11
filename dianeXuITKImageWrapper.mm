//
//  dianeXuITKImageWrapper.mm
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

#import "dianeXuITKImageWrapper.h"

@implementation dianeXuITKImageWrapper

/*
 * Create a new imagewrapper from the given ViewerController's content
 */
- (id)initWithViewer:(ViewerController*)sourceViewer andSlice:(int)slice {
    self = [super init];
    if (self) {
        NSLog(@"ITK image wrapper initialized.");
        activeViewer = sourceViewer;
        sliceIndex = slice;
        volumeData = 0;
        [self updateWrapper];
    } else {
        NSLog(@"dianeXu: ITK image wrapper failed to initialize.");
    }
    return self;
}

/*
 * Get a pointer to the ITK image
 */
- (ImageType::Pointer)image {
    return image;
}

/*
 * Update the imagewrapper to reflect changes in the viewer
 */
- (void)updateWrapper {
    
    DCMPix* firstPix = [[activeViewer pixList] objectAtIndex:0];
    int sliceCount = [[activeViewer pixList] count];
    long bufferSize;
    
    ImportFilterType::Pointer importfilter = ImportFilterType::New();
    ImportFilterType::SizeType size;
    ImportFilterType::IndexType start;
    ImportFilterType::RegionType region;
    
    // uncomment to enable debugging
    importfilter->DebugOn();
    
    activeOrigin[0] = [firstPix originX];
    activeOrigin[1] = [firstPix originY];
    activeOrigin[2] = [firstPix originZ];
    
    voxelSpacing[0] = [firstPix pixelSpacingX];
    voxelSpacing[1] = [firstPix pixelSpacingY];
    voxelSpacing[2] = [firstPix sliceThickness];
    
    size[0] = [firstPix pwidth];
    size[1] = [firstPix pheight];
    
    // ensure tabula rasa
    if (volumeData) {
        free(volumeData);
    }
    
    if (sliceIndex == -1) { // -1 = import all of them
        size[2] = sliceCount;
        bufferSize = size[0]*size[1]*size[2];
        volumeData = (float*)malloc(bufferSize*sizeof(float));
        
        if (volumeData) {
            memcpy(volumeData, [activeViewer volumePtr], bufferSize*sizeof(float));
        } else {
            NSLog(@"dianeXu: Couldn't allocate volume buffer for ITK image wrapper. Sorry!");
        }
        
        start.Fill(0);
        
    } else { // just get a single slice
        size[2] = 1;
        bufferSize = size[0]*size[1];
        volumeData = (float*)malloc(bufferSize*sizeof(float));
            if (volumeData) {
                memcpy(volumeData, [activeViewer volumePtr], bufferSize*sizeof(float));
            } else {
                NSLog(@"dianeXu: Couldn't allocate volume buffer for ITK image wrapper. Sorry!");
            }
            start[0];
            start[1];
            start[2] = sliceIndex;
        }
        region.SetIndex(start);
        region.SetSize(size);
        importfilter->SetRegion(region);
        importfilter->SetOrigin(activeOrigin);
        importfilter->SetSpacing(voxelSpacing);
        importfilter->SetImportPointer(volumeData, bufferSize, false);
    
    image = importfilter->GetOutput();
    
    // uncomment for debugging
    image->DebugOn();
    image->Update();
    NSLog(@"dianeXu: ITK image wrapper updated");
}

@end