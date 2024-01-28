//
//  ToolchainPackageManager.swift
//
//
//  Created by Jinwoo Kim on 1/21/24.
//

import Foundation
import CoreFoundation
import CoreData
import AsyncHTTPClient
import NIOCore
import RegexBuilder
import Darwin

@globalActor
public actor ToolchainPackageManager {
    public enum Error: Swift.Error {
        case noManagedObjectContext
        case corrupted
    }
    
    public static let shared: ToolchainPackageManager = .init()
    
    public static nonisolated func getSharedInstance() -> ToolchainPackageManager {
        .shared
    }
    
    public static nonisolated func getDidChangeToolchainPackagesNotificationName() -> String {
        "ToolchainPackageManagerDidChangeToolchainPackagesNotificationName"
    }
    
    public static nonisolated var deletedNamesKey: String {
        "deletedNamesKey"
    }
    
    public static nonisolated var insertedNamesKey: String {
        "insertedNamesKey"
    }
    
    public private(set) var toolchainPackages: [ToolchainPackage] {
        didSet {
            postNotificationForToolchainPackagesChanges(
                oldValue: oldValue,
                newValue: toolchainPackages
            )
        }
    }
    
    private let downloadsURL: URL = .applicationSupportDirectory
        .appending(path: "SwainCore", directoryHint: .isDirectory)
        .appending(path: "ToolchainPackages", directoryHint: .isDirectory)
    
    private init() {
        toolchainPackages = []
    }
    
    public func downloadedURL(for toolchain: Toolchain) async -> URL? {
        let name: String = toolchain.name
        return downloadedURL(name: name)
    }
    
    public func download(for toolchain: Toolchain, progressHandler: @escaping (@Sendable (_ progress: Progress) -> Void)) async throws -> URL {
        let (name, categoryType): (String, Toolchain.Category) = await MainActor.run {
            (toolchain.name, toolchain.categoryType)
        }
        
        return try await download(name: name, categoryType: categoryType, progressHandler: progressHandler)
    }
    
    public func packageURL(for name: String, category: String) async throws -> URL? {
        guard let categoryType: Toolchain.Category = .init(rawValue: category) else {
            return nil
        }
        
        guard
            let urlString: String = packageURLString(name: name, categoryType: categoryType),
            let url: URL = .init(string: urlString)
        else {
            return nil
        }
        
        return url
    }
    
    public nonisolated func getToolchainPackages(completionHandler: UnsafeRawPointer) {
        typealias BlockType = @convention(block) @Sendable ([ToolchainPackage]) -> Void
        
        let copiedBlock: AnyObject = unsafeBitCast(completionHandler, to: AnyObject.self).copy() as AnyObject
        
        Task {
            let castedBlock: BlockType = unsafeBitCast(copiedBlock, to: BlockType.self)
            let toolchainPackages: [ToolchainPackage] = await toolchainPackages
            
            castedBlock(toolchainPackages)
        }
    }
    
    public nonisolated func getDownloadedURL(for name: String, completionHandler: UnsafeRawPointer) {
        typealias BlockType = @convention(block) @Sendable (URL?) -> Void
        
        let copiedBlock: AnyObject = unsafeBitCast(completionHandler, to: AnyObject.self).copy() as AnyObject
        
        Task {
            let castedBlock: BlockType = unsafeBitCast(copiedBlock, to: BlockType.self)
            
            let result: URL? = await downloadedURL(name: name)
            castedBlock(result)
        }
    }
    
    public nonisolated func download(
        for name: String,
        category: String,
        progressHandler: UnsafeRawPointer,
        completionHandler: UnsafeRawPointer
    ) {
        typealias ProgressHandlerType = @convention(block) @Sendable (Progress) -> Void
        typealias CompletionHandlerType = @convention(block) @Sendable (URL?, Swift.Error?) -> Void
        
        guard let categoryType: Toolchain.Category = .init(rawValue: category) else {
            let progress: Progress = .init(totalUnitCount: 1)
            progress.cancel()
            
            unsafeBitCast(progressHandler, to: ProgressHandlerType.self)(progress)
            unsafeBitCast(completionHandler, to: CompletionHandlerType.self)(nil, Error.corrupted)
            
            return
        }
        
        let copiedProgressHandler: AnyObject = unsafeBitCast(progressHandler, to: AnyObject.self).copy() as AnyObject
        let copiedCompletionHandler: AnyObject = unsafeBitCast(completionHandler, to: AnyObject.self).copy() as AnyObject
        
        Task {
            let castedProgressHandler: ProgressHandlerType = unsafeBitCast(copiedProgressHandler, to: ProgressHandlerType.self)
            let castedCompletionHandler: CompletionHandlerType = unsafeBitCast(copiedCompletionHandler, to: CompletionHandlerType.self)
            
            do {
                let result: URL = try await download(name: name, categoryType: categoryType, progressHandler: castedProgressHandler)
                castedCompletionHandler(result, nil)
            } catch {
                castedCompletionHandler(nil, error)
            }
        }
    }
}

