//
//  XXWebView.swift
//  TestWebview
//
//  Created by wangxi1-ps on 2017/6/29.
//  Copyright © 2017年 wangxi. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class XXWebViewController: UIViewController ,WKNavigationDelegate ,WKUIDelegate ,WKScriptMessageHandler{
    var webTitle:String = ""        //title
    var url:String = ""
    var filePath = String()
    var showBack:Bool = true
    /// 记录goback时需要reload的url
    var reloadArrayWhenBack = [String]()
    lazy var webView:WKWebView = {
        let tempWebView = WKWebView(frame: CGRect(x:0 ,y:64, width:self.view.bounds.size.width,height:self.view.bounds.size.height-64), configuration: WKWebViewConfiguration())
        tempWebView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        tempWebView.navigationDelegate = self
        tempWebView.uiDelegate = self
        tempWebView.isMultipleTouchEnabled = true
        tempWebView.autoresizesSubviews = true
        tempWebView.scrollView.alwaysBounceVertical = true
        tempWebView.allowsBackForwardNavigationGestures = true
        tempWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        tempWebView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
        tempWebView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        return tempWebView
    }()
    var progressView:UIProgressView?
    var errorView:UIImageView?
    //分享按钮用到
    var shareTitle:String = ""
    var shareTimelinetitle:String = ""
    var shareContent:String = ""
    var shareImageUrl:String = ""
    var shareUrl:String = ""
    var shareWeiboUrl:String = ""
    var shareButton:UIButton?
    var shareIcon:UIImage?
    
    @objc init(url: String, defaultTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.webTitle = defaultTitle
        self.url = url
    }
    @objc convenience init(url:String,defaultTitle: String,showBack:Bool) {
        self.init(url: url, defaultTitle: defaultTitle)
        self.showBack = showBack
    }
    
    convenience init(filePath:String,defaultTitle: String,showBack:Bool) {
        self.init(url: "", defaultTitle: defaultTitle)
        self.showBack = showBack
        self.filePath = filePath
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //释放
    deinit {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView.removeObserver(self, forKeyPath: "canGoBack")
        self.webView.removeObserver(self, forKeyPath: "title")
        self.webView.navigationDelegate = nil
        self.webView.uiDelegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;
        self.navigationItem.title = webTitle
        self.configUi()
        self.loadUrl(surl: self.url)
        self.eventHandle()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    private func configUi() {
        self.view.addSubview(self.webView)
        //进度条
        self.progressView = UIProgressView(progressViewStyle: .default)
        self.progressView?.trackTintColor = UIColor(white: 1.0, alpha: 0.0)
        self.progressView?.progressTintColor = UIColor.red
        self.progressView?.frame = CGRect(x: 0, y: ((self.navigationController?.navigationBar.frame.origin.y)!+(self.navigationController?.navigationBar.frame.size.height)!), width: self.view.frame.width, height: (self.progressView?.frame.size.height)!)
        self.progressView?.autoresizingMask = [.flexibleTopMargin,.flexibleWidth]
        self.progressView?.setProgress(0.5, animated: true)
        
        //错误提示图片
        self.errorView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: (self.webView.frame.size.width), height: (self.webView.frame.size.height)))
        self.errorView?.autoresizingMask = [.flexibleWidth,.flexibleHeight];
        self.errorView?.image = UIImage.init(named: "disconnect")
        self.errorView?.isHidden = true
        self.errorView?.contentMode = .center
        self.errorView?.center = self.view.center
        self.view.addSubview(self.errorView!)
        //返回按钮
        if self.showBack {
            let baakButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 30, height: 35))
            baakButton.setImage(UIImage.init(named: "naviback"), for:.normal)
            baakButton.setImage(UIImage.init(named: "naviback_press"), for:.highlighted)
            baakButton.setImage(UIImage.init(named: "naviback_white"), for:.disabled)
            baakButton.addTarget(self, action: #selector(gooBack), for:.touchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: baakButton)
        }
        self.view.addSubview(self.progressView!)
    }
    
    public func loadUrl(surl: String) {
        if surl.isEmpty {
            if !self.filePath.isEmpty {
                let htmlstr = try? String(contentsOfFile: self.filePath, encoding: String.Encoding.utf8)
                self.webView.loadHTMLString(htmlstr!, baseURL: nil)
            }
        }
        else {
            let tempUrl:URL = URL(string:surl)!
            let request:URLRequest = URLRequest(url: tempUrl)
            _ =  self.webView.load(request)
        }
    }
    @objc public func reloadWebView() {
        self.webView.load(URLRequest(url: URL(string: self.url)!))
    }
    public func isLoading() ->Bool {
        return (self.webView.isLoading)
    }
    
    public func getTitle() -> String {
        return (self.webView.title)!
    
    }
    public func shareButtonReload(){
        //分享按钮
        self.reloadArrayWhenBack.forEach({ (subStr) in
            if subStr == self.webView.url?.absoluteString {
                self.webView.reload()
            }
        })
    }
    
    @objc func gooBack(sender: UIButton!) {
        if (self.webView.canGoBack) {
            self.webView.goBack()
            //分享按钮   8的系统会自动刷新，所以不需要手动在刷
            if #available(iOS 8.5, *) {
                self.shareButtonReload()
            }
        }
        else {
            //删除注册的脚本
            self.unregisterHandler(handlerName: "XXX")
            if (self.navigationController?.viewControllers.count)! > 0 {
                if let _ = self.navigationController?.viewControllers.index(of: self) {
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    //关闭webview 直接退出
    @objc func closeWebView(sender:UIButton!) {
        if (self.navigationController != nil) {
            self.unregisterHandler(handlerName: "XXX")
            if (self.navigationController?.viewControllers.index(of: self))! > 0 {
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    @objc public func evaluateJavaScriptFromString(strJs: String ,completion: ((Any) -> Swift.Void)? = nil) {
        self.webView.evaluateJavaScript(strJs, completionHandler: { (object: Any?, error: Error?) in
            if (completion != nil) {
                completion!(object as Any)
            }
        })
    }
    // 页面加在失败处理
    func failHandle() {
        let js:String = "document.body.innerHTML"
        self.evaluateJavaScriptFromString(strJs:js) { [unowned self] (object: Any) in
            if object is String , !(self.webView.isLoading) {
                let content:String = String(describing: object)
                if content.count < 10 || content == "Optional()" , !(self.webView.isLoading)  {
                    self.errorView?.isHidden = false
                    self.webView.scrollView.showsHorizontalScrollIndicator = false
                }
                else {
                    self.errorView?.isHidden = true
                    self.webView.scrollView.showsHorizontalScrollIndicator = true
                }
            }
        }
    }
    //返回按钮旁边添加关闭按钮
    func resetLeftItems(cangoback:Bool)  {
        if cangoback {
            let baakButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 30, height: 35))
            baakButton.setImage(UIImage.init(named: "naviback"), for:.normal)
            baakButton.setImage(UIImage.init(named: "naviback_press"), for:.highlighted)
            baakButton.setImage(UIImage.init(named: "naviback_white"), for:.disabled)
            baakButton.addTarget(self, action: #selector(gooBack), for:.touchUpInside)
            let closeButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 30, height: 35))
            closeButton.setImage(UIImage.init(named: "webclose"), for:.normal)
            closeButton.setImage(UIImage.init(named: "webclose_press"), for:.highlighted)
            closeButton.setImage(UIImage.init(named: "webclose"), for:.disabled)
            closeButton.addTarget(self, action: #selector(closeWebView), for:.touchUpInside)
            self.navigationItem.leftBarButtonItems = [UIBarButtonItem.init(customView: baakButton),UIBarButtonItem.init(customView: closeButton)]
        }
        else {
            let baakButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 30, height: 35))
            baakButton.setImage(UIImage.init(named: "naviback"), for:.normal)
            baakButton.setImage(UIImage.init(named: "naviback_press"), for:.highlighted)
            baakButton.setImage(UIImage.init(named: "naviback_white"), for:.disabled)
            baakButton.addTarget(self, action: #selector(gooBack), for:.touchUpInside)
            self.navigationItem.leftBarButtonItems = [UIBarButtonItem.init(customView: baakButton)]
        }
    }
    //默认右边按钮是不显示
    func resetRightItems() {
        self.navigationItem.rightBarButtonItems = nil
    }
    
    //MARK: Estimated Progress KVO (WKWebView)
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == NSStringFromSelector(#selector(getter: WKWebView.estimatedProgress)) {
            if self.progressView == nil {
                return
            }
            self.progressView?.alpha = 1.0
            let animated:Bool = (self.webView.estimatedProgress) > Double((self.progressView?.progress)!)
            self.progressView?.setProgress(Float((self.webView.estimatedProgress)), animated: animated)
            if (self.webView.estimatedProgress) >= Double(1.0) {
                UIView.animate(withDuration: 0.3, delay: 0.3, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
                    self.progressView?.alpha = 0.0
                }, completion: { (Bool) in
                    self.progressView?.setProgress(0.0, animated: false)
                })
            }
        }
        else if keyPath == "canGoBack" {
            if self.showBack {
                let canGoback =  change?[.newKey]
                let iscan:Bool = canGoback as! NSNumber as! Bool
                self.resetLeftItems(cangoback:iscan)
                if let title = webView.title {
                    self.navigationItem.title = title
                    }
            }
        }
        else if keyPath == "title" {
            let tempTitle =  change?[.newKey]
            let stitle:String = tempTitle as! String
            if !(stitle.isEmpty) {
                self.navigationItem.title = stitle
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    //MARK: other
    
}
//MARK: WKNavigationDelegate

private typealias wkNavigationDelegate = XXWebViewController
extension wkNavigationDelegate {
    //MARK: WKNavigationDelegate
    /**
     *  在收到响应后，决定是否跳转
     *
     *  @param webView            实现该代理的webview
     *  @param navigationResponse 当前navigation
     *  @param decisionHandler    是否跳转block
     */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let app:UIApplication = UIApplication.shared
        if let tempUrl = navigationAction.request.url {
            if tempUrl.scheme == "tel" ,app.canOpenURL(tempUrl)  {
//                app.open(tempUrl, options: [:], completionHandler: nil)
                app.openURL(tempUrl)
                decisionHandler(.cancel)
                return
            }
            if tempUrl.host == "itunes.apple.com" ,app.canOpenURL(tempUrl) {
//                app.open(tempUrl, options: [:], completionHandler: nil)
                app.openURL(tempUrl)
                decisionHandler(.cancel)
                return
            }
            if tempUrl.scheme == "weixin" ,app.canOpenURL(tempUrl)  {
//                app.open(tempUrl, options: [:], completionHandler: nil)
                app.openURL(tempUrl)
                decisionHandler(.cancel)
                return
            }
        }
        webView.scrollView.showsHorizontalScrollIndicator = true
        self.errorView?.isHidden = true
        //过滤 _blank 标签
        if let targetF:WKFrameInfo = navigationAction.targetFrame {
            let ismainFrame:Bool = targetF.isMainFrame
            if !ismainFrame {
                webView.evaluateJavaScript("var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}", completionHandler: nil)
            }
        }
        decisionHandler(.allow)
    }
    /**
     *  页面开始加载时调用
     *
     *  @param webView    实现该代理的webview
     *  @param navigation 当前navigation
     */
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.url = (webView.url?.absoluteString)!
        self.resetRightItems()
    }
    /**
     *  当内容开始返回时调用
     *
     *  @param webView    实现该代理的webview
     *  @param navigation 当前navigation
     */
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.url = (webView.url?.absoluteString)!
    }
    /**
     *  页面加载完成之后调用
     *
     *  @param webView    实现该代理的webview
     *  @param navigation 当前navigation
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.url = (webView.url?.absoluteString)!
    }
    /**
     *  加载失败时调用
     *
     *  @param webView    实现该代理的webview
     *  @param navigation 当前navigation
     *  @param error      错误
     */
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.failHandle()
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.failHandle()
    }
}
//MARK: WKUIDelegate
private typealias wkUIDelegate = XXWebViewController
extension wkUIDelegate {
    //处理alert事件
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let ac = UIAlertController(title: webView.title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (aa) -> Void in
            completionHandler()
        }))
        self.present(ac, animated: true, completion: nil)
    }
}
//MARK: WKScriptMessageHandler    js---Native 交互
private var jsHandlerKey: Void? // 我们还是需要这样的模板
typealias WJBResponseCallback = (Any?) -> Void

