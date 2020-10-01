//
//  NetworkManager.swift
//  Starling Shortcuts
//
//  Created by Andrew Glen on 29/09/2020.
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
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


let STARLING_ACCESS_TOKEN = "eyJhbGciOiJQUzI1NiIsInppcCI6IkdaSVAifQ.H4sIAAAAAAAAAH1Ty5KbMBD8lS3OO1tgnuaWW34gHzCMRrbKIFGScLKVyr9HIDDG2cqN7p5p9WjE70Q5l7QJjgoED-bDebS90pcO9e2DzJC8J27qQgVjmWXY5FDJroNCFg00pzoFKlFyWp7qKuNQzL_GpM2qNKvqssnK90Shj0TZnIuZQCIzaf_d9ILtDyWCtyi5aDIqoW5SgiJPq-BdZZCLLm_4jB2KKnh7c2MdOwo-hQhlDhIpg-LcnaHhtIaTCH0yOzVNcQodYaxvROxc7JKCKS3zBiQ34ZwaS-hyIiDOm64uZUoimwcmM_J8KTEpXJeooHHg1jKKtxfBf44vghKsvZKK7ZHvlfMHZgVC2BCyZaH8A0TFe6TrwI_KHf-0yvMbTv5qrHJhZaC0UHclJuxjcYc9alqjEVoBZLS3po8HzcyqGS2VHdAro8FIkJMW7iG5x-kbiEfT5LwZthF5QLUaD6gFem4F9xzqNriUDWhv7Oe0o2XJlkNA9z8pnhW1sUfiMKbni13CPjf-K66tbOmK2wgDewxpsKUAF3XFS_IRP5k3KYJ1iAj2IlADXtaZorZ9Qjf1t3bbC-_Ubhvx7hzxw6A3FFb4VL4QYOZdvrJrlzVS9VuomPJALVWWidXoD8AdpXhlDu9hDQ4uZs9x4NboB27xeWbAW9QuLPIri138wmsXo6kPL2h-F8aKJ7cju9kc2a3f8_zPALn7KzUKuVJT58iGS3i8qyUF0kIsd_pMzBXJn79dmdiaQAUAAA.b_Ee4B5Fv20MCL-Ldlo33TyU6QPp2IRA0RAGIJ-iJkzBJ4vIHCq7HktBxeCT88CxRfQzq5rlACJpzZY5lghCPJ6tqZRnAlBZoSBCxC3O0CvjJsEMAXywbVe0XPJe1frMBussZ05WCSUdq1N9-9RvHgCv7lNB6ZE82qk2YA8Auouim_8dR0Q6sIE_H4rawecr-lTGZ1L8Y9WlAGOe3pjmQ93sP9s9mNlyLo0LV0PyrINCZ8JUF4byFFUc8Wf66YiRShTU9bz8PIRsgLegp0EWksO2Tq8IzzT7V08kSp7QQHnBJhimb8qj-CmhFqOxLk_wH0JwdcVhUwdoxTZudEht9_5VPX3WrjiKCO5nqVnBv8bJL5ZQrux5Moe8u6d6cHVUCctovxe8pGwXHrGcADLZ3sr8-5iGDiM9uWDCvDkI7FJdPv6etLPxDE9F79RVxmDPduGx1lu-ivMyUY97_0-VtKqWVqALBqjSi6KPyooto36xpYMeMVOYsqviXr__-gMd4nEG_V8nb9t9IegGgdxvA5ittY9YhoZo8EgHCkVdiNF3APBiWZ9fXUi-ssdD5O7S3Jpjwx_ryTx08xmqEib18eWe-UKahC2zc8WNODxU8LKTjp95pMxr2AXykaNo4zZSIATDBty95h6QCGeVFzW4XqfdD-WD50b6gl9zupbCkzg"
