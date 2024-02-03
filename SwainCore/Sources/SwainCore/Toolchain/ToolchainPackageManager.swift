//
//  ToolchainPackageManager.swift
//
//
//  Created by Jinwoo Kim on 1/21/24.
//

import Foundation
import CoreFoundation
import CoreData
import CoreServices
import AsyncHTTPClient
import NIOCore
import RegexBuilder
import Darwin
import UniformTypeIdentifiers
import ObjectiveC
import FoundationEssentials

extension ProgressUserInfoKey {
    public static var toolchainNameKey: ProgressUserInfoKey {
        .init("toolchainName")
    }
    
    public static var cancelReasonErrorKey: ProgressUserInfoKey {
        .init("cancelReasonError")
    }
}

extension UTType {
    static var installerPackage: UTType {
        .init("com.apple.installer-package-archive")!
    }
}

@globalActor
public actor ToolchainPackageManager {
    public enum Error: Swift.Error {
        case downloading
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
    
    public static nonisolated var toolchainNameProgressUserInfoKey: String {
        ProgressUserInfoKey.toolchainNameKey.rawValue
    }
    
    public static nonisolated var cancelReasonErrorProgressUserInfoKey: String {
        ProgressUserInfoKey.cancelReasonErrorKey.rawValue
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
    
    @_spi(SwainCoreTests)
    public nonisolated let downloadsURL: Foundation.URL = .applicationSupportDirectory
        .appending(path: "SwainCore", directoryHint: .isDirectory)
        .appending(path: "ToolchainPackages", directoryHint: .isDirectory)
    
    private let mdQuery: MDQuery
    private let mdQueryWeakPtrContext: UnsafeMutablePointer<AnyObject?> = .allocate(capacity: 1)

    private let notificationCallback: CFNotificationCallback = { notificationCenter, observer, notificationName, object, userInfo in
        guard
            let object: UnsafeRawPointer,
            let manager: ToolchainPackageManager = objc_loadWeak(unsafeBitCast(observer, to: AutoreleasingUnsafeMutablePointer<AnyObject?>.self)) as? ToolchainPackageManager
        else {
            return
        }
        
        let query: MDQuery = unsafeBitCast(object, to: MDQuery.self)
        manager.mdQueryDidUpdate(query)
    }
    
    private init() {
        toolchainPackages = []
        mdQueryInitlaizer = ()
        objc_storeWeak(.init(mdQueryWeakPtrContext), self)
        assert(MDQueryExecute(mdQuery, .init(kMDQueryWantsUpdates.rawValue)))
    }
    
    deinit {
        mdQueryWeakPtrContext.deallocate()
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
    
    public nonisolated func download(
        for name: String,
        category: String,
        toolchainPackageHandler: UnsafeRawPointer,
        completionHandler: UnsafeRawPointer
    ) {
        typealias ToolchainPackagrHandlerType = @convention(block) @Sendable (ToolchainPackage) -> Void
        typealias CompletionHandlerType = @convention(block) @Sendable (Foundation.URL?, Swift.Error?) -> Void
        
        guard let categoryType: Toolchain.Category = .init(rawValue: category) else {
            unsafeBitCast(completionHandler, to: CompletionHandlerType.self)(nil, Error.corrupted)
            return
        }
        
        let copiedToolchainPackageHandler: AnyObject = unsafeBitCast(toolchainPackageHandler, to: AnyObject.self).copy() as AnyObject
        let copiedCompletionHandler: AnyObject = unsafeBitCast(completionHandler, to: AnyObject.self).copy() as AnyObject
        
        Task {
            let castedToolchainPackageHandler: ToolchainPackagrHandlerType = unsafeBitCast(copiedToolchainPackageHandler, to: ToolchainPackagrHandlerType.self)
            let castedCompletionHandler: CompletionHandlerType = unsafeBitCast(copiedCompletionHandler, to: CompletionHandlerType.self)
            
            do {
                let result: Foundation.URL = try await download(
                    name: name,
                    categoryType: categoryType,
                    toolchainPackageHandler: castedToolchainPackageHandler
                )
                
                castedCompletionHandler(result, nil)
            } catch {
                castedCompletionHandler(nil, error)
            }
        }
    }
    
    private nonisolated var mdQueryInitlaizer: Void {
        @storageRestrictions(initializes: mdQuery, accesses: downloadsURL, mdQueryWeakPtrContext, notificationCallback)
        init(__) {
            let queryString: CFString = withVaList(
                [
                    CFStringGetCStringPtr(kMDItemContentType, CFStringBuiltInEncodings.UTF8.rawValue),
                    UTType.installerPackage.identifier
                ]
            ) { ptr in
                let format: CFString = CFStringCreateWithCString(
                    kCFAllocatorDefault, 
                    "%s == '%@'",
                    CFStringBuiltInEncodings.UTF8.rawValue
                )
                
                let result: CFString = CFStringCreateWithFormatAndArguments(
                    kCFAllocatorDefault,
                    nil,
                    format,
                    ptr
                )
                
                return result
            }
            
            let queryValues: UnsafeMutableBufferPointer<UnsafeRawPointer?> = .allocate(capacity: 2)
            
            queryValues[.zero] = unsafeBitCast(kMDItemFSName, to: UnsafeRawPointer.self)
            queryValues[1] = unsafeBitCast(kMDItemFSCreationDate, to: UnsafeRawPointer.self)
            
            let valueListAttrs: CFArray = withUnsafePointer(to: kCFTypeArrayCallBacks) { ptr in
                CFArrayCreate(
                    kCFAllocatorDefault,
                    queryValues.baseAddress,
                    queryValues.count,
                    ptr
                )
            }
            
            queryValues.deallocate()
            
            let mdQuery: MDQuery = withUnsafePointer(to: kCFTypeArrayCallBacks) { ptr_3 in
                MDQueryCreate(
                    kCFAllocatorDefault,
                    queryString,
                    valueListAttrs,
                    nil
                )  
            }
            
            let downloadsCFString: CFString = CFStringCreateWithCString(
                kCFAllocatorDefault,
                downloadsURL.path(),
                CFStringBuiltInEncodings.UTF8.rawValue
            )
            
            let downloadsCFURL: CFURL = CFURLCreateWithString(
                kCFAllocatorDefault,
                downloadsCFString,
                nil
            )
            
            withUnsafePointer(to: downloadsCFURL) { ptr_1 in
                ptr_1.withMemoryRebound(to: UnsafeRawPointer?.self, capacity: 1) { ptr_2 in
                    withUnsafePointer(to: kCFTypeArrayCallBacks) { ptr_3 in
                        MDQuerySetSearchScope(
                            mdQuery,
                            CFArrayCreate(
                                kCFAllocatorDefault,
                                .init(mutating: ptr_2),
                                1,
                                ptr_3
                            ),
                            .zero
                        )
                    }
                }
            }
            
            MDQuerySetDispatchQueue(mdQuery, .global())
            
            withUnsafePointer(to: kCFTypeArrayCallBacks) { [mdQueryWeakPtrContext] ptr in
                MDQuerySetCreateResultFunction(
                    mdQuery,
                    nil,
                    mdQueryWeakPtrContext,
                    ptr
                )
            }
            
            CFNotificationCenterAddObserver(
                CFNotificationCenterGetLocalCenter(),
                mdQueryWeakPtrContext,
                notificationCallback,
                kMDQueryDidFinishNotification,
                unsafeBitCast(mdQuery, to: UnsafeRawPointer.self),
                .deliverImmediately
            )
            
            CFNotificationCenterAddObserver(
                CFNotificationCenterGetLocalCenter(),
                mdQueryWeakPtrContext,
                notificationCallback,
                kMDQueryDidUpdateNotification,
                unsafeBitCast(mdQuery, to: UnsafeRawPointer.self),
                .deliverImmediately
            )
            
            self.mdQuery = mdQuery
        }
        get {
            
        }
    }
}

extension ToolchainPackageManager {
    @_spi(SwainCoreTests)
    public nonisolated func destinationURL(name: String) -> Foundation.URL {
        downloadsURL
            .appending(component: "\(name)-osx.pkg", directoryHint: .notDirectory)
    }
    
    @_spi(SwainCoreTests)
    public nonisolated func packageURLString(name: String, categoryType: Toolchain.Category) -> String? {
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
    
    private func download(
        name: String,
        categoryType: Toolchain.Category,
        toolchainPackageHandler: @escaping (@Sendable (ToolchainPackage) -> Void)
    ) async throws -> Foundation.URL {
        if let toolchainPackage: ToolchainPackage = toolchainPackages.first(where: { $0.name == name }) {
            toolchainPackageHandler(toolchainPackage)
            throw Error.downloading
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
            
            let destinationURL: Foundation.URL = destinationURL(name: name)
            let destinationTmpURL: Foundation.URL = destinationURL
                .appendingPathExtension("tmp")
            
            // TODO: resume
            if access(destinationURL.path(percentEncoded: false).cString(using: .utf8), F_OK) == .zero {
                assert(remove(destinationURL.path(percentEncoded: false).cString(using: .utf8)) != .zero)
            }
            
            let progress: Progress = .init(totalUnitCount: contentLength)
            progress.setUserInfoObject(name, forKey: .toolchainNameKey)
            
            progress.cancellationHandler = {
                client.shutdown { _ in
                    
                }
            }
            
            _progress = progress
            
            let toolchainPackage: ToolchainPackage = .init(
                name: name,
                creationDate: .now,
                state: .downloading(progress)
            )
            
            var toolchainPackages: [ToolchainPackage] = self.toolchainPackages
            toolchainPackages.append(toolchainPackage)
            toolchainPackages.sort { $0.creationDate > $1.creationDate }
            self.toolchainPackages = toolchainPackages
            
            toolchainPackageHandler(toolchainPackage)
            
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
                _progress.setUserInfoObject(error, forKey: .cancelReasonErrorKey)
                _progress.cancel()
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
            Unmanaged.passUnretained(self).toOpaque(),
            userInfo,
            .init(true)
        )
    }
    
    private nonisolated func mdQueryDidUpdate(_ query: MDQuery) {
        let count: CFIndex = MDQueryGetResultCount(query)
        
        guard count > .zero else {
            Task {
                await setToolchainPackages(.init())
            }
            return
        }
        
        var metadata: [(String, FoundationEssentials.Date)] = .init()
        
        for i in 0..<count {
            guard let nameRef: UnsafeMutableRawPointer = MDQueryGetAttributeValueOfResultAtIndex(query, kMDItemFSName, i) else {
                continue
            }
            
            guard let dateRef: UnsafeMutableRawPointer = MDQueryGetAttributeValueOfResultAtIndex(query, kMDItemFSCreationDate, i) else {
                continue
            }
            
            let name: String = .init(
                cString: CFStringGetCStringPtr(
                    unsafeBitCast(nameRef, to: CFString.self),
                    CFStringBuiltInEncodings.UTF8.rawValue
                )
            )
            
            let date: FoundationEssentials.Date = .init(
                timeIntervalSinceReferenceDate: CFDateGetAbsoluteTime(
                    unsafeBitCast(dateRef, to: CFDate.self)
                )
            )
            
            metadata.append((name, date))
        }
        
        Task { [metadata] in
            await updateToolchainPackages(metadata: metadata)
        }
    }
    
    private func updateToolchainPackages(metadata: [(String, FoundationEssentials.Date)]) {
        guard !metadata.isEmpty else {
            return
        }
        
        var toolchainPackages: [ToolchainPackage] = toolchainPackages
        
        for datum in metadata {
            guard !toolchainPackages.contains(where: { $0.name == datum.0 }) else {
                continue
            }
            
            let url: Foundation.URL = downloadsURL
                .appending(component: datum.0, directoryHint: .notDirectory)
            
            let toolchainPackage: ToolchainPackage = .init(
                name: datum.0,
                creationDate: datum.1,
                state: .downloaded(url)
            )
            
            toolchainPackages.append(toolchainPackage)
        }
        
        var removedIndexes: Set<Int> = .init()
        for (index, toolchainPackage) in toolchainPackages.enumerated() {
            guard !metadata.contains(where: { $0.0 == toolchainPackage.name }) else {
                continue
            }
            
            removedIndexes.insert(index)
        }
        
        for index in removedIndexes {
            toolchainPackages.remove(at: index)
        }
        
        toolchainPackages.sort(by: { $0.creationDate > $1.creationDate })
        
        self.toolchainPackages = toolchainPackages
    }
    
    private func setToolchainPackages(_ toolchainPackages: [ToolchainPackage]) {
        self.toolchainPackages = toolchainPackages
    }
}
