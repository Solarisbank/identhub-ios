//
//  NSDate+Compare.swift
//  IdentHubSDKCore
//

import Foundation

public extension Date {

    /// Method defines if compared date is later or equal to the current date
    /// - Parameter dateToCompare: compared date
    /// - Returns: equals status
    func isLaterThanOrEqualTo(_ dateToCompare: Date) -> Bool {
        return !(self.compare(dateToCompare) == .orderedAscending)
    }

    /// Method defines if compared date is earlier or equal to the current date
    /// - Parameter dateToCompare: compared date
    /// - Returns: equals status
    func isEarlierOrEqualTo(_ dateToCompere: Date) -> Bool {
        return !(self.compare(dateToCompere) == .orderedDescending)
    }

    /// Method calculated new date from setted by adding number of years
    /// - Parameter yearsToAdd: number of years
    /// - Returns: new date
    func addYears(_ yearsToAdd: Int) -> Date {
        var dateComponent = DateComponents()

        dateComponent.year = yearsToAdd

        return Calendar.current.date(byAdding: dateComponent, to: self) ?? Date()
    }
}
