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
        assert(dlopen("/System/Library/PrivateFrameworks/PackageKit.framework/Versions/A/PackageKit", RTLD_NOW) != nil)
        
        let listner: XPCListener = try .init(
            service: "com.pookjw.Swain.Helper",
            targetQueue: nil,
            options: .inactive
        ) { request in
            return request.accept { (receivedMessage: XPCReceivedMessage) in
                receivedMessage.handoffReply(to: .global()) { 
                    handle(receivedMessage: receivedMessage)
                }
            } cancellationHandler: { (error: XPCRichError) in
                
            }
        }
        
        try listner.activate()
        
//        dispatchMain()
        // installClient:currentState:package:progress:timeRemaining:는 Main Thread가 살아 있어야 함
        CFRunLoopRun()
    }
    
    private static func handle(receivedMessage: XPCReceivedMessage) {
        guard 
            let xpcDictionary: XPCDictionary = receivedMessage.dictionary,
            let action: String = xpcDictionary["action"]
        else {
            fatalError()
        }
        
        switch action {
        case "install_package":
            guard 
                let packagePath: String = xpcDictionary["package_path"],
                let packageURL: URL = .init(string: packagePath)
            else {
                fatalError()
            }
            
            Task {
                try! await installPackage(packageURL: packageURL)
                
                var replyDictionary: XPCDictionary = .init()
                replyDictionary["success"] = true
                
                receivedMessage.reply(replyDictionary)
            }
        default:
            fatalError()
        }
    }
    
    private static func installPackage(packageURL: URL) async throws {
        let installer: PackageInstaller = .init(packageURL: packageURL)
        
        for try await (progress, timeRemaining) in try installer.install() {
            NSLog("\([progress, timeRemaining])")
        }
    }
}

extension XPCReceivedMessage {
    fileprivate var dictionary: XPCDictionary? {
        Mirror(reflecting: self).descendant("dictionary") as? XPCDictionary
    }
    
    fileprivate func reply(_ dictionary: XPCDictionary) {
        let xpcHandle: UnsafeMutableRawPointer = dlopen("/usr/lib/system/libxpc.dylib", RTLD_NOW)
        let symbol: UnsafeMutableRawPointer = dlsym(xpcHandle, "xpc_dictionary_send_reply_4SWIFT")
        typealias Function = @convention(c) (xpc_object_t, xpc_object_t) -> Void
        let xpc_dictionary_send_reply_4SWIFT: Function = unsafeBitCast(symbol, to: Function.self)
        
        xpc_dictionary_send_reply_4SWIFT(self.dictionary!.xpc_dictionary!, dictionary.xpc_dictionary!)
    }
}

extension XPCDictionary {
    fileprivate var xpc_dictionary: xpc_object_t? {
        Mirror(reflecting: self).descendant("_value") as? xpc_object_t
    }
}
