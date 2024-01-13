//
//  GitHub.swift
//  
//
//  Created by Jinwoo Kim on 1/13/24.
//

import FoundationEssentials
import FoundationInternationalization
import AsyncHTTPClient
import NIOHTTP1

struct GitHub: Sendable {
    enum Error: Swift.Error {
        case unexpectedStatus(NIOHTTP1.HTTPResponseStatus)
    }
    
    func swiftReleases(perPage: Int = 100, page: Int = 1) async throws -> [Release] {
        try await request(path: "/repos/apple/swift/releases?per_page=\(perPage)&page=\(page)")
    }
    
    private func request<T: Decodable & Sendable>(path: String) async throws -> T {
        var request: AsyncHTTPClient.HTTPClientRequest = .init(url: "https://api.github.com\(path)")
        request.method = .GET
        request.headers = [
            "Accept": "application/vnd.github+json",
            "Authorization": "5a4d690ae4c3ca0616d131da2f807e49aec1f615",
            "User-Agent": "PostmanRuntime/7.30.0"
        ]
        
        let client: AsyncHTTPClient.HTTPClient = .init(eventLoopGroupProvider: .singleton)
        let response: AsyncHTTPClient.HTTPClientResponse = try await client.execute(request, timeout: .minutes(1))
        
        var data: FoundationEssentials.Data = .init()
        for try await buffer in response.body {
            buffer.readableBytesView.withUnsafeBytes { p in
                data.append(p.assumingMemoryBound(to: UInt8.self).baseAddress!, count: buffer.readableBytesView.count)
            }
        }
        
        try await client.shutdown()
        
        response.headers.
        
        guard response.status == .ok else {
            if let string: String = .init(data: data, encoding: .utf8) {
                print(string)
            }
            
            throw Error.unexpectedStatus(response.status)
        }
        
        let jsonDecoder: FoundationEssentials.JSONDecoder = .init()
        jsonDecoder.dateDecodingStrategy = .custom({ decoder in
            let dateString: String = try decoder.singleValueContainer().decode(String.self)
            let forammter: FoundationEssentials.Date.ISO8601FormatStyle = .init()
            return try forammter.parse(dateString)
        })
        
        return try jsonDecoder.decode(T.self, from: data)
    }
}
