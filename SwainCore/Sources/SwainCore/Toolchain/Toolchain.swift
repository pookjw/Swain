//
//  Toolchain.swift
//  
//
//  Created by Jinwoo Kim on 1/14/24.
//

import Foundation
import SwiftData
import RegexBuilder

@Model
public final class Toolchain: Hashable, Sendable {
    public enum Category: String, Hashable, Sendable {
        case stable, release, main
    }
    
    public var categoryType: Category {
        @storageRestrictions(accesses: _$backingData, initializes: _category)
        init(initialValue) {
            _$backingData.setValue(forKey: \.category, to: initialValue.rawValue)
            _category = _SwiftDataNoType()
        }
        get {
            .init(rawValue: category)!
        }
//        set {
//            _category = newValue.rawValue
//        }
    }
    
    public var packageURLString: String? {
        let name: String = name
        
        /*
         https://download.swift.org/swift-5.9.2-release/xcode/swift-5.9.2-RELEASE/swift-5.9.2-RELEASE-osx.pkg
         https://download.swift.org/swift-5.10-branch/xcode/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a-osx.pkg
         https://download.swift.org/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a-osx.pkg
         */
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
    
    @Attribute(.unique) public let name: String
    @Attribute() let category: String
    
    init?(refName: String) {
        guard let name: String = Self.getTagName(refName: refName) else {
            return nil
        }
        
        if name.contains(Self.stableRegex) {
            self.categoryType = .stable
        } else if name.contains(Self.releaseRegex) {
            self.categoryType = .release
        } else if name.contains(Self.mainRegex) {
            self.categoryType = .main
        } else {
            return nil
        }
        
        self.name = name
    }
    
    /// swift-\d+\.\d+\.\d+-RELEASE
    private static var stableRegex: Regex<Substring> {
        Regex {
          "swift-"
          OneOrMore(.digit)
          "."
          OneOrMore(.digit)
          "."
          OneOrMore(.digit)
          "-RELEASE"
        }
    }
    
    /// swift-\d+\.\d+-DEVELOPMENT-SNAPSHOT-\d{4}-\d{2}-\d{2}-\w
    private static var releaseRegex: Regex<Substring> {
        Regex {
          "swift-"
          OneOrMore(.digit)
          "."
          OneOrMore(.digit)
          "-DEVELOPMENT-SNAPSHOT-"
          Repeat(count: 4) {
            One(.digit)
          }
          "-"
          Repeat(count: 2) {
            One(.digit)
          }
          "-"
          Repeat(count: 2) {
            One(.digit)
          }
          "-"
          One(.word)
        }
    }
    
    /// swift-DEVELOPMENT-SNAPSHOT-\d{4}-\d{2}-\d{2}-\w
    private static var mainRegex: Regex<Substring> {
        Regex {
          "swift-DEVELOPMENT-SNAPSHOT-"
          Repeat(count: 4) {
            One(.digit)
          }
          "-"
          Repeat(count: 2) {
            One(.digit)
          }
          "-"
          Repeat(count: 2) {
            One(.digit)
          }
          "-"
          One(.word)
        }
    }
    
    private static func getTagName(refName: String) -> String? {
        let regex: Regex = .init {
            "refs/tags/"
            Capture {
                OneOrMore(.any)
            }
        }
        
        guard let match: Substring = refName.firstMatch(of: regex)?.output.1 else {
            return nil
        }
        
        return String(match)
    }
}
