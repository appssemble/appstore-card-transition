//
//  UIViewController+Extension.swift
//  AppstoreTransition
//
//  Created by Razvan Chelemen on 15/05/2019.
//  Copyright © 2019 appssemble. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {
    
    func presentExpansion(_ viewControllerToPresent: UIViewController, cell: TransitionableCardView, animated flag: Bool, completion: (() -> Void)? = nil) {
        
        present(viewControllerToPresent, animated: true, completion: { [unowned cell] in
            // Unfreeze
            cell.unfreezeAnimations()
        })
    }
    
}


public extension UIViewController {
    func unpackViewController<T: UIViewController>(type: T.Type) -> T? {
        if let typed = self as? T {
            return typed
        }
        if let tabVC = self as? UITabBarController {
            if let typed = tabVC.selectedViewController as? T {
                return typed
            }
            guard let navVC = tabVC.selectedViewController as? UINavigationController else {
                return nil
            }
            if let typed = navVC.visibleViewController as? T {
                return typed
            }
        }
        return nil
    }
}
