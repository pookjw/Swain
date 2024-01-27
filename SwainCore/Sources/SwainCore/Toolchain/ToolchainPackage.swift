//
//  ToolchainPackage.swift
//
//
//  Created by Jinwoo Kim on 1/28/24.
//

import Foundation
import FoundationPreview

public struct ToolchainPackage: Hashable, Identifiable, Sendable {
    public var id: String { name }
    
    public enum State: Hashable, Identifiable, Sendable {
        public var id: Int {
            hashValue
        }
        
        case downloading(Progress)
        case downloaded(Foundation.URL)
    }
    
    public let name: String
    
    public let createdDate: FoundationEssentials.Date
    public var createdDateRef: UnsafeRawPointer {
        let nsDate: NSDate = .init(timeIntervalSinceReferenceDate: createdDate.timeIntervalSinceReferenceDate)
        return unsafeBitCast(nsDate, to: UnsafeRawPointer.self)
    }
    
    public let state: State
    
    public var isDownloading: Bool {
        switch state {
        case .downloading(let progress):
            true
        default:
            false
        }
    }
    
    public var downloadingProgressRef: UnsafeRawPointer? {
        switch state {
        case .downloading(let progress):
            return .init(Unmanaged<Progress>.passUnretained(progress).toOpaque())
        default:
            return nil
        }
    }
    
    public var downloadedURLRef: UnsafeRawPointer? {
        switch state {
        case .downloaded(let url):
            return .init(Unmanaged<NSURL>.passUnretained(url as NSURL).toOpaque())
        default:
            return nil
        }
    }
}

public func foo() -> ToolchainPackage { fatalError() }
