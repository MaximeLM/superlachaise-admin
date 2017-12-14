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
