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

struct Constants {
    static let CLOSE_THRESHOLD: Float = 0.1
    static let DEFAULT_OPEN_VOL: Float = 0.9
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var openMic = true
    var soundEffects = true
    var pushToTalk = false
    var soundEffectsMenuItem: NSMenuItem!
    var pushToTalkMenuItem: NSMenuItem!
    var oldVolume: Float = 0.0
    let openSound = NSSound(named: "opening.wav")
    let closeSound = NSSound(named: "closing.wav")
    let hotKey = HotKey(key: .equal, modifiers: [.command, .shift])
    let pushToTalkKey = HotKey(key: .escape, modifiers: [.command])
    let unifiedKey = HotKey(key: .f13, modifiers: [])
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.soundEffects = !UserDefaults.standard.bool(forKey: "noSoundEffects")
        self.pushToTalk = UserDefaults.standard.bool(forKey: "pushToTalk")

        self.oldVolume = MicManager.micVolume()
        if self.oldVolume <= Constants.CLOSE_THRESHOLD {
            self.openMic = false
            self.oldVolume = Constants.DEFAULT_OPEN_VOL
        }
        
        MicManager.addMicVolumeListener({
            let volume = MicManager.micVolume()
            let oldOpenMic = self.openMic
            if volume <= Constants.CLOSE_THRESHOLD {
                self.openMic = false
            } else {
                self.openMic = true
                self.oldVolume = volume
            }
            if oldOpenMic != self.openMic {
                self.syncState()
            }
        })
        
        self.constructMenu()
        self.syncState()
        
        if self.pushToTalk && self.openMic {
            self.toggleMic()
        }
        
        self.hotKey.keyDownHandler = {
            if !self.pushToTalk {
                self.toggleMic()
            }
        }

        self.pushToTalkKey.keyDownHandler = {
            self.doPushToTalk(open: true)
        }

        self.pushToTalkKey.keyUpHandler = {
            self.doPushToTalk(open: false)
        }

        self.unifiedKey.keyDownHandler = {
            if self.pushToTalk {
                self.doPushToTalk(open: true)
            } else {
                self.toggleMic()
            }
        }

        self.unifiedKey.keyUpHandler = {
            self.doPushToTalk(open: false)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        if !self.openMic {
            let resetVolume = self.oldVolume <= Constants.CLOSE_THRESHOLD ? Constants.DEFAULT_OPEN_VOL : self.oldVolume;
            MicManager.setMicVolume(resetVolume);
        }
    }

    func doPushToTalk(open: Bool) {
        if self.pushToTalk {
            if self.openMic != open {
                self.toggleMic()
            }
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
        if let menuItem = self.pushToTalkMenuItem {
            if self.pushToTalk {
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
    
    @objc func toggleMic() {
        self.openMic = !self.openMic
        if self.soundEffects {
            if self.openMic {
                self.openSound?.play()
            } else {
                self.closeSound?.play()
            }
        }
        self.syncState()
    }
    
    @objc func toggleSoundEffects(_ sender: Any?) {
        self.soundEffects = !self.soundEffects
        UserDefaults.standard.set(!self.soundEffects, forKey: "noSoundEffects")
        self.syncState()
    }
    
    @objc func togglePushToTalk(_ sender: Any?) {
        self.pushToTalk = !self.pushToTalk
        UserDefaults.standard.set(self.pushToTalk, forKey: "pushToTalk")
        self.syncState()
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        soundEffectsMenuItem = NSMenuItem(title: "Play Sound Effects", action: #selector(AppDelegate.toggleSoundEffects(_:)), keyEquivalent: "")
        pushToTalkMenuItem = NSMenuItem(title: "Push to Talk", action: #selector(AppDelegate.togglePushToTalk(_:)), keyEquivalent: "")

        menu.addItem(soundEffectsMenuItem)
        menu.addItem(pushToTalkMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))

        statusItem.menu = menu
    }
}

