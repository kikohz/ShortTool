//
//  ShareService.swift
//  ShortTool
//
//  Created by Bllgo on 2018/6/27.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import UIKit
extension UIViewController {
    func shareActivity(_ items:Array<Any>) {
        let activityVC = UIActivityViewController.init(activityItems: items, applicationActivities: nil)
//        activityVC.excludedActivityTypes = [.mail,.message,.airDrop,.postToWeibo,.postToTwitter,.copyToPasteboard]
//        activityVC.completionWithItemsHandler = (activity:String,completed:Bool)
        self.present(activityVC, animated: true, completion: nil)
    }
}
