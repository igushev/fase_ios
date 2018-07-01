//
//  Datetime.swift
//  Fase_iOS
//
//  Created by Eduard Igushev on 7/1/18.
//  Copyright © 2018 Fase. All rights reserved.
//

import Foundation

enum FaseDateFormat: String {
    case server = "yyyy-MM-dd'T'HH:mm:ss"
    case printDate = "yyyy-MM-dd"
    case printTime = "h:mm a"
}

class DatetimeFormatter {
    static var serverDateFormatter: DateFormatter {
        return DateFormatter(withFormat: FaseDateFormat.server.rawValue, locale: "US")
    }
    static var printDateFormatter: DateFormatter {
        return DateFormatter(withFormat: FaseDateFormat.printDate.rawValue, locale: "US")
    }
    static var printTimeFormatter: DateFormatter {
        return DateFormatter(withFormat: FaseDateFormat.printTime.rawValue, locale: "US")
    }

}
