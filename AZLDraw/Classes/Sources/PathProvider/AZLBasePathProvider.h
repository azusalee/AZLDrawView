//
//  AZLBasePathProvider.h
//  ALExampleTest
//
//  Created by yangming on 2018/10/17.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AZLBasePathProvider;
@protocol AZLPathProviderDelegate <NSObject>

//path改變的時候回調
- (void)pathProvider:(AZLBasePathProvider*)provider didChangePath:(UIBezierPath *)path;

@end

@interface AZLBasePathProvider : NSObject


@property (nonatomic, weak) id<AZLPathProviderDelegate> delegate;

//觸摸事件發生時，調用下面對應的方法
- (void)touchBeganWithPoint:(CGPoint)point;
- (void)touchMoveWithPoint:(CGPoint)point;
- (void)touchEndWithPoint:(CGPoint)point;

//清空path
- (void)clear;

@end

NS_ASSUME_NONNULL_END
