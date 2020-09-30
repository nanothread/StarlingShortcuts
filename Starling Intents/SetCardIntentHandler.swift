//
//  SetCardIntentHandler.swift
//  Starling Intents
//
//  Created by Andrew Glen on 30/09/2020.
//

import Foundation
import Intents

class SetCardIntentHandler: NSObject, SetCardIntentHandling {
    func resolveCard(for intent: SetCardIntent, with completion: @escaping ([SCCardResolutionResult]) -> Void) {
        
    }
    
    func resolveEnabled(for intent: SetCardIntent, with completion: @escaping (INBooleanResolutionResult) -> Void) {
        
    }
    
    func provideCardOptionsCollection(for intent: SetCardIntent, with completion: @escaping (INObjectCollection<SCCard>?, Error?) -> Void) {
        
    }
}
