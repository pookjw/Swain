//
//  ToolchainPackageManager.swift
//  
//
//  Created by Jinwoo Kim on 1/21/24.
//

import Foundation
import CoreData
import AsyncHTTPClient
import NIOCore
import RegexBuilder
import Darwin

@globalActor
@objc(SWCToolchainPackageManager)
public actor ToolchainPackageManager: NSObject {
    public enum Error: Swift.Error {
        case noManagedObjectContext
        case corrupted
    }
    
    @objc(sharedInstance)
    public static let shared: ToolchainPackageManager = .init()
    
    private let downloadsURL: URL = .applicationSupportDirectory
        .appending(path: "SwainCore", directoryHint: .isDirectory)
        .appending(path: "Downloads", directoryHint: .isDirectory)
    
    private override init() {
        super.init()
    }
}

extension ToolchainPackageManager {
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
    
    public func packageURLString(for toolchain: Toolchain) async -> String? {
        let (name, categoryType): (String, Toolchain.Category) = await MainActor.run {
            (toolchain.name, toolchain.categoryType)
        }
        
        return packageURLString(name: name, categoryType: categoryType)
    }
}
 
extension ToolchainPackageManager {
    @objc public func downloadedURL(for toolchain: NSManagedObject) async throws -> URL? {
        guard let managedObjectContext: NSManagedObjectContext = toolchain.managedObjectContext else {
            throw Error.noManagedObjectContext
        }
        
        let name: Any? = await managedObjectContext.perform { 
            toolchain.value(forKey: "name")
        }
        
        guard let name: String = name as? String else {
            throw Error.corrupted
        }
        
        return downloadedURL(name: name)
    }
    
    @objc public func download(for toolchain: NSManagedObject, progressHandler: @escaping (@Sendable (_ progress: Progress) -> Void)) async throws -> URL {
        let (name, categoryType): (String, Toolchain.Category) = try await metadata(from: toolchain)
        
        return try await download(name: name, categoryType: categoryType, progressHandler: progressHandler)
    }
    
    @objc public func packageURL(for toolchain: NSManagedObject) async throws -> URL? {
        let (name, categoryType): (String, Toolchain.Category) = try await metadata(from: toolchain)
        
        guard
            let urlString: String = packageURLString(name: name, categoryType: categoryType),
            let url: URL = .init(string: urlString)
        else {
            return nil
        }
        
        return url
    }
}
 
extension ToolchainPackageManager {
    private func metadata(from toolchain: NSManagedObject) async throws -> (String, Toolchain.Category) {
        guard let managedObjectContext: NSManagedObjectContext = toolchain.managedObjectContext else {
            throw Error.noManagedObjectContext
        }
        
        let (name, category): (Any?, Any?) = await managedObjectContext.perform { 
            (toolchain.value(forKey: "name"), toolchain.value(forKey: "category"))
        }
        
        guard
            let name: String = name as? String,
            let category: String = category as? String,
            let categoryType: Toolchain.Category = .init(rawValue: category)
        else {
            throw Error.corrupted
        }
        
        return (name, categoryType)
    }
    
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
            
            let destinationURL: URL = destinationURL(name: name)
            let destinationTmpURL: URL = destinationURL
                .appendingPathExtension("tmp")
            
            // TODO: resume
            if access(destinationURL.path(percentEncoded: false).cString(using: .utf8), F_OK) == .zero {
                assert(remove(destinationURL.path(percentEncoded: false).cString(using: .utf8)) != .zero)
            }
            
            let progress: Progress = .init(totalUnitCount: contentLength)
            _progress = progress
            progressHandler(progress)
            
            let file: UnsafeMutablePointer<FILE> = fopen(destinationTmpURL.path(percentEncoded: false).cString(using: .utf8), "a+")
            _file = file
            
            for try await buffer in response.body {
                buffer.readableBytesView.withUnsafeBytes { p in
                    let result: Int = fwrite(p.baseAddress, MemoryLayout<NIOCore.ByteBufferView.Element>.size, p.count, file)
                    assert(result != .zero)
                }
                
                progress.completedUnitCount += Int64(buffer.capacity)
                print(destinationTmpURL, progress.fractionCompleted)
            }
            
            try await client.shutdown()
            assert(fclose(file) == .zero)
            
            let renameResult: Int32 = rename(
                destinationTmpURL.path(percentEncoded: false).cString(using: .utf8),
                destinationURL.path(percentEncoded: false).cString(using: .utf8)
            )
            assert(renameResult == .zero)
            
            return destinationURL
        } catch {
            if _progress == nil {
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
}
