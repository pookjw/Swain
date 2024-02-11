//
//  SwainHelper.swift
//  SwainHelper
//
//  Created by Jinwoo Kim on 2/4/24.
//

import Foundation
import XPC
import Security
import SwainCore

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
                    Task {
                        try! await handle(receivedMessage: receivedMessage)
                    }
                }
            } cancellationHandler: { (error: XPCRichError) in
                
            }
        }
        
        try listner.activate()
        
//        dispatchMain()
        // installClient:currentState:package:progress:timeRemaining:는 Main Thread가 살아 있어야 함
        CFRunLoopRun()
    }
    
    private static func handle(receivedMessage: XPCReceivedMessage) async throws {
        guard 
            let xpcDictionary: XPCDictionary = receivedMessage.dictionary,
            let action: String = xpcDictionary["action"],
            let authExtForm: xpc_object_t = xpcDictionary["authorization_external_form"],
            xpc_data_get_length(authExtForm) == MemoryLayout<AuthorizationExternalForm>.size,
            let authExtFormRawData: UnsafeRawPointer = xpc_data_get_bytes_ptr(authExtForm)
        else {
            fatalError()
        }
        
        let authExtFormData: UnsafePointer<AuthorizationExternalForm> = authExtFormRawData.assumingMemoryBound(to: AuthorizationExternalForm.self)
        let authorized: Bool = await authorize(data: authExtFormData)
        assert(authorized)
        
        //
        
        switch action {
        case "install_package":
            guard 
                let packagePath: String = xpcDictionary["package_path"],
                let packageURL: URL = .init(string: packagePath)
            else {
                fatalError()
            }
            
            try await installPackage(packageURL: packageURL)
            
            var replyDictionary: XPCDictionary = .init()
            replyDictionary["success"] = true
            
            receivedMessage.reply(replyDictionary)
        default:
            fatalError()
        }
    }
    
    private static func authorize(data: UnsafePointer<AuthorizationExternalForm>) async -> Bool {
        var authRef: AuthorizationRef? = nil
        
        let status_1: OSStatus = AuthorizationCreateFromExternalForm(data, &authRef)
        assert(status_1 == errAuthorizationSuccess)
        
        let _: Void = await withCheckedContinuation { continuation in
            "Swain".withCString { namePtr in
                let authItem: AuthorizationItem = .init(
                    name: namePtr,
                    valueLength: .zero,
                    value: nil,
                    flags: .zero
                )
                
                withUnsafePointer(to: authItem) { authPtr in
                    let authRights: AuthorizationRights = .init(count: 1, items: .init(mutating: authPtr))
                    
                    withUnsafePointer(to: authRights) { ptr in
                        AuthorizationCopyRightsAsync(
                            authRef!,
                            ptr,
                            nil,
                            [.extendRights, .interactionAllowed]
                        ) { status_2, _ in
                            assert(status_2 == errAuthorizationSuccess)
                            continuation.resume(with: .success(()))
                        }
                    }
                }
            }
        }
        
        AuthorizationFree(authRef!, .init(rawValue: .zero))
        return true
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
