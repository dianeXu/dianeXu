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
        NSLog(@"dianeXu: Initialized 3D region growing segmentation controller.");
    } else {
        NSLog(@"dianeXu: Init of 3D region growing segmentation controller failed.");
    }
    return self;
}

/*
 * Custom dealloc to get rid of itk objects.
 */
-(void)dealloc {
    [segImageWrapper dealloc];
    [super dealloc];
}

@end
