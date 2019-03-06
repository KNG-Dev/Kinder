//
//  MatchView.swift
//  Kinder
//
//  Created by Kenny Ho on 3/6/19.
//  Copyright © 2019 Kenny Ho. All rights reserved.
//

import UIKit
import Firebase

class MatchView: UIView {

    var currentUser: User! {
        didSet {
        }
    }
    
    var cardUID: String! {
        didSet {
            //either fetch current user if we have it
            
            //fetch cardUID information from Firestore
            let query = Firestore.firestore().collection("users")
            query.document(cardUID).getDocument { (snapshot, err) in
                if let err = err {
                    print("Failed to fetch card user:", err)
                    return
                }
                
                guard let dictionary = snapshot?.data() else { return }
                let user = User(dictionary: dictionary)
                guard let url = URL(string: user.imageUrl1 ?? "") else { return }
                
                self.cardUserImageView.sd_setImage(with: url, completed: nil)
                
                guard let currentUserImageUrl = URL(string: self.currentUser.imageUrl1 ?? "") else { return }
                self.currentUserImageView.sd_setImage(with: currentUserImageUrl, completed: { (_, _, _, _) in
                    self.setupAnimations()
                })
            }
        }
    }
    
    fileprivate let itsAMatchImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "itsamatch"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    fileprivate let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "You match with X, you liked\neach other"
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    let currentUserImageView = createImageView(image: #imageLiteral(resourceName: "kelly1"))
    let cardUserImageView = createImageView(image: #imageLiteral(resourceName: "jane2"))
    
    static func createImageView(image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 140 / 2
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        return imageView
    }
    
    fileprivate let sendMessageButton: UIButton = {
        let button = SendMessageButton(type: .system)
        button.setTitle("SEND MESSAGE", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    fileprivate let keepSwipingButton: UIButton = {
        let button = KeepSwipingButton(type: .system)
        button.setTitle("Keep Swiping", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlurView()
        setupLayout()
//        setupAnimations()
    }
    
    fileprivate func setupBlurView() {
        
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        
        addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        visualEffectView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.visualEffectView.alpha = 1
        }) { (_) in
            
        }
    }
    
    lazy var views = [
        self.itsAMatchImageView,
        self.descriptionLabel,
        self.currentUserImageView,
        self.cardUserImageView,
        self.sendMessageButton,
        self.keepSwipingButton
    ]
    
    fileprivate func setupLayout() {
        views.forEach { (v) in
            addSubview(v)
            v.alpha = 0
        }
        
        let imageWidth: CGFloat = 140
        
        itsAMatchImageView.anchors(top: nil, leading: nil, bottom: descriptionLabel.topAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 16, right: 0), size: .init(width: 300, height: 80))
        itsAMatchImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        descriptionLabel.anchors(top: nil, leading: leadingAnchor, bottom: currentUserImageView.topAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 32, right: 0), size: .init(width: 0, height: 50))
        
        currentUserImageView.anchors(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 16), size: .init(width: imageWidth, height: imageWidth))
        currentUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        cardUserImageView.anchors(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: .init(width: imageWidth, height: imageWidth))
        cardUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        sendMessageButton.anchors(top: cardUserImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 32, left: 48, bottom: 0, right: 48), size: .init(width: 0, height: 60))
        keepSwipingButton.anchors(top: sendMessageButton.bottomAnchor, leading: sendMessageButton.leadingAnchor, bottom: nil, trailing: sendMessageButton.trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 60))
    }
    
    fileprivate func setupAnimations() {
        views.forEach({$0.alpha = 1})
        
        //start positions
        let angle = 30 * CGFloat.pi / 180
        
        currentUserImageView.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: 200, y: 0))
        cardUserImageView.transform = CGAffineTransform(rotationAngle: -angle).concatenating(CGAffineTransform(translationX: -200, y: 0))
        sendMessageButton.transform = CGAffineTransform(translationX: -500, y: 0)
        keepSwipingButton.transform = CGAffineTransform(translationX: 500, y: 0)
        
        //Keyframe Animations for segmented animations
        UIView.animateKeyframes(withDuration: 1.3, delay: 0, options: .calculationModeCubic, animations: {
            
            //animation 1: Translation back to original position
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45, animations: {
                self.currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle)
                self.cardUserImageView.transform = CGAffineTransform(rotationAngle: angle)
            })
            
            //animation 2: Rotation
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4, animations: {
                self.currentUserImageView.transform = .identity
                self.cardUserImageView.transform = .identity
                
            })
            
        }) { (_) in
            
        }
        
        UIView.animate(withDuration: 0.75, delay: 0.6 * 1.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            self.sendMessageButton.transform = .identity
            self.keepSwipingButton.transform = .identity
        })
    }
    
    @objc fileprivate func handleTapDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
