//
//  Model.swift
//  Swipe Assignment
//
//  Created by usha mayuri on 20/07/24.
//

import Foundation

struct Response: Codable, Identifiable {
    var id: String = UUID().uuidString
    let image: String
    let price: Double
    let productName: String
    let productType: String
    let tax: Double

    enum CodingKeys: String, CodingKey {
        case image, price
        case productName = "product_name"
        case productType = "product_type"
        case tax
    }
}

struct PostProduct: Codable {
    let image: Data?
    let price: String
    let productName: String
    let productType: String
    let tax: String
    
    enum CodingKeys: String, CodingKey {
        case price, tax
        case productName = "product_name"
        case productType = "product_type"
        case image = "files"
    }
}

struct SimpleResponseModel: Codable {
    let message: String
    let success: Bool
}

// Add product type
enum ProductType: CaseIterable {
    case technology
    case food
    case service
    case product
    
    var description: String {
        switch self {
            case .technology:
                return "Technology"
            case .food:
                return "Food"
            case .service:
                return "Service"
            case .product:
                return "Product"
        }
    }
}
