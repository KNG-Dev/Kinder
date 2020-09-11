//
//  MatchesMessagesController.swift
//  Kinder
//
//  Created by Kenny Ho on 11/8/19.
//  Copyright © 2019 Kenny Ho. All rights reserved.
//

import UIKit
import LBTATools
import Firebase

struct Match {
    let name: String
    let profileImageUrl: String
}

class MatchCell: LBTAListCell<Match> {
    
    let profileImageView = UIImageView(image: #imageLiteral(resourceName: "kelly1"), contentMode: .scaleAspectFill)
    let userNameLabel = UILabel(text: "Username Here", font: .systemFont(ofSize: 14, weight: .semibold),textColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), textAlignment: .center, numberOfLines: 2)
    
    override var item: Match! {
        didSet {
            userNameLabel.text = item.name
            profileImageView.sd_setImage(with: URL(string: item.profileImageUrl), completed: nil)
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

class MatchesMessagesController: LBTAListController<MatchCell, Match>, UICollectionViewDelegateFlowLayout {
    let cellId = "cellId"
    
    let customNavBar = MatchesNavBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = [
            Match(name: "Sarah", profileImageUrl: "https://firebasestorage.googleapis.com/v0/b/kinder-7fd50.appspot.com/o/images%2FB734C0DD-62A0-479F-A2C7-0012CA2DBB17?alt=media&token=247a58dd-096b-44d2-9f41-48de5826b6b0"),
            Match(name: "Rachel", profileImageUrl: "profileUrl"),
            Match(name: "Megan", profileImageUrl: "profileUrl"),
        ]
        
        fetchMatches()

        navigationController?.navigationBar.isHidden = true
        
        collectionView.backgroundColor = .white
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        collectionView.contentInset.top = 150
        
    }
    
    fileprivate func fetchMatches() {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("matches").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Failed to fetch matches:", err)
                return
            }
            
            print("here are my matches document")
            querySnapshot?.documents.forEach({ (documentSnapshot) in
                print(documentSnapshot.data())
            })
        }
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 120, height: 140)
    }
    
}
