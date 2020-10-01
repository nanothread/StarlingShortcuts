//
//  IntentHandler.swift
//  Starling Intents
//
//  Created by Andrew Glen on 29/09/2020.
//

import Intents

/* Intent Ideas
    Download statement for account
        - For certain month
        - For certain date range
    Submit receipt for latest outgoing transaction
    Get next scheduled recurring transaction (may be a recurring payment or a standing order)
 
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
        if intent is GetTransactionIntent {
            return GetTransactionIntentHandler()
        }
        if intent is SetCardIntent {
            return SetCardIntentHandler()
        }
        
        return self
    }
    
}
