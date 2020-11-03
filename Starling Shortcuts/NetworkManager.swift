//
//  NetworkManager.swift
//  Starling Shortcuts
//
//  Created by Andrew Glen on 29/09/2020.
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
    // let STARLING_ACCESS_TOKEN = "my_secret_access_token"
    let starling = Starling(accessToken: STARLING_ACCESS_TOKEN)
    
    enum NetworkError: Error {
        case accountNotFound
    }
    
    func fetchAccounts() -> AnyPublisher<[Account], Error> {
        starling
            .fetchAccounts()
            .tryMap { data, _ in
                struct DTO: Codable {
                    var accounts: [Account]
                }

                let dto = try JSONDecoder().decode(DTO.self, from: data)
                return dto.accounts
            }
            .eraseToAnyPublisher()
    }
    
    func fetchLatestTransaction(from account: Account) -> AnyPublisher<Transaction?, Error> {
        // TODO: Currently only works for transactions made in the last 7 days
        starling
            .fetchTransactions(
                accountUid: account.accountUid,
                categoryUid: account.defaultCategory,
                since: Calendar.current.date(byAdding: DateComponents(day: -7), to: Date())!
            )
            .tryMap { data, _ in
                struct DTO: Codable {
                    var feedItems: [Transaction]
                }

                let dto = try JSONDecoder().decode(DTO.self, from: data)
                return dto.feedItems.first
            }
            .eraseToAnyPublisher()
    }
    
    func fetchCards() -> AnyPublisher<[Card], Error> {
        starling
            .fetchCards()
            .tryMap { data, _ in
                struct DTO: Codable {
                    var cards: [Card]
                }

                let dto = try JSONDecoder().decode(DTO.self, from: data)
                return dto.cards
            }
            .eraseToAnyPublisher()
    }
    
    func setCards(withIDs ids: [String], toEnabled enabled: Bool) -> AnyPublisher<Never, Error> {
        ids.publisher
            .flatMap {
                self.starling
                    .setCard(with: $0, enabled: enabled)
            }
            .ignoreOutput()
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    enum StatementTarget {
        case month(_ month: Int, year: Int)
        case dateRange(from: Date, to: Date)
    }
    
    func fetchStatement(for accountUid: String, target: StatementTarget, format: Starling.StatementFormat) -> AnyPublisher<Data, Error> {
        switch target {
        case .month(let month, year: let year):
            return starling
                .fetchStatementForMonth(for: accountUid, month: month, year: year, format: format)
                .map { data, _ in data }
                .mapError { $0 }
                .eraseToAnyPublisher()
        case .dateRange(let start, let end):
            return starling
                .fetchStatementForDateRange(for: accountUid, start: start, end: end, format: format)
                .map { data, _ in data }
                .mapError { $0 }
                .eraseToAnyPublisher()
        }
    }
}
