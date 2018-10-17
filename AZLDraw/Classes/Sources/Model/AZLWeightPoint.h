//
//  AZLWeightPoint.h
//  ALExampleTest
//
//  Created by yangming on 2018/10/16.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AZLDotWeight  3.0f

NS_ASSUME_NONNULL_BEGIN

@interface AZLWeightPoint : NSObject

@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGFloat weight;


+ (CGFloat)weightWithPointA:(CGPoint)pointA pointB:(CGPoint)pointB;

@end

NS_ASSUME_NONNULL_END
