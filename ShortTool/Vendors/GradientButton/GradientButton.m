//
//  GradientButton.m
//  NiCaiFu
//
//  Created by wangxi1-ps on 2017/7/24.
//  Copyright © 2017年 x. All rights reserved.
//

#import "GradientButton.h"
#import "UIImage+Gradient.h"

@implementation GradientButton
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self defaultConfig];
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    if(self) {
        [self defaultConfig];
    }
}
- (void)defaultConfig{
    UIImage *backgroundImg = [[UIImage alloc] createImageWithSize:self.frame.size gradientColors:@[UIColorFromRGB(0xf36544),UIColorFromRGB(0xed4e39)] percentage:@[@0,@1] gradientType:GradientFromLeftTopToRightBottom];
    UIImage *backgroundImgSel = [[UIImage alloc] createImageWithSize:self.frame.size gradientColors:@[UIColorFromRGB(0xdd533d),UIColorFromRGB(0xef6048)] percentage:@[@0,@1] gradientType:GradientFromLeftTopToRightBottom];
    [self setBackgroundImage:backgroundImg forState:UIControlStateNormal];
    [self setBackgroundImage:backgroundImgSel forState:UIControlStateHighlighted];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
}

- (void)confiugStartColor:(int)startClolr endColor:(int)endColor cornerRadius:(NSInteger)radius{
    UIImage *backgroundImg = [[UIImage alloc]createImageWithSize:self.frame.size gradientColors:@[UIColorFromRGB(startClolr),UIColorFromRGB(endColor)] percentage:@[@0,@1] gradientType:GradientFromLeftTopToRightBottom];
    UIImage *backgroundImgSel = [[UIImage alloc]createImageWithSize:self.frame.size gradientColors:@[UIColorFromRGB(endColor),UIColorFromRGB(startClolr)] percentage:@[@0,@1] gradientType:GradientFromLeftTopToRightBottom];
    [self setBackgroundImage:backgroundImg forState:UIControlStateNormal];
    [self setBackgroundImage:backgroundImgSel forState:UIControlStateHighlighted];
    
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

@end
