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
//import AZDropdownMenu
import SnapKit

class HomeViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var urlTf: UITextField!
    @IBOutlet weak var convertButton: GradientButton!

    @IBOutlet weak var qrImgBottomOffset: NSLayoutConstraint!
    //    private var buttonAnimation:LOTAnimationView?
    @IBOutlet weak var qrCodeImg: UIImageView!
    
    @IBOutlet weak var qrCodeImgWidth: NSLayoutConstraint!
    @IBOutlet weak var qrCodeImgHeight: NSLayoutConstraint!
    //
    let titleButton = UIButton(type: .custom)
    //切换w服务vmenu
    var currentService = ShortenServiceMode.init()
    var services = [ShortenServiceMode]()
    var serviceMenu:AZDropdownMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loa ding the view.
//        self.view.backgroundColor = UIColor.init(hexString: "#f3f3f3")
        self.configUi()
        self.configService()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    deinit{
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    //返回键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.urlTf.resignFirstResponder()
    }
    
    func configUi() {
//        self.navigationItem.title = "t.cn"
        self.view.backgroundColor = UIColor.white//UIColor.init(hexString: "#E3E7E9")
        self.navigationController?.navigationBar.isTranslucent = false
        //nav
        let titleView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.width, height: (self.navigationController?.navigationBar.height)!))
//        titleView.backgroundColor = UIColor.red
        self.navigationItem.titleView = titleView
        titleView.addSubview(self.titleButton)
        self.titleButton.snp.makeConstraints{
            $0.center.equalToSuperview()
        }
//        titleButton.setTitle("t.cn ∨", for: .normal)//∧▽↓^∨∪∩νv
        titleButton.setAttributedTitle(self.setviceAttStrWith("t.cn ∨"), for: .normal)
//        titleButton.setImage(#imageLiteral(resourceName: "arrow_down_pressed"), for: .normal)
//        titleButton.contentHorizontalAlignment = .center
        titleButton.contentVerticalAlignment = .center
        titleButton.titleLabel?.font = UIFont.init(name: "PingFangSC-Semibold", size: 18)
        titleButton.setTitleColor(UIColor.init(hexString: "3C4945"), for: .normal)
        titleButton.sizeToFit()
        titleButton.addTarget(self, action: #selector(showServiceMenu), for: .touchUpInside)
        titleButton.titleImgAlignRight()
        //
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
        placeholder.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "#C7C7CC")], range: NSMakeRange(0, text.count))
        self.urlTf.attributedPlaceholder = placeholder
        //
        self.qrCodeImg.layer.shadowColor = UIColor.init(hexString: "#A9A9A9").cgColor
        self.qrCodeImg.layer.shadowOpacity = 0.8
        self.qrCodeImg.layer.shadowRadius = 15.0
        self.qrCodeImg.isHidden = true
        //通知
        //前台进入程序
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        //添加点击手势到二维码
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapQRcode(sender:)))
        tap.numberOfTapsRequired = 1
        self.qrCodeImg.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
//    override func viewDidLayoutSubviews() {
//    }
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if Device.size() == .screen4Inch || Device.size() == .screen3_5Inch{
            self.qrCodeImgWidth.constant = 150
            self.qrCodeImgHeight.constant = 150
            self.qrImgBottomOffset.constant = 90
        }
        else {
            self.qrCodeImgWidth.constant = 200
            self.qrCodeImgHeight.constant = 200
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
        warningConfig.presentationContext = .window(windowLevel: UIWindow.Level(rawValue: UIWindow.Level.statusBar.rawValue))
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
            ServiceManage.shared().converUrl(urls: [url], serviceMode: self.currentService) { (newUrlModel) in
                MBProgressHUD.hide(for: self.view, animated: true)
                if newUrlModel.isEmpty {
                    self.showFailureTip()
                }
                //s判断是否成功
                if let item = newUrlModel.first {
                    if item.converStatus == .failure {
                        self.showFailureTip()
                    }
                    else {
                        self.urlTf.text = item.serviceUrl
                        //显示二维码
                        self.showQRcode(shortUrl: item.serviceUrl)
                    }
                }
            }
//            SinaConver.shared().converSinaUrl(urls: [url]) { (newUrlModel) in
//                MBProgressHUD.hide(for: self.view, animated: true)
//                if newUrlModel.isEmpty {
//                    self.urlTf.text = "缩短失败了😑"
//                    self.qrCodeImg.image = nil
//                }
//                if let item = newUrlModel.first {
//                    self.urlTf.text = item.urlShort
//                    //显示二维码
//                    if let tempShortUrl = item.urlShort {
//                        self.showQRcode(shortUrl: tempShortUrl)
//                    }
//                }
//            }
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
    
    fileprivate func showFailureTip() {
        self.urlTf.text = "缩短失败了😑"
        self.qrCodeImg.image = nil
    }
    
    fileprivate func clearShortUrl() {
        self.qrCodeImg.image = nil
        self.urlTf.text = ""
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
//MARK: 切换服务
extension HomeViewController {
    @objc func showServiceMenu () {
        if self.serviceMenu?.isDescendant(of: self.view) == true {
            self.serviceMenu?.hideMenu()
        }
        else {
            self.serviceMenu?.showMenuFromView(self.view)
//            self.titleButton.setTitle("关闭", for: .normal)
            self.titleButton.setAttributedTitle(self.setviceAttStrWith("关闭 ∧"), for: .normal)
        }
    }
    
    func configService() {
//        self.currentService = ShortenServiceMode.init()
        self.services = ServiceManage.shared().loadService()
        var azdropMenuDataSource = [AZDropdownMenuItemData]()
        for item in self.services {
            let azdropItem = AZDropdownMenuItemData.init(title: item.name)
            azdropMenuDataSource.append(azdropItem)
        }
        self.serviceMenu = AZDropdownMenu(dataSource: azdropMenuDataSource)
        self.serviceMenu?.itemHeight = 70
        self.serviceMenu?.itemFontSize = 14.0
        self.serviceMenu?.itemFontName = "Menlo-Bold"
        self.serviceMenu?.itemColor = UIColor.white
        self.serviceMenu?.itemFontColor = UIColor(red: 55/255, green: 11/255, blue: 17/255, alpha: 1.0)
        self.serviceMenu?.itemSelectionColor = UIColor(hexString: "#f3f3f3")
        self.serviceMenu?.overlayColor = UIColor(hexString: "#666666")
        self.serviceMenu?.overlayAlpha = 0.3
        self.serviceMenu?.itemAlignment = .center
        self.serviceMenu?.itemImagePosition = .postfix
        self.serviceMenu?.menuSeparatorStyle = .none
        self.serviceMenu?.shouldDismissMenuOnDrag = true
        //action
        self.serviceMenu?.cellTapHandler = { [weak self] (indexPath:IndexPath) ->Void in
            let item:ShortenServiceMode = self!.services[indexPath.row]
            self?.currentService = item
            self?.titleButton.setAttributedTitle(self?.setviceAttStrWith(item.name+"∨"), for: .normal)
//            self?.clearShortUrl()
        }
        
        self.serviceMenu?.hideMenuHandler = { [weak self] in
            self?.titleButton.setAttributedTitle(self?.setviceAttStrWith((self?.currentService.name)! + " ∨"), for: .normal)
        }
    }
    func setviceAttStrWith(_ title:String) ->NSAttributedString {
        let attstring:NSMutableAttributedString = NSMutableAttributedString.init(string: title)
        attstring.addAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)], range: NSRange(location: title.count-1, length: 1))
        return attstring
    }
}
