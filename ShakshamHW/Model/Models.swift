//
//  Models.swift
//  ShakshamHW
//
//  Created by Saksham Saraswaton 14/04/19.
//  Copyright © 2019 ok. All rights reserved.
//

import UIKit

struct ParkingModel : Decodable {
    var userId:String
    var type:String
    var price:String
    var description:String
    var feature:String
    var lat:String
    var long:String
    var rating:String
    var booking:String
}
