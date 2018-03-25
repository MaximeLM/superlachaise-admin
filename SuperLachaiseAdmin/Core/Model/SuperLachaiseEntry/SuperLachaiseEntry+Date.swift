//
//  SuperLachaiseEntry+Date.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation

extension SuperLachaiseEntry {

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
