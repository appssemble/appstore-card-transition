//
//  PresentCardAnimator.swift
//  Kickster
//
//  Created by Razvan Chelemen on 06/05/2019.
//  Copyright © 2019 appssemble. All rights reserved.
//

import UIKit

final class PresentCardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let params: Params
    
    struct Params {
        let fromCardFrame: CGRect
        let fromCell: TransitionableCardView
        let settings: TransitionSettings
    }
    
    private let presentAnimationDuration: TimeInterval
    private let springAnimator: UIViewPropertyAnimator
    private var transitionDriver: PresentCardTransitionDriver?
    
    init(params: Params) {
        self.params = params
        self.springAnimator = PresentCardAnimator.createBaseSpringAnimator(params: params)
        self.presentAnimationDuration = springAnimator.duration
        super.init()
    }
    
    private static func createBaseSpringAnimator(params: PresentCardAnimator.Params) -> UIViewPropertyAnimator {
        // Damping between 0.7 (far away) and 1.0 (nearer)
        let cardPositionY = params.fromCardFrame.minY
        let distanceToBounce = abs(params.fromCardFrame.minY)
        let extentToBounce = cardPositionY < 0 ? params.fromCardFrame.height : UIScreen.main.bounds.height
        let dampFactorInterval: CGFloat = 0.3
        let damping: CGFloat = 1.0 - dampFactorInterval * (distanceToBounce / extentToBounce)
        
        // Duration between 0.5 (nearer) and 0.9 (nearer)
        let baselineDuration: TimeInterval = 0.5
        let maxDuration: TimeInterval = 0.9
        let duration: TimeInterval = baselineDuration + (maxDuration - baselineDuration) * TimeInterval(max(0, distanceToBounce)/UIScreen.main.bounds.height)
        
        let springTiming = UISpringTimingParameters(dampingRatio: damping, initialVelocity: .init(dx: 0, dy: 0))
        return UIViewPropertyAnimator(duration: duration, timingParameters: springTiming)
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        // 1.
        return presentAnimationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 2.
        transitionDriver = PresentCardTransitionDriver(params: params,
                                                       transitionContext: transitionContext,
                                                       baseAnimator: springAnimator)
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        // 4.
        transitionDriver = nil
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        // 3.
        return transitionDriver!.animator
    }
}

final class PresentCardTransitionDriver {
    let animator: UIViewPropertyAnimator
    init(params: PresentCardAnimator.Params, transitionContext: UIViewControllerContextTransitioning, baseAnimator: UIViewPropertyAnimator) {
        let ctx = transitionContext
        let container = ctx.containerView
        let screens: (home: CardsViewController, cardDetail: CardDetailViewController) = (
            ctx.viewController(forKey: .from)! as! CardsViewController,
            ctx.viewController(forKey: .to)! as! CardDetailViewController
        )
        
        let cardDetailView = ctx.view(forKey: .to)!
        cardDetailView.backgroundColor = .clear
        let fromCardFrame = params.fromCardFrame
        
        // Temporary container view for animation
        let animatedContainerView = UIView()
        animatedContainerView.translatesAutoresizingMaskIntoConstraints = false
        if params.settings.isEnabledDebugAnimatingViews {
            animatedContainerView.layer.borderColor = UIColor.yellow.cgColor
            animatedContainerView.layer.borderWidth = 4
            cardDetailView.layer.borderColor = UIColor.red.cgColor
            cardDetailView.layer.borderWidth = 2
        }
        container.addSubview(animatedContainerView)
        
        do /* Fix centerX/width/height of animated container to container */ {
            let animatedContainerConstraints = [
                animatedContainerView.widthAnchor.constraint(equalToConstant: container.bounds.width - (params.settings.cardContainerInsets.left + params.settings.cardContainerInsets.right)),
                animatedContainerView.heightAnchor.constraint(equalToConstant: container.bounds.height - (params.settings.cardContainerInsets.top + params.settings.cardContainerInsets.bottom)),
                animatedContainerView.leftAnchor.constraint(equalTo: container.leftAnchor, constant: params.settings.cardContainerInsets.left),
                animatedContainerView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -params.settings.cardContainerInsets.right)
            ]
            NSLayoutConstraint.activate(animatedContainerConstraints)
        }
        
        let animatedContainerVerticalConstraint: NSLayoutConstraint = {
            switch params.settings.cardVerticalExpandingStyle {
            case .fromCenter:
                return animatedContainerView.centerYAnchor.constraint(
                    equalTo: container.centerYAnchor,
                    constant: (fromCardFrame.height/2 + fromCardFrame.minY) - container.bounds.height/2
                )
            case .fromTop:
                return animatedContainerView.topAnchor.constraint(equalTo: container.topAnchor, constant: fromCardFrame.minY + params.settings.cardContainerInsets.top)
            }
            
        }()
        animatedContainerVerticalConstraint.isActive = true
        
