//
//  NetworkManager.swift
//  Starling Shortcuts
//
//  Created by Andrew Glen on 29/09/2020.
//

import Foundation
import Combine

class NetworkManager: ObservableObject {
    let starling = Starling(accessToken: STARLING_ACCESS_TOKEN)
    
    enum NetworkError: Error {
        case accountNotFound
    }
    
    func fetchAccounts() -> AnyPublisher<[Account], Error> {
        starling
            .fetchAccounts()
            .tryMap { data, _ in
                struct DTO: Codable {
                    var accounts: [Account]
                }

                let dto = try JSONDecoder().decode(DTO.self, from: data)
                return dto.accounts
            }
            .eraseToAnyPublisher()
    }
    
    func fetchLatestTransaction(from account: Account) -> AnyPublisher<Transaction?, Error> {
        // TODO: Currently only works for transactions made in the last 7 days
        starling
            .fetchTransactions(
                accountUid: account.accountUid,
                categoryUid: account.defaultCategory,
                since: Calendar.current.date(byAdding: DateComponents(day: -7), to: Date())!
            )
            .tryMap { data, _ in
                struct DTO: Codable {
                    var feedItems: [Transaction]
                }

                let dto = try JSONDecoder().decode(DTO.self, from: data)
                return dto.feedItems.first
            }
            .eraseToAnyPublisher()
    }
    
    func fetchCards() -> AnyPublisher<[Card], Error> {
        starling
            .fetchCards()
            .tryMap { data, _ in
                struct DTO: Codable {
                    var cards: [Card]
                }

                let dto = try JSONDecoder().decode(DTO.self, from: data)
                return dto.cards
            }
            .eraseToAnyPublisher()
    }
}


let STARLING_ACCESS_TOKEN = "eyJhbGciOiJQUzI1NiIsInppcCI6IkdaSVAifQ.H4sIAAAAAAAAAH1Ty5KbMBD8lS3OO1tgnuaWW34gHzCMRrbKIFGScLKVyr9HIDDG2cqN7p5p9WjE70Q5l7QJjgoED-bDebS90pcO9e2DzJC8J27qQgVjmWXY5FDJroNCFg00pzoFKlFyWp7qKuNQzL_GpM2qNCvL86nK3xOFPhJFfWpmAonMpP130wu2P5QI3qLkosmohLpJCYo8rYJ3lUEuurzhM3YoquDtzY117CiqhgVRBecaUyiwLgGbtIQz5SKTXVWeRRY6wljfiNi52CUFU1rmDUhuwjk1ltDlRECcN11dypSWLkdm5PlSYlK4LlFB48CtZRRvL4L_HF8EJVh7JRXbI98r5w_MCoSwIWTLQvkHiIr3SNeBH5U7_mmV5zec_NVY5cLKQGmh7kpM2MfiDnvUtEYjtALIaG9NHw-amVUzWio7oFdGg5EgJy3cQ3KP0zcQj6bJeTNsI_KAajUeUAv03AruOdRtcCkb0N7Yz2lHy5Ith4Duf1I8K2pjj8RhTM8Xu4R9bvxXXFvZ0hW3EQb2GNJgSwEu6oqX5CN-Mm9SBOsQEexFoAa8rDNFbfuEbupv7bYX3qndNuLdOeKHQW8orPCpfCHAzLt8Zdcua6Tqt1Ax5YFaqiwTq9EfgDtK8coc3sMaHFzMnuPArdEP3OLzzIC3qF1Y5FcWu_iF1y5GUx9e0PwujBVPbkd2szmyW7_n-Z8BcvdXahRypabOkQ2X8HhXSwqkhVju9JmYK5I_fwGFR2CqQAUAAA.TuhMHAGQHTESgOTMKOGL7grPGzMRmQbNuAOBhEVtC4Z7dEg59V09A1ls8w59mXHw0V1zB3FqGR5eY4UDQbu3z3s_TTrXQybtwp_ouT3x1_biOF39sO4YnQUnaMyGwQTG2NCr2p6LAsvg7sza8uuN-JBGo-gdf8x-rOxDAN4Si_YRbDgZHUl79vUFDtX7ZAsAic4aJ_BIniQDGL016SP-Djnnv_GiqUfM7PZ-QIrxRSh_89bM6Rmv87eUExrcrIpx0f5HwG8cCHt_i68Qla0HndhlxttlWEpHwqiwPz9FSJ_xi4DLj9XXyYvr-B9CKsKX_nGbEJnYh4E4RGNL1__DK7UIuGyVU_3K_9h3jQ725otfHQb6D2RPmQa85OQSIhacjEUOOYqdN2ECJIjjgTnaDdJRlFKB95GF0h2eWYnh3R5dgB__IJhiXHSQ6ZpEoDyehsfHFfxGHC0qHzeIyVlZnKIlBwjQWWf1818_LDGmDX9odFZEM7ZSavD5zdItW-eBrYGnGuUklDrb9e9Q9Xe2SNS51ueJ4kpktqkigZKuVrqp75lpDHgDt42mF5TSV1mHhvFlySNSdZRhQ8ckDIMqMT7wWiFdotEfsabIjQ5HtLR6t3l9mZkrP3G_0fjoJVIrptwomSQx1uWcD8BUvBp9rEJTyEGl0-WskF6qykIHSi8"
