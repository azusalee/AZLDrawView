//
//  UIBezierPath+AZLSignaturePath.m
//  ALExampleTest
//
//  Created by yangming on 2018/10/16.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "UIBezierPath+AZLSignaturePath.h"
#import "AZLPointHelper.h"


/**
 A struct to represent a line between a start and end point
 */
typedef struct
{
    CGPoint startPoint;
    CGPoint endPoint;
} AZLLine;

/**
 A struct to represent a pair of UBLines
 */
typedef struct
{
    AZLLine firstLine;
    AZLLine secondLine;
} AZLLinePair;

@implementation UIBezierPath (AZLSignaturePath)

- (void)azl_addDotWithWeightedPoint:(AZLWeightPoint *)pointA
{
    [self moveToPoint:pointA.point];
    [self addArcWithCenter:pointA.point radius:pointA.weight startAngle:0 endAngle:(CGFloat)M_PI * 2.0 clockwise:YES];
    
}

- (void)azl_addLineWithPointA:(AZLWeightPoint *)pointA pointB:(AZLWeightPoint *)pointB{
    
    AZLLinePair linePair = [UIBezierPath _linesPerpendicularToLineWithWeightedPointA:pointA pointB:pointB];
    
    [self moveToPoint:linePair.firstLine.startPoint];
    [self addLineToPoint:linePair.secondLine.startPoint];
    [self addLineToPoint:linePair.secondLine.endPoint];
    [self addLineToPoint:linePair.firstLine.endPoint];
    [self closePath];
    
}


- (void)azl_addQuadCurveWithWeightedPointA:(AZLWeightPoint *)pointA pointB:(AZLWeightPoint *)pointB pointC:(AZLWeightPoint *)pointC
{
    AZLLinePair linePairAB = [self.class _linesPerpendicularToLineWithWeightedPointA:pointA pointB:pointB];
    AZLLinePair linePairBC = [self.class _linesPerpendicularToLineWithWeightedPointA:pointB pointB:pointC];
    
    AZLLine lineA = linePairAB.firstLine;
    AZLLine lineB = [self.class _averageLine:linePairAB.secondLine andLine:linePairBC.firstLine];
    AZLLine lineC = linePairBC.secondLine;
    
    [self moveToPoint:lineA.startPoint];
    [self addQuadCurveToPoint:lineC.startPoint controlPoint:lineB.startPoint];
    [self addLineToPoint:lineC.endPoint];
    [self addQuadCurveToPoint:lineA.endPoint controlPoint:lineB.endPoint];
    [self closePath];
    
    
    
}



- (void)azl_addBezierCurveWithWeightedPointA:(AZLWeightPoint *)pointA pointB:(AZLWeightPoint *)pointB pointC:(AZLWeightPoint *)pointC pointD:(AZLWeightPoint *)pointD
{
    AZLLinePair linePairAB = [self.class _linesPerpendicularToLineWithWeightedPointA:pointA pointB:pointB];
    AZLLinePair linePairBC = [self.class _linesPerpendicularToLineWithWeightedPointA:pointB pointB:pointC];
    AZLLinePair linePairCD = [self.class _linesPerpendicularToLineWithWeightedPointA:pointC pointB:pointD];
    
    AZLLine lineA = linePairAB.firstLine;
    AZLLine lineB = [self.class _averageLine:linePairAB.secondLine andLine:linePairBC.firstLine];
    AZLLine lineC = [self.class _averageLine:linePairBC.secondLine andLine:linePairCD.firstLine];
    AZLLine lineD = linePairCD.secondLine;
    
    [self moveToPoint:lineA.startPoint];
    [self addCurveToPoint:lineD.startPoint controlPoint1:lineB.startPoint controlPoint2:lineC.startPoint];
    [self addLineToPoint:lineD.endPoint];
    [self addCurveToPoint:lineA.endPoint controlPoint1:lineC.endPoint controlPoint2:lineB.endPoint];
    [self closePath];
    
    
}



#pragma mark - Private

+ (AZLLinePair)_linesPerpendicularToLineWithWeightedPointA:(AZLWeightPoint*)pointA pointB:(AZLWeightPoint*)pointB
{
    AZLLine line = (AZLLine){pointA.point, pointB.point};
    
    AZLLine linePerpendicularToPointA = [self.class _linePerpendicularToLine:line withMiddlePoint:pointA.point length:pointA.weight];
    AZLLine linePerpendicularToPointB = [self.class _linePerpendicularToLine:line withMiddlePoint:pointB.point length:pointB.weight];
    
    return (AZLLinePair){linePerpendicularToPointA, linePerpendicularToPointB};
}

+ (AZLLine)_linePerpendicularToLine:(AZLLine)line withMiddlePoint:(CGPoint)middlePoint length:(CGFloat)newLength
{
    // Calculate end point if line started at 0,0
    CGPoint relativeEndPoint = AZLPointDifferentialPointOfPoints(line.startPoint, line.endPoint);
    
    if (newLength == 0 || CGPointEqualToPoint(relativeEndPoint, CGPointZero)) {
        return (AZLLine){middlePoint, middlePoint};
    }
    
    // Modify line's length to be the length needed either side of the middle point
    CGFloat lengthEitherSideOfMiddlePoint = newLength / 2.0f;
    CGFloat originalLineLength = [self.class _lengthOfLine:line];
    CGFloat lengthModifier = lengthEitherSideOfMiddlePoint / originalLineLength;
    relativeEndPoint.x *= lengthModifier;
    relativeEndPoint.y *= lengthModifier;
    
    // Swap X/Y and invert one axis to get perpendicular line
    CGPoint perpendicularLineStartPoint = CGPointMake(relativeEndPoint.y, -relativeEndPoint.x);
    // Make other axis negative for perpendicular line in the opposite direction
    CGPoint perpendicularLineEndPoint = CGPointMake(-relativeEndPoint.y, relativeEndPoint.x);
    
    // Move perpendicular line to middle point
    perpendicularLineStartPoint.x += middlePoint.x;
    perpendicularLineStartPoint.y += middlePoint.y;
    
    perpendicularLineEndPoint.x += middlePoint.x;
    perpendicularLineEndPoint.y += middlePoint.y;
    
    return (AZLLine){perpendicularLineStartPoint, perpendicularLineEndPoint};
}

+ (AZLLine)_averageLine:(AZLLine)lineA andLine:(AZLLine)lineB
{
    return (AZLLine){AZLPointAveragePoints(lineA.startPoint, lineB.startPoint), AZLPointAveragePoints(lineA.endPoint, lineB.endPoint)};
}

+ (CGFloat)_lengthOfLine:(AZLLine)line
{
    return AZLPointDistanceBetweenPoints(line.startPoint, line.endPoint);
}

@end
