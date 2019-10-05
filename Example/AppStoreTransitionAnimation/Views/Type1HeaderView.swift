//
//  Type1HeaderView.swift
//  AppStoreTransitionAnimation
//
//  Created by Razvan Chelemen on 15/05/2019.
//  Copyright © 2019 appssemble. All rights reserved.
//

import UIKit

class Type1HeaderView: UIView {
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var topContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var textWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textWidth.constant = UIScreen.main.bounds.width - 32.0
    }
    
}
