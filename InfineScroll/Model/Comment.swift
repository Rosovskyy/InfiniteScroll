//
//  Comment.swift
//  InfineScroll
//
//  Created by Serhiy Rosovskyy on 6/26/19.
//  Copyright © 2019 Serhiy Rosovskyy. All rights reserved.
//

import Foundation


struct Comment: Decodable, Comparable {

    /**
        The function, which makes the structure comparable.
    */
    static func < (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id < rhs.id
    }

    /**
        Comments fields, which we get out of the api request.
    */
    let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String
}
