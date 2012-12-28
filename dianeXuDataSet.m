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
    //prepare needed data du adjust pixelspacings in eam data
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
    
    //make new points with values in pixels!
    for (dianeXuCoord* currentCoord in eamPoints) {
        dianeXuCoord* newItem = [[dianeXuCoord alloc] init];
        
        [newItem setXValue:[[currentCoord xValue] decimalNumberByDividingBy:[pixelGeometry xValue]]];
        [newItem setYValue:[[currentCoord yValue] decimalNumberByDividingBy:[pixelGeometry yValue]]];
        [newItem setZValue:[[currentCoord zValue] decimalNumberByDividingBy:[pixelGeometry zValue]]];
        [newItem setZValue:[[newItem zValue] decimalNumberByRoundingAccordingToBehavior:roundingControl]];
        //TODO: IMPLEMENT ORIGIN OFFSET!
        [pointsROI addObject:newItem];
        newItem = nil;
    }
    
    [pointsROI sortUsingDescriptors:sortDescriptors];
    
    //prepare data for ROI handling
    DCMPix* curPix = [[targetController pixList] objectAtIndex:[[targetController imageView] curImage]];
    NSMutableArray* roiSeriesList = [targetController roiList];
    NSMutableArray* roiImageList = [roiSeriesList objectAtIndex:[[targetController imageView] curImage]];
    ROI* newRoi = [targetController newROI: tCPolygon];
    
    //TODO: ITERARE over all Images and correspindung slice coords
    //prepare more data for handling points
    NSMutableArray* points = [newRoi points];
    float xCenter = 0;
    float yCenter = 0;
    
    for (dianeXuCoord* currentCoord in pointsROI) {
        if ([[[currentCoord zValue] stringValue] isEqualToString:@"-28"]) {
            [points addObject:[targetController newPoint:[[currentCoord xValue] floatValue]+111 :[[currentCoord yValue] floatValue]+111]];
            
            xCenter += [[points lastObject] x];
            yCenter += [[points lastObject] y];
        }
    }
    //adjust center for sorting
    xCenter /= [points count];
    yCenter /= [points count];

    //sort points clockwise around center
    
    //display ROI
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
    //get the first images of each viewer
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

+ (void)sortClockwise:(NSMutableArray *)theArray {
    
    NSPoint currentCenter;
    currentCenter.x = 0;
    currentCenter.y = 0;
    for (MyPoint* currentPoint in theArray) {
        currentCenter.x += [currentPoint x];
        currentCenter.y += [currentPoint y];
    }
    currentCenter.x /= [theArray count];
    currentCenter.y /= [theArray count];
    
    NSComparisonResult (^sortBlock)(id, id) = ^(id obj1, id obj2) {
        if ([obj1 position] > [obj2 position]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 position] < [obj2 position]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };

        
    }
}

@end
