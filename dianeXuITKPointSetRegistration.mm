//
//  dianeXuITKPointSetRegistration.mm
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

#import "dianeXuITKPointSetRegistration.h"



@implementation dianeXuITKPointSetRegistration

/*
 * Init the class with two sets of dianeXuCoords
 */
-(id)initWithFixedSet:(NSMutableArray*)fixed andMovingSet:(NSMutableArray*)moving {
    self = [super init];
    if (self) {
        if ([moving count] == 0 || [fixed count] == 0) {
            NSRunInformationalAlertPanel(@"OOPS... I am missing some data", @"Seems you forgot to complete a prior step, since one of the models is empty. If you are sure this is a bug, please refer to teh bugtracker via the preferences.", @"OK", nil, nil,nil);
            NSLog(@"dianeXu: Point set registration failed because fixed (%d) or moving (%d) points are empty.",[fixed count],[moving count]);
            return nil;
        } else {
            fixedPointSet = PointSetType::New();
            movingPointSet = PointSetType::New();
            
            PointsContainer::Pointer fixedPointContainer = PointsContainer::New();
            PointsContainer::Pointer movingPointContainer = PointsContainer::New();
            
            NSLog(@"dianeXu: Point set registration initialized with %ld fixed and %ld moving points.",fixedPointSet->GetNumberOfPoints(),movingPointSet->GetNumberOfPoints());
        }
    }
    return self;
}

@end
