//
//  MatchesMessagesController.swift
//  Kinder
//
//  Created by Kenny Ho on 11/8/19.
//  Copyright © 2019 Kenny Ho. All rights reserved.
//

import UIKit
import LBTATools

class MatchCell: LBTAListCell<UIColor> {
    
    let profileImageView = UIImageView(image: #imageLiteral(resourceName: "kelly1"), contentMode: .scaleAspectFill)
    let userNameLabel = UILabel(text: "Username Here", font: .systemFont(ofSize: 14, weight: .semibold),textColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), textAlignment: .center, numberOfLines: 2)
    
    override var item: UIColor! {
        didSet {
            backgroundColor = item
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        profileImageView.clipsToBounds = true
        profileImageView.constrainWidth(80)
        profileImageView.constrainHeight(80)
        profileImageView.layer.cornerRadius = 80 / 2
        stack(profileImageView, userNameLabel, alignment: .center)
    }
}

class MatchesMessagesController: LBTAListController<MatchCell, UIColor>, UICollectionViewDelegateFlowLayout {
    let cellId = "cellId"
    
    let customNavBar = MatchesNavBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = [.systemRed, .systemBlue, .systemGreen, .purple, .systemOrange]
        navigationController?.navigationBar.isHidden = true
        
        collectionView.backgroundColor = .white
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        collectionView.contentInset.top = 150
        
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 120, height: 140)
    }
    
}
