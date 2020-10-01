//
//  SetCardIntentHandler.swift
//  Starling Intents
//
//  Created by Andrew Glen on 30/09/2020.
//

import Foundation
import Intents
import Combine

extension SCCard {
    convenience init(_ card: Card) {
        self.init(identifier: card.cardUid, display: card.description)
    }
}

class SetCardIntentHandler: NSObject, SetCardIntentHandling {
    let network = NetworkManager()
    var cancellables = Set<AnyCancellable>()
    
    func handle(intent: SetCardIntent, completion: @escaping (SetCardIntentResponse) -> Void) {
        guard let cardIDs = intent.cards?.compactMap(\.identifier),
              let enabled = intent.enabled?.boolValue
        else {
            completion(.init(code: .failure, userActivity: nil))
            return
        }
        
        network
            .setCards(withIDs: cardIDs, toEnabled: enabled)
            .sink { result in
                switch result {
                case .finished:
                    completion(.init(code: .success, userActivity: nil))
                case .failure(let error):
                    print("Failed to set cards enabled:", error)
                    completion(.init(code: .failure, userActivity: nil))
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func resolveCards(for intent: SetCardIntent, with completion: @escaping ([SCCardResolutionResult]) -> Void) {
        if let cards = intent.cards {
            completion(cards.map(SCCardResolutionResult.success))
        } else {
            network
                .fetchCards()
                .map { $0.map(SCCard.init).map(SCCardResolutionResult.success) }
                .sink { result in
                    if case .failure(let error) = result {
                        print("Failed to resolve cards:", error)
                        completion([])
                    }
                } receiveValue: { cards in
                    completion(cards)
                }
                .store(in: &cancellables)
        }
    }
    
    func resolveEnabled(for intent: SetCardIntent, with completion: @escaping (INBooleanResolutionResult) -> Void) {
        if let enabled = intent.enabled {
            completion(.success(with: enabled.boolValue))
        } else {
            completion(.confirmationRequired(with: nil))
        }
    }
    
    func provideCardsOptionsCollection(for intent: SetCardIntent, with completion: @escaping (INObjectCollection<SCCard>?, Error?) -> Void) {
        network
            .fetchCards()
            .map { $0.map(SCCard.init) }
            .sink { result in
                if case .failure(let error) = result {
                    completion(nil, error)
                }
            } receiveValue: { cards in
                completion(.init(items: cards), nil)
            }
            .store(in: &cancellables)
    }
}
