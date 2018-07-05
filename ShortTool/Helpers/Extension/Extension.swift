//
//  Extension.swift
//  ShortTool
//
//  Created by Bllgo on 2018/6/21.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import Foundation
import UIKit
// swift file
// extend the NSObject class
extension NSObject {
    // create a static method to get a swift class for a string name
    class func swiftClassFromString(className: String) -> AnyClass! {
        // get the project name
        if  let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String? {
            // generate the full name of your class (take a look into your "YourProject-swift.h" file)
            let className = appName + "." + className
            // return the class!
            return NSClassFromString(className)
        }
        return nil;
    }
}

import Photos
extension UIImage {
    class func creatImg(_ color:UIColor) ->UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 5, height: 5)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let resultImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImg
    }
    //保存图片到相册
    class func savePhotoLibray(_ image:UIImage, completionHandler:@escaping(_ success:Bool,_ status:PHAuthorizationStatus)->Void) {
        //获取相册授权
        let authoriztionStatus = PHPhotoLibrary.authorizationStatus()
        //已经授权
        if authoriztionStatus == .authorized {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { (asuccess, error) in
                completionHandler(asuccess,authoriztionStatus)
            }
        }
        //还没有 确定
        else if authoriztionStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {  //授权了
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { (asuccess, error) in
                        completionHandler(asuccess,authoriztionStatus)
                    }
                }
                else {
                    completionHandler(false,authoriztionStatus)
                }
            }
        }
        else {
            completionHandler(false,authoriztionStatus)
        }
    }
}
