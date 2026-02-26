//  Untitled.swift
//  CryptoExchange
//
//  Created by Marcio on 26/02/26.
//

import Foundation

// /v1/exchange/info response
struct ExchangeInfoResponseDTO: Decodable {
    let status: StatusDTO
    let data: [String: ExchangeInfoDTO]
}

struct ExchangeInfoDTO: Decodable {
    let id: Int
    let name: String
    let slug: String
    let logo: String?
    let description: String?
    let dateLaunched: String?
    let notice: String?
    let spotVolumeUsd: Double?
    let makerFee: Double?
    let takerFee: Double?
    let weeklyVisits: Int?
    let spot: Int?
    let urls: ExchangeURLsDTO?

    enum CodingKeys: String, CodingKey {
        case id, name, slug, logo, description, notice, urls, spot
        case dateLaunched = "date_launched"
        case spotVolumeUsd = "spot_volume_usd"
        case makerFee = "maker_fee"
        case takerFee = "taker_fee"
        case weeklyVisits = "weekly_visits"
    }
}

struct ExchangeURLsDTO: Decodable {
    let website: [String]?
    let blog: [String]?
    let chat: [String]?
    let fee: [String]?
    let twitter: [String]?
}
