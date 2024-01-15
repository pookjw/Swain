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
        try await ToolchainManager.shared.configure()
    }
    
    override func tearDown() async throws {
        try await ToolchainManager.shared.destory()
    }
    
    func testAll() async {
        await XCTestScaffold.runAllTests(hostedBy: self)
    }
}
