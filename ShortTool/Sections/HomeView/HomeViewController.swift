//
//  HomeViewController.swift
//  ShortTool
//
//  Created by Bllgo on 2018/6/20.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import UIKit
//import Lottie
import SwiftMessages
import MBProgressHUD
import EFQRCode
import VSAlert
import Device

class HomeViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var urlTf: UITextField!
    @IBOutlet weak var convertButton: GradientButton!
    //动画
//    private var buttonAnimation:LOTAnimationView?
    @IBOutlet weak var qrCodeImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loa ding the view.
//        self.view.backgroundColor = UIColor.init(hexString: "#f3f3f3")
        self.configUi()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit{
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
    }
    //返回键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.urlTf.resignFirstResponder()
    }
    
    func configUi() {
        self.navigationItem.title = "t.cn"
        self.view.backgroundColor = UIColor.white//UIColor.init(hexString: "#E3E7E9")
        self.lineView.height = SINGLE_LINE_WIDTH
        self.urlTf.delegate = self
        self.urlTf.autocorrectionType = .no
        //nav
        let navBar = self.navigationController!.navigationBar
        navBar.setBackgroundImage(UIImage.creatImg(UIColor.white), for: .default)
        navBar.shadowImage = UIImage()
        //  #selector(UIImage.withRenderingMode(_:))
        self.urlTf.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        self.textFieldDidChange(self.urlTf)
        //textfield
        let text = "请输入要转换的地址"
        let placeholder = NSMutableAttributedString.init(string: text)
        placeholder.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.init(hexString: "#C7C7CC")], range: NSMakeRange(0, text.count))
        self.urlTf.attributedPlaceholder = placeholder
        //
        self.qrCodeImg.layer.shadowColor = UIColor.init(hexString: "#A9A9A9").cgColor
        self.qrCodeImg.layer.shadowOpacity = 0.8
        self.qrCodeImg.layer.shadowRadius = 15.0
        //通知
        //前台进入程序
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        //添加点击手势到二维码
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapQRcode(sender:)))
        tap.numberOfTapsRequired = 1
        self.qrCodeImg.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidLayoutSubviews() {
        //界面调整
        if Device.size() == .screen4Inch || Device.size() == .screen3_5Inch {
            self.qrCodeImg.width = 150
            self.qrCodeImg.height = 150
            self.qrCodeImg.x = (self.view.width-self.qrCodeImg.width)/2
            self.qrCodeImg.top = self.lineView.bottom + 50
        }
    }
    //进入程序
    @objc func applicationDidBecomeActive() {
        if self.isViewLoaded && (self.view.window != nil) {    //判断当前页面是否在显示
            self.autoConvert()
        }
    }
    
    @objc func tapQRcode(sender:UITapGestureRecognizer) {
        if let qrimg = self.qrCodeImg.image {
            self.shareActivity(["分享",qrimg])
//            UIImage.savePhotoLibray(qrimg) { (success, status) in
//                if !success {
//                    if status == .denied {  //提示用户去授权
//                        let alertController = VSAlertController.init(title: "需要授权", message: "App需要您的同意，才能访问相册,请您授权访问", preferredStyle: .alert)
//                        let vsCancelAction = VSAlertAction.init(title: "不授权", style:.default, action: nil)
//                        alertController?.add(vsCancelAction!)
//                        let vsOkAction = VSAlertAction.init(title: "去授权", style: .cancel) { (action) in
//                            if let url = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) {
//                                UIApplication.shared.openURL(url)
//                            }
//                        }
//                        alertController?.add(vsOkAction!)
//                        alertController?.animationStyle = .automatic
//                        self.present(alertController!, animated: true, completion: nil)
//                    }
//                }
//                else {
//                 self.showTip("保存成功", "二维码已经保存在系统相册，请您去相册查看", .cardView, .success)
//                }
//            }
        }
        
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
    
    func convertTip(_ str:String) {
        let alertController = VSAlertController.init(title: "检测到Url", message: "自动检测到您复制的Url，是否自动帮你缩短?", preferredStyle: .alert)
        let vsCancelAction = VSAlertAction.init(title: "不需要", style:.default, action: nil)
        alertController?.add(vsCancelAction!)
        let vsOkAction = VSAlertAction.init(title: "缩短", style: .cancel) { (action) in
            self.urlTf.text = str
            self.convertUrl(str)
        }
        alertController?.add(vsOkAction!)
        alertController?.animationStyle = .automatic
        self.present(alertController!, animated: true, completion: nil)
    }
    
    func autoConvert() {
        let pasteboard = UIPasteboard.general
        if let str = pasteboard.string,RegexHelper.isUrl(str) {
            if str.ranges(of: "http").count == 1 {    //批量的不做自动处理
                self.convertTip(str)
            }
        }
    }

    func showQRcode(shortUrl:String) {
        if let tempImg = self.generateQRCodeImg(content: shortUrl, size: CGSize(width: self.qrCodeImg.width*2, height: self.qrCodeImg.height*2)) {
            self.qrCodeImg.isHidden = false
            self.qrCodeImg.image = tempImg
        }
    }
    func convertUrl(_ url:String) {
        //检查输入的内容是否正确
        if RegexHelper.isUrl(url) {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            self.convertButton.isHidden = true
            SinaConver.shared().converSinaUrl(urls: [url]) { (newUrlModel) in
                MBProgressHUD.hide(for: self.view, animated: true)
                if newUrlModel.isEmpty {
                    self.urlTf.text = "缩短失败了😑"
                    self.qrCodeImg.image = nil
                }
                if let item = newUrlModel.first {
                    self.urlTf.text = item.urlShort
                    //显示二维码
                    if let tempShortUrl = item.urlShort {
                        self.showQRcode(shortUrl: tempShortUrl)
                    }
                }
            }
        }
        else {
            //无效地址提示
            self.showTip("出错了", "您输入的地址有误，请重新输入", .cardView, .warning)
        }
    }
    
    @IBAction func convertAction(_ sender: Any) {
        self.urlTf.resignFirstResponder()
        if let url = self.urlTf.text {
            self.convertUrl(url)
        }
    }
    //MARK: TextField Action
    @objc func textFieldDidChange(_ textField:UITextField) {
        //判断url 做出相应处理
        if let text = textField.text {
            if RegexHelper.isUrl(text) {
                self.convertButton.isHidden = false
                self.convertButton.backgroundColor = UIColor.init(hexString: "#f04447")
            }
            else {
                self.convertButton.isHidden = true
            }
        }
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        return true
//    }
    
    //键盘按下完成按键之后
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.urlTf.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.qrCodeImg.image = nil
        return true
    }
}
//MARK: 二维码
extension HomeViewController {
    func generateQRCodeImg(content:String,size:CGSize) -> UIImage? {
        let efSize = EFIntSize(width: Int(size.width), height: Int(size.height))
        if let cgimg = EFQRCode.generate(content: content, size: efSize) {
            let img = UIImage(cgImage: cgimg)
            return img
        }
        return nil
    }
}
