//
//  CALayerExtension.swift
//  Alamofire
//
//  Created by Frank Lehmann on 17.09.19.
//

import Foundation

extension CALayer {
    func applyShadow(from otherLayer: CALayer) {
        shadowRadius = otherLayer.shadowRadius
        shadowOpacity = otherLayer.shadowOpacity
        shadowColor = otherLayer.shadowColor
        shadowOffset = otherLayer.shadowOffset
        
        shouldRasterize = otherLayer.shouldRasterize
        rasterizationScale = otherLayer.rasterizationScale
    }
}
