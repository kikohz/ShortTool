//
//  BatchViewController.swift
//  ShortTool
//
//  Created by Bllgo on 2018/6/20.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import UIKit
import DynamicButton
import SwiftMessages
import MBProgressHUD

class BatchViewController: UIViewController,UITextViewDelegate {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var convertButton: GradientButton!
    var clearButton: DynamicButton!
    @IBOutlet weak var textView: UITextView!
    enum ConvertStatus {
        case NotStarted
        case Converting
        case Complete
    }
    var convertStatus = ConvertStatus.NotStarted    //转换状态
//    var oldUrls = [String]()             //转换之前的url数组
    var newUrls = [SinaShortUrlModel]()             //转换之后的url
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configUi()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func clearText(_ sender: Any) {
        if self.clearButton.style == .arrowUp {   //分享 微信暂时不能分享文字，所以这个版本会有问题，下个版本解决
            self.shareActivity([self.textView.text])
        }
        else{
            if self.textView.text != "请输入带有需要转换的Url的文本" {
                self.textView.text = ""
            }
        }
    }
    func configUi(){
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = .init(rawValue: 0)
        self.view.backgroundColor = UIColor.init(hexString: "#f3f3f3")
        self.textView.delegate = self
        //nav
        let navBar = self.navigationController!.navigationBar
        navBar.setBackgroundImage(UIImage.creatImg(UIColor.white), for: .default)
        navBar.shadowImage = UIImage()
        //
        self.clearButton = DynamicButton(style: .hamburger)
        if self.textView.text.count <= 0 {
            self.clearButton.isHidden = true
        }
        self.clearButton.setStyle(.close, animated: true)
        self.backgroundView.addSubview(self.clearButton)
        
        self.clearButton.autoresizingMask = [.flexibleRightMargin,.flexibleBottomMargin]
        self.clearButton.strokeColor = UIColor.init(hexString: "#ed4e39")
        self.clearButton.lineWidth = 1
        self.clearButton.addTarget(self, action: #selector(clearText(_:)), for: .touchUpInside)
        //text view Placeholder
        self.textView.text = "请输入带有需要转换的Url的文本"
        self.textView.textColor = UIColor.init(hexString: "#C7C7CC")
        self.textView.becomeFirstResponder()
        self.textView.selectedTextRange = self.textView.textRange(from: self.textView.beginningOfDocument, to: self.textView.beginningOfDocument)
        // 通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: .UIKeyboardDidHide, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.clearButton.frame = CGRect(x: self.backgroundView.width - 40, y: self.backgroundView.height - 27, width: 25, height: 25)
    }
    
    @IBAction func convertAction(_ sender: Any) {
        self.textView.resignFirstResponder()
        //开始解析
        self.startConvert()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.textView.resignFirstResponder()
    }
    
    //MARK: 处理
    func resolveStr(_ text:String) -> [String]{
        var allUrl = [String]()
        let regulaStr = "((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"
        if  let regex = try? NSRegularExpression(pattern: regulaStr, options: .caseInsensitive) {
            let allMatchrs = regex.matches(in: text, options:.reportCompletion, range: NSMakeRange(0, text.count))
            for match in allMatchrs {
                let startIndex = text.index(text.startIndex, offsetBy: match.range.location)
                let endIndex = text.index(startIndex, offsetBy: match.range.length)
                let subString = text[startIndex ..< endIndex]
                allUrl.append(String(subString))
            }
        }
        return allUrl
    }
    
    func startConvert(){
        self.convertStatus = ConvertStatus.Converting
        MBProgressHUD.showAdded(to: self.view, animated: true)
        if let text = self.textView.text {
            //解析字符串
            let oldUrls = self.resolveStr(text)
            
            if oldUrls.count > 0 {
                //开始短链接转换
                SinaConver.shared().converSinaUrl(urls: oldUrls) { (newUrlModel) in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.newUrls = newUrlModel
                    self.updateUrlText()
                }
            }
            else {
                self.showTip("解析失败", "解析url失败，请您检查输入的内容", .cardView, .warning)
            }
        }
    }

    func updateUrlText() {
        if self.newUrls.count <= 0 {
            self.showTip("转换失败", "缩短失败，请您再次尝试", .cardView, .error)
            return
        }
        let tempTextStr = self.textView.text
        var newText = tempTextStr
        for sinaUrlModel in self.newUrls {
            if let urlShort = sinaUrlModel.urlShort ,let urlLong = sinaUrlModel.urlLong{
                newText = newText?.replacingOccurrences(of: urlLong, with: urlShort)
            }
        }
        self.textView.text = newText
        self.clearButton.setStyle(.arrowUp, animated: true)
        //提示
        self.showTip("转换成功", "批量缩短完成,已经复制到剪切板", .cardView, .success)
        self.convertStatus = ConvertStatus.Complete
        //复制到剪切板
        let pasteboard = UIPasteboard.general
        pasteboard.string = newText
    }
    
    func showTip(_ title:String, _ text:String, _ layoput:MessageView.Layout ,_ theme:Theme) {
        var warningConfig = SwiftMessages.defaultConfig
        warningConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        let view = MessageView.viewFromNib(layout: layoput)
        view.configureTheme(theme)
        //   view.conf
        view.configureDropShadow()
        view.button?.isHidden = true
        
        view.configureContent(title:title, body: text)
        SwiftMessages.show(config: warningConfig, view: view)
    }
    //键盘
    @objc func keyboardDidHide() {
        //键盘隐藏了就显示分享
        if self.convertStatus == ConvertStatus.Complete {
            self.clearButton.setStyle(.arrowUp, animated: true)
        }
    }
}
//MARK: UITextViewDelegate
extension BatchViewController {
    //开始编辑
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.count > 0{
            self.clearButton.isHidden = false
            self.clearButton.setStyle(.close, animated: true)
        }
        else {
            self.clearButton.isHidden = true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            self.clearButton.isHidden = false
            self.clearButton.setStyle(.close, animated: true)
        }
        else {
            self.clearButton.isHidden = true
        }
    }
    //内容改变
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //Placeholder
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            textView.text = "请输入带有需要转换的Url的文本"
            textView.textColor = UIColor.init(hexString: "#C7C7CC")
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == UIColor.init(hexString: "#C7C7CC") && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            return true
        }
        
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.init(hexString: "#C7C7CC") {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
}

