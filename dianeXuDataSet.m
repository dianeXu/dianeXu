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
    }
    primarySpacing = [[dianeXuCoord alloc] init];
    primaryOrigin = [[dianeXuCoord alloc] init];
    secondarySpacing = [[dianeXuCoord alloc] init];
    secondaryOrigin = [[dianeXuCoord alloc] init];
    eamPoints = [[NSMutableArray alloc] init];
    return self;
}

- (void)eamROItoController: (ViewerController*)targetController {
    //prepare needed data
    dianeXuCoord* pixelGeometry = [[dianeXuCoord alloc] init];
    DCMPix* slice = [[targetController pixList] objectAtIndex:0];
    //NSMutableArray* pointsROI = [[NSMutableArray alloc] init];
    
    [pixelGeometry setXValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingX]] decimalValue]]];
    [pixelGeometry setYValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice pixelSpacingY]] decimalValue]]];
    [pixelGeometry setZValue:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:[slice sliceThickness]] decimalValue]]];
    NSLog(@"Preparing EAM ROI for %u points with pixelspacings X=%@ Y=%@ Z=%@",[eamPoints count],[pixelGeometry xValue],[pixelGeometry yValue],[pixelGeometry zValue]);
    
    NSLog(@"%@ %@ %@", [[eamPoints objectAtIndex:0] xValue],[[eamPoints objectAtIndex:0] yValue],[[eamPoints objectAtIndex:0] zValue]);
    
    for (int i = 0; i < [eamPoints count]; i++) {
        dianeXuCoord* newValues = [[dianeXuCoord alloc] init]; //[eamPoints objectAtIndex:i];
        
        [newValues setXValue:[[eamPoints objectAtIndex:i] xValue]];
        [newValues setYValue:[[eamPoints objectAtIndex:i] yValue]];
        [newValues setZValue:[[eamPoints objectAtIndex:i] zValue]];
        
        //[tmpCoord setX:[[currentCoord x] decimalNumberByDividingBy:[pixelGeometry x]]];
        //[tmpCoord setY:[[currentCoord y] decimalNumberByDividingBy:[pixelGeometry y]]];
        //[tmpCoord setZ:[[currentCoord z] decimalNumberByDividingBy:[pixelGeometry z]]];
        
     //   NSLog(@"%@ %@ %@", [[eamPoints objectAtIndex:i] xValue],[[eamPoints objectAtIndex:i] yValue],[[eamPoints objectAtIndex:i] zValue]);
    }
}

- (void)makePointsFromNavxString:(NSString *)inputString:(int)pointCount {
    //+status
    [status showWindow:self];
    [[status window] orderFrontRegardless];
    [status setStatusText:@"Reading NavX coordinates to dianeXu..."];
    int statusDone = 0;
    //-status
    
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
        
        //NSLog(@"%@ %@ %@", [[eamPoints objectAtIndex:[eamPoints count]-1] xValue],[[eamPoints objectAtIndex:[eamPoints count]-1] yValue],[[eamPoints objectAtIndex:[eamPoints count]-1] zValue]);
        
        currentCoord = nil;
        
        //+status
        statusDone++;
        [status setStatusPercent:(int)statusDone/pointCount];
        [[status window] update];
        //-status
    }
    
    //+status
    [[status window] orderOut:self];
    [status setStatusPercent:0];
    //-status
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
    
    NSLog(@"Updated prime geometry info to psX:%@, psY:%@, psZ:%@",[primarySpacing xValue],[primarySpacing yValue],[primarySpacing zValue]);
    NSLog(@"Updated scnd geometry info to psX:%@, psY:%@, psZ:%@",[secondarySpacing xValue],[secondarySpacing yValue],[secondarySpacing zValue]);
}


@end
