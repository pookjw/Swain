//
//  ToolchainDataManager+Tests.swift
//  
//
//  Created by Jinwoo Kim on 1/15/24.
//

import Testing
@testable import SwainCore

extension ToolchainDataManager {
    struct Tests {
        @Test(.tags("test_configure")) func test_modelContext() async throws {
            _ = try await ToolchainDataManager.shared.modelContext
        }
        
        @Test(.tags("test_reloadToolchains")) func test_reloadToolchains() async throws {
            try await ToolchainDataManager.shared.reloadToolchains()
            
            let modelContext: ModelContext! = try await ToolchainDataManager.shared.modelContext
            #expect(modelContext != nil)
            
            let fetchDescriptor: FetchDescriptor<Toolchain> = .init()
            let toolchains: [Toolchain] = try modelContext.fetch(fetchDescriptor)
            #expect(!toolchains.isEmpty)
        }
        
        @Test(.tags("test_managedObjectContext")) func test_managedObjectContext() async throws {
            let managedObjectContext: NSManagedObjectContext? = try await ToolchainDataManager.shared.managedObjectContext()
            #expect(managedObjectContext != nil)
        }
    }
}
