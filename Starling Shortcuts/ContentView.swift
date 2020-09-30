//
//  ContentView.swift
//  Starling Shortcuts
//
//  Created by Andrew Glen on 28/09/2020.
//

import SwiftUI
import Combine

class StateManager: ObservableObject {
    @Published var accounts = [Account]()
    @Published var latestTransaction: Transaction?
    @Published var cards = [Card]()
    
    private var network = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    
    func fetchAccounts() {
        network
            .fetchAccounts()
            .receive(on: DispatchQueue.main)
            .print("Accounts - ")
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
    
    func fetchLatestTransaction() {
        network
            .fetchAccounts()
            .compactMap(\.first)
            .print()
            .flatMap(network.fetchLatestTransaction)
            .print()
            .catch { error -> Just<Transaction?> in
                print("Failed to fetch latest transaction:", error)
                return Just(nil)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$latestTransaction)
    }
    
    func fetchCards() {
        network
            .fetchCards()
            .receive(on: DispatchQueue.main)
            .print("Cards - ")
            .sink { result in
                print("Finished fetching cards")
                if case .failure(let error) = result {
                    print(error)
                }
            } receiveValue: { cards in
                self.cards = cards
            }
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @StateObject var state = StateManager()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: HStack {
                    Text("Accounts")
                    Spacer()
                    Button {
                        state.fetchAccounts()
                    } label: {
                        Text("Fetch")
                    }
                }) {
                    ForEach(state.accounts) { account in
                        Text(account.name)
                    }
                }
                
                Section(header: HStack {
                    Text("Latest Transaction")
                    Spacer()
                    Button {
                        state.fetchLatestTransaction()
                    } label: {
                        Text("Fetch")
                    }
                }) {
                    if let transaction = state.latestTransaction  {
                        Text(transaction.debugDescription)
                    }
                }
                
                Section(header: HStack {
                    Text("Cards")
                    Spacer()
                    Button {
                        state.fetchCards()
                    } label: {
                        Text("Fetch")
                    }
                }) {
                    ForEach(state.cards) { card in
                        Text(card.id)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Starling Shortcuts")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
