//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

enum Endpoint {
    case exchangeMap(start: Int, limit: Int)
    case exchangeInfo(id: Int)
    case exchangeMarketPairs(id: Int, start: Int, limit: Int)

    private static let baseURL = "https://pro-api.coinmarketcap.com"

    var url: URL? {
        var components = URLComponents(string: Endpoint.baseURL)
        components?.path = path
        components?.queryItems = queryItems
        return components?.url
    }

    private var path: String {
        switch self {
        case .exchangeMap:
            return "/v1/exchange/map"
        case .exchangeInfo:
            return "/v1/exchange/info"
        case .exchangeMarketPairs:
            return "/v1/exchange/market-pairs/latest"
        }
    }

    private var queryItems: [URLQueryItem] {
        switch self {
        case .exchangeMap(let start, let limit):
            return [
                URLQueryItem(name: "start", value: "\(start)"),
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "sort", value: "volume_24h")
            ]
        case .exchangeInfo(let id):
            return [URLQueryItem(name: "id", value: "\(id)")]
        case .exchangeMarketPairs(let id, let start, let limit):
            return [
                URLQueryItem(name: "id", value: "\(id)"),
                URLQueryItem(name: "start", value: "\(start)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
        }
    }
}
