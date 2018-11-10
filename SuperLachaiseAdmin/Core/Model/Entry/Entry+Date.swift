//
//  Entry+Date.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 10/11/2018.
//

import Foundation

struct EntryDate {

    enum Precision: String {
        case day, month, year
    }

    let date: Date
    let precision: Precision

}

extension EntryDate: CustomStringConvertible {

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
        let key = "SuperLachaise.EntryDate.dateFormatters.\(template)"
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

extension Entry {

    var dateOfBirth: EntryDate? {
        get {
            guard let date = rawDateOfBirth else {
                return nil
            }
            guard let precision = EntryDate.Precision(rawValue: rawDateOfBirthPrecision) else {
                Logger.warning("Invalid rawDateOfBirthPrecision: \(rawDateOfBirthPrecision)")
                return nil
            }
            return EntryDate(date: date, precision: precision)
        }
        set {
            rawDateOfBirth = newValue?.date
            rawDateOfBirthPrecision = newValue?.precision.rawValue ?? ""
        }
    }

    var dateOfDeath: EntryDate? {
        get {
            guard let date = rawDateOfDeath else {
                return nil
            }
            guard let precision = EntryDate.Precision(rawValue: rawDateOfDeathPrecision) else {
                Logger.warning("Invalid rawDateOfDeathPrecision: \(rawDateOfDeathPrecision)")
                return nil
            }
            return EntryDate(date: date, precision: precision)
        }
        set {
            rawDateOfDeath = newValue?.date
            rawDateOfDeathPrecision = newValue?.precision.rawValue ?? ""
        }
    }

}
