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
//  Copyright (c) 2012-2013 Dipl.Ing.(FH) Björn Schwarz <beegz@dianeXu.com>. All rights reserved.
//

#import "dianeXuDataSet.h"

@implementation dianeXuDataSet

@synthesize difGeometry,eamGeometry,lesionGeometry, angioGeometry;

- (id)init {
    self = [super init];
    if (self != nil) {
        difGeometry = [[NSMutableArray alloc] init];
        eamGeometry = [[NSMutableArray alloc] init];
        lesionGeometry = [[NSMutableArray alloc] init];
        angioGeometry = [[NSMutableArray alloc] init];
    }
    return self;
}

/*
 * output modeldata data as roi to a viewer controller
 */
- (void)modelROItoController: (ViewerController*)targetController forGeometry:(NSString*)geometry {
    NSMutableArray* modelData = [NSMutableArray new];
    modelData = [self valueForKey:geometry];
    //NSLog(@"%@",modelData);
    // prepare needed data du adjust pixelspacings in model data
    dianeXuCoord* pixelGeometry = [[dianeXuCoord alloc] init];
    DCMPix* slice = [[targetController pixList] objectAtIndex:0];
    NSMutableArray* pointsROI = [[NSMutableArray alloc] init];
    NSDecimalNumberHandler* roundingControl = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSSortDescriptor* zSort =[[[NSSortDescriptor alloc] initWithKey:@"zValue" ascending:YES] autorelease];
    NSArray* sortDescriptors = [NSArray arrayWithObject:zSort];
    
    if ([targetController orientationVector] == eCoronalPos) {
        [pixelGeometry setXValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingX]] decimalValue]]];
        [pixelGeometry setYValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice sliceThickness]] decimalValue]]];
        [pixelGeometry setZValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingY]] decimalValue]]];
        //NSLog(@"Preparing model ROI for %u points with pixelspacings %@",[eamPoints count],pixelGeometry);
        //NSLog(@"dianeXu: series origin is X:%f Y:%f Z:%f",[slice originX],[slice originY],[slice originZ]);
        
        // make new points with values in pixels!
        for (dianeXuCoord* currentCoord in modelData) {
            dianeXuCoord* newItem = [[dianeXuCoord alloc] init];
            
            // get coordinates corrected by originoffset, correct offset orientation, swap y- and z-values to match Osirix image orientation
            [newItem setXValue:[[currentCoord xValue] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originX]] decimalValue]]]];
            [newItem setYValue:[[currentCoord yValue] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originY]] decimalValue]]]];
            [newItem setZValue:[[currentCoord zValue] decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originZ]] decimalValue]]]];
            
            // adjust pixelspacings and adjust z to be matched with slices
            [newItem setXValue:[[newItem xValue] decimalNumberByDividingBy:[pixelGeometry xValue]]];
            [newItem setYValue:[[newItem yValue] decimalNumberByDividingBy:[pixelGeometry yValue]]];
            [newItem setZValue:[[newItem zValue] decimalNumberByDividingBy:[pixelGeometry zValue]]];
            [newItem setYValue:[[newItem yValue] decimalNumberByRoundingAccordingToBehavior:roundingControl]];
            
            [pointsROI addObject:newItem];
            newItem = nil;
        }
    } else if ([targetController orientationVector] == eAxialPos) {
        [pixelGeometry setXValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingX]] decimalValue]]];
        [pixelGeometry setYValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingY]] decimalValue]]];
        [pixelGeometry setZValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice sliceThickness]] decimalValue]]];
        NSLog(@"Preparing model ROI for %u points with pixelspacings %@",[modelData count],pixelGeometry);
        NSLog(@"dianeXu: series origin is X:%f Y:%f Z:%f",[slice originX],[slice originY],[slice originZ]);
        
        // make new points with values in pixels!
        for (dianeXuCoord* currentCoord in modelData) {
            dianeXuCoord* newItem = [[dianeXuCoord alloc] init];
            
            // get coordinates corrected by originoffset, correct offset orientation, swap y- and z-values to match Osirix image orientation
            [newItem setXValue:[[currentCoord xValue] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originX]] decimalValue]]]];
            [newItem setYValue:[[currentCoord yValue] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originY]] decimalValue]]]];
            [newItem setZValue:[[currentCoord zValue] decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originZ]] decimalValue]]]];
            
            // adjust pixelspacings and adjust z to be matched with slices
            [newItem setXValue:[[newItem xValue] decimalNumberByDividingBy:[pixelGeometry xValue]]];
            [newItem setYValue:[[newItem yValue] decimalNumberByDividingBy:[pixelGeometry yValue]]];
            [newItem setZValue:[[newItem zValue] decimalNumberByDividingBy:[pixelGeometry zValue]]];
            float correctedZ = [[newItem zValue] floatValue]+ [[targetController pixList] count];
            [newItem setZValue:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",correctedZ]]];
            [newItem setZValue:[[newItem zValue] decimalNumberByRoundingAccordingToBehavior:roundingControl]];
            
            [pointsROI addObject:newItem];
            newItem = nil;
        }
    }
    
    // sort points to approximate the polygon border 
    [pointsROI sortUsingDescriptors:sortDescriptors];
