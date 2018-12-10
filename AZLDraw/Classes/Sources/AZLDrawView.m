//
//  AZLDrawView.m
//  ALExampleTest
//
//  Created by yangming on 2018/9/30.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "AZLDrawView.h"
#import "AZLWeightPoint.h"
#import "UIBezierPath+AZLSignaturePath.h"
#import "AZLPointHelper.h"
#import "AZLPenPathProvider.h"


@interface AZLDrawView()<AZLPathProviderDelegate>
{
    
}

//一個生成path的類
@property (nonatomic, strong) AZLBasePathProvider *pathProvider;



@end

@implementation AZLDrawView

+ (Class)layerClass
{
    //this makes our view create a CAShapeLayer
    //instead of a CALayer for its backing layer
    return [CAShapeLayer class];
}


- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupView];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    
    self.multipleTouchEnabled = NO;
    
    self.pathProvider = [[AZLPenPathProvider alloc] init];
    self.pathProvider.delegate = self;
    
    CAShapeLayer *shapeLayer = (CAShapeLayer *)self.layer;
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.fillColor = [UIColor blackColor].CGColor;

    shapeLayer.lineCap = kCALineCapRound;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //獲取觸點位置
    CGPoint point = [[touches anyObject] locationInView:self];
    
    [self.pathProvider touchBeganWithPoint:point];
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //獲取觸點位置
    CGPoint point = [[touches anyObject] locationInView:self];
    
    [self.pathProvider touchMoveWithPoint:point];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //獲取觸點位置
    CGPoint point = [[touches anyObject] locationInView:self];
    
    [self.pathProvider touchEndWithPoint:point];
    
}


- (void)setPathProvider:(AZLBasePathProvider *)pathProvider{
    _pathProvider = pathProvider;
    pathProvider.delegate = self;
}

//清空view
- (void)clear{
    [self.pathProvider clear];
}

//修改畫筆的顏色
- (void)changeStrokeColor:(UIColor *)color{
    CAShapeLayer *shapeLayer = (CAShapeLayer *)self.layer;
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor = color.CGColor;
}

- (void)changeLineWidth:(CGFloat)lineWidth{
    CAShapeLayer *shapeLayer = (CAShapeLayer *)self.layer;
    shapeLayer.lineWidth = lineWidth;
}


//pathProviderDelegate
- (void)pathProvider:(AZLBasePathProvider *)provider didChangePath:(UIBezierPath *)path{
    //更新UI
    ((CAShapeLayer *)self.layer).path = path.CGPath;
    if (self.delegate) {
        [self.delegate drawView:self contentDidChangeWithClear:path.isEmpty];
    }
}


@end