private typealias wkScriptMessageHandler = XXWebViewController
extension wkScriptMessageHandler {
    var jsHandler:Dictionary<String, Any> {
        get {
            return objc_getAssociatedObject(self, &jsHandlerKey) as! Dictionary
        }
        set(newValue) {
             objc_setAssociatedObject(self, &jsHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func registerHandler(handlerName:String ,handler:WJBResponseCallback?) {
        if handlerName.isEmpty {
            return
        }
        self.jsHandler = [:]   //设置默认值
        self.jsHandler.updateValue(handler!, forKey: handlerName)
        self.webView.configuration.userContentController.add(self, name: handlerName)
    }
    
    func unregisterHandler(handlerName:String)  {
        if handlerName.isEmpty {
            return
        }
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: handlerName)
    }
    //接受消息
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let handller:WJBResponseCallback? = (self.jsHandler[message.name] as! WJBResponseCallback)
        if handller != nil {
            handller!(message.body)
        }
        print(message.name)
        print((message.body as AnyObject).description)
    }
}

private typealias XXXScriptHandler = XXWebViewController
extension XXXScriptHandler {
    func eventHandle() {
        self .registerHandler(handlerName: "XXX") { [unowned self] (body:Any?) in
            //            var dictData:Dictionary<String, Any>!
            //            if body is String {
            //                let bodyStr = body as? String
            //                dictData = bodyStr?.objectFromJSONString() as! Dictionary<String, Any>
            //            }
            //            if body is Dictionary<String, Any> {
            //                dictData = (body as? Dictionary)!
            //            }
            //            if dictData.isEmpty == false {
            //        }
        }
    }
}
