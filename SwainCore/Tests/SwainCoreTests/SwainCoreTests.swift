//
//  File.swift
//  
//
//  Created by Jinwoo Kim on 1/13/24.
//

import XCTest
import Testing

final class SwainCoreTests: XCTestCase {
    func testAll() async {
        await XCTestScaffold.runAllTests(hostedBy: self)
    }
}
