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
        
        navigationController?.navigationBar.isHidden = true
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        topStackView.messageButton.addTarget(self, action: #selector(handleMessages), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        
        setupLayout()
        fetchCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //kick user out when they log out
        if Auth.auth().currentUser == nil {
            let registrationViewController = RegistrationViewController()
            registrationViewController.delegate = self
            let navController = UINavigationController(rootViewController: registrationViewController)
            navController.modalPresentationStyle = .fullScreen
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
            self.fetchSwipes()
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
            
            self.fetchUserFromFirestore()
            print("Swipes:", snapshot?.data() ?? "")
            guard let data = snapshot?.data() as? [String: Int] else { return }
            self.swipes = data
            
        }
    }
    
    func didSaveSettings() {
        fetchCurrentUser()
    }
    
    @objc func handleMessages() {
        let vc = MatchesMessagesController()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleRefresh() {
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        fetchUserFromFirestore()
    }
    
    var topCardView: CardView?
    
    @objc func handleLike() {
        saveSwipeToFirestore(didLike: 1)
        performSwipeAnimation(translation: 700, angle: 15)
    }
    
    @objc func handleDislike() {
        saveSwipeToFirestore(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -15)
    }
    
    fileprivate func saveSwipeToFirestore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid, let cardUID = topCardView?.cardViewModel.uid else { return }
        
    
        let documentData = [cardUID: didLike]
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipe document:", err)
                return
            }
            
            if snapshot?.exists == true {
                //Append save to saved list
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (err) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    
                    print("Successfully updated swipe...")
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            } else {
                //Save
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) { (err) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    
                    print("Successfully saved swipe...")
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            }
        }
    }
    
    fileprivate func checkIfMatchExists(cardUID: String) {
        //Detect match between 2 users
        print("Detecting match")
        
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch document for card user:", err)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            print(data)
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                print("has Matched")
                self.presentMatchView(cardUID: cardUID)
            }
        }
    }
    
    fileprivate func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
        view.addSubview(matchView)
        matchView.fillSuperview()
    }
    
    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        
        //Use BasicAnimation because UIView.animate can be buggy when moving multiple views simultaneously
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
            
        }
        //Doesnt matter what forKey you use
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        CATransaction.commit()
    }
    
    var lastFetchUser: User?

    fileprivate func fetchUserFromFirestore() {
        let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
        let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
        
        //Pagination. Fetch 2 users at a time vs whole list
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        
        //resetting topCardView
        topCardView = nil
        
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
                let isNotCurrentUser =  user.uid != Auth.auth().currentUser?.uid
//                let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                let hasNotSwipedBefore = true
                if isNotCurrentUser && hasNotSwipedBefore {
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
    func didSwipeDirection(direction: Bool) {
        if direction == true {
            handleLike()
        } else {
            handleDislike()
        }
    }
   
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

