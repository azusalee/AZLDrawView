//
//  AZLDrawView.h
//  ALExampleTest
//
//  Created by yangming on 2018/9/30.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AZLDrawView : UIView

//清空view
- (void)clear;

//修改畫筆的顏色
- (void)changeStrokeColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
