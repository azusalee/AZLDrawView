//
//  UIBezierPath+AZLSignaturePath.h
//  ALExampleTest
//
//  Created by yangming on 2018/10/16.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZLWeightPoint.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (AZLSignaturePath)

- (void)azl_addDotWithWeightedPoint:(AZLWeightPoint *)pointA;

- (void)azl_addLineWithPointA:(AZLWeightPoint*)pointA pointB:(AZLWeightPoint*)pointB;

- (void)azl_addQuadCurveWithWeightedPointA:(AZLWeightPoint *)pointA pointB:(AZLWeightPoint *)pointB pointC:(AZLWeightPoint *)pointC;

- (void)azl_addBezierCurveWithWeightedPointA:(AZLWeightPoint *)pointA pointB:(AZLWeightPoint *)pointB pointC:(AZLWeightPoint *)pointC pointD:(AZLWeightPoint *)pointD;

@end

NS_ASSUME_NONNULL_END
