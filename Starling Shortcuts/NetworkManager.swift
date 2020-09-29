//
//  NetworkManager.swift
//  Starling Shortcuts
//
//  Created by Andrew Glen on 29/09/2020.
//

import Foundation
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
    let starling = Starling(accessToken: STARLING_ACCESS_TOKEN)
    
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
}


let STARLING_ACCESS_TOKEN = """
eyJhbGciOiJQUzI1NiIsInppcCI6IkdaSVAifQ.H4sIAAAAAAAAAH1Ty46cMBD8lRXn9QrzHm655QfyAU27PWMN2Mg2k6yi_HsM5jFMVrlRVd3larf5nSjnkjaBUTFBg_lwHmyv9LUDff9AMyTviZu6UEFQcg5NzirZdayQRcOarE4ZliApLbO64hSK6deYtLxKeVGXdXV5TxT4SOTNJZ8JQDST9t9NL8j-UCJ4i5KKhmPJ6iZFVuRpFbwrznLR5Q1doANRBW9v7qRjR8E5QX7JWMmpCB1ZwZqLyNiFY8Yb2SBlInSEsb4hknOxSwrCtMwbJqkJ59RQsi5HZEh509WlTFHweWA0I82XEpOy2xKVaRiotQTi7UXwn-OLoARpr6Qie-Z75fyJWYEQNoRsSSi_g6h4D3gbaK888E-rPL3B5G_GKhdWxpQW6qHEBH0s7qAHjWs0BCsYGu2t6eNBM7NqRktlB_DKaGYkk5MWbpfcfvoG4tE4OW-GbUQaQK3GA2gBnlpBPYW6DS5lA9g7-TntaEmSpRDQ_U-KZ0Vt7AEpjOnpapewz43_imsrWbzBNsJAHkIaaDHARV3xknyET6JNimAdIoKjiKkBrutMUds-WTf193bbCx3UYRvx4RzxbtAbDCt8Kl8IZuZdvrJrlzVS9VuomPJELVWWkNToT8CdpXhlDh5hDY5dzZHjxK3RT9zi88wwb0G7sMivLA7xC69DjKY-vKD5XRgrntzO7GZzZrd-T_M_w9A9XqlRyJWaOoc2XML-rpYUgAux3OkzMVckf_4C-1rBjkAFAAA.gP_I64a8q7Soof_qfKylhF-Q5atamPuQ3pxMcgR6NwQdm4R3H0j4_KMxMzurYo6GuiRDoiZlQ4XeHjdSvyy84yLwPon-0A7bmDqmdHPtnmvgiAk57kcBMtLH5jMnpyI1aLHMc4Cn8LyqlZdZqNLIuNFEoIN8DGgBWLIM47piu75F1nR_WIuHx_NKizKTuABAChOoghzRzQPNUVj6onoaOHPdsapKteem0h9XPG0I5yK5ojJN4ATTpDxD73i6IeAcxuAQC2maOaX2W_lc3xkSNnm2mYwOZWYe5aN4rZY_TL-IfAphDEDSeV9x-tGBS10q8IFNOLLvjf6_WtcBJbxwJ-LnOb1042Kkg2kgnWX83-25hKxVq1ReM0XMMvrPSWBXE6ytKffQyLSfEDPa7NSZFRzkRcuB_-9H3m6ZMmcF_iTR7FN_13EKJFLBqfUv7agFfS3K_oJHMXhbS3FTJ4bsMKzr8PfDDDxW6F-oTuR28f0wJBR4TNHXQrpyaRSx3Ji96-d_bPY5GEqwFkfNfYoIPXZookz7MkMZ-qPDChfMVKvgAJPSdTfZC1s3dgsZoyQnSLTRncrFKDNg4pM94HYFjcdQ1JCGgcwrh3dBgNC1mQu0f9HlZQ6ryp4luxPJPgGyZcoLqmnC4Ns7i1cVoNOdPerR1T2b8rIcyFkRxVDzbnY
"""
