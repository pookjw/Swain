//
//  SwainHelper.swift
//  SwainHelper
//
//  Created by Jinwoo Kim on 2/4/24.
//

import Foundation
import XPC

@main
struct SwainHelper {
    static func main() throws {
        let listner: XPCListener = try .init(
            service: "com.pookjw.Swain.Helper",
            targetQueue: nil,
            options: .inactive
        ) { request in
            return request.reject(reason: "TODO")
        }
        
        try listner.activate()
        
        dispatchMain()
    }
}
