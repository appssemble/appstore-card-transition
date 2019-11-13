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
    func unpackViewController<Type: UIViewController>() -> Type? {
        if let typed = self as? Type {
            return typed
        }
        if let tabVC = self as? UITabBarController {
            if let typed = tabVC.selectedViewController as? Type {
                return typed
            }
            guard let navVC = tabVC.selectedViewController as? UINavigationController else {
                return nil
            }
            if let typed = navVC.visibleViewController as? Type {
                return typed
            }
        }
        return nil
    }
}
