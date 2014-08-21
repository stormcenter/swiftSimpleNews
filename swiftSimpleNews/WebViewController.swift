//
//  WebViewController.swift
//  swiftSimpleNews
//
//  Created by Chi Zhang on 14/6/30.
//  Copyright (c) 2014年 Chi. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    var detailID = NSString()
    var detailURL = "http://qingbin.sinaapp.com/api/html/"
    var webView : UIWebView?
    
    func loadDataSource() {
        var urlString = detailURL + "\(detailID).html"
        var url = NSURL.URLWithString(urlString)
        var urlRequest = NSURLRequest(URL :NSURL.URLWithString(urlString))
        webView!.loadRequest(urlRequest)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView=UIWebView()
        webView!.frame=self.view.frame
        webView!.backgroundColor=UIColor.grayColor()
        self.view.addSubview(webView!)
        
        loadDataSource()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
