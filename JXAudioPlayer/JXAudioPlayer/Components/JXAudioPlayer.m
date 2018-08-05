//
//  JXAudioPlayer.m
//  JXAudioPlayer
//
//  Created by zl on 2018/8/4.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import "JXAudioPlayer.h"
#import "JXAudioPlayer+Time.h"

NSString * const kJXAudioPlayerKVOKeyPathPlayerItemStatus = @"player.currentItem.status";
NSString * const kJXAudioPlayerKVOKeyPathPlayerItemDuration = @"player.currentItem.duration";
NSString * const kJXAudioPlayerKVOKeyPathPlayerItemLoadedTimeRanges = @"player.currentItem.loadedTimeRanges";

static void * kJXAudioPlayerKVOContext = &kJXAudioPlayerKVOContext;

@interface JXAudioPlayer () 

@property (nonatomic, assign, readwrite) JXAudioPlayerStatus playerStatus;

@property (nonatomic, strong, readwrite) AVPlayer *player;
@property (nonatomic, strong, readwrite) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVURLAsset *asset;

@end


@implementation JXAudioPlayer

#pragma mark - public method
- (void)play {
    if (self.isPlaying) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(jx_audioPlayerWillStartPlaying:)]) {
        [self.delegate jx_audioPlayerWillStartPlaying:self];
    }
    
    if (self.playerStatus & (JXAudioPlayerStatusPaused | JXAudioPlayerStatusStopped)) {
        [self.player play];
        self.playerStatus = JXAudioPlayerStatusPlaying;
        return;
    }
    
    if (self.asset) {
        [self asynchronouslyLoadUrlAsset:self.asset];
    }
}

- (void)pause {
    if (self.isPlaying) {
        if ([self.delegate respondsToSelector:@selector(jx_audioPlayerWillPause:)]) {
            [self.delegate jx_audioPlayerWillPause:self];
        }
        
        [self.player pause];
        
        self.playerStatus = JXAudioPlayerStatusPaused;
        
        if ([self.delegate respondsToSelector:@selector(jx_audioPlayerDidPause:)]) {
            [self.delegate jx_audioPlayerDidPause:self];
        }
    }
}

- (void)stopWithReleaseAudio:(BOOL)shouldReleaseAudio {
    if ([self.delegate respondsToSelector:@selector(jx_audioPlayerWillStop:)]) {
        [self.delegate jx_audioPlayerWillStop:self];
    }
    
    [self.player pause];
    
    self.playerStatus = JXAudioPlayerStatusStopped;
    
    if (shouldReleaseAudio) {
        [self.player replaceCurrentItemWithPlayerItem:nil];
        self.playerStatus = JXAudioPlayerStatusReady;
    }
    
    if ([self.delegate respondsToSelector:@selector(jx_audioPlayerDidStop:)]) {
        [self.delegate jx_audioPlayerDidStop:self];
    }
}

#pragma mark - life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [self performInitProcess];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:kJXAudioPlayerKVOKeyPathPlayerItemStatus context:kJXAudioPlayerKVOContext];
    [self removeObserver:self forKeyPath:kJXAudioPlayerKVOKeyPathPlayerItemDuration context:kJXAudioPlayerKVOContext];
    [self removeObserver:self forKeyPath:kJXAudioPlayerKVOKeyPathPlayerItemLoadedTimeRanges context:kJXAudioPlayerKVOContext];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self deallocTime];
}

- (void)performInitProcess {
    if (_playerStatus != JXAudioPlayerStatusReady) {
        return;
    }
    
    // KVO
    [self addObserver:self
           forKeyPath:kJXAudioPlayerKVOKeyPathPlayerItemStatus
              options:NSKeyValueObservingOptionNew
              context:&kJXAudioPlayerKVOContext];
    
    [self addObserver:self
           forKeyPath:kJXAudioPlayerKVOKeyPathPlayerItemDuration
              options:NSKeyValueObservingOptionNew
              context:&kJXAudioPlayerKVOContext];
    
    [self addObserver:self
           forKeyPath:kJXAudioPlayerKVOKeyPathPlayerItemLoadedTimeRanges
              options:NSKeyValueObservingOptionNew
              context:&kJXAudioPlayerKVOContext];
    
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAVPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAVPlayerItemFailedToPlayToEndTimeNotification:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (context != kJXAudioPlayerKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:kJXAudioPlayerKVOKeyPathPlayerItemStatus]) {
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = [newStatusAsNumber isKindOfClass:[NSNumber class]] ? newStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;
        
        if (newStatus == AVPlayerItemStatusFailed) {
            NSLog(@"%@", self.player.currentItem.error);
        }
    }
    
    if ([keyPath isEqualToString:kJXAudioPlayerKVOKeyPathPlayerItemDuration]) {
        [self durationDidLoadedWithChange:change];
    }
    
    if ([keyPath isEqualToString:kJXAudioPlayerKVOKeyPathPlayerItemLoadedTimeRanges]) {
        NSTimeInterval ti = [self availableDuration];
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        CGFloat rate = ti / totalDuration;
        if ([self.timeDelegate respondsToSelector:@selector(jx_audioPlayer:didBufferToProgress:)]) {
            [self.timeDelegate jx_audioPlayer:self didBufferToProgress:rate];
        }
    }
}


#pragma mark - notification method
- (void)didReceiveAVPlayerItemDidPlayToEndTimeNotification:(NSNotification *)noti {
    if (noti.object == self.player.currentItem) {
        [self.player seekToTime:kCMTimeZero];
        
        if ([self.delegate respondsToSelector:@selector(jx_audioPlayerDidFinshPlaying:)]) {
            [self.delegate jx_audioPlayerDidFinshPlaying:self];
        }
        
        self.playerStatus = JXAudioPlayerStatusStopped;
    }
}

- (void)didReceiveAVPlayerItemFailedToPlayToEndTimeNotification:(NSNotification *)noti {
    if (noti.object == self.player.currentItem) {
        self.playerStatus = JXAudioPlayerStatusError;
    }
}

#pragma mark - private method
- (void)asynchronouslyLoadUrlAsset:(AVAsset *)asset {
    
    self.playerStatus = JXAudioPlayerStatusBuffering;
    
    WeakSelf
    [asset loadValuesAsynchronouslyForKeys:@[@"playable"] completionHandler:^{
        StrongSelf
        
        NSError *error = nil;
        if ([asset statusOfValueForKey:@"tracks" error:&error] == AVKeyValueStatusFailed) {
            NSLog(@"%@", error);
        }
        if ([asset statusOfValueForKey:@"duration" error:&error] == AVKeyValueStatusFailed) {
            NSLog(@"%@", error);
        }
        if ([asset statusOfValueForKey:@"playable" error:&error] == AVKeyValueStatusFailed) {
            NSLog(@"%@", error);
        }
        
        strongSelf.playerItem = [AVPlayerItem playerItemWithAsset:asset];
        
        [strongSelf willStartPlay];
        
        [strongSelf.player play];
        
        strongSelf.playerStatus = JXAudioPlayerStatusPlaying;
    }];
    
}


#pragma mark - help method
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - getter and setter
- (AVPlayer *)player {
    if (_player == nil) {
        _player = [AVPlayer new];
    }
    return _player;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem != playerItem) {
        _playerItem = playerItem;
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    }
}

- (void)setAudioUrl:(NSURL *)audioUrl {
    _audioUrl = audioUrl;
    self.asset = [AVURLAsset assetWithURL:audioUrl];
    self.playerStatus = JXAudioPlayerStatusRunning;
}

- (BOOL)isPlaying {
    return self.player.rate >= 1.0;
}


@end
