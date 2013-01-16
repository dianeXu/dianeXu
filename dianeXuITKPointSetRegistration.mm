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

#include "itkTranslationTransform.h"
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

typedef opITK::TranslationTransform<double,dimension> TransformType;
typedef opITK::LevenbergMarquardtOptimizer OptimizerType;
typedef opITK::PointSetToPointSetRegistrationMethod<PointSetType,PointSetType> RegistrationType;


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
            
            PointsContainer::Pointer fixedPointContainer = PointsContainer::New();
            PointsContainer::Pointer movingPointContainer = PointsContainer::New();
            
            PointType fixedPoint;
            PointType movingPoint;
            
            //fill the fixedPointSet
            unsigned int pointId = 0;
            for (dianeXuCoord* inCoord in fixed) {
                    fixedPoint[0] = [[inCoord xValue] floatValue];
                    fixedPoint[1] = [[inCoord yValue] floatValue];
                    fixedPoint[2] = [[inCoord zValue] floatValue];
                    fixedPointContainer->InsertElement(pointId,fixedPoint);
                    pointId++;
            }
            fixedPointSet->SetPoints(fixedPointContainer);
            
            //fill the movingPointSet
            pointId = 0;
            for (dianeXuCoord* inCoord in moving) {
                movingPoint[0] = [[inCoord xValue] floatValue];
                movingPoint[1] = [[inCoord yValue] floatValue];
                movingPoint[2] = [[inCoord zValue] floatValue];
                movingPointContainer->InsertElement(pointId,movingPoint);
                pointId++;
                step = 0;
            }
            movingPointSet->SetPoints(movingPointContainer);
            
            NSLog(@"dianeXu: Point set registration initialized with %ld fixed and %ld moving points.",fixedPointSet->GetNumberOfPoints(),movingPointSet->GetNumberOfPoints());
        } else {
            NSRunInformationalAlertPanel(@"OOPS... I am missing some data", @"Seems you forgot to complete a prior step, since one of the models is empty. If you are sure this is a bug, please refer to teh bugtracker via the preferences.", @"OK", nil, nil,nil);
            NSLog(@"dianeXu: Point set registration failed because fixed (%d) or moving (%d) points are empty.",[fixed count],[moving count]);
            self = nil;
        }
    }
    return self;
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
    scales.Fill(0.01);
    
    unsigned long numberOfIterations = 100;
    // convergende criteria
    double gradientTolerance = 1e-5;
    double valueTolerance = 1e-5;
    double epsilonFunction = 1e-6;
    
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
    
    std::cout << "Solution =" << transform->GetParameters() << std::endl;
}

@end
