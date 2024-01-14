//
//  Toolchain.swift
//  
//
//  Created by Jinwoo Kim on 1/14/24.
//

import RegexBuilder

public enum Toolchain: Hashable, Sendable {
    case stable(String) // swift-5.9.2-RELEASE
    case release(String) // swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a
    case main(String) // swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a
    
    init?(refName: String) {
        guard let name: String = Self.getTagName(refName: refName) else {
            return nil
        }
        
        if name.contains(Self.stableRegex) {
            self = .stable(name)
        } else if name.contains(Self.releaseRegex) {
            self = .release(name)
        } else if name.contains(Self.mainRegex) {
            self = .main(name)
        } else {
            return nil
        }
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
        
        guard let match = refName.firstMatch(of: regex)?.output.1 else {
            return nil
        }
        
        return String(match)
    }
}