        animatedContainerView.addSubview(cardDetailView)
        cardDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        let weirdCardToAnimatedContainerTopAnchor: NSLayoutConstraint
        
        // Pin top (or center Y) and center X of the card, in animated container view
        let verticalAnchor: NSLayoutConstraint = {
            switch params.settings.cardVerticalExpandingStyle {
            case .fromCenter:
                return cardDetailView.centerYAnchor.constraint(equalTo: animatedContainerView.centerYAnchor)
            case .fromTop:
                // WTF: SUPER WEIRD BUG HERE.
                // I should set this constant to 0 (or nil), to make cardDetailView sticks to the animatedContainerView's top.
                // BUT, I can't set constant to 0, or any value in range (-1,1) here, or there will be abrupt top space inset while animating.
                // Funny how -1 and 1 work! WTF. You can try set it to 0.
                return cardDetailView.topAnchor.constraint(equalTo: animatedContainerView.topAnchor, constant: -1)
            }
        }()
        
        let cardLeftConstraint = cardDetailView.leftAnchor.constraint(equalTo: animatedContainerView.leftAnchor, constant: 0)
        let cardRightConstraint = cardDetailView.rightAnchor.constraint(equalTo: animatedContainerView.rightAnchor, constant: 0)
        let cardHeightConstraint = cardDetailView.heightAnchor.constraint(equalToConstant: fromCardFrame.height - (params.settings.cardContainerInsets.top + params.settings.cardContainerInsets.bottom))
        
        NSLayoutConstraint.activate([
            verticalAnchor,
            cardHeightConstraint,
            cardLeftConstraint,
            cardRightConstraint
        ])
        
        cardDetailView.layer.cornerRadius = params.settings.cardCornerRadius
        
        // -------------------------------
        // Final preparation
        // -------------------------------
        params.fromCell.cardContentView.isHidden = true
        params.fromCell.isHidden = false
        params.fromCell.resetTransform()
        
        container.layoutIfNeeded()
        
        let topTemporaryFix = screens.cardDetail.cardContentView.topAnchor.constraint(equalTo: cardDetailView.topAnchor, constant: 0)
        topTemporaryFix.isActive = params.settings.isEnabledWeirdTopInsetsFix
        
        // ------------------------------
        // 1. Animate container bouncing up
        // ------------------------------
        func animateContainerBouncingUp() {
            animatedContainerVerticalConstraint.constant = 0
            container.layoutIfNeeded()
        }
        
        // ------------------------------
        // 2. Animate cardDetail filling up the container
        // ------------------------------
        func animateCardDetailViewSizing() {
            screens.cardDetail.didStartPresentAnimationProgress()
            
            cardLeftConstraint.constant = -params.settings.cardContainerInsets.left
            cardRightConstraint.constant = params.settings.cardContainerInsets.right
                        
            cardHeightConstraint.constant = animatedContainerView.bounds.height + (params.settings.cardContainerInsets.top + params.settings.cardContainerInsets.bottom)
            cardDetailView.layer.cornerRadius = 0
            container.layoutIfNeeded()
        }
        
        func completeEverything() {
            // Remove temporary `animatedContainerView`
            animatedContainerView.removeConstraints(animatedContainerView.constraints)
            animatedContainerView.removeFromSuperview()
            
            // Re-add to the top
            container.addSubview(cardDetailView)
            
            cardDetailView.removeConstraints([topTemporaryFix, cardLeftConstraint, cardRightConstraint, cardHeightConstraint])
            
            // Keep -1 to be consistent with the weird bug above.
            cardDetailView.edges(to: container, top: -1)
            
            // No longer need the bottom constraint that pins bottom of card content to its root.
            //screens.cardDetail.cardBottomToRootBottomConstraint.isActive = false
            screens.cardDetail.scrollView.isScrollEnabled = true
            
            let success = !ctx.transitionWasCancelled
            ctx.completeTransition(success)
            
            screens.cardDetail.didFinishPresentAnimationProgress()
        }
        
        baseAnimator.addAnimations {
            
            // Spring animation for bouncing up
            animateContainerBouncingUp()
            
            // Linear animation for expansion
            let cardExpanding = UIViewPropertyAnimator(duration: baseAnimator.duration * 0.6, curve: .easeOut) {
                animateCardDetailViewSizing()
            }
            cardExpanding.startAnimation()
        }
        
        baseAnimator.addCompletion { (_) in
            completeEverything()
        }
        
        self.animator = baseAnimator
    }
}
