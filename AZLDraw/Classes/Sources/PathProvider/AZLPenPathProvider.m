//
//  AZLPenPathProvider.m
//  ALExampleTest
//
//  Created by yangming on 2018/10/17.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "AZLPenPathProvider.h"
#import "AZLWeightPoint.h"
#import "UIBezierPath+AZLSignaturePath.h"
#import "AZLPointHelper.h"


@interface AZLPenPathProvider ()
{
    
}


@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) UIBezierPath *tmpPath;



@property (nonatomic, strong) AZLWeightPoint *point0;
@property (nonatomic, strong) AZLWeightPoint *point1;
@property (nonatomic, strong) AZLWeightPoint *point2;
@property (nonatomic, strong) AZLWeightPoint *point3;

@property (nonatomic, assign) NSInteger nextPointIndex;


@end

@implementation AZLPenPathProvider

- (instancetype)init{
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (void)setup{
    self.path = [[UIBezierPath alloc] init];
    self.tmpPath = [[UIBezierPath alloc] init];
    
}


- (void)touchBeganWithPoint:(CGPoint)point{
    AZLWeightPoint *weightPoint = [[AZLWeightPoint alloc] init];
    weightPoint.point = point;
    weightPoint.weight = AZLDotWeight;
    self.point0 = weightPoint;
    [self.tmpPath removeAllPoints];
    [self.tmpPath appendPath:self.path];
    [self.tmpPath azl_addDotWithWeightedPoint:self.point0];
    self.nextPointIndex = 1;
    
    if (self.delegate) {
        [self.delegate pathProvider:self didChangePath:self.tmpPath];
    }
    
}

- (void)touchMoveWithPoint:(CGPoint)point{
    
    AZLWeightPoint *previousPoint;
    if (self.nextPointIndex == 1) {
        previousPoint = self.point0;
        
    }else if (self.nextPointIndex == 2){
        previousPoint = self.point1;
        
    }else if (self.nextPointIndex == 3){
        previousPoint = self.point2;
        
    }else if (self.nextPointIndex == 4){
        previousPoint = self.point3;
    }
    
    //兩點間距離過少的時候不作處理
    if (AZLPointDistanceBetweenPoints(point, previousPoint.point) < 2) {
        return;
    }
    
    
    //分開4中情況，1，2，3，4個點的時候分別處理
    //只有四個點的時候為完整的，添加到path；其他的情況都為臨時線，添加到tmpPath
    if (self.nextPointIndex == 1){
        
        AZLWeightPoint *weightPoint = [[AZLWeightPoint alloc] init];
        weightPoint.point = point;
        weightPoint.weight = [AZLWeightPoint weightWithPointA:self.point0.point pointB:point];
        self.point1 = weightPoint;
        
        [self.tmpPath removeAllPoints];
        [self.tmpPath appendPath:self.path];
        [self.tmpPath azl_addLineWithPointA:self.point0 pointB:self.point1];
        
        self.nextPointIndex = 2;
    }else if (self.nextPointIndex == 2){
        AZLWeightPoint *weightPoint = [[AZLWeightPoint alloc] init];
        weightPoint.point = point;
        weightPoint.weight = [AZLWeightPoint weightWithPointA:self.point1.point pointB:point];
        self.point2 = weightPoint;
        
        [self.tmpPath removeAllPoints];
        [self.tmpPath appendPath:self.path];
        [self.tmpPath azl_addQuadCurveWithWeightedPointA:self.point0 pointB:self.point1 pointC:self.point2];
        
        self.nextPointIndex = 3;
        
    }else if (self.nextPointIndex == 3) {
        
        AZLWeightPoint *weightPoint = [[AZLWeightPoint alloc] init];
        weightPoint.point = point;
        weightPoint.weight = [AZLWeightPoint weightWithPointA:self.point2.point pointB:point];
        self.point3 = weightPoint;
        
        [self.tmpPath removeAllPoints];
        [self.tmpPath appendPath:self.path];
        [self.tmpPath azl_addBezierCurveWithWeightedPointA:self.point0 pointB:self.point1 pointC:self.point2 pointD:self.point3];
        
        self.nextPointIndex = 4;
    }else if (self.nextPointIndex == 4){
        //第四個點的時候，為完整的線，添加到path，然後重新計算pointIndex
        CGPoint point3 = AZLPointAveragePoints(self.point2.point, point);
        AZLWeightPoint *weightPoint = [[AZLWeightPoint alloc] init];
        weightPoint.point = point3;
        weightPoint.weight = [AZLWeightPoint weightWithPointA:self.point2.point pointB:point3];
        self.point3 = weightPoint;
        
        [self.path azl_addBezierCurveWithWeightedPointA:self.point0 pointB:self.point1 pointC:self.point2 pointD:self.point3];
        
        
        {
            self.point0 = self.point3;
            AZLWeightPoint *weightPoint = [[AZLWeightPoint alloc] init];
            weightPoint.point = point;
            weightPoint.weight = [AZLWeightPoint weightWithPointA:previousPoint.point pointB:point];
            self.point1 = weightPoint;
            self.nextPointIndex = 2;
            
            [self.tmpPath removeAllPoints];
            [self.tmpPath appendPath:self.path];
            [self.tmpPath azl_addLineWithPointA:self.point0 pointB:self.point1];
            
        }
        
    }
    
    if (self.delegate) {
        [self.delegate pathProvider:self didChangePath:self.tmpPath];
    }
}

- (void)touchEndWithPoint:(CGPoint)point{
    //鬆手的時候為完成這次畫線，把tmpPath的線路賦值到path里
    [self.path removeAllPoints];
    [self.path appendPath:self.tmpPath];
    self.nextPointIndex = 0;
}


- (void)clear{
    [self.path removeAllPoints];
    if (self.delegate) {
        [self.delegate pathProvider:self didChangePath:self.path];
    }
}

@end
