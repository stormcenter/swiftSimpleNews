//
//  RootTableViewController.swift
//  swiftSimpleNews
//
//  Created by Chi Zhang on 14/6/30.
//  Copyright (c) 2014年 Chi. All rights reserved.
//

import UIKit

class RootTableViewController: UITableViewController, LoadMoreTableFooterViewDelegate {
    
    var dataSource = NSMutableArray()
    
    var thumbQueue = NSOperationQueue()
    
    var pageNo = 1
    
    let PAGESIZE = 10
    
    var loadMoreFooterView: LoadMoreTableFooterView?
    var loadingMore: Bool = false
    var loadingMoreShowing: Bool = false
    
//    init(coder aDecoder: NSCoder!) {
//        super.init(coder: aDecoder)
//        println("init coder")
//    }
//
//    init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        println("init name")
//    }
    
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

        if self.loadMoreFooterView == nil {
            println("contentSize \(self.tableView.contentSize.height) framewidth = \(self.tableView.frame.size.width) frameheight= \(self.tableView.frame.size.height)")
            self.loadMoreFooterView = LoadMoreTableFooterView(frame: CGRectMake(0, self.tableView.contentSize.height, self.tableView.frame.width, self.tableView.frame.height))
            self.loadMoreFooterView!.delegate = self
            self.tableView.addSubview(self.loadMoreFooterView!)
        }

        loadDataSource(true)
    }
    
    // LoadMoreTableFooterViewDelegate
    func loadMoreTableFooterDidTriggerRefresh(view: LoadMoreTableFooterView) {
//        loadMoreTableViewDataSource()
        self.pageNo++
        loadingMore = true
        loadDataSource(false)
        println("loadMoreTableFooterDidTriggerRefresh")
    }
    
    func loadMoreTableFooterDataSourceIsLoading(view: LoadMoreTableFooterView) -> Bool {
        return loadingMore
    }

    override// UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView!)
    {
        if (loadingMoreShowing) {
            loadMoreFooterView!.loadMoreScrollViewDidScroll(scrollView)
        }
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView!, willDecelerate decelerate: Bool) {
        
        if (loadingMoreShowing) {
            loadMoreFooterView!.loadMoreScrollViewDidEndDragging(scrollView)
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // #pragma mark - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        
        return 1
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        
        return dataSource.count
        
    }
    
    func refreshSource() {
        pageNo = 1
        self.dataSource.removeAllObjects()
        loadDataSource(true)
    }
    
    func loadDataSource(isRefresh : Bool) {
        println("loadDataSource \(isRefresh)")
        self.refreshControl.beginRefreshing()
        var loadURL = NSURL.URLWithString("http://qingbin.sinaapp.com/api/lists?ntype=%E5%9B%BE%E7%89%87&pageNo=\(pageNo)&pagePer=10&list.htm")
        var request = NSURLRequest(URL: loadURL)
        var loadDataSourceQueue = NSOperationQueue();
        
        NSURLConnection.sendAsynchronousRequest(request, queue: loadDataSourceQueue, completionHandler: { response, data, error in
            if (error != nil) {
                println(error)
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshControl.endRefreshing()
                    })
            } else {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                let newsDataSource = json["item"] as NSArray
                
//                var currentNewsDataSource = NSMutableArray()
                for currentNews : AnyObject in newsDataSource {
                    let newsItem = XHNewsItem()
                    newsItem.newsTitle = currentNews["title"] as NSString
                    newsItem.newsThumb = currentNews["thumb"] as NSString
                    newsItem.newsID = currentNews["id"] as NSString
                    self.dataSource.addObject(newsItem)
                    println( newsItem.newsTitle)
                }
                if (self.dataSource.count != self.PAGESIZE) {
                    self.loadingMoreShowing = false
                } else {
                    self.loadingMoreShowing = true
                }
                if (!self.loadingMoreShowing) {
                    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                }
                dispatch_async(dispatch_get_main_queue(), {
 //                   self.dataSource = currentNewsDataSource
                    self.tableView.reloadData()
                    
                    if isRefresh {
                        self.refreshControl.endRefreshing()
                    } else {
                        self.doneLoadingMoreTableViewData()
                    }
                    })
            }
            })
    }
    
    func doneLoadingMoreTableViewData() {
        loadingMore = false
        loadMoreFooterView!.loadMoreScrollViewDataSourceDidFinishedLoading(tableView)
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
//        if !cell {
//            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
//        }
        if(indexPath.row < dataSource.count) {
            var newsItem = dataSource[indexPath.row] as XHNewsItem
            cell.textLabel.text = newsItem.newsTitle
            cell.imageView.image = UIImage(named :"iconpng")
            cell.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        
        
            let request = NSURLRequest(URL :NSURL.URLWithString(newsItem.newsThumb))
            NSURLConnection.sendAsynchronousRequest(request, queue: thumbQueue, completionHandler: { response, data, error in
                if (error != nil) {
                    println(error)
                
                } else {
                    let image = UIImage.init(data :data)
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.imageView.image = image
                    })
                }
            })
        
        }
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