//    NSLog(@"dianeXu: %@",pointsROI);
    
    // prepare data for ROI handling
    //DCMPix* curPix = [[targetController pixList] objectAtIndex:[[targetController imageView] curImage]];
    NSMutableArray* roiSeriesList = [targetController roiList];
    NSMutableArray* roiImageList = [roiSeriesList objectAtIndex:[[targetController imageView] curImage]];
    
    for (DCMPix* currentSlice in [targetController pixList]) {
        ROI* newRoi = [targetController newROI: tCPolygon];
        NSMutableArray* points = [newRoi points];
        
        NSInteger currentIndex = [[targetController pixList] indexOfObject:currentSlice];
        for (dianeXuCoord* currentCoord in pointsROI) {
            if ([targetController orientationVector] == eCoronalPos) {
                if ([[[currentCoord yValue] stringValue] isEqualToString:[NSString stringWithFormat:@"%u",currentIndex]]) {
                    [points addObject:[targetController newPoint:[[currentCoord xValue] floatValue]:[[currentCoord zValue] floatValue]]];
                }
            } else if ([targetController orientationVector] == eAxialPos) {
                if ([[[currentCoord zValue] stringValue] isEqualToString:[NSString stringWithFormat:@"%u",currentIndex]]) {
                    float correctedX = [[currentCoord xValue] floatValue];
                    float correctedY = [[currentCoord yValue] floatValue];
                    [points addObject:[targetController newPoint:correctedX:correctedY]];
                }
            }

        }
        // sort points to be a polygon in order and set some additional properties
        [dianeXuDataSet sortClockwise:points];
        //[newRoi setROIMode: ROI_selected];
        NSString* roiName = [NSString stringWithFormat:@"dianeXu %@",geometry];
        [newRoi setName:roiName];
        // go to image matching the current slice
        roiImageList = [roiSeriesList objectAtIndex:currentIndex];
        // add ROI if there are any points in it
        if ([points count] > 2) {
            [roiImageList addObject:newRoi];
        }
    }
    // update the targetcontroller in case something happened on the current image
    [targetController needsDisplayUpdate];
    [modelData release];
}

/*
 * output model data as point rois to a viewer controller
 */
- (void)modelPointsToController:(ViewerController*)targetController forGeometry:(NSString*)geometry {
    NSMutableArray* modelData = [NSMutableArray new];
    modelData = [self valueForKey:geometry];
    //NSLog(@"%@",modelData);
    // prepare needed data du adjust pixelspacings in model data
    dianeXuCoord* pixelGeometry = [[dianeXuCoord alloc] init];
    DCMPix* slice = [[targetController pixList] objectAtIndex:0];
    NSMutableArray* pointsROI = [[NSMutableArray alloc] init];
    NSDecimalNumberHandler* roundingControl = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSSortDescriptor* zSort =[[[NSSortDescriptor alloc] initWithKey:@"zValue" ascending:YES] autorelease];
    NSArray* sortDescriptors = [NSArray arrayWithObject:zSort];
    
    if ([targetController orientationVector] == eCoronalPos) {
        [pixelGeometry setXValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingX]] decimalValue]]];
        [pixelGeometry setYValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice sliceThickness]] decimalValue]]];
        [pixelGeometry setZValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingY]] decimalValue]]];
        //NSLog(@"Preparing model ROI for %u points with pixelspacings %@",[eamPoints count],pixelGeometry);
        //NSLog(@"dianeXu: series origin is X:%f Y:%f Z:%f",[slice originX],[slice originY],[slice originZ]);
        
        // make new points with values in pixels!
        for (dianeXuCoord* currentCoord in modelData) {
            dianeXuCoord* newItem = [[dianeXuCoord alloc] init];
            
            // get coordinates corrected by originoffset, correct offset orientation, swap y- and z-values to match Osirix image orientation
            [newItem setXValue:[[currentCoord xValue] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originX]] decimalValue]]]];
            [newItem setYValue:[[currentCoord yValue] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originY]] decimalValue]]]];
            [newItem setZValue:[[currentCoord zValue] decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originZ]] decimalValue]]]];
            
            // adjust pixelspacings and adjust z to be matched with slices
            [newItem setXValue:[[newItem xValue] decimalNumberByDividingBy:[pixelGeometry xValue]]];
            [newItem setYValue:[[newItem yValue] decimalNumberByDividingBy:[pixelGeometry yValue]]];
            [newItem setZValue:[[newItem zValue] decimalNumberByDividingBy:[pixelGeometry zValue]]];
            [newItem setYValue:[[newItem yValue] decimalNumberByRoundingAccordingToBehavior:roundingControl]];
            
            [pointsROI addObject:newItem];
            newItem = nil;
        }
    } else if ([targetController orientationVector] == eAxialPos) {
        [pixelGeometry setXValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingX]] decimalValue]]];
        [pixelGeometry setYValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingY]] decimalValue]]];
        [pixelGeometry setZValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice sliceThickness]] decimalValue]]];
        //NSLog(@"Preparing model ROI for %u points with pixelspacings %@",[eamPoints count],pixelGeometry);
        //NSLog(@"dianeXu: series origin is X:%f Y:%f Z:%f",[slice originX],[slice originY],[slice originZ]);
        
        // make new points with values in pixels!
        for (dianeXuCoord* currentCoord in modelData) {
            dianeXuCoord* newItem = [[dianeXuCoord alloc] init];
            
            // get coordinates corrected by originoffset, correct offset orientation, swap y- and z-values to match Osirix image orientation
            [newItem setXValue:[[currentCoord xValue] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originX]] decimalValue]]]];
            [newItem setYValue:[[currentCoord zValue] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originY]] decimalValue]]]];
            [newItem setZValue:[[currentCoord yValue] decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice originZ]] decimalValue]]]];
            
            // adjust pixelspacings and adjust z to be matched with slices
            [newItem setXValue:[[newItem xValue] decimalNumberByDividingBy:[pixelGeometry xValue]]];
            [newItem setYValue:[[newItem yValue] decimalNumberByDividingBy:[pixelGeometry yValue]]];
            [newItem setZValue:[[newItem zValue] decimalNumberByDividingBy:[pixelGeometry zValue]]];
            [newItem setYValue:[[newItem yValue] decimalNumberByRoundingAccordingToBehavior:roundingControl]];
            
            [pointsROI addObject:newItem];
            newItem = nil;
        }
    }
    // sort points to approximate the polygon border
    [pointsROI sortUsingDescriptors:sortDescriptors];
