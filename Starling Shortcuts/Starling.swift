//
//  Starling.swift
//  Starling Shortcuts
//
//  Created by Andrew Glen on 30/09/2020.
//

import Foundation
import Combine

class Starling {
    typealias APIPublisher = URLSession.DataTaskPublisher
    
    private let root = "https://api-sandbox.starlingbank.com/api/v2"
    var accessToken: String
    
    struct APIError: Codable, Swift.Error, LocalizedError {
        struct Error: Codable {
            var message: String
        }
        
        var errors: [Error]
        
        var errorDescription: String? {
            errors.reduce("Starling API Error:") { $0 + "\n\($1)" }
        }
    }
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    private func request(
        endpoint: String,
        method: String = "GET",
        query: [String: String]? = nil,
        body: [String: Any]? = nil
    ) -> URLRequest
    {
        var url = URLComponents(string: root + endpoint)!
        if let query = query {
            url.queryItems = query.map(URLQueryItem.init)
        }
        
        var request = URLRequest(url: url.url!)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = method
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    func fetchAccounts() -> APIPublisher {
        URLSession.shared
            .dataTaskPublisher(for: request(endpoint: "/accounts"))
    }
    
    func fetchTransactions(accountUid: String, categoryUid: String, since: Date) -> APIPublisher {
        URLSession.shared
            .dataTaskPublisher(for: request(endpoint: "/feed/account/\(accountUid)/category/\(categoryUid)",
                                            query: ["changesSince": ISO8601DateFormatter().string(from: since)]))
    }
    
    func fetchCards() -> APIPublisher {
        URLSession.shared
            .dataTaskPublisher(for: request(endpoint: "/cards"))
    }
    
    func setCard(with uid: String, enabled: Bool) -> APIPublisher {
        URLSession.shared
            .dataTaskPublisher(for: request(endpoint: "/cards/\(uid)/controls/enabled",
                                            method: "PUT",
                                            body: ["enabled": enabled]))
    }
}
