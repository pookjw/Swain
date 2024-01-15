//
//  ToolchainManager+Tests.swift
//  
//
//  Created by Jinwoo Kim on 1/15/24.
//

import Testing
@testable import SwainCore

extension ToolchainManager {
    struct Tests {
        @Test(.tags(["test_configure"])) func test_configure() async throws {
            try await ToolchainManager.shared.configure()
        }
        
        @Test(.tags(["test_reloadToolchains"])) func test_reloadToolchains() async throws {
            try await ToolchainManager.shared.configure()
            try await ToolchainManager.shared.reloadToolchains()
            
            let modelContext: ModelContext! = await ToolchainManager.shared.modelContext
            #expect(modelContext != nil)
            
            let fetchDescriptor: FetchDescriptor<Toolchain> = .init()
            let toolchains: [Toolchain] = try modelContext.fetch(fetchDescriptor)
            #expect(!toolchains.isEmpty)
        }
        
        @Test(.tags(["test_managedObjectContext"])) func test_managedObjectContext() async throws {
            try await ToolchainManager.shared.configure()
            let managedObjectContext: NSManagedObjectContext? = await ToolchainManager.shared.managedObjectContext
            #expect(managedObjectContext != nil)
        }
    }
}
