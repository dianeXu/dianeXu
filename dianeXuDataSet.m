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
    return self;
}

- (void)makePointsFromNavxString:(NSString *)inputString:(int)pointCount {
    [status showWindow:self];
    [[status window] orderFrontRegardless];
    [status setStatusText:@"Reading NavX coordinates to dianeXu..."];
    
    dianeXuCoord *currentCoord = [[dianeXuCoord alloc] init];
    
    NSMutableArray *lineCoords = [[inputString componentsSeparatedByString:@"\n"] mutableCopy];
    //trim lines
    [lineCoords removeObjectAtIndex:0];
    [lineCoords removeLastObject];
    int statusDone = 0;
    for (NSString *singleCoord in lineCoords) {
        NSString *trimmedSingleCoord = [singleCoord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *justCoords = [trimmedSingleCoord componentsSeparatedByString:@"  "];
        
        [currentCoord setX:[NSNumber numberWithDouble:[[justCoords objectAtIndex:0]  doubleValue]]];
        [currentCoord setY:[NSNumber numberWithDouble:[[justCoords objectAtIndex:0]  doubleValue]]];
        [currentCoord setZ:[NSNumber numberWithDouble:[[justCoords objectAtIndex:0]  doubleValue]]];
        
        [eamPoints addObject:currentCoord];
        statusDone++;
        [status setStatusPercent:(int)statusDone];
    }
    [[status window] orderOut:self];
    [status setStatusPercent:0];
}

@end
