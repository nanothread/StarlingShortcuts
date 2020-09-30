//
//  Account.swift
//  Starling Shortcuts
//
//  Created by Andrew Glen on 30/09/2020.
//

import Foundation

struct Account: Codable {
    var accountUid: String
    var name: String
    var defaultCategory: String
}

extension Account: Identifiable {
    var id: String { accountUid }
}

extension Account: CustomStringConvertible {
    var description: String {
        name
    }
}
