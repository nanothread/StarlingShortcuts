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
    
    private(set) var network = NetworkManager()
    var cancellables = Set<AnyCancellable>()
    
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
            .flatMap(network.fetchLatestTransaction)
            .print("LatestTransaction - ")
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
                        Text(account.description)
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
                        Text(transaction.description)
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
                        HStack {
                            Text(card.description)
                            Spacer()
                            Text(card.enabled ? "Enabled" : "Disabled")
                            
                            Button {
                                state.network
                                    .setCards(withIDs: [card.id], toEnabled: !card.enabled)
                                    .print("Set Cards - ")
                                    .sink { _ in
                                        state.fetchCards()
                                    } receiveValue: { _ in }
                                    .store(in: &state.cancellables)
                            } label: {
                                Text("Toggle")
                            }
                        }
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
