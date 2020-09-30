//
//  Transaction.swift
//  Starling Shortcuts
//
//  Created by Andrew Glen on 30/09/2020.
//

import Foundation

struct Transaction: Codable {
    var feedItemUid: String
    var amount: CurrencyAndAmount
    var counterPartyName: String
}

extension Transaction: Identifiable {
    var id: String { feedItemUid }
}

extension Transaction: CustomStringConvertible {
    var description: String {
        "\(amount) with \(counterPartyName)"
    }
}
