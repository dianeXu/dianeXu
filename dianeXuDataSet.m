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
    NSNumber* stdSpacing = [[NSNumber alloc] initWithInt:1];
    NSNumber* stdOrigin = [[NSNumber alloc] initWithInt:0];
    [primarySpacing setX:stdSpacing];
    [primarySpacing setY:stdSpacing];
    [primarySpacing setZ:stdSpacing];
    [secondarySpacing setX:stdSpacing];
    [secondarySpacing setY:stdSpacing];
    [secondarySpacing setZ:stdSpacing];
    [primaryOrigin setX:stdOrigin];
    [primaryOrigin setY:stdOrigin];
    [primaryOrigin setZ:stdOrigin];
    [secondaryOrigin setX:stdOrigin];
    [secondaryOrigin setY:stdOrigin];
    [secondaryOrigin setZ:stdOrigin];
    return self;
}

- (ROI*) eamROI {
    //TODO: Add code!
    
    return eamROI;
}

- (void)makePointsFromNavxString:(NSString *)inputString:(int)pointCount {
    //+status
    [status showWindow:self];
    [[status window] orderFrontRegardless];
    [status setStatusText:@"Reading NavX coordinates to dianeXu..."];
    int statusDone = 0;
    //-status
    
    dianeXuCoord *currentCoord = [[dianeXuCoord alloc] init];
    
    NSMutableArray *lineCoords = [[inputString componentsSeparatedByString:@"\n"] mutableCopy];
    //trim lines
    [lineCoords removeObjectAtIndex:0];
    [lineCoords removeLastObject];
    
    
    for (NSString *singleCoord in lineCoords) {
        //trim junk from the single lines
        NSString *trimmedSingleCoord = [singleCoord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //seperate the coords
        NSArray *justCoords = [trimmedSingleCoord componentsSeparatedByString:@"  "];
        
        //set coordinate values and add to eamPoints array.
        [currentCoord setX:[NSNumber numberWithDouble:[[justCoords objectAtIndex:0]  doubleValue]]];
        [currentCoord setY:[NSNumber numberWithDouble:[[justCoords objectAtIndex:0]  doubleValue]]];
        [currentCoord setZ:[NSNumber numberWithDouble:[[justCoords objectAtIndex:0]  doubleValue]]];
        [eamPoints addObject:currentCoord];
        
        //+status
        statusDone++;
        [status setStatusPercent:(int)statusDone/pointCount];
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
    
    [primarySpacing setX:[[NSNumber alloc] initWithDouble:[primeSlice pixelSpacingX]]];
    [primarySpacing setY:[[NSNumber alloc] initWithDouble:[primeSlice pixelSpacingY]]];
    //[primarySpacing setZ:[[NSNumber alloc] initWithDouble:[primeSlice sliceInterval]]];
    
    [secondarySpacing setX:[[NSNumber alloc] initWithDouble:[secondSlice pixelSpacingX]]];
    [secondarySpacing setY:[[NSNumber alloc] initWithDouble:[secondSlice pixelSpacingY]]];
    //[secondarySpacing setZ:[[NSNumber alloc] initWithDouble:[secondSlice sliceInterval]]];
    
    NSLog(@"Updated prime geometry info to psX:%@, psY:%@, psZ:%@",[primarySpacing x],[primarySpacing y],[primarySpacing z]);
    NSLog(@"Updated scnd geometry info to psX:%@, psY:%@, psZ:%@",[secondarySpacing x],[secondarySpacing y],[secondarySpacing z]);
}


@end
