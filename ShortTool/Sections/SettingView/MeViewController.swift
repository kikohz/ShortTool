//
//  MeViewController.swift
//  ShortTool
//
//  Created by Bllgo on 2018/6/20.
//  Copyright © 2018 Bllgo. All rights reserved.
//

import UIKit
import StoreKit
import MBProgressHUD
import VSAlert

class MeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,SKStoreProductViewControllerDelegate {
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var logoImg: UIImageView!
    var dataSource = [AboutModel]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configUi()
        self.loadListData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func configUi() {
        self.edgesForExtendedLayout = .init(rawValue: 0)
        self.automaticallyAdjustsScrollViewInsets = false
        //nav
        let navBar = self.navigationController!.navigationBar
        navBar.setBackgroundImage(UIImage.creatImg(UIColor.white), for: .default)
        navBar.shadowImage = UIImage()
        //tableview
        self.tableview.register(UINib.init(nibName: "MeTableViewCell", bundle: nil), forCellReuseIdentifier: "MeTableViewCell")
        self.tableview.separatorColor = UIColor.init(hexString: "#eeeeee")
        self.tableview.tableFooterView = UIView.init(frame: CGRect.zero)
        self.tableview.dataSource = self
        self.tableview.delegate = self
    }
    
    func loadListData() {
        let path = Bundle.init(for: MeViewController.self).path(forResource: "about", ofType: "json")
        if let data = try? Data.init(contentsOf: URL(fileURLWithPath: path!), options:.mappedIfSafe) {
            let decoder = JSONDecoder()
            let about = try! decoder.decode([AboutModel].self, from: data)
            self.dataSource = about
            self.tableview.reloadData()
        }
    }
}

extension MeViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //填充数据
        let item:AboutModel = self.dataSource[indexPath.row]
        let aboutCell:MeTableViewCell = cell as! MeTableViewCell
        aboutCell.titleLb.text = item.title
        aboutCell.subTitleLb.text = item.subtitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeTableViewCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item:AboutModel = self.dataSource[indexPath.row]
        if item.id == "score" {
            UIApplication.shared.keyWindow?.endEditing(true)
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                let storeProduct = SKStoreProductViewController.init()
                storeProduct.delegate = self
                storeProduct.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier : "1026789253"]) { (result, error) in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    if (error != nil) {
                    }
                    else {
                        self.present(storeProduct, animated: true, completion: nil)
                    }
                }
            }
        }
        else if item.id == "wx-gzh" {
            let pasteboard = UIPasteboard.general
            pasteboard.string = "羊毛实验室"
            let alertController = VSAlertController.init(title: "关注公众号", message: "已经复制到了剪切板，立即前往微信去关注", preferredStyle: .alert)
            let vsCancelAction = VSAlertAction.init(title: "取消", style:.default, action: nil)
            alertController?.add(vsCancelAction!)
            let vsOkAction = VSAlertAction.init(title: "去关注", style: .cancel) { (action) in
                UIApplication.shared.openURL(URL(string: "weixin://")!)
            }
            alertController?.add(vsOkAction!)
            alertController?.animationStyle = .automatic
            self.present(alertController!, animated: true, completion: nil)
        }
        else if item.id == "thanks" {
            let htmlPath = Bundle.init(for: MeViewController.classForCoder()).path(forResource: "opensource", ofType: "html")
            let webview = XXWebViewController.init(filePath: htmlPath!, defaultTitle: "特别感谢", showBack: true)
            webview.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(webview, animated: true)
        }
    }
    
    //MARK: SKStoreProductViewControllerDelegate
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}
