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
import NIOCore

extension GitHub {
    enum Error: Swift.Error {
        case unexpectedStatus(NIOHTTP1.HTTPResponseStatus)
    }
    
    static func swiftRefs() async throws -> [Ref] {
        try await request(path: "/repos/apple/swift/git/refs/tags")
    }
    
    private static func request<T: Decodable>(path: String) async throws -> T {
        var _client: AsyncHTTPClient.HTTPClient?
        
        do {
            var request: AsyncHTTPClient.HTTPClientRequest = .init(url: "https://api.github.com\(path)")
            request.method = .GET
            request.headers = [
                "Accept": "application/vnd.github+json",
                "Authorization": "Basic YjU4YWM1N2NjMjIzNDIzOThhOWQwMWNjOGYwZjhlNWI6em5aME9zN3ozNDZ6Q3F3V0ZwNWcxcVJoaG5YUGIzT2Q=",
                "User-Agent": "SwainCore/1.0"
            ]
            
            let client: AsyncHTTPClient.HTTPClient = .init(eventLoopGroupProvider: .singleton)
            _client = client
            let response: AsyncHTTPClient.HTTPClientResponse = try await client.execute(request, timeout: .minutes(1))
            
            var data: FoundationEssentials.Data = .init()
            for try await buffer in response.body {
                buffer.readableBytesView.withUnsafeBytes { p in
                    data.append(p.assumingMemoryBound(to: NIOCore.ByteBufferView.Element.self).baseAddress!, count: p.count)
                }
            }
            
            try await client.shutdown()
            
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
            
            let decoded: T = try jsonDecoder.decode(T.self, from: data)
            
            return decoded
        } catch {
            if let _client: AsyncHTTPClient.HTTPClient {
                try await _client.shutdown()
            }
            
            throw error
        }
    }
}
