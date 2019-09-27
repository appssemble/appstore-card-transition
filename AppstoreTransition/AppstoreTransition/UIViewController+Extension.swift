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
