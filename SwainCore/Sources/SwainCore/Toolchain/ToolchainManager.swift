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
    
    public var managedObjectContext: NSManagedObjectContext! {
        guard let modelContext: ModelContext else { return nil }
        
        return Mirror(reflecting: modelContext)
            .descendant("_nsContext") as? NSManagedObjectContext
    }
    
    public private(set) var modelContext: ModelContext!
    private var modelContainer: ModelContainer!
    
    private override init() {
        super.init()
    }
    
    @objc
    public func configure() async throws {
        guard modelContext == nil else { return }
        
        let url: URL = .applicationSupportDirectory
            .appending(component: "Toolchain", directoryHint: .notDirectory)
            .appendingPathExtension("sqlite")
        
        let configuration: ModelConfiguration = .init(
            "Toolchain",
            url: url
        )
        
        print(configuration.url)
        
        let modelContainer: ModelContainer = try .init(for: Toolchain.self, configurations: configuration)
        
        self.modelContainer = modelContainer
        self.modelContext = await modelContainer.mainContext
    }
    
    @AddObjCCompletionHandler
    public nonisolated func reloadToolchains() async throws {
        let refs: [GitHub.Ref] = try await GitHub.swiftRefs()
        try Task.checkCancellation()
        let modelContext: ModelContext = await modelContext
        
        try await MainActor.run {
            try modelContext.delete(model: Toolchain.self)
            
            for ref in refs {
                guard let toolchain: Toolchain = .init(refName: ref.ref) else {
                    continue
                }
                
                modelContext.insert(toolchain)
            }
            
            try modelContext.save()
        }
    }
    
    @_spi(SwainCoreTests) public func destory() async throws {
        guard let modelContainer: ModelContainer else { return }
        
        modelContainer.deleteAllData()
        
        for configuration in modelContainer.configurations {
            let url: URL = configuration.url
            let lastPathComponent: String = url.lastPathComponent
            
            try FileManager.default.removeItem(at: url)
            try FileManager.default.removeItem(at: url.deletingLastPathComponent().appending(component: "\(lastPathComponent)-shm"))
            try FileManager.default.removeItem(at: url.deletingLastPathComponent().appending(component: "\(lastPathComponent)-wal"))
        }
        
        self.modelContext = nil
        self.modelContainer = nil
    }
}
