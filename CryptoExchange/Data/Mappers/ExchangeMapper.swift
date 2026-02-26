//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

enum ExchangeMapper {
    static func map(_ dto: ExchangeInfoDTO) -> Exchange {
        // ISO8601 with fractional seconds (e.g. "2017-07-14T00:00:00.000Z")
        let date = parseDate(dto.dateLaunched)
        let logo = dto.logo.flatMap { URL(string: $0) }
        let website = dto.urls?.website?.first.flatMap { URL(string: $0) }

        // Log logo presence — proves data flows from API to domain model
        CMCLogger.shared.logLogoURL(
            exchangeId: dto.id,
            name: dto.name,
            logoURL: dto.logo
        )

        return Exchange(
            id: dto.id,
            name: dto.name,
            slug: dto.slug,
            logo: logo,
            description: dto.description,
            websiteURL: website,
            dateLaunched: date,
            spotVolumeUSD: dto.spotVolumeUsd,
            makerFee: dto.makerFee,
            takerFee: dto.takerFee,
            weeklyVisits: dto.weeklyVisits,
            spot: dto.spot
        )
    }

    static func mapFromMapItem(_ dto: ExchangeMapItemDTO) -> Exchange {
        return Exchange(
            id: dto.id,
            name: dto.name,
            slug: dto.slug,
            logo: nil,
            description: nil,
            websiteURL: nil,
            dateLaunched: nil,
            spotVolumeUSD: nil,
            makerFee: nil,
            takerFee: nil,
            weeklyVisits: nil,
            spot: nil
        )
    }

    // MARK: - Date parsing

    /// Handles both "2017-07-14T00:00:00.000Z" (with ms) and "2017-07-14T00:00:00Z" (without ms).
    /// The default ISO8601DateFormatter doesn't handle the ".000Z" fractional seconds variant.
    private static func parseDate(_ string: String?) -> Date? {
        guard let string, !string.isEmpty else { return nil }

        // Try with fractional seconds first (most common in CMC API)
        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = withFractional.date(from: string) { return date }

        // Fallback: without fractional seconds
        let withoutFractional = ISO8601DateFormatter()
        withoutFractional.formatOptions = [.withInternetDateTime]
        if let date = withoutFractional.date(from: string) { return date }

        // Last resort: yyyy-MM-dd prefix
        let simple = DateFormatter()
        simple.dateFormat = "yyyy-MM-dd"
        simple.locale = Locale(identifier: "en_US_POSIX")
        return simple.date(from: String(string.prefix(10)))
    }
}

enum MarketPairMapper {
    static func map(_ dto: MarketPairDTO, index: Int) -> ExchangeMarketPair? {
        guard
            let base = dto.marketPairBase,
            let quote = dto.marketPairQuote,
            let baseCurrencyID = base.currencyId,
            let baseSymbol = base.currencySymbol,
            let baseExchangeSymbol = base.exchangeSymbol,
            let baseCurrencyType = base.currencyType,
            let quoteCurrencyID = quote.currencyId,
            let quoteSymbol = quote.currencySymbol,
            let quoteExchangeSymbol = quote.exchangeSymbol,
            let quoteCurrencyType = quote.currencyType
        else { return nil }

        let priceUSD = dto.quote?.usd?.price ?? dto.quote?.exchangeReported?.price
        let volumeUSD = dto.quote?.usd?.volume24hUsd
        let id = dto.marketId.map { "\($0)" } ?? "\(index)"

        return ExchangeMarketPair(
            id: id,
            marketPairBase: MarketCurrency(
                currencyID: baseCurrencyID,
                currencySymbol: baseSymbol,
                exchangeSymbol: baseExchangeSymbol,
                currencyType: baseCurrencyType
            ),
            marketPairQuote: MarketCurrency(
                currencyID: quoteCurrencyID,
                currencySymbol: quoteSymbol,
                exchangeSymbol: quoteExchangeSymbol,
                currencyType: quoteCurrencyType
            ),
            priceUSD: priceUSD,
            volumeUSD24h: volumeUSD,
            lastUpdated: nil
        )
    }
}
