//
//  CardCollectionViewCell.swift
//  Kickster
//
//  Created by Razvan Chelemen on 08/05/2019.
//  Copyright © 2019 appssemble. All rights reserved.
//

import UIKit

private struct AssociatedKeys {
    static var settingsKey: UInt8 = 0
    static var disabledHighlightedAnimationKey: UInt8 = 0
}

public protocol CardCollectionViewCell: UICollectionViewCell {
    var cardContentView: UIView { get }
    var disabledHighlightedAnimation: Bool { get set }
    var settings: TransitionSettings { get }
    
    func resetTransform()
    func freezeAnimations()
    func unfreezeAnimations()
    
}

public extension CardCollectionViewCell {
    
    var disabledHighlightedAnimation:Bool {
        get {
            if let disabledHighlight = objc_getAssociatedObject(self, &AssociatedKeys.disabledHighlightedAnimationKey) as? Bool {
                return disabledHighlight
            } else {
                self.disabledHighlightedAnimation = false
                return disabledHighlightedAnimation
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.disabledHighlightedAnimationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var settings:TransitionSettings {
        get {
            if let settings = objc_getAssociatedObject(self, &AssociatedKeys.settingsKey) as? TransitionSettings {
                return settings
            } else {
                self.settings = TransitionSettings()
                return settings
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.settingsKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
 
    func resetTransform() {
        transform = .identity
    }
    
    func freezeAnimations() {
        disabledHighlightedAnimation = true
        layer.removeAllAnimations()
    }
    
    func unfreezeAnimations() {
        disabledHighlightedAnimation = false
    }
    
    func animate(isHighlighted: Bool, completion: ((Bool) -> Void)?=nil) {
        if disabledHighlightedAnimation {
            return
        }
        let animationOptions: UIView.AnimationOptions = settings.isEnabledAllowsUserInteractionWhileHighlightingCard
            ? [.allowUserInteraction] : []
        if isHighlighted {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions, animations: {
                            self.transform = .init(scaleX: self.settings.cardHighlightedFactor, y: self.settings.cardHighlightedFactor)
            }, completion: completion)
        } else {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                           options: animationOptions, animations: {
                            self.transform = .identity
            }, completion: completion)
        }
    }
    
}

