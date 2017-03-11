//
//  Complain.swift
//  Connect
//
//  Created by Chirag Palesha on 12/6/16.
//  Copyright © 2016 Chirag Palesha. All rights reserved.
//

import UIKit

class Complain: NSObject {
    var category: String
    var desc: String
    var image: String
    var latitude: String
    var longitude: String
    var status: String
    var uid: String
    
    override init(){
        category = ""
        desc = ""
        image = ""
        latitude = ""
        longitude = ""
        status = ""
        uid = ""
    }

}
