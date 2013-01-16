//
//  dianeXuITKPointSetRegistration.h
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

#import <Foundation/Foundation.h>

#import "dianeXuCoord.h"
#include "itkEuler3DTransform.h"

#include "itkPointSet.h"

/*
 * general purpose typedefs needed for member va
 */
const unsigned int dimension = 3;
typedef opITK::PointSet<float,dimension> PointSetType;
typedef opITK::Euler3DTransform<double> TransformType;
typedef PointSetType::PointType PointType;
typedef PointSetType::PointsContainer PointsContainer;

@interface dianeXuITKPointSetRegistration : NSObject {
    PointSetType::Pointer fixedPointSet;
    PointSetType::Pointer movingPointSet;
    TransformType::Pointer transformData;
}

/*
 * Init the class with two sets of dianeXuCoords
 */
-(id)initWithFixedSet:(NSMutableArray*)fixed andMovingSet:(NSMutableArray*)moving;

/*
 * perform the registration based on the PointSets and needed TransformType
 */
-(void)performRegistration:(int)transformType;

@end
