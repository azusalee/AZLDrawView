//
//  AZLDrawDemoViewController.m
//  ALExampleTest
//
//  Created by yangming on 2018/9/30.
//  Copyright © 2018年 Mac. All rights reserved.
//

#import "AZLDrawDemoViewController.h"
#import "AZLDrawView.h"
#import "UIImage+AZLProcess.h"
#import "AZLPenPathProvider.h"
#import "AZLPencilPathProvider.h"

@interface AZLDrawDemoViewController ()
@property (weak, nonatomic) IBOutlet AZLDrawView *drawView;
@property (weak, nonatomic) IBOutlet UIImageView *colorImageView;

@end

@implementation AZLDrawDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.drawView setPathProvider:[[AZLPenPathProvider alloc] init]];
}

- (IBAction)clearDidTap:(id)sender {
    [self.drawView clear];
}
- (IBAction)colorDidTap:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.colorImageView];
    UIImage *snapImage = [UIImage azl_imageFromView:self.colorImageView];
    UIColor *color = [snapImage azl_colorFromPoint:location];
    [self.drawView changeStrokeColor:color];
    
}

- (IBAction)changeLineWidth:(UISlider*)sender {
    [self.drawView changeLineWidth:sender.value];
}
- (IBAction)changeLineCap:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self.drawView changeLineCap:kCALineCapButt];
    }else if (sender.selectedSegmentIndex == 1){
        [self.drawView changeLineCap:kCALineCapRound];
    }else{
        [self.drawView changeLineCap:kCALineCapSquare];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
