//
//  Toolchain.swift
//  
//
//  Created by Jinwoo Kim on 1/14/24.
//

import Foundation
import SwiftData
import RegexBuilder

////@_cdecl("SWCToolchainCategoryStableName")
//@_expose(Cxx, "SWCToolchainCategoryStableName")
//public func SWCToolchainCategoryStableName() -> String {
//    Toolchain.Category.stable.rawValue
//}
//
////@_cdecl("SWCToolchainCategoryReleaseName") 
//@_expose(Cxx, "SWCToolchainCategoryReleaseName")
//public func SWCToolchainCategoryReleaseName() -> String {
//    Toolchain.Category.release.rawValue
//}
//
////@_cdecl("SWCToolchainCategoryMainName")
//@_expose(Cxx, "SWCToolchainCategoryMainName")
//public func SWCToolchainCategoryMainName() -> String {
//    Toolchain.Category.main.rawValue
//}

@Model
public final class Toolchain: Hashable, Sendable {
    public static func getCategoryStableName() -> String {
        Category.stable.rawValue
    }
    
    public static func getCategoryReleaseName() -> String {
        Category.release.rawValue
    }
    
    public static func getCategoryMainName() -> String {
        Category.main.rawValue
    }
    
    enum Category: String, Hashable, Sendable {
        case stable, release, main
    }
    
    var categoryType: Category {
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
