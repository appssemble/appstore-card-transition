//
//  Type1CollectionViewCell.swift
//  AppStoreTransitionAnimation
//
//  Created by Razvan Chelemen on 15/05/2019.
//  Copyright © 2019 appssemble. All rights reserved.
//

import UIKit
import AppstoreTransition

class Type1CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var commentImageView: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
    }

    // Make it appears very responsive to touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animate(isHighlighted: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animate(isHighlighted: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animate(isHighlighted: false)
    }
    
}

extension Type1CollectionViewCell: CardCollectionViewCell {    
    
    var cardContentView: UIView {
        get {
            return containerView
        }
    }
    
}
