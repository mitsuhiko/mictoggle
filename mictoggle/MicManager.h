//
//  MicManager.h
//  mictoggle
//
//  Created by Armin Ronacher on 06.04.20.
//  Copyright © 2020 Armin Ronacher. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MicManagerVolumeListener)(void);

@interface MicManager : NSObject

+(void)addMicVolumeListener:(MicManagerVolumeListener)listener;
+(float)micVolume;
+(void)setMicVolume:(float)vol;

@end

NS_ASSUME_NONNULL_END
