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
