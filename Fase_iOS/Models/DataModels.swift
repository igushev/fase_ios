//
//  DataClasses.swift
//  TestJson
//
//  Created by Alexey Bidnyk on 3/1/18.
//  Copyright © 2018 Alexey Bidnyk. All rights reserved.
//

import Foundation

struct Locale {
    var countryCode: String
    
    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
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
    var country: String
    var state: String
    var city: String
    
    enum CodingKeys: String, CodingKey {
        case googlePlaceId = "google_place_id"
        case country = "country"
        case state = "state"
        case city = "city"
    }
}

struct User {
    var userId: String
    var dateOfBirth: Date
    var firstName: String
    var lastName: String
    var homeCity: Place
    var phoneNumber: String
    var datetimeAdded: Date
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case dateOfBirth = "date_of_birth"
        case firstName = "first_name"
        case lastName = "last_name"
        case homeCity = "home_city"
        case phoneNumber = "phone_number"
        case datetimeAdded = "datetime_added"
    }
}
