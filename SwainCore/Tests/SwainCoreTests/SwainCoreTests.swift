//
//  File.swift
//  
//
//  Created by Jinwoo Kim on 1/13/24.
//

import XCTest
import Testing
@testable @_spi(SwainCoreTests) import SwainCore

final class SwainCoreTests: XCTestCase {
    override func setUp() async throws {
        _ = try await ToolchainDataManager.shared.modelContext
    }
    
    override func tearDown() async throws {
        try await ToolchainDataManager.shared.destory()
    }
    
    func testAll() async {
        await XCTestScaffold.runAllTests(hostedBy: self)
    }
}
