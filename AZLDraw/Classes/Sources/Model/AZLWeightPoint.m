//
//  AZLWeightPoint.m
//  ALExampleTest
//
//  Created by yangming on 2018/10/16.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "AZLWeightPoint.h"
#import "AZLPointHelper.h"

@implementation AZLWeightPoint


+ (CGFloat)weightWithPointA:(CGPoint)pointA pointB:(CGPoint)pointB{
    CGFloat length = AZLPointDistanceBetweenPoints(pointA, pointB);
    
    /**
     The is the maximum length that will vary weight. Anything higher will return the same weight.
     */
    static const CGFloat maxLengthRange = 50.0f;
    
    /*
     These are based on having a minimum line thickness of 2.0 and maximum of 7, linearly over line lengths 0-maxLengthRange. They fit into a typical linear equation: y = mx + c
     
     Note: Only the points of the two parallel bezier curves will be at least as thick as the constant. The bezier curves themselves could still be drawn with sharp angles, meaning there is no true 'minimum thickness' of the signature.
     */
    static const CGFloat gradient = 0.1f;
    static const CGFloat constant = 2.0f;
    
    CGFloat inversedLength = maxLengthRange - length;
    inversedLength = MAX(0, inversedLength);
    
    return (inversedLength * gradient) + constant;
}

@end
