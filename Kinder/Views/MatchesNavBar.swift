//
//  MatchesNavBar.swift
//  Kinder
//
//  Created by Kenny Ho on 11/8/19.
//  Copyright © 2019 Kenny Ho. All rights reserved.
//

import UIKit
import LBTATools

class MatchesNavBar: UIView {
    
    let backButton = UIButton(image: #imageLiteral(resourceName: "app_icon"), tintColor: .lightGray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let iconImageView = UIImageView(image: #imageLiteral(resourceName: "top_messages_icon").withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        iconImageView.tintColor = #colorLiteral(red: 1, green: 0.3378824735, blue: 0.5011497205, alpha: 1)
        let messageLabel = UILabel(text: "Messages", font: .boldSystemFont(ofSize:20), textColor: #colorLiteral(red: 1, green: 0.3378824735, blue: 0.5011497205, alpha: 1), textAlignment: .center)
        let feedLabel = UILabel(text: "Feed", font: .boldSystemFont(ofSize:20), textColor: .gray, textAlignment: .center)
        
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        stack(iconImageView.withHeight(44),
              hstack(messageLabel,feedLabel, distribution: .fillEqually)).padTop(10)
        
        
        addSubview(backButton)
        backButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 34, height: 34)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
