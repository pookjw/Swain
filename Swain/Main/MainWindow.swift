//
//  MainWindow.swift
//  Swain
//
//  Created by Jinwoo Kim on 1/13/24.
//

import Cocoa

@MainActor
final class MainWindow: NSWindow {
    convenience init() {
        self.init(
            contentRect: NSRect(origin: .zero, size: .init(width: 600.0, height: 400.0)),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .titled],
            backing: .buffered,
            defer: true
        )
    }
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        commonInit()
    }
    
    private func commonInit() {
        isMovableByWindowBackground = true
    }
}
