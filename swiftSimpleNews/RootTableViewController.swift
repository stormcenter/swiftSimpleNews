//
//  RootTableViewController.swift
//  swiftSimpleNews
//
//  Created by Chi Zhang on 14/6/30.
//  Copyright (c) 2014年 Chi. All rights reserved.
//

//
//  RootTableViewController.swift
//  UITableViewControllerDemo
//
//  Created by 赵超 on 14-6-24.
//  Copyright (c) 2014年 赵超. All rights reserved.
//

import UIKit

class RootTableViewController: UITableViewController {
    
    var dataSource = []
    
    var thumbQueue = NSOperationQueue()
    
    var pageNo = 1
    
//    var hackerNewsApiUrl:String =
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        self.tableView!.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新")
        refreshControl.addTarget(self, action: "loadDataSource", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        
        
        loadDataSource()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // #pragma mark - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        
        return dataSource.count
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        
        return dataSource.count
        
    }
    
    func loadDataSource() {
        self.refreshControl.beginRefreshing()
        var loadURL = NSURL.URLWithString("http://qingbin.sinaapp.com/api/lists?ntype=%E5%9B%BE%E7%89%87&pageNo=\(pageNo)&pagePer=10&list.htm")
        var request = NSURLRequest(URL: loadURL)
        var loadDataSourceQueue = NSOperationQueue();
        
        NSURLConnection.sendAsynchronousRequest(request, queue: loadDataSourceQueue, completionHandler: { response, data, error in
            if error {
                println(error)
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshControl.endRefreshing()
                    })
            } else {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                let newsDataSource = json["item"] as NSArray
                
                var currentNewsDataSource = NSMutableArray()
                for currentNews : AnyObject in newsDataSource {
                    let newsItem = XHNewsItem()
                    newsItem.newsTitle = currentNews["title"] as NSString
                    newsItem.newsThumb = currentNews["thumb"] as NSString
                    newsItem.newsID = currentNews["id"] as NSString
                    currentNewsDataSource.addObject(newsItem)
                    println( newsItem.newsTitle)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.dataSource = currentNewsDataSource
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    })
            }
            })
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        var cell = tableView .dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        var newsItem = dataSource[indexPath.row] as XHNewsItem
        cell.textLabel.text = newsItem.newsTitle
        cell.imageView.image = UIImage(named :"iconpng")
        cell.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        
        
        let request = NSURLRequest(URL :NSURL.URLWithString(newsItem.newsThumb))
        NSURLConnection.sendAsynchronousRequest(request, queue: thumbQueue, completionHandler: { response, data, error in
            if error {
                println(error)
                
            } else {
                let image = UIImage.init(data :data)
                dispatch_async(dispatch_get_main_queue(), {
                    cell.imageView.image = image
                    })
            }
            })
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 80
    }
    
    // #pragma mark - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("aa")
    }
    
    //选择一行
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
        var row=indexPath.row as Int
        var data=self.dataSource[row] as XHNewsItem
        //入栈
        
        var webView=WebViewController()
        webView.detailID=data.newsID
        //取导航控制器,添加subView
        self.navigationController.pushViewController(webView,animated:true)
    }
    
    
}
