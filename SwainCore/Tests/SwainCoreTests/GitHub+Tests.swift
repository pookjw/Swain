//
//  GitHub+Tests.swift
//  
//
//  Created by Jinwoo Kim on 1/13/24.
//

import Testing
@testable import SwainCore

extension GitHub {
    @Test(.tags(["test_swiftReleases"])) func test_swiftReleases() async throws {
        let gitHub: GitHub = .init()
        let releases: [GitHub.Release] = try await gitHub.swiftReleases()
    }
}
