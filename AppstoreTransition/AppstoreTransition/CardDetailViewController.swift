//
//  CardDetailViewController.swift
//  Kickster
//
//  Created by Razvan Chelemen on 08/05/2019.
//  Copyright © 2019 appssemble. All rights reserved.
//

import UIKit

private struct AssociatedKeys {
    static var settingsKey: UInt8 = 0
    static var dismissHandlerKey: UInt8 = 0
}

public protocol CardsViewController {
    
}

public protocol CardDetailViewController: UIViewController {
    var cardContentView: UIView { get }
    var scrollView: UIScrollView { get }
    var settings: TransitionSettings { get set }
    var dismissHandler: CardDismissHandler { get }
    
    func didStartPresentAnimationProgress()
    func didFinishPresentAnimationProgress()
    
    func didBeginDismissAnimation()
    func didChangeDismissAnimationProgress(progress:CGFloat)
    func didStartDismissAnimation()
    func didFinishDismissAnimation()
    func didCancelDismissAnimation(progress:CGFloat)
}

public extension CardDetailViewController {
    
    var dismissHandler:CardDismissHandler {
        get {
            if let settings = objc_getAssociatedObject(self, &AssociatedKeys.dismissHandlerKey) as? CardDismissHandler {
                return settings
            } else {
                self.dismissHandler = CardDismissHandler(source: self)
                return dismissHandler
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.dismissHandlerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
    
    var dismissEnabled: Bool {
        get {
            return dismissHandler.dismissalPanGesture.isEnabled
        }
        
        set {
            dismissHandler.dismissalPanGesture.isEnabled = newValue
            dismissHandler.dismissalScreenEdgePanGesture.isEnabled = newValue
        }
    }
    
    func didStartPresentAnimationProgress() {}
    func didFinishPresentAnimationProgress() {}
    
    func didBeginDismissAnimation() {}
    func didChangeDismissAnimationProgress(progress:CGFloat) {}
    func didStartDismissAnimation() {}
    func didFinishDismissAnimation() {}
    func didCancelDismissAnimation(progress:CGFloat) {}
    
}

public final class CardDismissHandler: NSObject {
    
    final class DismissalPanGesture: UIPanGestureRecognizer {}
    final class DismissalScreenEdgePanGesture: UIScreenEdgePanGestureRecognizer {}
    
    lazy var dismissalPanGesture: DismissalPanGesture = {
        let pan = DismissalPanGesture()
        pan.maximumNumberOfTouches = 1
        return pan
    }()
    
    lazy var dismissalScreenEdgePanGesture: DismissalScreenEdgePanGesture = {
        let pan = DismissalScreenEdgePanGesture()
        pan.edges = .left
        return pan
    }()
    
    var interactiveStartingPoint: CGPoint?
    var dismissalAnimator: UIViewPropertyAnimator?
    var draggingDownToDismiss = false
    
    private let source: CardDetailViewController
    
    init(source: CardDetailViewController) {
        // We require source object in case we need access some properties etc.
        self.source = source
        
        super.init()
        
        dismissalPanGesture.addTarget(self, action: #selector(handleDismissalPan(gesture:)))
        dismissalPanGesture.delegate = self
        
        dismissalScreenEdgePanGesture.addTarget(self, action: #selector(handleDismissalPan(gesture:)))
        dismissalScreenEdgePanGesture.delegate = self
        
        // Make drag down/scroll pan gesture waits til screen edge pan to fail first to begin
        dismissalPanGesture.require(toFail: dismissalScreenEdgePanGesture)
        source.scrollView.panGestureRecognizer.require(toFail: dismissalScreenEdgePanGesture)
        
        source.loadViewIfNeeded()
        source.view.addGestureRecognizer(dismissalPanGesture)
        source.view.addGestureRecognizer(dismissalScreenEdgePanGesture)
        
        checkScrolling(scrollView: source.scrollView)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkScrolling(scrollView: scrollView)
    }
    
    private var dismissTop = true
    private var lastContentOffset: CGFloat = 0
    
    // This handles both screen edge and dragdown pan. As screen edge pan is a subclass of pan gesture, this input param works.
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        
        let velocity = gesture.velocity(in: source.view)
        //if velocity.y > 0 { return }
        
        let isScreenEdgePan = gesture.isKind(of: DismissalScreenEdgePanGesture.self)
        let canStartDragDownToDismissPan = !isScreenEdgePan && !draggingDownToDismiss
        
        // Don't do anything when it's not in the drag down mode
        if canStartDragDownToDismissPan { return }
        
        let targetAnimatedView = gesture.view!
        let startingPoint: CGPoint
        
        if let p = interactiveStartingPoint {
            startingPoint = p
        } else {
            // Initial location
            startingPoint = gesture.location(in: nil)
            interactiveStartingPoint = startingPoint
        }
        
        let currentLocation = gesture.location(in: nil)
        
        let progress: CGFloat
        if (dismissTop) {
            progress = isScreenEdgePan ? (gesture.translation(in: targetAnimatedView).x / 100) : (currentLocation.y - startingPoint.y) / 100
        } else {
            progress = isScreenEdgePan ? (gesture.translation(in: targetAnimatedView).x / 100) : (startingPoint.y - currentLocation.y) / 100
        }
        
        let targetShrinkScale: CGFloat = 0.86
        let targetCornerRadius: CGFloat = source.settings.cardCornerRadius
        
        func createInteractiveDismissalAnimatorIfNeeded() -> UIViewPropertyAnimator {
            if let animator = dismissalAnimator {
                return animator
            } else {
                let animator = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: {
                    targetAnimatedView.transform = .init(scaleX: targetShrinkScale, y: targetShrinkScale)
                    targetAnimatedView.layer.cornerRadius = targetCornerRadius
                })
                animator.isReversed = false
                animator.pauseAnimation()
                animator.fractionComplete = progress
                return animator
            }
        }
        
        switch gesture.state {
        case .began:
            
            if (source.scrollView.contentOffset.y <= 0) {
                dismissTop = true
            } else if (source.scrollView.contentOffset.y >= source.scrollView.contentSize.height - source.scrollView.frame.height && source.settings.isEnabledBottomClose) {
                dismissTop = false
            }
            
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded()
            source.didBeginDismissAnimation()
        case .changed:
            dismissalAnimator = createInteractiveDismissalAnimatorIfNeeded()
            
            let actualProgress = progress
            let isDismissalSuccess = actualProgress >= 1.0
            
            dismissalAnimator!.fractionComplete = actualProgress
            if progress >= 0 && progress <= 1 && dismissTop {
                source.scrollView.contentOffset = CGPoint(x: 0, y: 100 * max(progress, 0))
            }
            source.didChangeDismissAnimationProgress(progress: progress)
            
            if isDismissalSuccess {
                dismissalAnimator!.stopAnimation(false)
                dismissalAnimator!.addCompletion { [unowned self] (pos) in
                    switch pos {
                    case .end:
                        self.didSuccessfullyDragDownToDismiss()
                    default:
                        fatalError("Must finish dismissal at end!")
                    }
                }
                dismissalAnimator!.finishAnimation(at: .end)
            }
            
        case .ended, .cancelled:
            if dismissalAnimator == nil {
                // Gesture's too quick that it doesn't have dismissalAnimator!
                print("Too quick there's no animator!")
                didCancelDismissalTransition()
                return
            }
            // NOTE:
            // If user lift fingers -> ended
            // If gesture.isEnabled -> cancelled
            
            // Ended, Animate back to start
            dismissalAnimator!.pauseAnimation()
            dismissalAnimator!.isReversed = true
            
            source.didCancelDismissAnimation(progress: progress)
            // Disable gesture until reverse closing animation finishes.
            gesture.isEnabled = false
            dismissalAnimator!.addCompletion { [unowned self] (pos) in
                self.didCancelDismissalTransition()
                gesture.isEnabled = true
                
                //if (!self.dismissTop && self.lastContentOffset < self.source.scrollView.contentOffset.y) {
                //self.source.scrollView.setContentOffset(CGPoint(x: 0, y: self.source.scrollView.contentSize.height - self.source.scrollView.bounds.size.height + self.source.scrollView.contentInset.bottom), animated: true)
                //}
            }
            dismissalAnimator!.startAnimation()
        default:
            fatalError("Impossible gesture state? \(gesture.state.rawValue)")
        }
        
        do {
            self.lastContentOffset = source.scrollView.contentOffset.y
        }
        
        source.scrollView.bounces = source.scrollView.contentOffset.y > 100
    }
    
    func didSuccessfullyDragDownToDismiss() {
        //cardViewModel = unhighlightedCardViewModel
        //source.dismiss(animated: true)
        self.source.didStartDismissAnimation()
        source.dismiss(animated: true) {
            self.source.didFinishDismissAnimation()
        }
    }
    
    func didCancelDismissalTransition() {
        // Clean up
        interactiveStartingPoint = nil
        dismissalAnimator = nil
        draggingDownToDismiss = false
    }
    
    private func checkScrolling(scrollView: UIScrollView) {
        if (shouldDismiss()) {
            draggingDownToDismiss = true
        }
        
        scrollView.showsVerticalScrollIndicator = !draggingDownToDismiss
    }
    
    func shouldDismiss() -> Bool {
        if (source.settings.isEnabledBottomClose) {
            return source.scrollView.contentOffset.y <= 0 || source.scrollView.contentOffset.y >= source.scrollView.contentSize.height - source.scrollView.frame.height
        } else {
            return source.scrollView.contentOffset.y <= 0
        }
    }
    
}

extension CardDismissHandler: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        checkScrolling(scrollView: source.scrollView)
        return shouldDismiss()
    }
}
