//
//  SoundPlayer.m
//  AESTextEncryption
//
//  Created by Evgenii Neumerzhitckii on 21/02/2015.
//  Copyright (c) 2015 Evgenii Neumerzhitckii. All rights reserved.
//

#import "SoundPlayer.h"

@interface iiSoundPlayer()

@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation iiSoundPlayer

- (id)initWithSoundName:(NSString*) fileName
{
  self = [super init];

  if (self) {
    [self setAudioSessionToAmbient];
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]error:NULL];
  }

  return self;
}

// Allows the sounds to be played with sounds from other apps
- (void)setAudioSessionToAmbient {
  NSError *sessionError = nil;
  AVAudioSession *session = [AVAudioSession sharedInstance];
  [session setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
  [session setActive:true error:&sessionError];
}

- (void)playAtVolume: (float)volume {
  if (!self.player) { return; }

  self.player.currentTime = 0;
  self.player.volume = volume;
  [self.player play];
}

- (void)playAsyncAtVolume: (float)volume {
  dispatch_queue_t playerQueue = dispatch_queue_create("player queue", NULL);
  dispatch_async(playerQueue, ^{
    [self playAtVolume:volume];
  });
}

- (void)prepareToPlay {
  [self.player prepareToPlay];
}

@end