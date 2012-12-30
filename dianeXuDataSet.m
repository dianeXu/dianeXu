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

- (id)init {
    self = [super init];
    if (self != nil) {
        primarySpacing = [[dianeXuCoord alloc] init];
        primaryOrigin = [[dianeXuCoord alloc] init];
        secondarySpacing = [[dianeXuCoord alloc] init];
        secondaryOrigin = [[dianeXuCoord alloc] init];
        eamPoints = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)eamROItoController: (ViewerController*)targetController {
    // prepare needed data du adjust pixelspacings in eam data
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
    
    // make new points with values in pixels!
    for (dianeXuCoord* currentCoord in eamPoints) {
        dianeXuCoord* newItem = [[dianeXuCoord alloc] init];
        
        [newItem setXValue:[[currentCoord xValue] decimalNumberByDividingBy:[pixelGeometry xValue]]];
        [newItem setYValue:[[currentCoord yValue] decimalNumberByDividingBy:[pixelGeometry yValue]]];
        [newItem setZValue:[[currentCoord zValue] decimalNumberByDividingBy:[pixelGeometry zValue]]];
        [newItem setZValue:[[newItem zValue] decimalNumberByRoundingAccordingToBehavior:roundingControl]];
        // TODO: IMPLEMENT ORIGIN OFFSET!
        [pointsROI addObject:newItem];
        newItem = nil;
    }
    
    [pointsROI sortUsingDescriptors:sortDescriptors];
    
    // prepare data for ROI handling
    DCMPix* curPix = [[targetController pixList] objectAtIndex:[[targetController imageView] curImage]];
    NSMutableArray* roiSeriesList = [targetController roiList];
    NSMutableArray* roiImageList = [roiSeriesList objectAtIndex:[[targetController imageView] curImage]];
    ROI* newRoi = [targetController newROI: tCPolygon];
    
    // TODO: ITERARE over all Images and correspindung slice coords
    // prepare more data for handling points
    NSMutableArray* points = [newRoi points];
    
    for (dianeXuCoord* currentCoord in pointsROI) {
        if ([[[currentCoord zValue] stringValue] isEqualToString:@"-28"]) {
            [points addObject:[targetController newPoint:[[currentCoord xValue] floatValue]+111 :[[currentCoord yValue] floatValue]+111]];
        }
    }
    // sort points to be a polygon in order
    [dianeXuDataSet sortClockwise:points];
    
    // display ROI
    [newRoi setROIMode: ROI_selected];
    [roiImageList addObject:newRoi];
    [targetController needsDisplayUpdate];
}

- (void)makePointsFromNavxString:(NSString *)inputString {
    
    NSMutableArray *lineCoords = [[inputString componentsSeparatedByString:@"\n"] mutableCopy];
    //trim lines
    [lineCoords removeObjectAtIndex:0];
    [lineCoords removeLastObject];
    
    for (NSString *singleCoord in lineCoords) {
        dianeXuCoord *currentCoord = [dianeXuCoord alloc];
        
        //trim junk from the single lines
        NSString *trimmedSingleCoord = [singleCoord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        //seperate the coords
        NSArray *justCoords = [trimmedSingleCoord componentsSeparatedByString:@"  "];
        
        //set coordinate values and add to eamPoints array.
        [currentCoord setXValue:[NSDecimalNumber  decimalNumberWithString:[justCoords objectAtIndex:0]]];
        [currentCoord setYValue:[NSDecimalNumber decimalNumberWithString:[justCoords objectAtIndex:1]]];
        [currentCoord setZValue:[NSDecimalNumber decimalNumberWithString:[justCoords objectAtIndex:2]]];
        //NSLog(@"%@ %@ %@", [currentCoord xValue],[currentCoord yValue],[currentCoord zValue]);
        
        [eamPoints addObject:currentCoord];
        //NSLog(@"%@", [eamPoints objectAtIndex:[eamPoints count]-1]);
        
        currentCoord = nil;
    }
}

- (void)updateGeometryInfoFrom:(ViewerController *)primeViewer andFrom:(ViewerController *)secondViewer {
    // get the first images of each viewer
    DCMPix* primeSlice = [[primeViewer pixList] objectAtIndex:0];
    DCMPix* secondSlice = [[secondViewer pixList] objectAtIndex:0];
    
    [primarySpacing setXValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[primeSlice pixelSpacingX]] decimalValue]]];
    [primarySpacing setYValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[primeSlice pixelSpacingY]] decimalValue]]];
    [primarySpacing setZValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[primeSlice sliceThickness]] decimalValue]]];
    
    [secondarySpacing setXValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[secondSlice pixelSpacingX]] decimalValue]]];
    [secondarySpacing setYValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[secondSlice pixelSpacingY]] decimalValue]]];
    [secondarySpacing setZValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[secondSlice sliceThickness]] decimalValue]]];
    
    NSLog(@"Updated prime geometry info to %@",primarySpacing);
    NSLog(@"Updated scnd geometry info to %@",secondarySpacing);
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
