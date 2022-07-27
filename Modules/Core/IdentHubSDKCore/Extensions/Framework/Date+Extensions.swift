//
//  Date+Extensions.swift
//  IdentHubSDKCore
//

import Foundation

public extension Date {
    
    static var defaultDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return dateFormatter
    }

    /// Method converts date object to string with format passed as parameter
    /// - Parameter format: string value of the required date format
    /// - Returns: string of the date
    func dateString(with format: String) -> String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        return dateFormatter.string(from: self)
    }

    /// Method returns date with default format for SDK
    /// - Returns: string of the date
    func defaultDateString() -> String {
        return Date.defaultDateFormatter.string(from: self)
    }
}

public extension String {

    func dateFromString() -> Date? {
        return Date.defaultDateFormatter.date(from: self)
    }
}

public extension DateFormatter {

    /// Decodable format
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
