//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

// GET /v1/exchange/map response
struct ExchangeMapResponseDTO: Decodable {
    let status: StatusDTO
    let data: [ExchangeMapItemDTO]
}

struct StatusDTO: Decodable {
    let errorCode: Int
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case errorMessage = "error_message"
    }
}

struct ExchangeMapItemDTO: Decodable {
    let id: Int
    let name: String
    let slug: String
    let isActive: Int?
    let firstHistoricalData: String?
    let lastHistoricalData: String?

    enum CodingKeys: String, CodingKey {
        case id, name, slug
        case isActive = "is_active"
        case firstHistoricalData = "first_historical_data"
        case lastHistoricalData = "last_historical_data"
    }
}
