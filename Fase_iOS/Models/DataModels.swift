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
    
    init(countryCode: String) {
        self.countryCode = countryCode
    }
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        countryCode <- map["country_code"]
    }
}

struct Contact: Mappable {
    var displayName: String
    var phoneNumber: String
    
    init(name: String, phone: String) {
        self.displayName = name
        self.phoneNumber = phone
    }
    
    init?(map: Map) {
        displayName = try! map.value("display_name")
        phoneNumber = try! map.value("phone_number")
    }
    
    mutating func mapping(map: Map) {
        displayName <- map["display_name"]
        phoneNumber <- map["phone_number"]
    }
}

struct Place: Mappable {
    var googlePlaceId: String?
    var city: String?
    var state: String?
    var country: String?
    
    init(placeId: String, city: String, state: String, country: String) {
        self.googlePlaceId = placeId
        self.city = city
        self.state = state
        self.country = country
    }
    
    init?(map: Map) {
        googlePlaceId = try! map.value("google_place_id")
        city = try! map.value("city")
        state = try! map.value("state")
        country = try! map.value("country")
    }
    
    mutating func mapping(map: Map) {
        googlePlaceId <- map["google_place_id"]
        city <- map["city"]
        state <- map["state"]
        country <- map["country"]
    }
}

struct User {
    var userId: String?
    var phoneNumber: String?
    var firstName: String?
    var lastName: String?
    var dateOfBirth: Date?
    var homeCity: Place?
    var locale: Locale?
    var datetimeAdded: Date?
    
    init?(map: Map) {
        userId = try! map.value("user_id")
        phoneNumber = try! map.value("phone_number")
        firstName = try! map.value("first_name")
        lastName = try! map.value("last_name")
        dateOfBirth = try! map.value("date_of_birth")
        homeCity = try! map.value("home_city")
        locale = try! map.value("locale")
        datetimeAdded = try! map.value("datetime_added")
    }
    
    mutating func mapping(map: Map) {
        userId <- map["user_id"]
        phoneNumber <- map["phone_number"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        dateOfBirth <- map["date_of_birth"]
        homeCity <- map["home_city"]
        locale <- map["locale"]
        datetimeAdded <- map["datetime_added"]
    }
    
}

