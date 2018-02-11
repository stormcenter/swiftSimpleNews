//
//  LoadMoreTableFooterView.swift
//  LoadMoreTableFooterView-for-swift
//
//  Created by zhang on 14-6-18.
//  Copyright (c) 2014 zhang. All rights reserved.
//

import Foundation
import UIKit

let TEXT_COLOR: UIColor = UIColor(red: 87.0 / 255.0, green: 108.0 / 255.0, blue: 137.0 / 255.0, alpha: 1.0)

enum LoadMoreState{
    case LoadMorePulling
    case LoadMoreNormal
    case LoadMoreLoading
}

protocol LoadMoreTableFooterViewDelegate {
    func loadMoreTableFooterDidTriggerRefresh(view: LoadMoreTableFooterView)
    func loadMoreTableFooterDataSourceIsLoading(view: LoadMoreTableFooterView) -> Bool
}

class LoadMoreTableFooterView: UIView {
    var delegate: LoadMoreTableFooterViewDelegate?
    var state: LoadMoreState                        = LoadMoreState.LoadMoreNormal
    var statusLabel: UILabel                        = UILabel()
    var activityView: UIActivityIndicatorView       = UIActivityIndicatorView()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizingMask = UIViewAutoresizing.flexibleWidth
        self.backgroundColor = UIColor.clear
        
        var label: UILabel = UILabel(frame: CGRect(0, 10, self.frame.size.width, 20))
        label.autoresizingMask = UIViewAutoresizing.flexibleWidth
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = TEXT_COLOR
        label.shadowColor = UIColor(white: 0.9, alpha: 1)
        label.shadowOffset = CGSize(0, 1)
        label.backgroundColor = UIColor.clear
        label.textAlignment = NSTextAlignment.center
        self.addSubview(label)
        statusLabel = label
        
        var view: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        view.frame = CGRect(55, 20, 20, 20)
        self.addSubview(view)
        activityView = view
        
        self.isHidden = true
        
        setState(aState: LoadMoreState.LoadMoreNormal)
    }
    
    func setState(aState: LoadMoreState) {
        switch aState {
        case LoadMoreState.LoadMorePulling:
            statusLabel.text = NSLocalizedString("松开加载更多...", comment: "")
            statusLabel.frame = CGRect(0, 20, self.frame.size.width, 20)
        case LoadMoreState.LoadMoreNormal:
            statusLabel.text = NSLocalizedString("上拉加载更多...", comment: "")
            statusLabel.frame = CGRect(0, 10, self.frame.size.width, 20)
            activityView.stopAnimating()
        case LoadMoreState.LoadMoreLoading:
            statusLabel.text = NSLocalizedString("加载中...", comment: "")
            statusLabel.frame = CGRect(0, 20, self.frame.size.width, 20)
            activityView.startAnimating()
        default:
            statusLabel.text = ""
        }
        state = aState
    }

    func loadMoreScrollViewDidScroll(loadScrollView: UIScrollView) {

        if state == LoadMoreState.LoadMoreLoading {
            loadScrollView.contentInset = UIEdgeInsetsMake(loadScrollView.contentInset.top, 0, 60, 0)
        } else if loadScrollView.isDragging {
            var loading: Bool = false
            if delegate != nil {
                loading = delegate!.loadMoreTableFooterDataSourceIsLoading(view: self)
            }
            
            if (state == LoadMoreState.LoadMoreNormal && loadScrollView.contentOffset.y < (loadScrollView.contentSize.height - (loadScrollView.frame.size.height - 60)) && loadScrollView.contentOffset.y > (loadScrollView.contentSize.height - loadScrollView.frame.size.height) && !loading) {

                self.frame = CGRectMake(0, loadScrollView.contentSize.height, self.frame.size.width, self.frame.size.height)
                self.isHidden = false
            } else if (state == LoadMoreState.LoadMoreNormal && loadScrollView.contentOffset.y > (loadScrollView.contentSize.height - (loadScrollView.frame.size.height - 60)) && !loading) {

                setState(aState: LoadMoreState.LoadMorePulling)
            } else if (state == LoadMoreState.LoadMorePulling && loadScrollView.contentOffset.y < (loadScrollView.contentSize.height - (loadScrollView.frame.size.height - 60)) && loadScrollView.contentOffset.y > (loadScrollView.contentSize.height - loadScrollView.frame.size.height) && !loading) {

                setState(aState: LoadMoreState.LoadMoreNormal)
            }
            
            if loadScrollView.contentInset.bottom != 40 {
                loadScrollView.contentInset = UIEdgeInsetsMake(loadScrollView.contentInset.top, 0, 40, 0)
            }
            
            var offset: CGFloat = loadScrollView.contentOffset.y - (loadScrollView.contentSize.height - loadScrollView.frame.size.height) - loadScrollView.contentInset.bottom
            if offset <= 20 && offset >= 0 {
                statusLabel.frame = CGRect(0, 10 + offset / 2, self.frame.size.width, 20)
            }
        }
    }
    
    func loadMoreScrollViewDidEndDragging(loadScrollView: UIScrollView) {
        var loading = false
        if delegate != nil {
            loading = delegate!.loadMoreTableFooterDataSourceIsLoading(view: self)
        }

        if (loadScrollView.contentOffset.y > (loadScrollView.contentSize.height - (loadScrollView.frame.size.height - 60)) && !loading) {
            if delegate != nil {
                delegate!.loadMoreTableFooterDidTriggerRefresh(view: self)
            }
            
            setState(aState: LoadMoreState.LoadMoreLoading)

            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.2)
            loadScrollView.contentInset = UIEdgeInsetsMake(loadScrollView.contentInset.top, 0, 60, 0)
            UIView.commitAnimations()
        }
    }
    
    func loadMoreScrollViewDataSourceDidFinishedLoading(scrollView: UIScrollView) {

        setState(aState: LoadMoreState.LoadMoreNormal)
        self.isHidden = true
    }
}
