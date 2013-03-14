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


#include "itkEuclideanDistancePointMetric.h"
#include "itkLevenbergMarquardtOptimizer.h"
#include "itkPointSetToPointSetRegistrationMethod.h"

/*
 * typedefs to setup the registration pipeline
 */
typedef opITK::EuclideanDistancePointMetric<PointSetType,PointSetType> MetricType;
typedef MetricType::TransformType TransformBaseType;
typedef TransformBaseType::ParametersType ParametersType;
typedef TransformBaseType::JacobianType JacobianType;

typedef opITK::LevenbergMarquardtOptimizer OptimizerType;
typedef opITK::PointSetToPointSetRegistrationMethod<PointSetType,PointSetType> RegistrationType;

// transform only typedefs
typedef PointsContainer::Iterator PointsIterator;


@implementation dianeXuITKPointSetRegistration

/*
 * Init the class with two sets of dianeXuCoords
 */
-(id)initWithFixedSet:(NSMutableArray*)fixed andMovingSet:(NSMutableArray*)moving {
    self = [super init];
    if (self) {
        if (([moving count] > 0) || ([fixed count] > 0)) {
            //prepare the types
            fixedPointSet = PointSetType::New();
            movingPointSet = PointSetType::New();
            transformData = TransformType::New();
            
            //fill the fixedPointSet
            fixedPointSet->SetPoints([self pointSetFromArray:fixed]);
            
            //fill the movingPointSet
            movingPointSet->SetPoints([self pointSetFromArray:moving]);
            
            NSLog(@"dianeXu: Point set registration initialized with %ld fixed and %ld moving points.",fixedPointSet->GetNumberOfPoints(),movingPointSet->GetNumberOfPoints());
        } else {
            NSRunInformationalAlertPanel(@"OOPS... I am missing some data", @"Seems you forgot to complete a prior step, since one of the models is empty. If you are sure this is a bug, please refer to the bugtracker via the preferences.", @"OK", nil, nil,nil);
            NSLog(@"dianeXu: Point set registration failed because fixed (%d) or moving (%d) points are empty.",[fixed count],[moving count]);
            self = nil;
        }
    }
    return self;
}

/*
 * fills the NSMutableArray coordinates into PointSetType:: pointsets
 */
- (PointsContainer::Pointer)pointSetFromArray:(NSMutableArray*)inArray {
    PointsContainer::Pointer resultContainer = PointsContainer::New();
    PointType pointForSet;
    unsigned int pointId = 0;
    for (dianeXuCoord* inCoord in inArray) {
        
        pointForSet[0] = [[inCoord xValue] floatValue];
        pointForSet[1] = [[inCoord yValue] floatValue];
        pointForSet[2] = [[inCoord zValue] floatValue];
        resultContainer->InsertElement(pointId,pointForSet);
        pointId++;
    }
    return resultContainer;
}

/*
 * perform the registration based on the PointSets and needed TransformType
 */
-(void)performRegistration:(int)transformType {
    // set up the metric
    MetricType::Pointer metric = MetricType::New();
    // set up a transform
    TransformType::Pointer transform = TransformType::New();
    // set up optimizer
    OptimizerType::Pointer optimizer = OptimizerType::New();
    optimizer->SetUseCostFunctionGradient(false);
    // set up registration
    RegistrationType::Pointer registration = RegistrationType::New();
    // scale the translation components of the transform in the optimizer
    OptimizerType::ScalesType scales(transform->GetNumberOfParameters());
    const double translationScale = 1000.0; // dynamic translation range
    const double rotationScale = 100.0; // dynamic rotation range
    const double scalarScale = 1000.0;
    
    scales[0] = 1.0/scalarScale;
    scales[1] = 1.0/rotationScale;
    scales[2] = 1.0/rotationScale;
    scales[3] = 1.0/rotationScale;
    scales[4] = 1.0/translationScale;
    scales[5] = 1.0/translationScale;
    scales[6] = 1.0/translationScale;
    
    
    unsigned long numberOfIterations = 2000;
    // convergende criteria
    double gradientTolerance = 1e-4;
    double valueTolerance = 1e-4;
    double epsilonFunction = 1e-5;
    
    optimizer->SetScales(scales);
    optimizer->SetNumberOfIterations(numberOfIterations);
    optimizer->SetGradientTolerance(gradientTolerance);
    optimizer->SetValueTolerance(valueTolerance);
    optimizer->SetEpsilonFunction(epsilonFunction);
    
    // identity transform as automated start
    transform->SetIdentity();
    
    registration->SetInitialTransformParameters(transform->GetParameters());
    
    // connect the pipeline
    registration->SetMetric(metric);
    registration->SetOptimizer(optimizer);
    registration->SetTransform(transform);
    registration->SetFixedPointSet(fixedPointSet);
    registration->SetMovingPointSet(movingPointSet);
    
    try {
        registration->StartRegistration();
    } catch (opITK::ExceptionObject &e) {
        NSLog(@"dianeXu: Error in registration.");
        
    }
    // set the member variable to the transform.
    transformData = transform;
    std::cout << "Solution =" << transformData->GetParameters() << std::endl;
}

/*
 * transform a pointset based on a given transform
 */
- (NSMutableArray*)transformPoints:(NSMutableArray*)pointSet {
    // set up stuff to transform 
    NSMutableArray* transformResult = [NSMutableArray new];
    TransformType::Pointer applyTransform = TransformType::New();
    PointSetType::Pointer pointSetIn = PointSetType::New();
    pointSetIn->SetPoints([self pointSetFromArray:pointSet]);
    PointsContainer::Pointer tmpContainer = PointsContainer::New();
    tmpContainer = pointSetIn->GetPoints();
    
    PointsContainer::Pointer outContainer = PointsContainer::New();
    
    PointsIterator pointIterator = tmpContainer->Begin();
    PointsIterator endIterator = tmpContainer->End();

    while (pointIterator != endIterator) {
        PointType tmpPoint = pointIterator.Value();
        NSLog(@"TMP %f %f %f",tmpPoint[0],tmpPoint[1],tmpPoint[2]);
        PointType inPoint = transformData->TransformPoint(tmpPoint);
        NSLog(@"%f %f %f",inPoint[0],inPoint[1],inPoint[2]);
        outContainer->InsertElement(pointIterator->Index(), inPoint);
        ++pointIterator;
    }
    
    PointsIterator pointIterator2 = outContainer->Begin();
    PointsIterator endIterator2 = outContainer->End();
    
    while (pointIterator2 != endIterator2) {
        dianeXuCoord* tmpCoord = [dianeXuCoord new];
        PointType outPoint = pointIterator2.Value();
        NSLog(@"OUT %f %f %f",outPoint[0],outPoint[1],outPoint[2]);
        [tmpCoord setXValue:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",outPoint[0]]]];
        [tmpCoord setYValue:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",outPoint[1]]]];
        [tmpCoord setZValue:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f",outPoint[2]]]];
        [transformResult addObject:tmpCoord];
        tmpCoord = nil;
        ++pointIterator2;
    }
    NSLog(@"dianeXu: %@",transformResult);
    return [transformResult retain];
}

@end
