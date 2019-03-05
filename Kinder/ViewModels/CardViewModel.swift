//
//  CardViewModel.swift
//  Kinder
//
//  Created by Kenny Ho on 1/16/19.
//  Copyright © 2019 Kenny Ho. All rights reserved.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel 
}

class CardViewModel {
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.imageUrls = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    fileprivate var imageIndex = 0 {
        didSet {
            let imageUrl = imageUrls[imageIndex]
//            let image =  UIImage(named: imageName)
            imageIndexObserver?(imageIndex, imageUrl)
            print("Observing index from \(#function) in line \(#line)")
        }
    }
    
    //Reactive Programming
    var imageIndexObserver: ((Int, String?) -> ())?
    
    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageUrls.count - 1)
    }
    
    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
}



