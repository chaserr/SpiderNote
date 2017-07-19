//
//  BaseWebView.swift
//  Spider
//
//  Created by 童星 on 16/7/12.
//  Copyright © 2016年 oOatuo. All rights reserved.
//  加载网页的基类

import UIKit
import WebKit
class BaseWebView: MainViewController, WKNavigationDelegate, WKUIDelegate {

    
    var webView:WKWebView!
    var currentUrl:String!
    var isPresentController:Bool = false
    
    // 进度条
    var progBar:UIProgressView!
    
    override init() {
        super.init()
        // 初始化webview
        setupWKWebView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customLizeNavigationBarBackBtn()

    }
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 初始化webview
    func setupWKWebView() -> Void {
        
        webView = WKWebView.init(frame: self.view.frame)
        webView.allowsBackForwardNavigationGestures = true
        webView.sizeToFit()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
        
        progBar = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30))
        progBar.progress = 0.0
        progBar.tintColor = UIColor.red
        
        // TODO: 先初始化view，再添加webview
        webView.addSubview(progBar)
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    // MARK:控制器生命周期
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    deinit{
    
        webView.removeObserver(self, forKeyPath: "estimatedProgress")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func loadPage(_ url:String, navTitle:String) -> Void {
        navigationTitleLabel.text = title

        currentUrl = url
        
        
        let urlRequest:NSMutableURLRequest = NSMutableURLRequest.init(url: URL(string: currentUrl)!)
        webView.load(urlRequest)
        
    }
    
    
    // MARK: 处理KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progBar.alpha = 1.0
            progBar.setProgress(Float(webView.estimatedProgress), animated: true)
            //进度条的值最大为1.0
            if(webView.estimatedProgress >= 1.0) {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: UIViewAnimationOptions(), animations: { () -> Void in
                    self.progBar.alpha = 0.0
                    }, completion: { (finished:Bool) -> Void in
                        self.progBar.progress = 0
                })
            }
        }
    }
    
    
    func refreshBtnClicked() -> Void {
        webView.reload()
    }
    
    override func backAction() {
        // 判断网页是否有后退方法
        if webView.canGoBack {
            webView.goBack()
        }
        else{
        
            if isPresentController == true {
                self.dismissVC(completion: nil)
            }else{
            
                AppNavigator.openMainViewController()

            }
        }
    }
    
    func toForword() -> Void {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    

}

// MARK: -- WKNavigationDelegate, WKUIDelegate
extension BaseWebView {

    // 内容开始加载
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    // 内容开始返回
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    // 页面加载完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        navigationTitleLabel.text = webView.title
    }
    
    
    // 页面加载失败
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    
    // 接收到服务器跳转请求之后调用
//    func webView(webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
//        
//    }
    
    // 收到响应之后，决定是否跳转
//    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
//        
//    }
    
    // 在发送请求之前，决定是否跳转
//    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
//        
//        
//    }
    
    // 创建一个新的webview
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // 如果目标主视图不为空，则允许导航，主要是为了防止系统拦截不安全链接
        if !(navigationAction.targetFrame?.isMainFrame != nil) {
            webView.load(navigationAction.request)
        }
        
        return nil
    }
    
    /**
     web界面中有弹出警告框时调用
     
     - parameter webView:           实现该代理的webview
     - parameter message:           警告框内容
     - parameter frame:             主窗口
     - parameter completionHandler: 警告框消失调用
     */
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) -> Void in
            completionHandler()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
