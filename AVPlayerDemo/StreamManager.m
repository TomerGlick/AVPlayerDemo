//
//  StreamManager.m
//  AVPlayerDemo
//
//  Created by TomerGlick on 16/09/2017.
//  Copyright © 2017 TomerGlick. All rights reserved.
//

#import "StreamManager.h"

static StreamManager *instance = nil;  //shared instance

#define kTimedMetaDataObserver  @"timedMetadata"


@interface StreamManager () {
    AVPlayer                * radioPlayer;
    AVPlayerItem            * playerItem;
    NSTimer                 * streamTimer;
}
@end

@implementation StreamManager
@synthesize delegate;

+ (StreamManager *)sharedInstance
{
    if(instance == nil)
    {
        @synchronized(self)
        {
            if(instance == nil)
            {
                instance = [[StreamManager alloc] init];
                
                NSError *error = nil;
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
                if (error)
                {
                    NSLog(@"Error: %@", error.localizedDescription);
                }
                else
                {
                    BOOL success = [[AVAudioSession sharedInstance] setActive:YES error: &error];
                    
                    if (!success && error) {
                        NSLog(@"Error: %@", error.localizedDescription);
                    }
                    else
                    {
                        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                    }
                }
            }
        }
    }
    return instance;
}


- (void) streamStation: (NSString*) stationURL {
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    if (radioPlayer)
    {
        [self pauseStream];
        [radioPlayer.currentItem removeObserver:self
                                     forKeyPath:kTimedMetaDataObserver context:nil];
    }
    
    if (playerItem) {
        playerItem = nil;
    }
    
    playerItem = [AVPlayerItem playerItemWithURL:
                  [NSURL URLWithString:stationURL]];
    
    [playerItem addObserver:self forKeyPath:kTimedMetaDataObserver options:NSKeyValueObservingOptionNew context:nil];
    
    if (radioPlayer)
    {
        [radioPlayer replaceCurrentItemWithPlayerItem:playerItem];
    }
    else
    {
        radioPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    }
    
    [radioPlayer play];
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
                         change:(NSDictionary*)change context:(void*)context {
    
    if ([keyPath isEqualToString:kTimedMetaDataObserver])
    {
        AVPlayerItem* playerItemTemp = object;
        for (AVMetadataItem* metadata in playerItemTemp.timedMetadata)
        {
            if([metadata.commonKey isEqualToString:@"title"])
            {
                if (delegate && [delegate respondsToSelector:@selector(StreamManagerProtocolMetaDataChanged:)])
                {
                    [delegate performSelector:@selector(StreamManagerProtocolMetaDataChanged:)
                                   withObject:metadata.stringValue];
                }
            }
        }
    }
}

- (void)seekInTimeForward {

    // pause
    [radioPlayer pause];
    // 30 seconds seek
    int seekTime = 30;
    // seek to - time
    float second = CMTimeGetSeconds(radioPlayer.currentTime) + seekTime;
    NSLog(@"Seek FWD To time (need): %f", second);
    
    CMTimeRange seekableRange = [radioPlayer.currentItem.seekableTimeRanges.lastObject CMTimeRangeValue];
    CGFloat seekableStart = CMTimeGetSeconds(seekableRange.start);
    CGFloat seekableDuration = CMTimeGetSeconds(seekableRange.duration);
    CGFloat livePosition = seekableStart + seekableDuration;
    
    if (second > livePosition)
    {
        second = livePosition - 5;
    }
    
    NSLog(@"Seek FWD To time (actual): %f", second);
    
    CMTime newTime = CMTimeMakeWithSeconds(second,
                                           radioPlayer.currentTime.timescale);
    
    
    [radioPlayer seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
        [radioPlayer play];
    }];
}

- (NSString *)getStreamingTime {
    if (radioPlayer)
    {
        AVPlayerItem *currentItem = radioPlayer.currentItem;
        NSTimeInterval currentTime = CMTimeGetSeconds(currentItem.currentTime);
        long seconds = lroundf(currentTime);
        int hour = (int)seconds / 3600;
        int mins = (seconds % 3600) / 60;
        int secs = seconds % 60;
        
        NSString *strTime;
        if (hour < 1)
        {
            strTime = [NSString stringWithFormat:@"%02d:%02d", mins,secs];
        }
        else
        {
            strTime = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, mins,secs];
        }
        NSLog(@"time: %@", strTime);
        return strTime;
    }
    return @"--:--";
}

- (void)seekInTimeBackward {
    
    [radioPlayer pause];
    // seek time
    int seekTime = 30;
    // calculate new second to seek to
    int second = CMTimeGetSeconds(radioPlayer.currentTime) - seekTime;
    long seconds = lroundf(second);
    
    // check new second didn't go below begining
    if (seconds < 0) seconds = 0;
    NSLog(@"Seek BKW To time: %ld", seconds);
    
    CMTime newTime = CMTimeMakeWithSeconds(seconds, radioPlayer.currentTime.timescale);
    
    //SLog(@"Seek BKW timescale: %d", radioPlayer.currentTime.timescale);
    [radioPlayer seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
        [radioPlayer play];
    }];
}


- (void) pauseStream {
    if (streamTimer)
    {
        [streamTimer invalidate];
        streamTimer = nil;
    }
    if (radioPlayer)
    {
        [radioPlayer pause];
    }
}

@end
