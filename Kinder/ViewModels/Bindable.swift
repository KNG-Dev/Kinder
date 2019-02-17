//
//  Bindable.swift
//  Kinder
//
//  Created by Kenny Ho on 1/23/19.
//  Copyright © 2019 Kenny Ho. All rights reserved.
//

import Foundation

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?) -> ())?
    
    func bind(observer: @escaping (T?) -> ()) {
        self.observer = observer
    }
}
