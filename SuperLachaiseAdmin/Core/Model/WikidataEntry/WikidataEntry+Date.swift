//
//  WikidataEntry+Date.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 14/12/2017.
//

import Foundation

struct WikidataEntryDate {

    enum Precision: String {
        case day, month, year
    }

    let date: Date
    let precision: Precision

}

extension WikidataEntryDate: CustomStringConvertible {

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

        let threadDict = Thread.current.threadDictionary
        let key = "SuperLachaise.WikidataEntryDate.dateFormatters.\(template)"
        if let dateFormatter = threadDict[key] as? DateFormatter {
            return dateFormatter
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.locale = Locale.current
            dateFormatter.setLocalizedDateFormatFromTemplate(template)
            threadDict[key] = dateFormatter
            return dateFormatter
        }
    }

    var description: String {
        return dateString(template: "dMMMMYYYY")
    }

}

extension WikidataEntry {

    var dateOfBirth: WikidataEntryDate? {
        get {
            guard let date = rawDateOfBirth else {
                return nil
            }
            guard let precision = WikidataEntryDate.Precision(rawValue: rawDateOfBirthPrecision) else {
                Logger.warning("Invalid rawDateOfBirthPrecision: \(rawDateOfBirthPrecision)")
                return nil
            }
            return WikidataEntryDate(date: date, precision: precision)
        }
        set {
            rawDateOfBirth = newValue?.date
            rawDateOfBirthPrecision = newValue?.precision.rawValue ?? ""
        }
    }

    var dateOfDeath: WikidataEntryDate? {
        get {
            guard let date = rawDateOfDeath else {
                return nil
            }
            guard let precision = WikidataEntryDate.Precision(rawValue: rawDateOfDeathPrecision) else {
                Logger.warning("Invalid rawDateOfDeathPrecision: \(rawDateOfDeathPrecision)")
                return nil
            }
            return WikidataEntryDate(date: date, precision: precision)
        }
        set {
            rawDateOfDeath = newValue?.date
            rawDateOfDeathPrecision = newValue?.precision.rawValue ?? ""
        }
    }

}
