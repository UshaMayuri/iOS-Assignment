//
//  ViewModel.swift
//  Swipe Assignment
//
//  Created by usha mayuri on 20/07/24.
//

import Foundation
import SwiftUI

//ViewModel
class ProductViewModel : ObservableObject {
    
    @Published var modelData: [Response]?
    @Published var errorMessage: String?
    
    static let shared = ProductViewModel()
    
    let decoder = JSONDecoder()
    
    // Asynchronous function to fetch product details from the API
    func getDetails() async throws {
        let endpoint = "https://app.getswipe.in/api/public/get"
            
        guard let url = URL(string: endpoint) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
            try await MainActor.run {
                self.modelData = try decoder.decode([Response].self, from: data)
            }
        } catch {
            throw error
        }
    }
    
    // Asynchronous function to post product details to the API
    
    func postDetails(product: PostProduct) async throws -> Bool {
        var multipart = MultipartRequest()
        for field in [
            "product_name": "\(product.productName)",
            "product_type": "\(product.productType)",
            "tax": "\(product.tax)",
            "price": "\(product.price)",
        ] {
            multipart.add(key: field.key, value: field.value)
        }
        
        if let image = product.image {
            multipart.add(
                key: "files[]",
                fileName: "pic.jpg",
                fileMimeType: "image/png",
                fileData: image
            )
        }
        
        let url = URL(string: "https://app.getswipe.in/api/public/add")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(multipart.httpContentTypeHeadeValue, forHTTPHeaderField: "Content-Type")
        request.httpBody = multipart.httpBody
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let simpleResponse = try decoder.decode(SimpleResponseModel.self, from: data)
        return simpleResponse.success
    }
}

//to define network errors and provide localized error descriptions

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The server responded with an error."
        case .invalidData:
            return "The data received from the server is invalid."
        }
    }
}

public extension Data {
    
    mutating func append(
        _ string: String,
        encoding: String.Encoding = .utf8
    ) {
        guard let data = string.data(using: encoding) else {
            return
        }
        append(data)
    }
}

// to handle multipart/form-data requests
public struct MultipartRequest {
    
    public let boundary: String
    
    private let separator: String = "\r\n"
    private var data: Data
    
    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
        self.data = .init()
    }
    
    private mutating func appendBoundarySeparator() {
        data.append("--\(boundary)\(separator)")
    }
    
    private mutating func appendSeparator() {
        data.append(separator)
    }
    
    private func disposition(_ key: String) -> String {
        "Content-Disposition: form-data; name=\"\(key)\""
    }
    
    // Function to add a key-value pair to the request
    public mutating func add(
        key: String,
        value: String
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + separator)
        appendSeparator()
        data.append(value + separator)
    }
    
    // Function to add a file to the request
    public mutating func add(
        key: String,
        fileName: String,
        fileMimeType: String,
        fileData: Data
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + "; filename=\"\(fileName)\"" + separator)
        data.append("Content-Type: \(fileMimeType)" + separator + separator)
        data.append(fileData)
        appendSeparator()
    }
    
    public var httpContentTypeHeadeValue: String {
        "multipart/form-data; boundary=\(boundary)"
    }
    
    public var httpBody: Data {
        var bodyData = data
        bodyData.append("--\(boundary)--")
        return bodyData
    }
}
