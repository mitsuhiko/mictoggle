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
            button.action = #selector(toggleMic(_:))
        }
        
        self.oldVolume = MicManager.micVolume()
        if self.oldVolume == 0 {
            self.openMic = false
            self.oldVolume = 0.8
        }
        self.syncState()
        self.constructMenu()
        
        self.hotKey.keyDownHandler = {
            self.toggleMic(nil)
        }
    }
    
    func syncState() {
        if let button = statusItem.button {
            if self.openMic {
                button.image = NSImage(named:NSImage.Name("MicIcon"))
                MicManager.setMicVolume(self.oldVolume);
            } else {
                button.image = NSImage(named:NSImage.Name("NoMicIcon"))
                MicManager.setMicVolume(0.0);
            }
        }
    }
    
    @objc func toggleMic(_ sender: Any?) {
        self.openMic = !self.openMic
        if self.openMic {
            NSSound(named: "Pop")?.play()
        } else {
            NSSound(named: "Bottle")?.play()
            self.oldVolume = MicManager.micVolume()
        }
        self.syncState()
    }
    
    func constructMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Toggle Mic", action: #selector(AppDelegate.toggleMic(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit App", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))

        statusItem.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

