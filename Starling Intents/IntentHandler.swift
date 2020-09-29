//
//  IntentHandler.swift
//  Starling Intents
//
//  Created by Andrew Glen on 29/09/2020.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        if intent is GetTransactionIntent {
            return GetTransactionIntentHandler()
        }
        
        return self
    }
    
}
