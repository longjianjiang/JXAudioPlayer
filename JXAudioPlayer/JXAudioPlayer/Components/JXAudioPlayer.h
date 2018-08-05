//
//  JXAudioPlayer.h
//  JXAudioPlayer
//
//  Created by zl on 2018/8/4.
//  Copyright © 2018年 longjianjiang. All rights reserved.


@import AVFoundation;

#import <UIKit/UIKit.h>
#import "JXAudioPlayerDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface JXAudioPlayer : NSObject

@property (nonatomic, strong) NSURL *audioUrl;

@property (nonatomic, weak) id<JXAudioPlayerDelegate> delegate;

@property (nonatomic, assign, readonly) JXAudioPlayerStatus playerStatus;

@property (nonatomic, assign, readonly) BOOL isPlaying;

@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;

- (void)play;
- (void)pause;
- (void)stopWithReleaseAudio:(BOOL)shouldReleaseAudio;

@end

NS_ASSUME_NONNULL_END
