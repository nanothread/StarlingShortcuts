//
//  CurrencyAndAmount.swift
//  Starling Shortcuts
//
//  Created by Andrew Glen on 30/09/2020.
//

import Foundation

struct CurrencyAndAmount: Codable {
    var currency: String
    var minorUnits: Int
}

extension CurrencyAndAmount: CustomStringConvertible {
    var description: String {
        String(format: "%.2f \(currency)", Double(minorUnits) / 100)
    }
}
