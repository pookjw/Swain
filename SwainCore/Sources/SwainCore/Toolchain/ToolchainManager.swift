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
        
        ValueTransformer.setValueTransformer(Toolchain._CategoryValueTransformer(), forName: .init("_CategoryValueTransformer"))
        
        let configuration: ModelConfiguration = .init()
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
}
