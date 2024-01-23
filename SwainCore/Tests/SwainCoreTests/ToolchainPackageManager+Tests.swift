//
//  ToolchainPackageManager+Tests.swift
//  
//
//  Created by Jinwoo Kim on 1/22/24.
//

import Testing
@testable import SwainCore

extension ToolchainPackageManager {
    struct Tests {
        @Test(.tags(["test_packageURLStringForStable"])) func test_packageURLStringForStable() async throws {
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-5.9.2-RELEASE")
            let unwrappedToolchain: Toolchain = try #require(toolchain)
            let packageURLString: String? = await ToolchainPackageManager.shared.packageURLString(for: unwrappedToolchain)
            let unwrappedPackageURLString = try #require(packageURLString)
            
            #expect(unwrappedPackageURLString == "https://download.swift.org/swift-5.9.2-release/xcode/swift-5.9.2-RELEASE/swift-5.9.2-RELEASE-osx.pkg")
        }
        
        @Test(.tags(["test_packageURLStringForRelease"])) func test_packageURLStringForRelease() async throws {
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
            let unwrappedToolchain: Toolchain = try #require(toolchain)
            let packageURLString: String? = await ToolchainPackageManager.shared.packageURLString(for: unwrappedToolchain)
            let unwrappedPackageURLString = try #require(packageURLString)
            
            #expect(unwrappedPackageURLString == "https://download.swift.org/swift-5.10-branch/xcode/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a-osx.pkg")
        }
        
        @Test(.tags(["test_packageURLStringForMain"])) func test_packageURLStringForMain() async throws {
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
            let unwrappedToolchain: Toolchain = try #require(toolchain)
            let packageURLString: String? = await ToolchainPackageManager.shared.packageURLString(for: unwrappedToolchain)
            let unwrappedPackageURLString = try #require(packageURLString)
            
            #expect(unwrappedPackageURLString == "https://download.swift.org/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a-osx.pkg")
        }
        
        @Test(.tags(["test_download"])) func test_download() async throws {
            let toolchain: Toolchain? = .init(refName: "refs/tags/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a")
            let unwrappedToolchain: Toolchain = try #require(toolchain)
            
            let progressPtr: UnsafeMutablePointer<Progress?> = .allocate(capacity: 1) 
            let downloadedURL: URL = try await ToolchainPackageManager.shared.download(for: unwrappedToolchain) { _progress in
                progressPtr.pointee = _progress
            }
            
            let progress: Progress = #require(progressPtr.pointee)
            #expect(progress.isFinished)
            
            let exists: Int32 = access(downloadedURL.path(percentEncoded: false).cString(using: .utf8), F_OK)
            #expect(exists == .zero)
        }
    }
}
