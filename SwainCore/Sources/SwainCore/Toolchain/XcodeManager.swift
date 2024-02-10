//
//  XcodeManager.swift
//
//
//  Created by Jinwoo Kim on 2/10/24.
//

import Foundation
import UniformTypeIdentifiers
import Darwin

@globalActor
public actor XcodeManager {
    public enum Error: Swift.Error {
        case notInstalled
        case valueNotFound
        case failedToParseFile
    }
    
    public static let shared: XcodeManager = .init()
    
    public static func getSharedInstance() -> XcodeManager {
        .shared
    }
    
    private nonisolated let prefsURL: Foundation.URL = Foundation
        .FileManager
        .default
        .urls(for: .libraryDirectory, in: .userDomainMask)
        .first!
        .appending(path: "Preferences", directoryHint: .isDirectory)
        .appendingPathComponent("com.apple.dt.Xcode", conformingTo: .propertyList)
    
    private nonisolated let installedToolchainsURL: Foundation.URL = Foundation
        .FileManager
        .default
        .urls(for: .libraryDirectory, in: .localDomainMask)
        .first!
        .appending(path: "Developer", directoryHint: .isDirectory)
        .appending(path: "Toolchains", directoryHint: .isDirectory)
    
    private init() {
        
    }
    
    public nonisolated func installedToolchainNames(completionHandler: UnsafeRawPointer) {
        typealias CompletionHandlerType = @convention(block) @Sendable (NSArray?, Swift.Error?) -> Void
        
        let copiedCompletionHandler: AnyObject = unsafeBitCast(completionHandler, to: AnyObject.self).copy() as AnyObject
        
        Task {
            let castedCompletionHandler: CompletionHandlerType = unsafeBitCast(copiedCompletionHandler, to: CompletionHandlerType.self)
            
            do {
                let installedToolchainNames: [String] = try await installedToolchainNames
                
                castedCompletionHandler(installedToolchainNames as NSArray, nil)
            } catch {
                castedCompletionHandler(nil, error)
            }
        }
    }
    
    public nonisolated func selectedToolchainName(completionHandler: UnsafeRawPointer) {
        typealias CompletionHandlerType = @convention(block) @Sendable (String?, Swift.Error?) -> Void
        
        let copiedCompletionHandler: AnyObject = unsafeBitCast(completionHandler, to: AnyObject.self).copy() as AnyObject
        
        Task {
            let castedCompletionHandler: CompletionHandlerType = unsafeBitCast(copiedCompletionHandler, to: CompletionHandlerType.self)
            
            do {
                let selectedToolchainName: String? = try await selectedToolchainName
                
                castedCompletionHandler(selectedToolchainName, nil)
            } catch {
                castedCompletionHandler(nil, error)
            }
        }
    }
    
    public nonisolated func changeSelectedToolchain(toolchainName: String, completionHandler: UnsafeRawPointer) {
        typealias CompletionHandlerType = @convention(block) @Sendable (Swift.Error?) -> Void
        
        let copiedCompletionHandler: AnyObject = unsafeBitCast(completionHandler, to: AnyObject.self).copy() as AnyObject
        
        Task {
            let castedCompletionHandler: CompletionHandlerType = unsafeBitCast(copiedCompletionHandler, to: CompletionHandlerType.self)
            
            do {
                try await changeSelectedToolchain(toolchainName: toolchainName)
                castedCompletionHandler(nil)
            } catch {
                castedCompletionHandler(error)
            }
        }
    }
}

extension XcodeManager {
    private var installedToolchainNames: [String] {
        get throws {
            let toolchainURLs: [URL] = try FileManager
                .default
                .contentsOfDirectory(at: installedToolchainsURL, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "xctoolchain" }
            
            return try toolchainURLs
                .compactMap { toolchainURL in
                    let infoURL: URL = toolchainURL
                        .appendingPathComponent("Info", conformingTo: .propertyList)
                    
                    let dictionary: NSDictionary = try .init(contentsOf: infoURL, error: ())
                    
                    return dictionary["CFBundleIdentifier"] as? String
                }
        }
    }
    
    private var selectedToolchainBundleIdentifier: String? {
        get throws {
            let dictionary: NSDictionary = try .init(contentsOf: prefsURL, error: ())
            return dictionary["DVTDefaultToolchainOverrideIdentifer"] as? String
        }
    }
    
    private var selectedToolchainName: String? {
        get throws {
            guard let selectedToolchainBundleIdentifier: String = try selectedToolchainBundleIdentifier else {
                return nil
            }
            
            return try toolchainName(from: selectedToolchainBundleIdentifier)
        }
    }
    
    private func toolchainBundleIdentifier(from toolchainName: String) throws -> String {
        let infoURL: URL = installedToolchainsURL
            .appending(path: toolchainName, directoryHint: .notDirectory)
            .appendingPathExtension("xctoolchain")
            .appendingPathComponent("Info", conformingTo: .propertyList)
        
        guard access(infoURL.path(percentEncoded: false), F_OK) == .zero else {
            throw Error.notInstalled
        }
        
        let dictionary: NSDictionary = try .init(contentsOf: infoURL, error: ())
        
        guard let bundleIdentifier: String = dictionary["CFBundleIdentifier"] as? String else {
            throw Error.valueNotFound
        }
        
        return bundleIdentifier
    }
    
    private func toolchainName(from toolchainBundleIdentifier: String) throws -> String? {
        let toolchainURLs: [URL] = try FileManager
            .default
            .contentsOfDirectory(at: installedToolchainsURL, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "xctoolchain" }
        
        for toolchainURL in toolchainURLs {
            let infoURL: URL = toolchainURL
                .appendingPathComponent("Info", conformingTo: .propertyList)
            
            let dictionary: NSDictionary = try .init(contentsOf: infoURL, error: ())
            
            guard let bundleIdentifier: String = dictionary["CFBundleIdentifier"] as? String else {
                continue
            }
            
            if toolchainBundleIdentifier == bundleIdentifier {
                return bundleIdentifier
            }
        }
        
        return nil
    }
    
    private func changeSelectedToolchain(toolchainName: String) throws {
        let toolchainBundleIdentifier: String = try toolchainBundleIdentifier(from: toolchainName)
        try changeSelectedToolchain(toolchainBundleIdentifier: toolchainBundleIdentifier)
    }
    
    private func changeSelectedToolchain(toolchainBundleIdentifier: String) throws {
        guard let dictionary: NSMutableDictionary = try? .init(contentsOf: prefsURL, error: ())  else {
            throw Error.failedToParseFile
        }
        
        dictionary["DVTDefaultToolchainOverrideIdentifer"] = toolchainBundleIdentifier
        
        try dictionary.write(to: prefsURL)
    }
}
