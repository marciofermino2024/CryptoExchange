//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

final class ExchangeRepository: ExchangeRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let multiIDClient: MultiIDAPIClient
    private let cache = NSCache<NSString, CacheEntry>()

    init(apiClient: APIClientProtocol, multiIDClient: MultiIDAPIClient) {
        self.apiClient = apiClient
        self.multiIDClient = multiIDClient
        cache.countLimit = 50
    }

    func fetchExchangeList(start: Int, limit: Int) async throws -> [Exchange] {
        let cacheKey = "list_\(start)_\(limit)" as NSString
        if let cached = cache.object(forKey: cacheKey) {
            return cached.exchanges
        }

        let mapResponse: ExchangeMapResponseDTO = try await apiClient.request(.exchangeMap(start: start, limit: limit))
        let ids = mapResponse.data.map { $0.id }
        guard !ids.isEmpty else { return [] }

        let infoResponse = try await multiIDClient.requestExchangeInfo(ids: ids)
        let exchanges = infoResponse.data.values.map { ExchangeMapper.map($0) }

        let idOrder = Dictionary(uniqueKeysWithValues: ids.enumerated().map { ($1, $0) })
        let sorted = exchanges.sorted { (idOrder[$0.id] ?? 0) < (idOrder[$1.id] ?? 0) }

        cache.setObject(CacheEntry(exchanges: sorted), forKey: cacheKey)
        return sorted
    }

    func fetchExchangeDetail(id: Int) async throws -> Exchange {
        let cacheKey = "detail_\(id)" as NSString
        if let cached = cache.object(forKey: cacheKey), let exchange = cached.exchanges.first {
            return exchange
        }

        let response: ExchangeInfoResponseDTO = try await apiClient.request(.exchangeInfo(id: id))
        guard let dto = response.data.values.first else {
            throw AppError.unknown("Exchange not found")
        }

        let exchange = ExchangeMapper.map(dto)
        cache.setObject(CacheEntry(exchanges: [exchange]), forKey: cacheKey)
        return exchange
    }

    func fetchExchangeMarketPairs(exchangeID: Int, start: Int, limit: Int) async throws -> [ExchangeMarketPair] {
        let response: ExchangeMarketPairsResponseDTO = try await apiClient.request(
            .exchangeMarketPairs(id: exchangeID, start: start, limit: limit)
        )
        let pairs = response.data.marketPairs ?? []
        return pairs.enumerated().compactMap { index, dto in
            MarketPairMapper.map(dto, index: index)
        }
    }
}

final class CacheEntry: NSObject {
    let exchanges: [Exchange]
    init(exchanges: [Exchange]) {
        self.exchanges = exchanges
    }
}
