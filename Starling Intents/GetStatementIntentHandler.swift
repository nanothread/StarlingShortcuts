//
//  GetStatementIntentHandler.swift
//  Starling Intents
//
//  Created by Andrew Glen on 01/10/2020.
//

import Foundation
import Intents
import Combine


class GetStatementIntentHandler: NSObject, GetStatementIntentHandling {
    let network = NetworkManager()
    var cancellables = Set<AnyCancellable>()
    
    private func getAccounts() -> AnyPublisher<[SCAccount], Error> {
        network
            .fetchAccounts()
            .map { $0.map(SCAccount.init) }
            .eraseToAnyPublisher()
    }
    
    func handle(intent: GetStatementIntent, completion: @escaping (GetStatementIntentResponse) -> Void) {
        
    }
    
    func resolveAccount(for intent: GetStatementIntent, with completion: @escaping (SCAccountResolutionResult) -> Void) {
        if let account = intent.account {
            completion(.success(with: account))
        } else {
            getAccounts()
                .sink { result in
                    
                } receiveValue: { accounts in
                    completion(.disambiguation(with: accounts))
                }
                .store(in: &cancellables)
        }
    }
    
    func resolveMonth(for intent: GetStatementIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
        completion(.success(with: intent.month!))
    }
    
    func resolveFormat(for intent: GetStatementIntent, with completion: @escaping (SCStatementFormatResolutionResult) -> Void) {
        completion(.success(with: intent.format))
    }
    
    func provideAccountOptionsCollection(for intent: GetStatementIntent, with completion: @escaping (INObjectCollection<SCAccount>?, Error?) -> Void) {
        getAccounts()
            .sink { result in
                if case .failure(let error) = result {
                    completion(nil, error)
                }
            } receiveValue: { accounts in
                completion(.init(items: accounts), nil)
            }
            .store(in: &cancellables)
    }
}
