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
    if (status == nil) {
        status = [[dianeXuStatusWindowController alloc] initWithWindowNibName:@"dianeXuStatusWindow"];
        primarySpacing = [[dianeXuCoord alloc] init];
        primaryOrigin = [[dianeXuCoord alloc] init];
        secondarySpacing = [[dianeXuCoord alloc] init];
        secondaryOrigin = [[dianeXuCoord alloc] init];
        eamPoints = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)eamROItoController: (ViewerController*)targetController {
    //prepare needed data
    dianeXuCoord* pixelGeometry = [[dianeXuCoord alloc] init];
    DCMPix* slice = [[targetController pixList] objectAtIndex:0];
    NSMutableArray* pointsROI = [[NSMutableArray alloc] init];
    
    [pixelGeometry setXValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingX]] decimalValue]]];
    [pixelGeometry setYValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingY]] decimalValue]]];
    [pixelGeometry setZValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice sliceThickness]] decimalValue]]];
    
    NSLog(@"Preparing EAM ROI for %u points with pixelspacings %@",[eamPoints count],pixelGeometry);
    
    NSLog(@"%@",eamPoints);
}

- (void)makePointsFromNavxString:(NSString *)inputString {
    
    NSMutableArray *lineCoords = [[inputString componentsSeparatedByString:@"\n"] mutableCopy];
    //trim lines
    [lineCoords removeObjectAtIndex:0];
    [lineCoords removeLastObject];
    
    for (NSString *singleCoord in lineCoords) {
        dianeXuCoord *currentCoord = [[dianeXuCoord alloc] init];
        
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
    
    NSLog(@"%@",eamPoints);
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


@end
