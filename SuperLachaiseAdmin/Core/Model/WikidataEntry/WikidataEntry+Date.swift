//
//  WikidataEntry+Date.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 14/12/2017.
//

import Foundation

enum WikidataDatePrecision: String {
    case day, month, year
}

struct WikidataDate {
    let date: Date
    let precision: WikidataDatePrecision
}

extension WikidataDate: CustomStringConvertible {

    private static var dateFormatters: [String: DateFormatter] = [:]

    func dateString(template: String) -> String {
        return dateFormatter(template: template).string(from: date)
    }

    private func dateFormatter(template: String) -> DateFormatter {
        var template = template
        switch precision {
        case .year:
            template = template.replacingOccurrences(of: "M", with: "")
            template = template.replacingOccurrences(of: "d", with: "")
        case .month:
            template = template.replacingOccurrences(of: "d", with: "")
        case .day:
            break
        }

        if let dateFormatter = WikidataDate.dateFormatters[template] {
            return dateFormatter
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.locale = Locale.current
            dateFormatter.setLocalizedDateFormatFromTemplate(template)
            WikidataDate.dateFormatters[template] = dateFormatter
            return dateFormatter
        }
    }

    var description: String {
        return dateString(template: "dMMMMYYYY")
    }

}

extension WikidataEntry {

    var dateOfBirth: WikidataDate? {
        get {
            guard let date = rawDateOfBirth else {
                return nil
            }
            guard let precision = WikidataDatePrecision(rawValue: rawDateOfBirthPrecision) else {
                Logger.warning("Invalid rawDateOfBirthPrecision: \(rawDateOfBirthPrecision)")
                return nil
            }
            return WikidataDate(date: date, precision: precision)
        }
        set {
            rawDateOfBirth = newValue?.date
            rawDateOfBirthPrecision = newValue?.precision.rawValue ?? ""
        }
    }

    var dateOfDeath: WikidataDate? {
        get {
            guard let date = rawDateOfDeath else {
                return nil
            }
            guard let precision = WikidataDatePrecision(rawValue: rawDateOfDeathPrecision) else {
                Logger.warning("Invalid rawDateOfDeathPrecision: \(rawDateOfDeathPrecision)")
                return nil
            }
            return WikidataDate(date: date, precision: precision)
        }
        set {
            rawDateOfDeath = newValue?.date
            rawDateOfDeathPrecision = newValue?.precision.rawValue ?? ""
        }
    }

}
