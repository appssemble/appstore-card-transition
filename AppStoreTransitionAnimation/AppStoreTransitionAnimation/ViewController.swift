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
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        
        if indexPath.row % 3 == 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Type1CollectionViewCell", for: indexPath)
        } else if indexPath.row % 3 == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Type2CollectionViewCell", for: indexPath)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Type1CollectionViewCell", for: indexPath)
        }
        
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row % 3 == 0 {
            showType1(indexPath: indexPath)
        } else if indexPath.row % 3 == 1 {
            showType2(indexPath: indexPath)
        } else {
            showType1(indexPath: indexPath)
        }
    }
    
    private func showType1(indexPath: IndexPath) {
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
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        
        cell.settings.dismissalScrollViewContentOffset = CGPoint(x: 0, y: 50)
        
        transition = CardTransition(cell: cell, settings: cell.settings)
        viewController.settings = cell.settings
        viewController.transitioningDelegate = transition
        
        // If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        //viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.modalPresentationStyle = .custom
        
        presentExpansion(viewController, cell: cell, animated: true)
    }
    
    private func showType2(indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "type2") as! Type2ViewController
        
        // Get tapped cell location
        let cell = collectionView.cellForItem(at: indexPath) as! CardCollectionViewCell
        cell.settings.cardContainerInsets = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
        
        transition = CardTransition(cell: cell, settings: cell.settings)
        viewController.settings = cell.settings
        viewController.transitioningDelegate = transition
        
        // If `modalPresentationStyle` is not `.fullScreen`, this should be set to true to make status bar depends on presented vc.
        //viewController.modalPresentationCapturesStatusBarAppearance = true
        viewController.modalPresentationStyle = .custom
        
        presentExpansion(viewController, cell: cell, animated: true)
    }
    
}

extension ViewController: CardsViewController {
    
}
