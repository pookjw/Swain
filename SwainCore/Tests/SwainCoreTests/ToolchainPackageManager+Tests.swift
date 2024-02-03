//
//  ToolchainPackageManager+Tests.swift
//  
//
//  Created by Jinwoo Kim on 1/22/24.
//

import Testing
@testable @_spi(SwainCoreTests) import SwainCore

extension ToolchainPackageManager {
    struct Tests {
        @Test(.tags("test_packageURLStringForStable")) func test_packageURLStringForStable() async throws {
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-5.9.2-RELEASE")
            let unwrappedToolchain: Toolchain = try #require(toolchain)
            let packageURLString: String? = ToolchainPackageManager
                .shared
                .packageURLString(
                    name: unwrappedToolchain.name,
                    categoryType: unwrappedToolchain.categoryType
                )
            let unwrappedPackageURLString = try #require(packageURLString)
            
            #expect(unwrappedPackageURLString == "https://download.swift.org/swift-5.9.2-release/xcode/swift-5.9.2-RELEASE/swift-5.9.2-RELEASE-osx.pkg")
        }
        
        @Test(.tags("test_packageURLStringForRelease")) func test_packageURLStringForRelease() async throws {
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
            let unwrappedToolchain: Toolchain = try #require(toolchain)
            let packageURLString: String? = ToolchainPackageManager
                .shared
                .packageURLString(
                    name: unwrappedToolchain.name,
                    categoryType: unwrappedToolchain.categoryType
                )
            let unwrappedPackageURLString = try #require(packageURLString)
            
            #expect(unwrappedPackageURLString == "https://download.swift.org/swift-5.10-branch/xcode/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a-osx.pkg")
        }
        
        @Test(.tags("test_packageURLStringForMain")) func test_packageURLStringForMain() async throws {
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
            let unwrappedToolchain: Toolchain = try #require(toolchain)
            let packageURLString: String? = ToolchainPackageManager
                .shared
                .packageURLString(
                    name: unwrappedToolchain.name,
                    categoryType: unwrappedToolchain.categoryType
                )
            let unwrappedPackageURLString = try #require(packageURLString)
            
            #expect(unwrappedPackageURLString == "https://download.swift.org/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a-osx.pkg")
        }
        
        @Test(.tags("test_download")) func test_download() async throws {
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
            let unwrappedToolchain: Toolchain = try #require(toolchain)
            
            let destinationURL: Foundation.URL = ToolchainPackageManager
                .shared
                .destinationURL(name: unwrappedToolchain.name)
            
            if access(destinationURL.path(percentEncoded: false), F_OK) == .zero {
                #expect(remove(destinationURL.path(percentEncoded: false)) == .zero)
            }
            
            //
            
            var toolchainPackage: ToolchainPackage?
            var progressTask: Task<Void, Never>?
            let toolchainPackageHandler: @convention(block) (ToolchainPackage) -> Void = { _toolchainPackage in
                toolchainPackage = _toolchainPackage
                
                progressTask = .init {
                    guard case .downloading(let progress) = _toolchainPackage.state else {
                        return
                    }
                    
                    for await (progress, fractionCompleted) in progress.observeValues(\.fractionCompleted, options: [.initial, .new]) {
                        print(fractionCompleted.newValue ?? progress.fractionCompleted)
                        
                        if progress.isFinished {
                            break
                        }
                    }
                }
            }
            
            //
            
            let url: Foundation.URL = try await withCheckedThrowingContinuation { continuation in
                let completionHandler: @convention(block) (Foundation.URL?, Swift.Error?) -> Void = { url, error in
                    if let error: Swift.Error {
                        continuation.resume(with: .failure(error))
                    } else {
                        do {
                            let unwrappedURL: Foundation.URL = try #require(url)
                            continuation.resume(with: .success(unwrappedURL))
                        } catch {
                            continuation.resume(with: .failure(error))
                        }
                    }
                }
                
                ToolchainPackageManager
                    .shared
                    .download(
                        for: unwrappedToolchain.name,
                        category: unwrappedToolchain.category,
                        toolchainPackageHandler: unsafeBitCast(toolchainPackageHandler, to: UnsafeRawPointer.self),
                        completionHandler: unsafeBitCast(completionHandler, to: UnsafeRawPointer.self)
                    )
            }
            
            try await #require(progressTask).value
            
            let unwrappedToolchainPackage: ToolchainPackage = try #require(toolchainPackage)
            #expect(unwrappedToolchainPackage.state == .downloaded(url))
            
            print(url)
            #expect(access(url.path(percentEncoded: false), F_OK) == .zero)
            
            let toolchainPackages: [ToolchainPackage] = await ToolchainPackageManager.shared.toolchainPackages
            let contains: Bool = toolchainPackages
                .contains { toolchainPackage in
                    guard case .downloaded(let _url) = toolchainPackage.state else {
                        return false
                    }
                    
                    return _url == url
                }
            
            #expect(contains)
        }
    }
}
