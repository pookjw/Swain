//
//  Toolchain+Tests.swift
//  
//
//  Created by Jinwoo Kim on 1/14/24.
//

import Testing
@testable import SwainCore

extension Toolchain {
    struct Tests {
        @Test(.tags(["test_initStable"])) func test_initStable() async throws {
            try await ToolchainManager.shared.configure()
            
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-5.9.2-RELEASE")
            #expect(toolchain?.category == .stable)
            #expect(toolchain?.name == "swift-5.9.2-RELEASE")
        }
        
        @Test(.tags(["test_initRelease"])) func test_initRelease() async throws {
            try await ToolchainManager.shared.configure()
            
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
            #expect(toolchain?.category == .release)
            #expect(toolchain?.name == "swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
        }
        
        @Test(.tags(["test_initMain"])) func test_initMain() async throws {
            try await ToolchainManager.shared.configure()
            
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
            #expect(toolchain?.category == .main)
            #expect(toolchain?.name == "swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
        }
        
        @Test(.tags(["test_packageURLStringForStable"])) func test_packageURLStringForStable() async throws {
            try await ToolchainManager.shared.configure()
            
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-5.9.2-RELEASE")
            #expect(toolchain?.packageURLString == "https://download.swift.org/swift-5.9.2-release/xcode/swift-5.9.2-RELEASE/swift-5.9.2-RELEASE-osx.pkg")
        }
        
        @Test(.tags(["test_packageURLStringForRelease"])) func test_packageURLStringForRelease() async throws {
            try await ToolchainManager.shared.configure()
            
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
            #expect(toolchain?.packageURLString == "https://download.swift.org/swift-5.10-branch/xcode/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a-osx.pkg")
        }
        
        @Test(.tags(["test_packageURLStringForMain"])) func test_packageURLStringForMain() async throws {
            try await ToolchainManager.shared.configure()
            
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
            #expect(toolchain?.packageURLString == "https://download.swift.org/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a-osx.pkg")
        }
    }
}
