//
//  AZLDrawView.h
//  ALExampleTest
//
//  Created by yangming on 2018/9/30.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AZLBasePathProvider.h"

NS_ASSUME_NONNULL_BEGIN

@class AZLDrawView;
@protocol AZLDrawViewDelegate <NSObject>

//當內容改變時調用
- (void)drawView:(AZLDrawView*)drawView contentDidChangeWithClear:(BOOL)isClear;

@end

@interface AZLDrawView : UIView


@property (nonatomic, weak) id<AZLDrawViewDelegate> delegate;

//設置路徑生成
- (void)setPathProvider:(AZLBasePathProvider *)pathProvider;

//清空view
- (void)clear;

//修改畫筆的顏色
- (void)changeStrokeColor:(UIColor *)color;

- (void)changeLineWidth:(CGFloat)lineWidth;

@end

NS_ASSUME_NONNULL_END
