//
//  Date+Extensions.swift
//  IdentHubSDK
//

import Foundation

extension Date {

    /// Method converts date object to string with format passed as parameter
    /// - Parameter format: string value of the required date format
    /// - Returns: string of the date
    func dateString(with format: String) -> String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = format

        return dateFormatter.string(from: self)
    }

    /// Method returns date with default format for SDK
    /// - Returns: string of the date
    func defaultDateString() -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        return dateFormatter.string(from: self)
    }
}

extension String {

    func dateFromString() -> Date? {
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        return dateFormatter.date(from: self)
    }
}
