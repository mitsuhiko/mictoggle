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

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var openMic = true
    var soundEffects = true
    var soundEffectsMenuItem: NSMenuItem!
    var oldVolume: Float = 0.0
    let hotKey = HotKey(key: .equal, modifiers: [.command, .shift])

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.action = #selector(toggleMic(_:))
        }
        
        self.soundEffects = !UserDefaults.standard.bool(forKey: "noSoundEffects")
        
        self.oldVolume = MicManager.micVolume()
        if self.oldVolume == 0 {
            self.openMic = false
            self.oldVolume = 0.8
        }
        
        MicManager.addMicVolumeListener({
            let volume = MicManager.micVolume()
            if volume == 0 {
                self.openMic = false
            } else {
                self.openMic = true
                self.oldVolume = volume
            }
            self.syncState()
        })
        
        self.constructMenu()
        self.syncState()
        
        self.hotKey.keyDownHandler = {
            self.toggleMic(nil)
        }
    }
    
    func syncState() {
        if let menuItem = self.soundEffectsMenuItem {
            if self.soundEffects {
                menuItem.state = NSControl.StateValue.on;
            } else {
                menuItem.state = NSControl.StateValue.off;
            }
        }
        if let button = self.statusItem.button {
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
        if self.soundEffects {
            if self.openMic {
                NSSound(named: "Pop")?.play()
            } else {
                NSSound(named: "Bottle")?.play()
                self.oldVolume = MicManager.micVolume()
            }
        }
        self.syncState()
    }
    
    @objc func toggleSoundEffects(_ sender: Any?) {
        self.soundEffects = !self.soundEffects
        UserDefaults.standard.set(!self.soundEffects, forKey: "noSoundEffects")
        self.syncState()
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        soundEffectsMenuItem = NSMenuItem(title: "Play Sound Effects", action: #selector(AppDelegate.toggleSoundEffects(_:)), keyEquivalent: "")

        menu.addItem(NSMenuItem(title: "Toggle Mic", action: #selector(AppDelegate.toggleMic(_:)), keyEquivalent: ""))
        menu.addItem(soundEffectsMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))

        statusItem.menu = menu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

