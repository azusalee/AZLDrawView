//
//  AZLPencilPathProvider.m
//  AZLDraw
//
//  Created by yangming on 2018/12/7.
//

#import "AZLPencilPathProvider.h"

@interface AZLPencilPathProvider()


@property (nonatomic, strong) UIBezierPath *path;

@end

@implementation AZLPencilPathProvider



- (instancetype)init{
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (void)setup{
    self.path = [[UIBezierPath alloc] init];
    
}


- (void)touchBeganWithPoint:(CGPoint)point{
    [self.path moveToPoint:point];
    
    if (self.delegate) {
        [self.delegate pathProvider:self didChangePath:self.path];
    }
    
}

- (void)touchMoveWithPoint:(CGPoint)point{
    [self.path addLineToPoint:point];
    [self.path moveToPoint:point];
    if (self.delegate) {
        [self.delegate pathProvider:self didChangePath:self.path];
    }
}

- (void)touchEndWithPoint:(CGPoint)point{
    
}


- (void)clear{
    [self.path removeAllPoints];
    if (self.delegate) {
        [self.delegate pathProvider:self didChangePath:self.path];
    }
}


@end
