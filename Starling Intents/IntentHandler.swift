//
//  IntentHandler.swift
//  Starling Intents
//
//  Created by Andrew Glen on 29/09/2020.
//

import Intents

/* Intent Ideas
    Lock/Unlock Card (there may be multiple cards)
    Submit receipt for latest outgoing transaction
    Get next scheduled recurring transaction (may be a recurring payment or a standing order)
    Download statement for account
        - For certain month
        - For certain date range
 
    Get spending insights
        - Grouped by merchant
        - Grouped by category
    Get latest transaction since a date with options to filter by:
        - Incoming/outgoing
        - Merchant
        - Payment reference
    Move money into/out of savings/kite spaces
    Get account balance
*/

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation. If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        if intent is GetTransactionIntent {
            return GetTransactionIntentHandler()
        }
        
        return self
    }
    
}
