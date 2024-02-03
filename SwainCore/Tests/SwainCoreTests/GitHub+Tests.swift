//
//  GitHub+Tests.swift
//  
//
//  Created by Jinwoo Kim on 1/13/24.
//

import Testing
import FoundationEssentials
import UniformTypeIdentifiers
@testable import SwainCore

extension GitHub {
    struct Tests {
        @Test(.tags("test_swiftRefs")) func test_swiftRefs() async throws {
            let result: [GitHub.Ref] = try await GitHub.swiftRefs()
            #expect(!result.isEmpty)
        }
        
        @Test(.tags("test_decodeTag")) func test_decodeTag() throws {
            let url: Foundation.URL = try #require(Bundle.module.url(forResource: "ref_tag", withExtension: UTType.json.preferredFilenameExtension))
            let nsData: Foundation.NSData = try .init(contentsOf: url)
            
            let data: FoundationEssentials.Data = .init(bytes: nsData.bytes, count: nsData.length)
            let decoder: FoundationEssentials.JSONDecoder = .init()
            _ = try decoder.decode(GitHub.Ref.self, from: data)
        }
    }
}
