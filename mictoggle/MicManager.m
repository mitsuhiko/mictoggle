//
//  MicManager.m
//  mictoggle
//
//  Created by Armin Ronacher on 06.04.20.
//  Copyright © 2020 Armin Ronacher. All rights reserved.
//

#import "MicManager.h"
#import <CoreAudio/CoreAudio.h>

@implementation MicManager

+(void)addMicVolumeListener:(MicManagerVolumeListener)listener {
    // get device
    AudioDeviceID device = kAudioDeviceUnknown;
    UInt32 size = sizeof(device);
    
    AudioObjectPropertyAddress propertyAddress;
    propertyAddress.mSelector = kAudioHardwarePropertyDefaultInputDevice;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    propertyAddress.mScope = kAudioObjectPropertyScopeGlobal;

    if (noErr != AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &size, &device)) {
        return;
    }
    
    // listen to  master volume (channel 0)
    float volume;
    size = sizeof(volume);
    
    propertyAddress.mSelector = kAudioDevicePropertyVolumeScalar;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    propertyAddress.mScope = kAudioDevicePropertyScopeInput;
    
    AudioObjectAddPropertyListenerBlock(device,
                                        &propertyAddress,
                                        dispatch_get_main_queue(),
                                        ^(UInt32 inNumberAddresses, const AudioObjectPropertyAddress *inAddresses) {
        listener();
    });
}

+(float)micVolume {
    // get device
    AudioDeviceID device = kAudioDeviceUnknown;
    UInt32 size = sizeof(device);
    
    AudioObjectPropertyAddress propertyAddress;
    propertyAddress.mSelector = kAudioHardwarePropertyDefaultInputDevice;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    propertyAddress.mScope = kAudioObjectPropertyScopeGlobal;

    if (noErr != AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &size, &device)) {
        return 0.0;
    }
    
    // try get master volume (channel 0)
    float volume;
    size = sizeof(volume);
    
    propertyAddress.mSelector = kAudioDevicePropertyVolumeScalar;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    propertyAddress.mScope = kAudioDevicePropertyScopeInput;

    if (noErr == AudioObjectGetPropertyData(device, &propertyAddress, 0, NULL, &size, &volume)) {
        return volume;
    }
    
    return 0.0;
}

+(void)setMicVolume:(float)vol {
    // get default device
    AudioDeviceID device;
    UInt32 size = sizeof(device);
    AudioObjectPropertyAddress propertyAddress;
    propertyAddress.mSelector = kAudioHardwarePropertyDefaultInputDevice;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    propertyAddress.mScope = kAudioObjectPropertyScopeGlobal;

    if (noErr != AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &size, &device)) {
        return;
    }
    
    // try set master-channel (0) volume
    Boolean canset = false;
    size = sizeof(canset);
    propertyAddress.mSelector = kAudioDevicePropertyVolumeScalar;
    propertyAddress.mElement = kAudioObjectPropertyElementMaster;
    propertyAddress.mScope = kAudioDevicePropertyScopeInput;

    if (noErr == AudioObjectIsPropertySettable(device, &propertyAddress, &canset)) {
        size = sizeof(vol);
        AudioObjectSetPropertyData(device, &propertyAddress, 0, NULL, size, &vol);
        return;
    }
}


@end
