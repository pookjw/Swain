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
    @objc public static let stateKey: String = "state"
    @objc public static let downloadingState: String = "downloadingState"
    @objc public static let downloadedState: String = "downloadedState"
    
    @objc public static let downloadingProgressKey: String = "downloadingProgress"
    @objc public static let downloadedURLKey: String = "downloadedURL"
    
    public enum State: Hashable, Sendable {
        case downloading(Progress)
        case downloaded(Foundation.URL)
    }
    
    @objc public let name: String
    
    public let creationDate: FoundationEssentials.Date
    
    @objc(creationDate) public var creationNSDate: NSDate {
        .init(timeIntervalSinceReferenceDate: creationDate.timeIntervalSinceReferenceDate)
    }
    
    public internal(set) var state: State {
        willSet {
            if state != newValue {
                willChangeValue(for: \.stateInfo)
            }
        }
        didSet {
            if oldValue != state {
                didChangeValue(for: \.stateInfo)
            }
        }
    }
    
    @objc public var stateInfo: [String: Any] {
        switch state {
        case .downloading(let progress):
            return [
                Self.stateKey: Self.downloadingState,
                Self.downloadingProgressKey: progress
            ]
        case .downloaded(let url):
            return [
                Self.stateKey: Self.downloadedState,
                Self.downloadedURLKey: url
            ]
        }
    }
    
    public override var hash: Int {
        name.hash
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        if 
            let objectClass: AnyObject = object as? AnyObject,
            Unmanaged<AnyObject>.passUnretained(self).toOpaque() == Unmanaged<AnyObject>.passUnretained(objectClass).toOpaque()
        {
            return true
        } else if !super.isEqual(object) {
            return false
        } else if let other: ToolchainPackage = object as? ToolchainPackage {
            return self.name == other.name
        } else {
            return false
        }
    }
    
    init(name: String, creationDate: FoundationEssentials.Date, state: State) {
        self.name = name
        self.creationDate = creationDate
        self.state = state
        super.init()
    }
}
