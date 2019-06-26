//
//  Array+Extension.swift
//  InfineScroll
//
//  Created by Serhiy Rosovskyy on 6/26/19.
//  Copyright © 2019 Serhiy Rosovskyy. All rights reserved.
//

import Foundation


extension Array {
    /**
        It allows us to write only needed set of characters
        in the text field
    */
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}
