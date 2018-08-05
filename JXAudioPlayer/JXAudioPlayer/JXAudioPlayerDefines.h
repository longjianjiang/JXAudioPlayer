//
//  JXAudioPlayerDefines.h
//  JXAudioPlayer
//
//  Created by zl on 2018/8/4.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#ifndef JXAudioPlayerDefines_h
#define JXAudioPlayerDefines_h

#define WeakSelf __weak typeof(self) weakSelf = self;
#define StrongSelf __strong typeof(weakSelf) strongSelf = weakSelf;

@import CoreMedia;
@class JXAudioPlayer;

typedef NS_ENUM(NSUInteger, JXAudioPlayerStatus) {
    JXAudioPlayerStatusReady        = 0, // Default state, right now player is not play audio
    JXAudioPlayerStatusRunning      = 1, // Player and audio file get ready for playing
    JXAudioPlayerStatusBuffering    = 1 << 1, // Buffering the audio content
    JXAudioPlayerStatusPlaying      = 1 << 2, // Playing
    JXAudioPlayerStatusPaused       = 1 << 3, // Paused
    JXAudioPlayerStatusStopped      = 1 << 4, // Raised when user invoke stop method or audio play end time
    JXAudioPlayerStatusError        = 1 << 5,  // Raised when an unexpected and possibly unrecoverable error has occured
};


/**************************************************************/

@protocol JXAudioPlayerDelegate <NSObject>

@optional
- (void)jx_audioPlayerWillStartPlaying:(JXAudioPlayer *)player;
- (void)jx_audioPlayerDidStartPlaying:(JXAudioPlayer *)player;
- (void)jx_audioPlayerDidFinshPlaying:(JXAudioPlayer *)player;

- (void)jx_audioPlayerWillPause:(JXAudioPlayer *)videoView;
- (void)jx_audioPlayerDidPause:(JXAudioPlayer *)videoView;

- (void)jx_audioPlayerWillStop:(JXAudioPlayer *)videoView;
- (void)jx_audioPlayerDidStop:(JXAudioPlayer *)videoView;

- (void)jx_audioPlayerWillSeek:(JXAudioPlayer *)videoView;
- (void)jx_audioPlayerDidSeek:(JXAudioPlayer *)videoView;

@end

/**************************************************************/

@protocol JXAudioPlayerTimeDelegate <NSObject>

@optional
- (void)jx_audioPlayer:(JXAudioPlayer *)player didBufferToProgress:(CGFloat)rate;
- (void)jx_aduioPlayerDidLoadAudioDuration:(JXAudioPlayer *)player;
- (void)jx_audioPlayer:(JXAudioPlayer *)player didFinishedMoveToTime:(CMTime)time;
- (void)jx_audioPlayer:(JXAudioPlayer *)player didPlayToSecond:(CGFloat)second;
@end


#endif /* JXAudioPlayerDefines_h */
