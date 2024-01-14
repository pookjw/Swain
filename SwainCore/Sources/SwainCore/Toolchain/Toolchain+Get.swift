//
//  Toolchain+Get.swift
//  
//
//  Created by Jinwoo Kim on 1/14/24.
//

import RegexBuilder

extension Toolchain {
    public static func toolchains() async throws -> [Self] {
        try await GitHub
            .swiftRefs()
            .compactMap { ref in
                Self(refName: ref.ref)
            }
    }
    
    public var packageURLString: String? {
        /*
         https://download.swift.org/swift-5.9.2-release/xcode/swift-5.9.2-RELEASE/swift-5.9.2-RELEASE-osx.pkg
         https://download.swift.org/swift-5.10-branch/xcode/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a/swift-5.10-DEVELOPMENT-SNAPSHOT-2024-01-11-a-osx.pkg
         https://download.swift.org/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a/swift-DEVELOPMENT-SNAPSHOT-2024-01-11-a-osx.pkg
         */
        switch self {
        case .stable(let name):
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
        case .release(let name):
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
        case .main(let name):
            return "https://download.swift.org/development/xcode/\(name)/\(name)-osx.pkg"
        }
    }
}
