//
//  ViewMacro.swift
//  NiCaiFu
//
//  Created by zhaoyongyan on 2017/6/30.
//  Copyright © 2017年 x. All rights reserved.
//

import UIKit


//MARK: - 设备屏幕的尺寸
let kScreenHeight = UIScreen.main.bounds.size.height
let kScreenWidth = UIScreen.main.bounds.size.width

//MARK: - Bar高度  CGFloat(20)
let kStatusBarHeight = UIApplication.shared.statusBarFrame.height
let kNavigationBarHeight = CGFloat(44)
let kTabBarHeight = CGFloat(49)

//MARK: - 布局上下高度
//StatusBar+NavigationBar
let kTopLayoutGuideLength = kStatusBarHeight+kNavigationBarHeight
//TabBar
let kBottomLayoutGuideLength = kTabBarHeight
//底部的Danger height
let kBottomSafeLayoutMargin = kStatusBarHeight > 20 ? CGFloat(34.0) : CGFloat(0)


//MARK: - 屏幕scale
let kScale = UIScreen.main.scale

//MARK: - 1像素的线
let SINGLE_LINE_WIDTH = 1/UIScreen.main.scale





//MARK: - 坐标(x,y)和宽高(width,height)
extension UIView {
    @objc var width: CGFloat {
        get { return self.frame.size.width }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    @objc var height: CGFloat {
        get { return self.frame.size.height }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    @objc var size: CGSize  {
        get { return self.frame.size }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    @objc var origin: CGPoint {
        get { return self.frame.origin }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    
    @objc var x: CGFloat {
        get { return self.frame.origin.x }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    @objc var y: CGFloat {
        get { return self.frame.origin.y }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    @objc var centerX: CGFloat {
        get { return self.center.x }
        set {
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
    }
    
    @objc var centerY: CGFloat {
        get { return self.center.y }
        set {
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
    }
    
    @objc var top : CGFloat {
        get { return self.frame.origin.y }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    @objc var bottom : CGFloat {
        get { return frame.origin.y + frame.size.height }
        set {
            var frame = self.frame
            frame.origin.y = newValue - self.frame.size.height
            self.frame = frame
        }
    }
    
    @objc var right : CGFloat {
        get { return self.frame.origin.x + self.frame.size.width }
        set {
            var frame = self.frame
            frame.origin.x = newValue - self.frame.size.width
            self.frame = frame
        }
    }
    
    @objc var left : CGFloat {
        get { return self.frame.origin.x }
        set {
            var frame = self.frame
            frame.origin.x  = newValue
            self.frame = frame
        }
    }
}
