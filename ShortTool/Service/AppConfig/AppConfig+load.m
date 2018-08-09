//
//  AppConfig+load.m
//  360finance
//
//  Created by x on 2018/7/25.
//  Copyright © 2018年 x. All rights reserved.
//
#import <ShortTool-Swift.h>
@implementation AppConfig (load)
    +(void)load {
        [self swiftLoad];
    }
    +(void)initialize {
        [self swiftInitialize];
    }
@end
