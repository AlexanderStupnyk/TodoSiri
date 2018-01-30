//
//  Item.swift
//  Todoey
//
//  Created by alex on 23.01.18.
//  Copyright © 2018 alex. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object{
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}

