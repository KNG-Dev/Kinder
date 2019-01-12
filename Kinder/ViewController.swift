//
//  ViewController.swift
//  Kinder
//
//  Created by Kenny Ho on 1/10/19.
//  Copyright © 2019 Kenny Ho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: - Instance Properties
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let buttonsStackView = HomeBottomControlsStackView()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupDummyCards()
    }
    
    //MARK: - Private Methods
    private func setupDummyCards() {
        print("Setting up dummy cards")
        let cardView = CardView(frame: .zero)
        cardsDeckView.addSubview(cardView)
        cardView.fillSuperview()
    }
    
    private func setupLayout() {
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, buttonsStackView])
        overallStackView.distribution = .fill
        overallStackView.axis = .vertical
        
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
    
    
}

