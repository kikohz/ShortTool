//
//  GradientButton.h
//  NiCaiFu
//
//  Created by wangxi1-ps on 2017/7/24.
//  Copyright © 2017年 x. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradientButton : UIButton
- (void)confiugStartColor:(int)startClolr endColor:(int)endColor cornerRadius:(NSInteger)radius;
- (void)defaultConfig;
@end
