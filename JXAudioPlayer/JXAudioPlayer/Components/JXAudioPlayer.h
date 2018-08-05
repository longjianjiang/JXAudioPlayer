//
//  JXAudioPlayer.h
//  JXAudioPlayer
//
//  Created by zl on 2018/8/4.
//  Copyright © 2018年 longjianjiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXAudioPlayer : NSObject

/**
 initialize a JXAudioPlayer with a remote or local audio url
 */
- (instancetype)initWithContentsOfURL:(NSURL *)url;

+ (instancetype)jx_audioPlayerWithContentsOfURL:(NSURL *)url;



@end

NS_ASSUME_NONNULL_END
