//
//  PackageInstaller.swift
//  SwainHelper
//
//  Created by Jinwoo Kim on 2/6/24.
//

import Foundation

final class PackageInstaller {
    private let packageURL: URL
    private let installRequest: PKInstallRequest
    
    init(packageURL: URL) {
        self.packageURL = packageURL
        initializeInstallRequest = ()
    }
    
    private var initializeInstallRequest: Void {
        @storageRestrictions(initializes: installRequest, accesses: packageURL)
        init(__) {
            let product: PKProduct = try! .init(byLoadingProductAt: packageURL)
            
            let packageSpecifiers: [PKPackageSpecifier] = product
                .allPackageReferences
                .map { .init(packageReference: $0) }
            
            let installRequest: PKInstallRequest = .init(packages: packageSpecifiers, destination: "/")
            self.installRequest = installRequest
        }
        get {}
    }
    
    func install() throws -> AsyncThrowingStream<(progress: Double, timeRemaining: Double), Error> {
        let (stream, continuation) = AsyncThrowingStream<(progress: Double, timeRemaining: Double), Error>.makeStream()
        
        let delegate: PackageInstallerDelegate = .init(
            didFailWithErrorHandler: { installClient, error in
                continuation.yield(with: .failure(error))
            }, 
            progressHandler: { installClient, currentState, package, progress, timeRemaining in
                continuation.yield(with: .success((progress, timeRemaining)))
            }, 
            didBeginHandler: { installClient in
                
            }, 
            didFinishHandler: { installClient in
                continuation.finish()
            }
        )
        
        let installClient: PKInstallClient = try .init(
            request: installRequest,
            inUserContext: true,
            holdingBoostDuringInstall: false,
            delegate: delegate
        )
        
        let unmanagedDelegate: Unmanaged<PackageInstallerDelegate> = .passRetained(delegate)
        let unmanagedInstallClient: Unmanaged<PKInstallClient> = .passRetained(installClient)
        
        continuation.onTermination = { _ in
            unmanagedDelegate.release()
            unmanagedInstallClient.release()
        }
        
        return stream
    }
}

fileprivate final class PackageInstallerDelegate: NSObject {
    typealias DidFailWithErrorHandlerType = (_ installClient: AnyObject, _ error: Error) -> Void
    typealias ProgressHandlerType = (_ installClient: AnyObject,_ currentState: Int, _ package: AnyObject?, _ progress: Double, _ timeRemaining: Double) -> Void
    typealias DidBeginHandlerType = (_ installClient: AnyObject) -> Void
    typealias DidFinishHandlerType = (_ installClient: AnyObject) -> Void
    
    private let didFailWithErrorHandler: DidFailWithErrorHandlerType
    private let progressHandler: ProgressHandlerType
    private let didBeginHandler: DidBeginHandlerType
    private let didFinishHandler: DidFinishHandlerType
    
    init(
        didFailWithErrorHandler: @escaping DidFailWithErrorHandlerType,
        progressHandler: @escaping ProgressHandlerType,
        didBeginHandler: @escaping DidBeginHandlerType,
        didFinishHandler: @escaping DidFinishHandlerType
    ) {
        self.didFailWithErrorHandler = didFailWithErrorHandler
        self.progressHandler = progressHandler
        self.didBeginHandler = didBeginHandler
        self.didFinishHandler = didFinishHandler
        
        super.init()
    }
    
    /*
     installClient:didFailWithError:
     installClient:currentState:package:progress:timeRemaining:
     installClient:discoveredManagedPaths:sandboxPath:
     installClient:registerBundlesWithLaunchServices:
     installClientDidBegin:
     installClientDidFinish:
     */
    
    @objc(installClient:didFailWithError:)
    private func installClient(_ installClient: AnyObject, didFailWithError error: Error) {
        didFailWithErrorHandler(installClient, error)
    }
    
    @objc(installClient:currentState:package:progress:timeRemaining:)
    private func installClient(_ installClient: AnyObject, currentState: Int, package: AnyObject?, progress: Double, timeRemaining: Double) {
        progressHandler(installClient, currentState, package, progress, timeRemaining)
    }
    
    @objc(installClientDidBegin:)
    private func installClientDidBegin(_ installClient: AnyObject) {
        didBeginHandler(installClient)
    }
    
    @objc(installClientDidFinish:)
    private func installClientDidFinish(_ installClient: AnyObject) {
        didFinishHandler(installClient)
    }
}
