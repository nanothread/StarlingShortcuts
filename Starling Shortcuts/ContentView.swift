//
//  ContentView.swift
//  Starling Shortcuts
//
//  Created by Andrew Glen on 28/09/2020.
//

import SwiftUI
import Combine

struct Account: Codable {
    var accountUid: String
    var name: String
}

extension Account: Identifiable {
    var id: String { accountUid }
}

// TODO get all accounts (to provide a list in the shortcut)
// TODO query latest transaction given a particular account

class Starling {
    private let root = "https://api-sandbox.starlingbank.com/api/v2"
    var accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    private func request(endpoint: String, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: URL(string: root + endpoint)!)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = method
        return request
    }
    
    func fetchAccounts() -> URLSession.DataTaskPublisher {
        URLSession.shared
            .dataTaskPublisher(for: request(endpoint: "/accounts"))
    }
}

class NetworkManager: ObservableObject {
    let starling = Starling(accessToken: ProcessInfo.processInfo.environment["STARLING_ACCESS_TOKEN"]!)
    
    func fetchAccounts() -> AnyPublisher<[Account], Error> {
        struct DTO: Codable {
            var accounts: [Account]
        }
        
        return starling
            .fetchAccounts()
            .tryMap { data, _ in
                print(String(data: data, encoding: .utf8))
                let dto = try JSONDecoder().decode(DTO.self, from: data)
                return dto.accounts
            }
            .eraseToAnyPublisher()
    }
}

class StateManager: ObservableObject {
    @Published var accounts = [Account]()
    private var network = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchAccounts() {
        network
            .fetchAccounts()
            .receive(on: DispatchQueue.main)
            .sink { result in
                print("Finished fetching accounts")
                if case .failure(let error) = result {
                    print(error)
                }
            } receiveValue: { accounts in
                self.accounts = accounts
            }
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @StateObject var state = StateManager()
    
    var body: some View {
        VStack {
            Button {
                state.fetchAccounts()
            } label: {
                Text("Fetch Accounts")
            }
            
            ForEach(state.accounts) { account in
                Text(account.name)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
