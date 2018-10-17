//
//  AZLPointHelper.h
//  ALExampleTest
//
//  Created by yangming on 2018/10/16.
//  Copyright © 2018年 Mac. All rights reserved.
//

#ifndef AZLPointHelper_h
#define AZLPointHelper_h

#import <CoreGraphics/CGGeometry.h>
#import <Foundation/Foundation.h>


/**
 獲取兩點間的中心點
 */
static inline CGPoint
AZLPointAveragePoints(CGPoint pointA, CGPoint pointB)
{
    CGPoint p;
    p.x = (pointA.x + pointB.x) * 0.5f;
    p.y = (pointA.y + pointB.y) * 0.5f;
    return p;
}

/**

 獲取點A到點B的矢量值
 */
static inline CGPoint
AZLPointDifferentialPointOfPoints(CGPoint pointA, CGPoint pointB)
{
    CGPoint p;
    p.x = pointB.x - pointA.x;
    p.y = pointB.y - pointA.y;
    return p;
}

/**
 計算矢量的標量長度
 */
static inline CGFloat
AZLPointHypotenuseOfPoint(CGPoint point)
{
    return (CGFloat)sqrt(point.x * point.x + point.y * point.y);
}

/**
 獲取兩點之間的距離
 */
static inline CGFloat
AZLPointDistanceBetweenPoints(CGPoint pointA, CGPoint pointB)
{
    return AZLPointHypotenuseOfPoint(AZLPointDifferentialPointOfPoints(pointA, pointB));
}



#endif /* AZLPointHelper_h */
