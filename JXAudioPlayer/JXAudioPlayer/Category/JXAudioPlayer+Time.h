//
//  JXAudioPlayer+Time.h
//  JXAudioPlayer
//
//  Created by zl on 2018/8/4.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import "JXAudioPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface JXAudioPlayer (Time)

@property (nonatomic, assign, readonly) CGFloat currentPlaySecond;
@property (nonatomic, assign, readonly) CGFloat totalPlaySecond;

/**
 indicate whether observe player `currentPlaySecond`, if YES, then will delegate method `jx_audioPlayer:didPlayToSecond:` will invoke
 */
@property (nonatomic, assign, readonly) BOOL shouldObservePlayTime;

/**
 if want to invoke `jx_audioPlayer:didPlayToSecond:`, you should implement `setShouldObservePlayTime:timeGapToObserve:`, set how often delegate method be invoked
 */
@property (nonatomic, assign, readonly) CGFloat timeGapToObserve;

@property (nonatomic, assign) CGFloat currentPlaySpeed;

@property (nonatomic, weak) id<JXAudioPlayerTimeDelegate> timeDelegate;

- (void)initTime;
- (void)deallocTime;

- (void)willStartPlay;
- (void)moveToSecond:(CGFloat)second shouldPlay:(BOOL)shouldPlay;
- (void)setShouldObservePlayTime:(BOOL)shouldObservePlayTime timeGapToObserve:(CGFloat)timeGapToObserve;

/**
 this method is give to be invoked by `KVO`, you should not invoke.
 */
- (void)durationDidLoadedWithChange:(NSDictionary *)change;

@end

NS_ASSUME_NONNULL_END
