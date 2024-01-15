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
    public var category: Category {
        @storageRestrictions(accesses: _$backingData, initializes: __category)
        init(initialValue) {
            _$backingData.setTransformableValue(forKey: \._category, to: .init(category: initialValue))
            __category = _SwiftDataNoType()
        }
        get {
            _category.category
        }
    }
    
    public var packageURLString: String? {
        let name: String = name
        
        /*
         https://download.swift.org/swift-5.9.2-release/xcode/swift-5.9.2-RELEASE/swift-5.9.2-RELEASE-osx.pkg
         https://download.swift.org/swift-5.10-branch/xcode/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a-osx.pkg
         https://download.swift.org/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a-osx.pkg
         */
        switch category {
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
    
    @Attribute(.unique, originalName: "name") public let name: String
    @Attribute(.transformable(by: _CategoryValueTransformer.self), originalName: "category") let _category: _Category
    
    init?(refName: String) {
        guard let name: String = Self.getTagName(refName: refName) else {
            return nil
        }
        
        if name.contains(Self.stableRegex) {
            self.category = .stable
        } else if name.contains(Self.releaseRegex) {
            self.category = .release
        } else if name.contains(Self.mainRegex) {
            self.category = .main
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

extension Toolchain {
    public enum Category: Hashable, Sendable {
        case stable, release, main
    }
    
    @_objcRuntimeName(_TtCC9SwainCore9Toolchain9_Category) final class _Category: NSObject, NSSecureCoding {
        static let supportsSecureCoding: Bool = true
        
        let category: Category
        
        init(category: Category) {
            self.category = category
            super.init()
        }
        
        init?(coder: NSCoder) {
            guard let value: String = coder.decodeObject(forKey: "category") as? String else {
                return nil
            }
            
            switch value {
            case "stable":
                self.category = .stable
            case "release":
                self.category = .release
            case "main":
                self.category = .main
            default:
                return nil
            }
            
            super.init()
        }
        
        func encode(with coder: NSCoder) {
            switch category {
            case .stable:
                coder.encode("stable", forKey: "category")
            case .release:
                coder.encode("release", forKey: "category")
            case .main:
                coder.encode("main", forKey: "category")
            }
        }
    }
    
    final class _CategoryValueTransformer: ValueTransformer {
        override class func allowsReverseTransformation() -> Bool {
            true
        }
        
        override class func transformedValueClass() -> AnyClass {
            _Category.self
        }
        
        override func transformedValue(_ value: Any?) -> Any? {
            guard let category: _Category = value as? _Category else {
                return nil
            }
            
            do {
                let data: Data = try NSKeyedArchiver.archivedData(withRootObject: category, requiringSecureCoding: true)
                return data
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        
        override func reverseTransformedValue(_ value: Any?) -> Any? {
            guard let data: Data = value as? Data else {
                return nil
            }
            
            do {
                guard let category: _Category = try NSKeyedUnarchiver.unarchivedObject(ofClass: _Category.self, from: data) else {
                    return nil
                }
                
                return category
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
    }
}
