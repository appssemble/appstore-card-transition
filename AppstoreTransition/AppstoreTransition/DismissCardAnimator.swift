
//
//  DismissCardAnimator.swift
//  Kickster
//
//  Created by Razvan Chelemen on 06/05/2019.
//  Copyright © 2019 appssemble. All rights reserved.
//

import UIKit

final class DismissCardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    struct Params {
        let fromCardFrame: CGRect
        let fromCardFrameWithoutTransform: CGRect
        let fromCell: TransitionableCardView
        let settings: TransitionSettings
    }
    
    struct Constants {
        static let relativeDurationBeforeNonInteractive: TimeInterval = 0.5
        static let minimumScaleBeforeNonInteractive: CGFloat = 0.8
    }
    
    private let params: Params
    
    init(params: Params) {
        self.params = params
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return params.settings.dismissalAnimationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let ctx = transitionContext
        let container = ctx.containerView
        let rawVC = ctx.viewController(forKey: .to)
        let toViewController = rawVC.unpackViewController() as! CardsViewController
        
        let screens: (cardDetail: CardDetailViewController, home: CardsViewController) = (
            ctx.viewController(forKey: .from)! as! CardDetailViewController,
            toViewController
        )
        
        // Sometimes they could pop up when the view shrinks
        screens.cardDetail.scrollView.showsVerticalScrollIndicator = false
        screens.cardDetail.scrollView.showsHorizontalScrollIndicator = false
        
        let cardDetailView = ctx.view(forKey: .from)!
        
        let animatedShadowContainerView = UIView()
        animatedShadowContainerView.backgroundColor = .clear
        animatedShadowContainerView.layer.applyShadow(from: params.fromCell.cardContentView.layer)
        
        let animatedContainerView = UIView()
        animatedContainerView.backgroundColor = .clear
        if params.settings.isEnabledDebugAnimatingViews {
            animatedContainerView.layer.borderColor = UIColor.yellow.cgColor
            animatedContainerView.layer.borderWidth = 4
            cardDetailView.layer.borderColor = UIColor.red.cgColor
            cardDetailView.layer.borderWidth = 2
            animatedShadowContainerView.layer.borderWidth = 3
            animatedShadowContainerView.layer.borderColor = UIColor.purple.cgColor
        }
        animatedShadowContainerView.translatesAutoresizingMaskIntoConstraints = false
        animatedContainerView.translatesAutoresizingMaskIntoConstraints = false
        cardDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        container.removeConstraints(container.constraints)
        
        container.addSubview(animatedShadowContainerView)
        animatedShadowContainerView.addSubview(animatedContainerView)
        animatedContainerView.addSubview(cardDetailView)
        
        // Card fills inside animated container view
        animatedContainerView.edges(to: animatedShadowContainerView)
        cardDetailView.edges(to: animatedContainerView)
                
        let animatedContainerLeftConstraint = animatedShadowContainerView.leftAnchor.constraint(equalTo: container.leftAnchor)
        let animatedContainerTopConstraint = animatedShadowContainerView.topAnchor.constraint(equalTo: container.topAnchor, constant: params.settings.cardContainerInsets.top)
        let animatedContainerWidthConstraint = animatedShadowContainerView.widthAnchor.constraint(equalToConstant: cardDetailView.frame.width)
        let animatedContainerHeightConstraint = animatedShadowContainerView.heightAnchor.constraint(equalToConstant: cardDetailView.frame.height)
        
        NSLayoutConstraint.activate([animatedContainerTopConstraint, animatedContainerWidthConstraint, animatedContainerHeightConstraint, animatedContainerLeftConstraint])
        
        container.layoutIfNeeded()
        
        // Fix weird top inset
        let topTemporaryFix = screens.cardDetail.cardContentView.topAnchor.constraint(equalTo: cardDetailView.topAnchor)
        topTemporaryFix.isActive = params.settings.isEnabledWeirdTopInsetsFix
        
        // Force card filling bottom
        let stretchCardToFillBottom = screens.cardDetail.cardContentView.bottomAnchor.constraint(equalTo: cardDetailView.bottomAnchor)
        // for tableview header required confilcts with autoresizing mask constraints
        stretchCardToFillBottom.priority = .required
        
        func animateCardViewBackToPlace() {
            stretchCardToFillBottom.isActive = true
            //screens.cardDetail.isFontStateHighlighted = false
            // Back to identity
            // NOTE: Animated container view in a way, helps us to not messing up `transform` with `AutoLayout` animation.
            cardDetailView.transform = CGAffineTransform.identity
            animatedContainerLeftConstraint.constant = self.params.fromCardFrameWithoutTransform.minX + params.settings.cardContainerInsets.left
            animatedContainerTopConstraint.constant = self.params.fromCardFrameWithoutTransform.minY + params.settings.cardContainerInsets.top
            animatedContainerWidthConstraint.constant = self.params.fromCardFrameWithoutTransform.width - (params.settings.cardContainerInsets.left + params.settings.cardContainerInsets.right)
            animatedContainerHeightConstraint.constant = self.params.fromCardFrameWithoutTransform.height - (params.settings.cardContainerInsets.top + params.settings.cardContainerInsets.bottom)
            container.layoutIfNeeded()
        }
        
        func completeEverything() {
            let success = !ctx.transitionWasCancelled
            
            animatedShadowContainerView.removeConstraints(animatedShadowContainerView.constraints)
            animatedShadowContainerView.removeFromSuperview()
            animatedContainerView.removeConstraints(animatedContainerView.constraints)
            animatedContainerView.removeFromSuperview()

            if success {
                cardDetailView.removeFromSuperview()
                self.params.fromCell.cardContentView.isHidden = false
            } else {
                //screens.cardDetail.isFontStateHighlighted = true
                
                // Remove temporary fixes if not success!
                topTemporaryFix.isActive = false
                stretchCardToFillBottom.isActive = false
                
                cardDetailView.removeConstraint(topTemporaryFix)
                cardDetailView.removeConstraint(stretchCardToFillBottom)
                
                container.removeConstraints(container.constraints)
                
                container.addSubview(cardDetailView)
                cardDetailView.edges(to: container)
            }
            ctx.completeTransition(success)
        }
        
        // Give gentle feedback at the point in time were the transition "snaps"
        // The .light feedback that would work on prior versions seems a little too much.
        if #available(iOS 13.0, *) {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
        }
        
        UIView.animate(withDuration: transitionDuration(using: ctx), delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            animateCardViewBackToPlace()
        }) { (finished) in
            completeEverything()
        }
        
        screens.cardDetail.scrollView.setContentOffset(.zero, animated: true)
//        
//        UIView.animate(withDuration: transitionDuration(using: ctx) * 0.4) {
//            //print("godam")
//            //screens.cardDetail.scrollView.setContentOffset(self.params.settings.dismissalScrollViewContentOffset, animated: true)
//            screens.cardDetail.scrollView.contentOffset = self.params.settings.dismissalScrollViewContentOffset
//        }
    }
}
