//
//  AppDelegate.swift
//  mictoggle
//
//  Created by Armin Ronacher on 06.04.20.
//  Copyright © 2020 Armin Ronacher. All rights reserved.
//

import Cocoa
import SwiftUI
import HotKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var openMic = true
    var oldVolume: Float = 0.0
    let hotKey = HotKey(key: .equal, modifiers: [.command, .shift])

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("MicIcon"))
            button.action = #selector(toggleMic(_:))
        }
        
        self.oldVolume = MicManager.micVolume()
        
        self.hotKey.keyDownHandler = {
            self.toggleMic(nil)
        }
    }
    
    @objc func toggleMic(_ sender: Any?) {
        self.openMic = !self.openMic
        
        if let button = statusItem.button {
            if self.openMic {
                button.image = NSImage(named:NSImage.Name("MicIcon"))
                MicManager.setMicVolume(self.oldVolume);
                NSSound(named: "Pop")?.play()
            } else {
                button.image = NSImage(named:NSImage.Name("NoMicIcon"))
                self.oldVolume = MicManager.micVolume()
                MicManager.setMicVolume(0.0);
                NSSound(named: "Bottle")?.play()
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

