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

extension String {
    //字符串中查找给定子串的所有Range
//    1、初始化时先设置查找范围为整个字符串
//    2、若能通过查找得到子串的Range，进入循环
//    3、保存子串Range到数组
//    4、缩小查找范围，减掉已经查找过的区域
//    5、在缩小的范围内查找子串
//    6、若能在缩小的范围内找到子串，继续下一轮循环
    func ranges(of string: String) -> [Range<String.Index>] {
        var rangeArray = [Range<String.Index>]()
        var searchedRange: Range<String.Index>
        guard let sr = self.range(of: self) else {
            return rangeArray
        }
        searchedRange = sr
        
        var resultRange = self.range(of: string, options: .regularExpression, range: searchedRange, locale: nil)
        while let range = resultRange {
            rangeArray.append(range)
            searchedRange = Range(uncheckedBounds: (range.upperBound, searchedRange.upperBound))
            resultRange = self.range(of: string, options: .regularExpression, range: searchedRange, locale: nil)
        }
        return rangeArray
    }
    
//    func sameStrCount(_ str:String) {
//        if let resultRange = self.range(of: str) {
//
//            while let range = resultRange {
//                resultRange =
//
//            }
//
////            let leftStr = self[..<range.lowerBound]
////            let right = self[range.lowerBound...]
//
//        }
    
        
//        let range = str.range(of: "http")!
//        let leftStr =
//            print(ran)
        
        
//    }
    
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

extension UIButton {
    func titleImgAlignRight() {
        self.layoutIfNeeded()
        let imageRect = self.imageView!.frame
        let titleRect = self.titleLabel!.frame
        let fontSize = self.titleLabel!.font.pointSize
        let imgtop = fontSize - imageRect.height
        let space = titleRect.origin.x - imageRect.origin.x  - imageRect.width + 3
        self.imageEdgeInsets = UIEdgeInsets.init(top: imgtop/2, left: titleRect.width + space, bottom: 0, right: -(titleRect.width + space))
        self.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: -(titleRect.origin.x - imageRect.origin.x), bottom: 0, right: titleRect.origin.x - imageRect.origin.x)
    }
}
