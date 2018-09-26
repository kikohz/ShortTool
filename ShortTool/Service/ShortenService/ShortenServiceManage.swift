//
//  ShortenServiceManage.swift
//  ShortTool
//
//  Created by Bllgo on 2018/8/31.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import Foundation
import Alamofire
enum SreviceType:String {
    case sina
    case tinyurl
    case bitly
}
class ServiceManage: NSObject {
    var serviceList = [ShortenServiceMode]()
    //单例
    private static let shareConfig: ServiceManage = {
        let shared = ServiceManage()
        return shared
    }()
    
    class func shared() ->ServiceManage {
        return shareConfig
    }
    
    private override init() {
        super.init()
        self.setup()
    }
    // load
    @objc public static func swiftLoad() {
        //        Swift.print("swift load")
    }
    
    @objc public static func swiftInitialize() {
        
    }
    //setup  fileprivate
    fileprivate func setup() {
        //初始化
        self.serviceList = self.loadService()
    }
    
    public func loadService() -> [ShortenServiceMode] {
        let jsonPath = Bundle.init(for: MainViewController.self).path(forResource: "service", ofType: "json")
        let data = try! Data.init(contentsOf: URL(fileURLWithPath: jsonPath!), options:.mappedIfSafe)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let services = try! decoder.decode([ShortenServiceMode].self, from: data)
        return services
    }
    
    ///转换
    //转换之后的url数组
    var allNewUrlMode = [ShortenUrlMode]()
    var oldUrl = [String]()
    
    typealias cSuccessBlock = (_ newUrls:[ShortenUrlMode]) ->Void
    var converSuccessBlock:cSuccessBlock?
    //支持多个url转换
    func converUrl(urls:[String], serviceMode:ShortenServiceMode, successBlock:@escaping(cSuccessBlock)) {
        self.oldUrl = urls
        self.converSuccessBlock = successBlock
        for url in urls {
            self.requestUrl(oldUrl: url,type: serviceMode) { (newUrlM) in
                if let tempUrlM = newUrlM {
                    self.allNewUrlMode.append(tempUrlM)
                }
            }
        }
    }
    
    fileprivate func requestUrl(oldUrl:String,type:ShortenServiceMode, success:@escaping(_ newUrlM:ShortenUrlMode?)->Void) {
        switch type.sid {
        case SreviceType.sina.rawValue:
            self.requestSinaShortUrl(oldUrl: oldUrl, type:type,success: success)
        case SreviceType.tinyurl.rawValue:
            self.requestTinyUrl(oldUrl: oldUrl, type:type, success: success)
        case SreviceType.bitly.rawValue:
            self.requestBitlyUrl(oldUrl: oldUrl, type: type, success: success)
        default:
            break
        }
    }
    //检查转换队列是否已经完成
    fileprivate func checkQueue() {
        if self.oldUrl.count > 0 {
            return
        }
        //任务执行完成
        if let tempBlock = self.converSuccessBlock {
            tempBlock(self.allNewUrlMode)
        }
        self.allNewUrlMode.removeAll()
    }
    //各自服务请求  sina
    fileprivate func requestSinaShortUrl(oldUrl:String, type:ShortenServiceMode, success:@escaping(_ newUrlM:ShortenUrlMode?)->Void) {
        var sinaSource = "2849184197"
        if let configDict:Dictionary<String,String> = UserDefaults.standard.object(forKey: "config") as? Dictionary<String, String> {
            if let sinas = configDict["sina_source"] {
                sinaSource = sinas
            }
        }
        let shortUrlRequest = SinaShortUrlRequest.init(source:sinaSource,longUrl: oldUrl)
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
                if let item = sinaUrls?.urls.first,let tempUrl = item.urlShort{
                    var urlModel = ShortenUrlMode(url: tempUrl, sid: type.sid)
                    urlModel.converStatus = .success
                    success(urlModel)
                    self.checkQueue()
                    return
                }
            }
            success(nil)
            self.checkQueue()
        }
    }
    //tinyurl 比较简单，所以直接发送请求
    fileprivate func requestTinyUrl(oldUrl:String, type:ShortenServiceMode, success:@escaping(_ newUrlM:ShortenUrlMode?)->Void) {
//        let requestUrl = "https://tinyurl.com/api-create.php"
        let parameter = ["url":oldUrl]
        var request = try? URLRequest.init(url: type.api, method: .get)
        request = try? URLEncoding.default.encode(request!, with: parameter)
        Alamofire.request(request!).responseString { response in
            //删除已经转换完成的
            if let index = self.oldUrl.index(of: oldUrl) {
                self.oldUrl.remove(at: index)
            }
            if let shortUrl:String = response.result.value {
                var urlModel = ShortenUrlMode(url: shortUrl, sid: type.sid)
                urlModel.converStatus = .success
                success(urlModel)
                self.checkQueue()
                return
            }
            success(nil)
            self.checkQueue()
//            debugPrint(strData)
        }
    }
    //bitly
    fileprivate func requestBitlyUrl(oldUrl:String, type:ShortenServiceMode, success:@escaping(_ newUrlM:ShortenUrlMode?)->Void) {
        var bitlyAccessToken = "c7a77bccd2d48aa135c3571f3c7b14b91b42b04b"
        if let configDict:Dictionary<String,String> = UserDefaults.standard.object(forKey: "config") as? Dictionary<String, String> {
            if let bitly = configDict["bitly_access_token"] {
                bitlyAccessToken = bitly
            }
        }
        let parameter = ["long_url":oldUrl,"domain":"bit.ly"]
        var request = try? URLRequest.init(url: type.api, method: .post)
        request?.addValue("Bearer " + bitlyAccessToken, forHTTPHeaderField: "Authorization")
        request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request = try? JSONEncoding.default.encode(request!, with: parameter)
//        debugPrint(request)
        Alamofire.request(request!).responseJSON { (response) in
            //删除已经转换完成的
            if let index = self.oldUrl.index(of: oldUrl) {
                self.oldUrl.remove(at: index)
            }
            if let data = response.data {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let bitlyShort = try? jsonDecoder.decode(BitlyShortenModel.self, from: data)
                if let shortUrl = bitlyShort?.link {
                    var urlModel = ShortenUrlMode(url: shortUrl, sid: type.sid)
                    urlModel.converStatus = .success
                    success(urlModel)
                    self.checkQueue()
                    return
                }
            }
            success(nil)
            self.checkQueue()
        }
    }
}
//"name":"t.cn",
//"sid":"sina",
//"api":"https://api.weibo.com/2/short_url/shorten.json",
//"parameter":"source=45678&url_long=http://google.com",
//"details":"由weibo提供的短链接服务"
struct ShortenServiceMode:Codable {
    var name:String
    var sid:String
    var api:String
    var parameter:String
    var details:String
    var enabled:Bool
    init() {
        name = "t.cn"
        sid = "sina"
        api = "https://api.weibo.com/2/short_url/shorten.json"
        parameter = "source=45678&url_long=http://google.com"
        details = "由weibo提供的短链接服务"
        enabled = true
    }
}
struct ShortenUrlMode:Codable {
    //转换状态
    enum ConverStatus:Int,Codable {
        case success
        case failure
        case unknown
    }
    var serviceUrl:String
    var serviceSid:String
    var converStatus:ConverStatus
    init(url:String,sid:String) {
        serviceUrl = url
        serviceSid = sid
        converStatus = .unknown
    }
}

struct BitlyShortenModel:Codable {
    let id:String?
    let link:String?
    let longUrl:String?
    let creatAt:String?
}
