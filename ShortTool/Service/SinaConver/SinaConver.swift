//
//  SinaConver.swift
//  ShortTool
//
//  Created by Bllgo on 2018/6/14.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import UIKit

class SinaConver {
    private static let shareSinaConver: SinaConver = {
        let shared = SinaConver()
        return shared
    }()
    
    class func shared() ->SinaConver {
        return shareSinaConver
    }
    
    private init() {
    }
    
    //转换之后的url数组
    var allNewUrlMode = [SinaShortUrlModel]()
    var oldUrl = [String]()
    
    typealias SinaSuccessBlock = (_ newUrls:[SinaShortUrlModel]) ->Void
    var sinaSuccessBlock:SinaSuccessBlock?
    //swift 默认为非逃逸闭包，但是我们网络请求，所以要使用逃逸闭包 escaping
    func converSinaUrl(urls:[String],successBlock:@escaping(SinaSuccessBlock)) {
        self.oldUrl = urls
        self.sinaSuccessBlock = successBlock
        for url in urls {
            self.requestShortUrl(oldUrl: url) { (newUrlM) in
                if let tempUrlM = newUrlM {
                    self.allNewUrlMode.append(tempUrlM)
                }
            }
        }
    }
    //检查转换队列是否已经完成
    func checkQueue() {
        if self.oldUrl.count > 0 {
            return
        }
        //任务执行完成
        if let tempBlock = self.sinaSuccessBlock {
            tempBlock(self.allNewUrlMode)
        }
        self.allNewUrlMode.removeAll()
    }
    //发起请求
    func requestShortUrl(oldUrl:String, success:@escaping(_ newUrlM:SinaShortUrlModel?)->Void) {
        let shortUrlRequest = SinaShortUrlRequest.init(longUrl: oldUrl)
        shortUrlRequest.startWithCompletionBlock {[unowned self] (response) in
//            if let JSON = response.result.value {
//                let dict = JSON as! Dictionary<String, Any>
//                print(dict)
//            }
            //删除已经转换完成的
            if let index = self.oldUrl.index(of: oldUrl) {
                self.oldUrl.remove(at: index)
            }
            if let data = response.data {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let sinaUrls = try? jsonDecoder.decode(SinaUrlList.self, from: data)
                if let item = sinaUrls?.urls.first {
                    success(item)
                    self.checkQueue()
                    return
                }
            }
            success(nil)
            self.checkQueue()
        }
    }
    
    
}
