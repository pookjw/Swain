//
//  File.swift
//  
//
//  Created by Jinwoo Kim on 1/13/24.
//

import XCTest
import Testing
import Darwin
@testable @_spi(SwainCoreTests) import SwainCore

final class SwainCoreTests: XCTestCase {
    override func setUp() async throws {
        _ = try await ToolchainDataManager.shared.modelContext
    }
    
    override func tearDown() async throws {
        try await ToolchainDataManager.shared.destory()
        
        let downloadsURL: Foundation.URL = ToolchainPackageManager.shared.downloadsURL
        print(downloadsURL)
        
        if access(downloadsURL.path(percentEncoded: false), F_OK) != .zero {
            XCTAssertEqual(remove(downloadsURL.path), .zero)
        }
    }
    
    func testAll() async {
        await XCTestScaffold.runAllTests(hostedBy: self)
    }
}