//    NSLog(@"%@",pointsROI);
    
    // prepare data for ROI handling
    long roiIndex = 0;
    for (DCMPix* currentSlice in [targetController pixList]) {
        NSInteger currentIndex = [[targetController pixList] indexOfObject:currentSlice];
        for (dianeXuCoord* currentCoord in pointsROI) {
            if ([[[currentCoord yValue] stringValue] isEqualToString:[NSString stringWithFormat:@"%u",currentIndex]]) {
                ROI* newRoi = [targetController newROI: t2DPoint];
//                NSString* roiName = [NSString stringWithFormat:@"dianeXu %@ point #%ld",geometry, roiIndex]; //bad for removal
                NSString* roiName = [NSString stringWithFormat:@"dianeXu %@ point",geometry];
                NSRect newRect;
                newRect = NSMakeRect([[currentCoord xValue] floatValue], [[currentCoord zValue] floatValue], 0, 0);
                [newRoi setROIRect:newRect];
                [newRoi setName:roiName];
                [[[targetController roiList] objectAtIndex:currentIndex] addObject:newRoi];
                newRoi = nil;
                roiIndex++;
            }
        }
    }
    // update the targetcontroller in case something happened on the current image
    [targetController needsDisplayUpdate];
    [modelData release];
}

/*
 * reduce the number of points in a model to be lower than maxPoints.
 */
- (NSMutableArray*)reduceModelPointsOf:(NSMutableArray*)inArray to:(int)maxPoints {
    NSMutableArray* result = [NSMutableArray new];
    if ([inArray count] < maxPoints) {
        result = inArray;
        return result;
    } else {
       int stepSize = (int)([inArray count]/maxPoints);
        int step = 0;
        for (dianeXuCoord* item in inArray) {
            if (step == stepSize) {
                [result addObject:item];
                step = 0;
            } else {
                step++;
            }
        }
        return result;
    }
}

/*
 * custom setters for all models using the number reduce
 */
- (void)setAngioGeometry:(NSMutableArray *)inGeometry {
    angioGeometry = [[self reduceModelPointsOf:inGeometry to:5000] retain];
}
- (void)setDifGeometry:(NSMutableArray *)inGeometry {
    difGeometry = [[self reduceModelPointsOf:inGeometry to:5000] retain];
}
- (void)setEamGeometry:(NSMutableArray *)inGeometry {
    eamGeometry = [[self reduceModelPointsOf:inGeometry to:5000] retain];
}
- (void)setLesionGeometry:(NSMutableArray *)inGeometry {
    lesionGeometry = [[self reduceModelPointsOf:inGeometry to:5000] retain];
}

/*
 * sort the points of a roi slice in circular fashion to approcimate the closed polygon order.
 */
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
