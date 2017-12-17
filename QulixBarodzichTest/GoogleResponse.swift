//
//  GoogleResponse.swift
//  QulixBarodzichTest
//
//  Created by Alexandr on 12/14/17.
//  Copyright © 2017 Alexandr. All rights reserved.
//

import Foundation

struct GoogleResponse : Codable {
    let items : Array<Item>?
    struct Item : Codable {
        let link : String
    }
    let error : Error?
    struct Error : Codable {
        let code : Int
    }
}
