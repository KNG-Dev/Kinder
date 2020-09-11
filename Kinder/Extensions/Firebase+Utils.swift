//
//  Firebase+Utils.swift
//  Kinder
//
//  Created by Kenny Ho on 2/8/19.
//  Copyright © 2019 Kenny Ho. All rights reserved.
//

import Firebase

extension Firestore {
    func fetchCurrentUser(completion: @escaping (User?, Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                completion(nil, err)
                return
            }
            
            //fetch User
            guard let dictionary = snapshot?.data() else {
                let error = NSError(domain: "kinder-7fd50.firebaseapp.com", code: 500, userInfo: [NSLocalizedDescriptionKey: "No user found in Firestore"])
                completion(nil, error)
                return
            }
            let user = User(dictionary: dictionary)
            completion(user, nil)
            
        }
    }
}
