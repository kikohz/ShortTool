//
//  XXHud.swift
//  Mall360
//
//  Created by x on 2019/3/8.
//  Copyright © 2019 x. All rights reserved.
//

import Foundation
//import MBProgressHUD
import ZKProgressHUD

class XXHud:NSObject {
    class func showIndeterminate(hostView:UIView, animation:Bool) {
        ZKProgressHUD.setMaskStyle(.visible)
        ZKProgressHUD.setMaskBackgroundColor(UIColor.white)
        ZKProgressHUD.setAutoDismissDelay(10)
        ZKProgressHUD.show()
        return
        //暂时屏蔽，会导致崩溃
//        return
//        let hud = MBProgressHUD.init(view: hostView)
//        hud.mode = .indeterminate
//        hostView.addSubview(hud)
//        hud.show(animated: animation)
    }
    
//    class func showIndeterminate(hostView:UIView, title:String,message:String, animation:Bool) {
//        let hud = MBProgressHUD.init(view: hostView)
//        hud.mode = .indeterminate
//        hud.label.text = title
//        hud.detailsLabel.text = message
//        hostView.addSubview(hud)
//        hud.show(animated: animation)
//    }
    
//    class func showIndeterminate(hostView:UIView, afterDelay:TimeInterval, animation:Bool) {
//        let hud = MBProgressHUD.init(view: hostView)
//        hud.mode = .indeterminate
//        hostView.addSubview(hud)
//        hud.show(animated: animation)
//        hud.hide(animated: animation, afterDelay: afterDelay)
//    }
    
    class func showIndeterminate(hostView:UIView, message:String, animation:Bool) {
        ZKProgressHUD.setMaskStyle(.hide)
        ZKProgressHUD.setAutoDismissDelay(1)
        if message.count > 0 {
            ZKProgressHUD.showMessage(message)
        }
//        let hud = MBProgressHUD.init(view: hostView)
//        hud.mode = .text
//        hud.detailsLabel.text = message
//        hud.detailsLabel.font = hud.label.font
//        hostView.addSubview(hud)
//        hud.show(animated: animation)
//        var duration = 1.0 *  Double(message.count) / 15
//        duration = duration < 1.0 ? 1.0:duration
//        duration = duration > 3.0 ? 3.0:duration
//        hud.hide(animated: animation, afterDelay: duration)
    }
    
//    class func showIndeterminate(hostView:UIView, message:String, afterDelay:TimeInterval, animation:Bool) {
//        ZKProgressHUD.showMessage(message)
//        return
//        let hud = MBProgressHUD.init(view: hostView)
//        hud.mode = .text
//        hud.detailsLabel.text = message
//        hud.detailsLabel.font = hud.label.font
//        hostView.addSubview(hud)
//        hud.show(animated: animation)
//        hud.hide(animated: animation, afterDelay: afterDelay)
//    }
    
    class func hideAllHud() {
        ZKProgressHUD.dismiss()
//        MBProgressHUD.hideAllHUDs(for: hostView, animated: animation)
    }
}
