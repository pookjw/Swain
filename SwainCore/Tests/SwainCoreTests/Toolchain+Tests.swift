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
        @Test(.tags("test_initStable")) func test_initStable() {
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-5.9.2-RELEASE")
            #expect(toolchain?.categoryType == .stable)
            #expect(toolchain?.name == "swift-5.9.2-RELEASE")
        }
        
        @Test(.tags("test_initRelease")) func test_initRelease() {
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
            #expect(toolchain?.categoryType == .release)
            #expect(toolchain?.name == "swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
        }
        
        @Test(.tags("test_initMain")) func test_initMain() {
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
            #expect(toolchain?.categoryType == .main)
            #expect(toolchain?.name == "swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
        }
    }
}
