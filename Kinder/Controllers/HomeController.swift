//
//  ViewController.swift
//  Kinder
//
//  Created by Kenny Ho on 1/10/19.
//  Copyright © 2019 Kenny Ho. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeController: UIViewController, LoginViewControllerDelegate, SettingsControllerDelegate {
    
    //MARK: - Instance Properties
    let topStackView = TopNavigationStackView()
    let bottomControls = HomeBottomControlsStackView()
    let cardsDeckView = UIView()
    var cardViewModels = [CardViewModel]()
    var user: User?
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        
        setupLayout()
        fetchCurrentUser()
        
//        fetchUserFromFirestore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //kick user out when they log out
        if Auth.auth().currentUser == nil {
            let registrationViewController = RegistrationViewController()
            registrationViewController.delegate = self
            let navController = UINavigationController(rootViewController: registrationViewController)
            present(navController, animated: true, completion: nil)
        }
    }
    
    //MARK: - Methods
    func didFinishLoginIn() {
        fetchCurrentUser()
    }
    
    fileprivate let hud = JGProgressHUD(style: .dark)
    fileprivate func fetchCurrentUser() {
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        
        cardsDeckView.subviews.forEach({ $0.removeFromSuperview() })
        Firestore.firestore().fetchCurrentUser { (user, err) in
            if let err = err {
                print("Failed to fetch user:", err)
                self.hud.dismiss()
                return
            }
            
            self.user = user
//            self.fetchSwipes()
            self.fetchUserFromFirestore()
        }
    }
    
    var swipes = [String: Int]()
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipes info for currently logged in user", err)
                return
            }
            
            print("Swipes:", snapshot?.data() ?? "")
            guard let data = snapshot?.data() as? [String: Int] else { return }
            self.swipes = data
            self.fetchUserFromFirestore()
        }
    }
    
    func didSaveSettings() {
        fetchCurrentUser()
    }
    
    @objc func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleRefresh() {
        fetchUserFromFirestore()
    }
    
    var topCardView: CardView?
    
    @objc fileprivate func handleLike() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            self.topCardView?.frame = CGRect(x: 600, y: 0, width: self.topCardView!.frame.width, height: self.topCardView!.frame.height)
            
            let angle = 15 * CGFloat.pi / 180
            self.topCardView?.transform = CGAffineTransform(rotationAngle: angle)
            
        }) { (_) in
            self.topCardView?.removeFromSuperview()
            self.topCardView = self.topCardView?.nextCardView
        }
    }
    
    var lastFetchUser: User?

    fileprivate func fetchUserFromFirestore() {
        let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
        let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
        
        //Pagination. Fetch 2 users at a time vs whole list
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        query.getDocuments { (snapshot, err) in
            self.hud.dismiss()
            if let err = err {
                print("Failed to fetch user", err)
                return
            }
            
            //Setup nextCardView relationship. This is called Linked List
            var previousCardView: CardView?
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                if user.uid != Auth.auth().currentUser?.uid {
                    let cardView = self.setupCardFromUser(user: user)
                    
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            })
            
        }
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
    private func setupLayout() {
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControls])
        overallStackView.distribution = .fill
        overallStackView.axis = .vertical
        
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
}

//MARK: - CardView Delegate
extension HomeController: CardViewDelegate {
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        print("HomeController:", cardViewModel.attributedString)
        let userDetailsController = UserDetailsController()
        userDetailsController.cardViewModel = cardViewModel
        present(userDetailsController, animated: true, completion: nil)
    }
    
    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
}

