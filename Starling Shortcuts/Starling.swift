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
    private let dateFormatter = ISO8601DateFormatter()
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
        body: [String: Any]? = nil,
        accept: String = "application/json"
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
        
        request.setValue(accept, forHTTPHeaderField: "Accept")
        
        return request
    }
    
    func fetchAccounts() -> APIPublisher {
        URLSession.shared
            .dataTaskPublisher(for: request(endpoint: "/accounts"))
    }
    
    func fetchTransactions(accountUid: String, categoryUid: String, since: Date) -> APIPublisher {
        URLSession.shared
            .dataTaskPublisher(for: request(endpoint: "/feed/account/\(accountUid)/category/\(categoryUid)",
                                            query: ["changesSince": dateFormatter.string(from: since)]))
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
    
    enum StatementFormat: String {
        case csv = "text/csv"
        case pdf = "application/pdf"
    }
    
    func fetchStatementForMonth(for accountUid: String, month: Int, year: Int, format: StatementFormat) -> APIPublisher {
        URLSession.shared
            .dataTaskPublisher(for: request(endpoint: "/accounts/\(accountUid)/statement/download",
                                            query: ["yearMonth": "\(year)-\(String(format: "%02d", month))"],
                                            accept: format.rawValue))
    }
    func fetchStatementForDateRange(for accountUid: String, start: Date, end: Date, format: StatementFormat) -> APIPublisher {
        URLSession.shared
            .dataTaskPublisher(for: request(endpoint: "/accounts/\(accountUid)/statement/downloadForDateRange",
                                            query: [
                                                "start": dateFormatter.string(from: start),
                                                "end": dateFormatter.string(from: end)
                                            ],
                                            accept: format.rawValue))
    }
}