extension ToolchainPackageManager {
    private nonisolated func destinationURL(name: String) -> URL {
        downloadsURL
            .appending(component: "\(name)-osx.pkg", directoryHint: .notDirectory)
    }
    
    private func downloadedURL(name: String) -> URL? {
        let url: URL = destinationURL(name: name)
        
        guard access(url.path(percentEncoded: false).cString(using: .utf8), F_OK) == .zero else {
            return nil
        }
        
        return url
    }
    
    private nonisolated func packageURLString(name: String, categoryType: Toolchain.Category) -> String? {
        switch categoryType {
        case .stable:
            let regex: Regex = .init {
                "swift-"
                Capture {
                    OneOrMore(.digit)
                }
                "."
                Capture {
                    OneOrMore(.digit)
                }
                "."
                Capture {
                    OneOrMore(.digit)
                }
            }
            
            
            guard let match: Regex.Match = name.firstMatch(of: regex) else {
                return nil
            }
            
            let version: String = "\(match.1).\(match.2).\(match.3)"
            
            return "https://download.swift.org/swift-\(version)-release/xcode/\(name)/\(name)-osx.pkg"
        case .release:
            let regex: Regex = .init {
                "swift-"
                Capture {
                    OneOrMore(.digit)
                }
                "."
                Capture {
                    OneOrMore(.digit)
                }
            }
            
            
            guard let match: Regex.Match = name.firstMatch(of: regex) else {
                return nil
            }
            
            let version: String = "\(match.1).\(match.2)"
            
            return "https://download.swift.org/swift-\(version)-branch/xcode/\(name)/\(name)-osx.pkg"
        case .main:
            return "https://download.swift.org/development/xcode/\(name)/\(name)-osx.pkg"
        }
    }
    
