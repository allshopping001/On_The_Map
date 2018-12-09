//
//  OTMWebViewController.swift
//  OnTheMap
//
//  Created by macos on 03/10/18.
//  Copyright © 2018 macos. All rights reserved.
//

import UIKit
import WebKit

class OTMWebViewController: UIViewController, WKNavigationDelegate {

    // Properties
    var urlRequest : URLRequest? = nil
    var webView: WKWebView!
    var navigationTitle : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let urlRequest = urlRequest {
            webView.load(urlRequest)
        }
    }
    
    @objc func cancelMediaRequest(){
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - UI Config Methods
    func configureUI(){
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), configuration: WKWebViewConfiguration())
        webView.autoresizingMask = [.flexibleHeight]
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        navigationItem.title = navigationTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector (cancelMediaRequest))
    }

}
