//
//  Entry+Date.swift
//  SuperLachaiseAdmin
//
//  Created by Maxime Le Moine on 25/03/2018.
//

import Foundation

extension Entry {

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