    private func download(name: String, categoryType: Toolchain.Category, progressHandler: @escaping (@Sendable (Progress) -> Void)) async throws -> URL {
        if let downloadedURL: URL = downloadedURL(name: name) {
            let progress: Progress = .init(totalUnitCount: 1)
            progress.completedUnitCount = 1
            
            toolchainPackages.append(.init(name: name, createdDate: .now, state: .downloaded(downloadedURL)))
            progressHandler(progress)
            return downloadedURL
        }
        
        var _progress: Progress?
        var _client: AsyncHTTPClient.HTTPClient?
        var _file: UnsafeMutablePointer<FILE>?
        
        do {
            guard let packageURLString: String = packageURLString(name: name, categoryType: categoryType) else {
                throw Error.corrupted
            }
            
            var request: AsyncHTTPClient.HTTPClientRequest = .init(url: packageURLString)
            request.method = .GET
            
            let client: AsyncHTTPClient.HTTPClient = .init(eventLoopGroupProvider: .singleton)
            _client = client
            let response: AsyncHTTPClient.HTTPClientResponse = try await client.execute(request, deadline: .distantFuture)
            
            /*
             [("Server", "dlb/1.0.2"), ("Date", "Mon, 22 Jan 2024 10:46:29 GMT"), ("Content-Type", "application/octet-stream"), ("Content-Length", "1250453964"), ("X-Responding-Server", "massilia_protocol_030:130011204:st49p01if-qufw02063901.st.if.apple.com:8083:24A14:7e5edf698261"), ("X-Apple-Request-UUID", "540dd1bf-8f12-4d09-a969-3aee39f789cf"), ("x-amz-storage-class", "STANDARD"), ("X-Apple-MS-Content-Length", "1250453964"), ("X-iCloud-Content-Length", "1250453964"), ("X-Apple-Request-UUID", "540dd1bf-8f12-4d09-a969-3aee39f789cf"), ("accept-ranges", "bytes"), ("x-apple-obj-store-current-version-id", "2d109de0-b139-11ee-a954-d8c497b452c9"), ("x-icloud-versionid", "2d109de0-b139-11ee-a954-d8c497b452c9"), ("ETag", "\"07A71A3A866675D4C5C89DDB9054F99A\""), ("Cache-Control", "max-age=3600, public"), ("Last-Modified", "Fri, 12 Jan 2024 10:56:02 GMT"), ("Strict-Transport-Security", "max-age=31536000; includeSubDomains;"), ("Age", "15"), ("Via", "http/1.1 jposa3-edge-lx-006.ts.apple.com (acdn/111.14403), https/1.1 jposa3-edge-bx-024.ts.apple.com (acdn/111.14403)"), ("X-Cache", "hit-fresh, miss"), ("CDNUUID", "57964a30-130a-4243-9084-6158333f0abf-2278002885"), ("Connection", "keep-alive"), ("Access-Control-Allow-Origin", "*")]
             */
            
            guard let contentLength: Int64 = response.headers.first(name: "Content-Length").flatMap(Int64.init) else {
                throw Error.corrupted
            }
            
            if access(downloadsURL.path(percentEncoded: false).cString(using: .utf8), F_OK) != .zero {
                let result: Int32 = mkdir(downloadsURL.path(percentEncoded: false), S_IRWXU | S_IRWXG | S_IRWXO)
                assert(result == .zero)
            }
            
            let destinationURL: URL = destinationURL(name: name)
            let destinationTmpURL: URL = destinationURL
                .appendingPathExtension("tmp")
            
            // TODO: resume
            if access(destinationURL.path(percentEncoded: false).cString(using: .utf8), F_OK) == .zero {
                assert(remove(destinationURL.path(percentEncoded: false).cString(using: .utf8)) != .zero)
            }
            
            let progress: Progress = .init(totalUnitCount: contentLength)
            
            progress.cancellationHandler = {
                client.shutdown { _ in
                    
                }
            }
            
            _progress = progress
            
            let toolchainPackage: ToolchainPackage = .init(
                name: name,
                createdDate: .now,
                state: .downloading(progress)
            )
            
            toolchainPackages.append(toolchainPackage)
            progressHandler(progress)
            
            let file: UnsafeMutablePointer<FILE> = fopen(destinationTmpURL.path(percentEncoded: false).cString(using: .utf8), "a+")
            _file = file
            
            for try await buffer in response.body {
                try Task.checkCancellation()
                
                if progress.isCancelled {
                    throw CancellationError()
                }
                
                buffer.readableBytesView.withUnsafeBytes { p in
                    let result: Int = fwrite(p.baseAddress, MemoryLayout<NIOCore.ByteBufferView.Element>.size, p.count, file)
                    assert(result != .zero)
                }
                
                progress.completedUnitCount += Int64(buffer.capacity)
            }
            
            try await client.shutdown()
            assert(fclose(file) == .zero)
            
            let renameResult: Int32 = rename(
                destinationTmpURL.path(percentEncoded: false).cString(using: .utf8),
                destinationURL.path(percentEncoded: false).cString(using: .utf8)
            )
            assert(renameResult == .zero)
            
            toolchainPackage.state = .downloaded(destinationURL)
            
            return destinationURL
        } catch {
            if let _progress: Progress {
                _progress.cancel()
            } else {
                let progress: Progress = .init(totalUnitCount: 1)
                progress.cancel()
                progressHandler(progress)
            }
            
            if let _client: AsyncHTTPClient.HTTPClient {
                try await _client.shutdown()
            }
            
            if let _file: UnsafeMutablePointer<FILE> {
                assert(fclose(_file) == .zero)
            }
            
            throw error
        }
    }
    
