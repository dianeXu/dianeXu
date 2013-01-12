//
//  dianeXuDataSet.m
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

#import "dianeXuDataSet.h"

@implementation dianeXuDataSet

@synthesize difGeometry,eamGeometry,lesionGeometry;

- (id)init {
    self = [super init];
    if (self != nil) {
        difGeometry = [[NSMutableArray alloc] init];
        eamGeometry = [[NSMutableArray alloc] init];
        lesionGeometry = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)difROItoController: (ViewerController*)targetController {
    // prepare needed data du adjust pixelspacings in dif data
    dianeXuCoord* pixelGeometry = [[dianeXuCoord alloc] init];
    DCMPix* slice = [[targetController pixList] objectAtIndex:0];
    NSMutableArray* pointsROI = [[NSMutableArray alloc] init];
    NSDecimalNumberHandler* roundingControl = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSSortDescriptor* zSort =[[[NSSortDescriptor alloc] initWithKey:@"zValue" ascending:YES] autorelease];
    NSArray* sortDescriptors = [NSArray arrayWithObject:zSort];
    
    [pixelGeometry setXValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingX]] decimalValue]]];
    [pixelGeometry setYValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingY]] decimalValue]]];
    [pixelGeometry setZValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice sliceThickness]] decimalValue]]];
    //NSLog(@"Preparing EAM ROI for %u points with pixelspacings %@",[eamPoints count],pixelGeometry);
    
    //NSLog(@"%f %f %f",[slice originX],[slice originY],[slice originZ]);
    
    // make new points with values in pixels!
    for (dianeXuCoord* currentCoord in difGeometry) {
        dianeXuCoord* newItem = [[dianeXuCoord alloc] init];
        
        // get coordinates corrected by originoffset, correct offset orientation, swap y- and z-values to match Osirix image orientation
        [newItem setXValue:[[currentCoord xValue] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originX]] decimalValue]]]];
        [newItem setYValue:[[currentCoord zValue] decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originZ]] decimalValue]]]];
        [newItem setZValue:[[currentCoord yValue] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originY]] decimalValue]]]];
        
        //adjust pixelspacings and adjust z to be matched with slices
        [newItem setXValue:[[newItem xValue] decimalNumberByDividingBy:[pixelGeometry xValue]]];
        [newItem setYValue:[[newItem yValue] decimalNumberByDividingBy:[pixelGeometry zValue]]];
        [newItem setZValue:[[newItem zValue] decimalNumberByDividingBy:[pixelGeometry yValue]]];
        [newItem setZValue:[[newItem zValue] decimalNumberByRoundingAccordingToBehavior:roundingControl]];
        [pointsROI addObject:newItem];
        newItem = nil;
    }
    
    [pointsROI sortUsingDescriptors:sortDescriptors];
    //NSLog(@"%@",pointsROI);
    
    // prepare data for ROI handling
    //DCMPix* curPix = [[targetController pixList] objectAtIndex:[[targetController imageView] curImage]];
    NSMutableArray* roiSeriesList = [targetController roiList];
    NSMutableArray* roiImageList = [roiSeriesList objectAtIndex:[[targetController imageView] curImage]];
    
    for (DCMPix* currentSlice in [targetController pixList]) {
        ROI* newRoi = [targetController newROI: tCPolygon];
        NSMutableArray* points = [newRoi points];
        
        NSInteger currentIndex = [[targetController pixList] indexOfObject:currentSlice];
        for (dianeXuCoord* currentCoord in pointsROI) {
            if ([[[currentCoord zValue] stringValue] isEqualToString:[NSString stringWithFormat:@"%u",currentIndex]]) {
                [points addObject:[targetController newPoint:[[currentCoord xValue] floatValue]:[[currentCoord yValue] floatValue]]];
            }
        }
        // sort points to be a polygon in order and set some additional properties
        [dianeXuDataSet sortClockwise:points];
        //[newRoi setROIMode: ROI_selected];
        [newRoi setName:@"Imported EAM Data"];
        // go to image matching the current slice
        roiImageList = [roiSeriesList objectAtIndex:currentIndex];
        // add ROI if there are any points in it
        if ([points count] != 0) {
            [roiImageList addObject:newRoi];
        }
    }
    //update the targetcontroller in case something happened on the current image
    [targetController needsDisplayUpdate];
}

+ (void)sortClockwise:(NSMutableArray *)sortArray {
    /*
     * Block to compute new centroid of our sorted polygon!
     */
    NSPoint (^updateCentroid)(NSMutableArray*) = ^(NSMutableArray* polygon) {
        NSPoint newCentroid;
        newCentroid.x = 0;
        newCentroid.y = 0;
        
        for (MyPoint* currentPoint in sortArray) {
            newCentroid.x += [currentPoint x];
            newCentroid.y += [currentPoint y];
        }
        newCentroid.x /= [polygon count];
        newCentroid.y /= [polygon count];
        return newCentroid;
    };
    
    // create a centroid point and use the above block
    NSPoint centroid = updateCentroid(sortArray);
    
    /*
     * Block to compute heading for a given Point
     */
    float (^heading2d)(NSPoint) = ^(NSPoint inPoint) {
        float angle = atan2f(-inPoint.y, inPoint.x);
        return -1*angle;
    };
    
    
    // now sort the array
    [sortArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        MyPoint* p1 = obj1;
        MyPoint* p2 = obj2;
        
        // create vectors from centroid to points first
        NSPoint v1;
        v1.x = p1.x-centroid.x;
        v1.y = p1.y-centroid.y;
        NSPoint v2;
        v2.x = p2.x-centroid.x;
        v2.y = p2.y-centroid.y;
        
        // compute headings
        float h1 = heading2d(v1);
        float h2 = heading2d(v2);
        
        // compare headings ans return accordingly
        if (h1 > h2) {
            return NSOrderedAscending;
        } else if (h1 < h2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

@end
