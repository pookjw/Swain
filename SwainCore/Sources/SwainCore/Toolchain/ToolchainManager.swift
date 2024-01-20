//
//  ToolchainManager.swift
//  
//
//  Created by Jinwoo Kim on 1/15/24.
//

import Foundation
@_exported import SwiftData
@_exported import CoreData
import HandyMacros

@globalActor
@objc(SWCToolchainManager)
public actor ToolchainManager: NSObject {
    @objc(sharedInstance) public static let shared: ToolchainManager = .init()
    
    public var modelContext: ModelContext {
        get async throws {
            if let _modelContext: ModelContext {
                return _modelContext
            }
            
            let modelContext: ModelContext = try await modelContainer.mainContext
            _modelContext = modelContext
            
            return modelContext
        }
    }
    
    public var modelContainer: ModelContainer {
        get async throws {
            if let _modelContainer: ModelContainer {
                return _modelContainer
            }
            
            let url: URL = .applicationSupportDirectory
                .appending(path: "SwainCore", directoryHint: .isDirectory)
                .appending(component: "Toolchain", directoryHint: .notDirectory)
                .appendingPathExtension("sqlite")
            
            let configuration: ModelConfiguration = .init(
                "Toolchain",
                url: url
            )
            
            print(configuration.url)
            
            let modelContainer: ModelContainer = try .init(for: Toolchain.self, configurations: configuration)
            
            _modelContainer = modelContainer
            
            return modelContainer
        }
    }
    
    private var _modelContext: ModelContext?
    private var _modelContainer: ModelContainer?
    
    private override init() {
        super.init()
    }
    
    @objc public func managedObjectContext() async throws -> NSManagedObjectContext! {
        let modelContext: ModelContext = try await modelContext
        
        return Mirror(reflecting: modelContext)
            .descendant("_nsContext") as? NSManagedObjectContext
    }
    
    @AddObjCCompletionHandler
    public nonisolated func reloadToolchains() async throws {
        let refs: [GitHub.Ref] = try await GitHub.swiftRefs()
        try Task.checkCancellation()
        let modelContext: ModelContext = try await modelContext
        
        try await MainActor.run {
            try modelContext.delete(model: Toolchain.self)
            
            try modelContext.save()
            
            let f = FetchDescriptor<Toolchain>.init()
            let count = try modelContext.fetchCount(f)
            print(count)
            
            for (index, ref) in refs.enumerated() {
                guard let toolchain: Toolchain = .init(refName: ref.ref) else {
                    continue
                }
                
                modelContext.insert(toolchain)
                
                if index > .zero, index % 500 == .zero {
                    try modelContext.save()
                }
            }
            
            try modelContext.save()
        }
    }
    
    @_spi(SwainCoreTests) public func destory() async throws {
        let modelContainer: ModelContainer = try await modelContainer
        
        modelContainer.deleteAllData()
        
        for configuration in modelContainer.configurations {
            let url: URL = configuration.url
            let lastPathComponent: String = url.lastPathComponent
            
            try FileManager.default.removeItem(at: url)
            try FileManager.default.removeItem(at: url.deletingLastPathComponent().appending(component: "\(lastPathComponent)-shm"))
            try FileManager.default.removeItem(at: url.deletingLastPathComponent().appending(component: "\(lastPathComponent)-wal"))
        }
        
        _modelContext = nil
        _modelContainer = nil
    }
}
