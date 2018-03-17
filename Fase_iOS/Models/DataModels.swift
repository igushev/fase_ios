//
//  DataClasses.swift
//  TestJson
//
//  Created by Alexey Bidnyk on 3/1/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import Foundation
import ObjectMapper

struct Locale: Mappable {
    var countryCode: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        countryCode <- map["country_code"]
    }
}

struct Contact {
    var displayName: String
    var phoneNumber: String
    
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case phoneNumber = "phone_number"
    }
}

struct Place {
    var googlePlaceId: String
    var city: String
    var state: String
    var country: String
    
    enum CodingKeys: String, CodingKey {
        case googlePlaceId = "google_place_id"
        case city = "city"
        case state = "state"
        case country = "country"
    }
}

struct User {
    var userId: String
    var phoneNumber: String
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var homeCity: Place
    var locale: Locale
    var datetimeAdded: Date
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case phoneNumber = "phone_number"
        case firstName = "first_name"
        case lastName = "last_name"
        case dateOfBirth = "date_of_birth"
        case homeCity = "home_city"
        case locale = "locale"
        case datetimeAdded = "datetime_added"
    }
}

