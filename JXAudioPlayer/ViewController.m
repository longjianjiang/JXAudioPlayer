//
//  ViewController.m
//  JXAudioPlayer
//
//  Created by zl on 2018/8/4.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//


#import "ViewController.h"
#import "JXAudioPlayerHeader.h"


@interface ViewController () <JXAudioPlayerDelegate, JXAudioPlayerTimeDelegate>
@property (nonatomic, strong) AVPlayerItem *item;
@property (nonatomic, strong) AVQueuePlayer *player;

@property (weak, nonatomic) IBOutlet UISlider *slider;


@property (nonatomic, strong) JXAudioPlayer *audioPlayer;

@end

@implementation ViewController
- (IBAction)pause:(id)sender {
    [self.audioPlayer pause];
}
- (IBAction)stop:(id)sender {
    [self.audioPlayer stopWithReleaseAudio:YES];
}
- (IBAction)play:(id)sender {
    [self.audioPlayer play];
}

#pragma mark - JXAudioPlayerDelegate
- (void)jx_audioPlayerDidFinshPlaying:(JXAudioPlayer *)player {
    NSLog(@"audio did end finish play");
}

#pragma mark - JXAudioPlayerTimeDelegate
- (void)jx_aduioPlayerDidLoadAudioDuration:(JXAudioPlayer *)player {
    self.slider.maximumValue = player.totalPlaySecond;
}

- (void)jx_audioPlayer:(JXAudioPlayer *)player didPlayToSecond:(CGFloat)second {
    self.slider.value = second;
}

- (void)jx_audioPlayer:(JXAudioPlayer *)player didFinishedMoveToTime:(CMTime)time {
    NSLog(@"user seek to second %f", CMTimeGetSeconds(time));
}

- (void)jx_audioPlayer:(JXAudioPlayer *)player didBufferToProgress:(CGFloat)rate {
    NSLog(@"current buffer value is %f", rate);
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew context:nil];
    NSURL *url = [NSURL URLWithString:@"https://xcx.alicdn2.hexiaoxiang.com/audio/2018-8-4/2018-08-04/037fa27b-ea85-400d-83f4-d7d31b929c831533364922061.mp3.mp3"];
    
//    self.player = [AVQueuePlayer new];
//    self.item = [AVPlayerItem playerItemWithURL:url];
//    [self.player insertItem:self.item afterItem:nil];
    
    // 如果player 不被引用，则没有效果，为什么？？
    [self.audioPlayer play];
    
    [self.slider addTarget:self
                             action:@selector(sliderDidEndSliding)
                   forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    [self.slider addTarget:self action:@selector(didMoveSlider:) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - response method
- (void)sliderDidEndSliding {
    NSLog(@"video slider did end sliding...");
    
    [self.audioPlayer moveToSecond:self.slider.value shouldPlay:YES];
    
}

- (void)didMoveSlider:(UISlider *)sender {
    CGFloat value = sender.value;
    
    NSLog(@"current slider value is %f", value);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"player.currentItem.status"]) {
        NSLog(@"right now player item status is %ld",(long)self.item.status);
        if (self.item.status == AVPlayerItemStatusReadyToPlay) {
            [self.player play];
        }
    }
    
    if ([keyPath isEqualToString:@"status"]) {
//        if (self.item.status == AVPlayerItemStatusReadyToPlay) {
//            [self.player play];
//        }
    }
}


- (JXAudioPlayer *)audioPlayer {
    if (_audioPlayer == nil) {
         NSURL *url = [NSURL URLWithString:@"https://xcx.alicdn2.hexiaoxiang.com/audio/2018-8-4/2018-08-04/037fa27b-ea85-400d-83f4-d7d31b929c831533364922061.mp3.mp3"];
        _audioPlayer = [JXAudioPlayer new];
        _audioPlayer.audioUrl = url;
        _audioPlayer.delegate = self;
        _audioPlayer.timeDelegate = self;
        [_audioPlayer setShouldObservePlayTime:YES timeGapToObserve:100];
    }
    return _audioPlayer;
}
@end
