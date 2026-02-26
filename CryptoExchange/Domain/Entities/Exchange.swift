// NOVA
import Foundation

struct Exchange: Identifiable, Equatable {
    let id: Int
    let name: String
    let slug: String
    let logo: URL?
    let description: String?
    let websiteURL: URL?
    let dateLaunched: Date?
    let spotVolumeUSD: Double?
    let makerFee: Double?
    let takerFee: Double?
    let weeklyVisits: Int?
    let spot: Int?
}
