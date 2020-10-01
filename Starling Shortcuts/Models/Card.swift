//
//  Card.swift
//  Starling Shortcuts
//
//  Created by Andrew Glen on 30/09/2020.
//

import Foundation

struct Card: Codable {
    var cardUid: String
    var enabled: Bool
    var endOfCardNumber: String
}

extension Card: Identifiable {
    var id: String { cardUid }
}

extension Card: CustomStringConvertible {
    var description: String {
        "*\(endOfCardNumber.suffix(4))"
    }
}
