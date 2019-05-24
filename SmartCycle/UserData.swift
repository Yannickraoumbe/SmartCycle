//
//  UserData.swift
//  SmartCycle
//
//  Created by Yannick Mael Raoumbe on 23/04/2019.
//  Copyright © 2019 ME. All rights reserved.
//

import Foundation
import RealmSwift

class BycicleUser: Object {
    @objc dynamic var UniqueID: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var numberOne : String = ""
    @objc dynamic var numberTwo : String = ""
    @objc dynamic var numberThree : String = ""
    
}
