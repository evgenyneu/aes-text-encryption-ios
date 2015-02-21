//
//  SoundPlayer.h
//  AESTextEncryption
//
//  Created by Evgenii Neumerzhitckii on 21/02/2015.
//  Copyright (c) 2015 Evgenii Neumerzhitckii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface iiSoundPlayer : NSObject

- (id)initWithSoundName:(NSString*) fileName;
- (void) playAtVolume: (float)volume;
- (void)playAsyncAtVolume: (float)volume;
- (void)prepareToPlay;

@end
