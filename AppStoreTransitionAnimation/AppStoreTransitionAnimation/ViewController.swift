//
//  ViewController.swift
//  AppStoreTransitionAnimation
//
//  Created by Razvan Chelemen on 15/05/2019.
//  Copyright © 2019 appssemble. All rights reserved.
//

import UIKit
import AppstoreTransition

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var transition: CardTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "Type1CollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Type1CollectionViewCell")
        collectionView.register(UINib(nibName: "Type2CollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "Type2CollectionViewCell")
        
        let layout = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
        let aspect: CGFloat = 1.272
        let width = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width:width, height: width * aspect)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
    }

}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        switch indexPath.row {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Type1CollectionViewCell", for: indexPath)
        case 1:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Type2CollectionViewCell", for: indexPath)
        case 2:
            let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Type1CollectionViewCell", for: indexPath) as! Type1CollectionViewCell
            customCell.subtitleLabel.text = "You can dismiss from bottom this one"
            customCell.backgroundImage.image = UIImage(named: "type1-bg-bottom")
            customCell.containerView.backgroundColor = .white
            customCell.reviewsLabel.textColor = UIColor(named: "text-color")
            customCell.commentImageView.tintColor = UIColor(named: "text-color")
            cell = customCell
        case 3:
            let customCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Type2CollectionViewCell", for: indexPath) as! Type2CollectionViewCell
            customCell.subtitleLabel.text = "Bottom dismissible"
            customCell.backgroundImage.image = UIImage(named: "type2-bg-bottom")
            cell = customCell
        default:
            fatalError("Invalid cell")
        }
        
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            showType1(indexPath: indexPath)
        case 1:
            showType2(indexPath: indexPath)
        case 2:
            showType3(indexPath: indexPath, bottomDismiss: true)
        case 3:
            showType4(indexPath: indexPath, bottomDismiss: true)
        default:
            fatalError("Invalid cell")
        }
    }
    
    private func showType1(indexPath: IndexPath, bottomDismiss: Bool = false) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "type1") as! Type1ViewController
        
        if let cell = collectionView.cellForItem(at: indexPath) as? Type1CollectionViewCell {
            cell.bottomContainer.alpha = 0
            
            viewController.dismissAnimationFinishedAction = {
                UIView.animate(withDuration: 0.3, animations: {
                    cell.bottomContainer.alpha = 1.0
                })
            }
        }
        
        // Get tapped cell location
        let cell = collectionView.cellForItem(at: indexPath) as! TransitionableCardView
        
        cell.settings.dismissalScrollViewContentOffset = CGPoint(x: 0, y: 50)
        cell.settings.isEnabledBottomClose = bottomDismiss
        cell.settings.cardContainerInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 0, right: 8.0)
        
        transition = CardTransition(cell: cell, settings: cell.settings)
        viewController.settings = cell.settings
        viewController.transitioningDelegate = transition
        
        // If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        //viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.modalPresentationStyle = .custom
        
        presentExpansion(viewController, cell: cell, animated: true)
    }
    
    private func showType2(indexPath: IndexPath, bottomDismiss: Bool = false) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "type2") as! Type2ViewController
        
        // Get tapped cell location
        let cell = collectionView.cellForItem(at: indexPath) as! TransitionableCardView
        cell.settings.cardContainerInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
        cell.settings.isEnabledBottomClose = bottomDismiss
        
        transition = CardTransition(cell: cell, settings: cell.settings)
        viewController.settings = cell.settings
        viewController.transitioningDelegate = transition
        
        // If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        //viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.modalPresentationStyle = .custom
        
        presentExpansion(viewController, cell: cell, animated: true)
    }
    
    private func showType3(indexPath: IndexPath, bottomDismiss: Bool = false) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "type1") as! Type1ViewController
        
        if let cell = collectionView.cellForItem(at: indexPath) as? Type1CollectionViewCell {
            cell.bottomContainer.alpha = 0
            
            viewController.dismissAnimationFinishedAction = {
                UIView.animate(withDuration: 0.3, animations: {
                    cell.bottomContainer.alpha = 1.0
                })
            }
        }
        
        // Get tapped cell location
        let cell = collectionView.cellForItem(at: indexPath) as! TransitionableCardView
        
        cell.settings.dismissalScrollViewContentOffset = CGPoint(x: 0, y: 50)
        cell.settings.isEnabledBottomClose = bottomDismiss
        cell.settings.cardContainerInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 0, right: 8.0)
        
        transition = CardTransition(cell: cell, settings: cell.settings)
        viewController.settings = cell.settings
        viewController.transitioningDelegate = transition
        viewController.subtitle = "You can dismiss from bottom this one"
        viewController.backgroundImage = UIImage(named: "type1-bg-bottom")
        viewController.backgroundColor = .white
        
        // If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        //viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.modalPresentationStyle = .custom
        
        presentExpansion(viewController, cell: cell, animated: true)
    }
    
    private func showType4(indexPath: IndexPath, bottomDismiss: Bool = false) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "type2") as! Type2ViewController
        
        // Get tapped cell location
        let cell = collectionView.cellForItem(at: indexPath) as! TransitionableCardView
        cell.settings.cardContainerInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
        cell.settings.isEnabledBottomClose = bottomDismiss
        
        transition = CardTransition(cell: cell, settings: cell.settings)
        viewController.settings = cell.settings
        viewController.transitioningDelegate = transition
        viewController.subtitle = "Bottom dismissible"
        viewController.background = UIImage(named: "type2-bg-bottom")
        
        // If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        //viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.modalPresentationStyle = .custom
        
        presentExpansion(viewController, cell: cell, animated: true)
    }
    
}

extension ViewController: CardsViewController {
    
}
