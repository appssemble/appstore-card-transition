//
//  Type2ViewController.swift
//  AppStoreTransitionAnimation
//
//  Created by Razvan Chelemen on 15/05/2019.
//  Copyright © 2019 appssemble. All rights reserved.
//

import UIKit
import AppstoreTransition

class Type2ViewController: UIViewController {
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.clipsToBounds = true
        contentScrollView.delegate = self
        
        let _ = dismissHandler
    }

}

extension Type2ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissHandler.scrollViewDidScroll(scrollView)
    }
    
}

extension Type2ViewController: CardDetailViewController {
    
    var scrollView: UIScrollView {
        return contentScrollView
    }
    
    
    var cardContentView: UIView {
        return headerView
    }

}
