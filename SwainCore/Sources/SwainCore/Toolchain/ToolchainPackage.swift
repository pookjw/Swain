//
//  ToolchainPackage.swift
//
//
//  Created by Jinwoo Kim on 1/28/24.
//

import Foundation
import FoundationPreview

public struct ToolchainPackage: Hashable, Sendable {
    public enum State: Hashable, Sendable {
        public static func == (lhs: ToolchainPackage.State, rhs: ToolchainPackage.State) -> Bool {
            switch (lhs, rhs) {
            case (.downloading(let lhsValue), .downloading(let rhsValue)):
                return lhsValue == rhsValue
            case (.downloaded(let lhsValue), .downloaded(let rhsValue)):
                return lhsValue == rhsValue
            case (.failed(let lhsValue), .failed(let rhsValue)):
                return lhsValue._code == rhsValue._code && lhsValue._domain == rhsValue._domain
            default:
                return false
            }
        }
        
        case downloading(Progress)
        case downloaded(Foundation.URL)
        case failed(Error)
        
        public func hash(into hasher: inout Hasher) {
            switch self {
            case .downloading(let progress):
                hasher.combine(1 << 0)
                hasher.combine(progress)
            case .downloaded(let url):
                hasher.combine(1 << 1)
                hasher.combine(url)
            case .failed(let error):
                hasher.combine(1 << 2)
                hasher.combine(error._code)
                hasher.combine(error._domain)
            }
        }
    }
    
    public let name: String
    public let createdDate: FoundationEssentials.Date
    public let state: State
}
