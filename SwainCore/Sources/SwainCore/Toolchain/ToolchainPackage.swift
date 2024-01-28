//
//  ToolchainPackage.swift
//
//
//  Created by Jinwoo Kim on 1/28/24.
//

import Foundation
import FoundationPreview

@objc(SWCToolchainPackage)
public final class ToolchainPackage: NSObject, @unchecked Sendable {
    public enum State: Hashable, Sendable {
        case downloading(Progress)
        case downloaded(Foundation.URL)
    }
    
    @objc public let name: String
    
    public let createdDate: FoundationEssentials.Date
    
    @objc(createdDate) public var createdNSDate: NSDate {
        .init(timeIntervalSinceReferenceDate: createdDate.timeIntervalSinceReferenceDate)
    }
    
    public internal(set) var state: State {
        willSet {
            if state != newValue {
                willChangeValue(for: \.isDownloading)
                willChangeValue(for: \.downloadingProgress)
                willChangeValue(for: \.downloadedURL)
            }
        }
        didSet {
            if oldValue != state {
                didChangeValue(for: \.isDownloading)
                didChangeValue(for: \.downloadingProgress)
                didChangeValue(for: \.downloadedURL)
            }
        }
    }
    
    @objc public var isDownloading: Bool {
        switch state {
        case .downloading:
            true
        default:
            false
        }
    }
    
    @objc public var downloadingProgress: Progress? {
        switch state {
        case .downloading(let progress):
            return progress
        default:
            return nil
        }
    }
    
    @objc public var downloadedURL: Foundation.URL? {
        switch state {
        case .downloaded(let url):
            return url
        default:
            return nil
        }
    }
    
    public override var hash: Int {
        name.hash
    }
    
    init(name: String, createdDate: FoundationEssentials.Date, state: State) {
        self.name = name
        self.createdDate = createdDate
        self.state = state
        super.init()
    }
}