    private func postNotificationForToolchainPackagesChanges(
        oldValue: [ToolchainPackage],
        newValue: [ToolchainPackage]
    ) {
        guard oldValue != newValue else { return }
        
        let difference: CollectionDifference<ToolchainPackage> = newValue.difference(from: oldValue)
        guard !difference.isEmpty else { return }
        
        let userInfo: CFMutableDictionary = withUnsafePointer(to: kCFTypeDictionaryKeyCallBacks) { p1 in
            withUnsafePointer(to: kCFTypeDictionaryValueCallBacks) { p2 in
                CFDictionaryCreateMutable(
                    kCFAllocatorDefault,
                    .zero,
                    p1,
                    p2
                )
            }
        }
        
        //
        
        let removals: [CollectionDifference<ToolchainPackage>.Change] = difference.removals
        if !removals.isEmpty {
            let deletedNames: CFMutableSet = withUnsafePointer(to: kCFTypeSetCallBacks) { p in
                CFSetCreateMutable(kCFAllocatorDefault, removals.count, p)
            }
            
            for removal in removals {
                switch removal {
                case .remove(let offset, let element, let associatedWith):
                    let name: CFString = CFStringCreateWithCString(
                        kCFAllocatorDefault,
                        element.name,
                        CFStringBuiltInEncodings.UTF8.rawValue
                    )
                    
                    CFSetAddValue(deletedNames, unsafeBitCast(name, to: UnsafeRawPointer.self))
                default:
                    break
                }
            }
            
            let key: CFString = CFStringCreateWithCString(
                kCFAllocatorDefault,
                ToolchainPackageManager.deletedNamesKey,
                CFStringBuiltInEncodings.UTF8.rawValue
            )
            
            CFDictionarySetValue(
                userInfo,
                unsafeBitCast(key, to: UnsafeRawPointer.self),
                unsafeBitCast(deletedNames, to: UnsafeRawPointer.self)
            )
        }
        
        //
        
        let insertions: [CollectionDifference<ToolchainPackage>.Change] = difference.insertions
        if !insertions.isEmpty {
            let insertedNames: CFMutableSet = withUnsafePointer(to: kCFTypeSetCallBacks) { p in
                CFSetCreateMutable(kCFAllocatorDefault, insertions.count, p)
            }
            
            for insertion in insertions {
                switch insertion {
                case .insert(let offset, let element, let associatedWith):
                    let name: CFString = CFStringCreateWithCString(
                        kCFAllocatorDefault,
                        element.name,
                        CFStringBuiltInEncodings.UTF8.rawValue
                    )
                    
                    CFSetAddValue(insertedNames, unsafeBitCast(name, to: UnsafeRawPointer.self))
                default:
                    break
                }
            }
            
            let key: CFString = CFStringCreateWithCString(
                kCFAllocatorDefault,
                ToolchainPackageManager.insertedNamesKey,
                CFStringBuiltInEncodings.UTF8.rawValue
            )
            
            CFDictionarySetValue(
                userInfo,
                unsafeBitCast(key, to: UnsafeRawPointer.self),
                unsafeBitCast(insertedNames, to: UnsafeRawPointer.self)
            )
        }
        
        //
        
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetLocalCenter(),
            .init(
                rawValue: CFStringCreateWithCString(
                    kCFAllocatorDefault,
                    ToolchainPackageManager.getDidChangeToolchainPackagesNotificationName(),
                    CFStringBuiltInEncodings.UTF8.rawValue
                )
            ),
            Unmanaged<ToolchainPackageManager>.passUnretained(self).toOpaque(),
            userInfo,
            .init(true)
        )
    }
}
