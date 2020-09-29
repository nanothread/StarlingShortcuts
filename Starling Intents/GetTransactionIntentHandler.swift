//
//  GetTransactionIntentHandler.swift
//  Starling Intents
//
//  Created by Andrew Glen on 29/09/2020.
//

import Foundation
import Intents
import Combine

extension SCAccount {
    convenience init(_ account: Account) {
        self.init(identifier: account.accountUid, display: account.name)
    }
}

class GetTransactionIntentHandler: NSObject, GetTransactionIntentHandling {
    let network = NetworkManager()
    var cancellables = Set<AnyCancellable>()
    
    private func getAccounts() -> AnyPublisher<[SCAccount], Error> {
        network
            .fetchAccounts()
            .map { $0.map(SCAccount.init) }
            .eraseToAnyPublisher()
    }
    
    func handle(intent: GetTransactionIntent, completion: @escaping (GetTransactionIntentResponse) -> Void) {
        completion(.init(code: .success, userActivity: nil))
    }
    
    func resolveAccount(for intent: GetTransactionIntent, with completion: @escaping (SCAccountResolutionResult) -> Void) {
        if let account = intent.account {
            completion(.success(with: account))
        } else {
            getAccounts()
                .sink { result in
                    if case .failure(let error) = result {
                        print("Failed to fetch accounts from resolveAccount:", error)
                        completion(.confirmationRequired(with: nil))
                    }
                } receiveValue: { accounts in
                    if accounts.count == 1 {
                        completion(.success(with: accounts[0]))
                    } else {
                        completion(.disambiguation(with: accounts))
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    func provideAccountOptionsCollection(for intent: GetTransactionIntent, with completion: @escaping (INObjectCollection<SCAccount>?, Error?) -> Void) {
        getAccounts()
            .sink { result in
                if case .failure(let error) = result {
                    completion(nil, error)
                }
            } receiveValue: { accounts in
                completion(INObjectCollection(items: accounts), nil)
            }
            .store(in: &cancellables)
    }
}
