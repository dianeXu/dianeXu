//
//  dianeXuITK3dRegionGrowing.h
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
//  Copyright (c) 2012-2013 Dipl.Ing.(FH) Björn Schwarz <beegz@dianeXu.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OsiriXAPI/ViewerController.h"

#import "dianeXuITKImageWrapper.h"

@interface dianeXuITK3dRegionGrowing : NSObject {
    ViewerController* segViewer;
    dianeXuITKImageWrapper* segImageWrapper;
    ImageType::PointType outOrigin;
    ImageType::SpacingType outSpacing;
    ImageType::SizeType outSize;
}

/*
 * Initializes the class with a viewer for segmentation
 */
- (id)initWithViewer:(ViewerController*)viewer;

/*
 * Perform the 3d region growing and return a ROI to the viewer
 */
- (NSMutableArray*)start3dRegionGrowingAt:(long)slice withSeedPoint:(NSPoint)seed usingRoiName:(NSString*)name andRoiColor:(NSColor*)color withAlgorithm:(int)algorithmIndex lowerThreshold:(float)lowerThreshold upperThreshold:(float)upperThreshold outputResolution:(long)roiResolution;
@end
