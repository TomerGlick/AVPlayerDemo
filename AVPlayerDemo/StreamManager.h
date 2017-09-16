//
//  StreamManager.h
//  AVPlayerDemo
//
//  Created by TomerGlick on 16/09/2017.
//  Copyright © 2017 TomerGlick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@protocol StreamManagerProtocol <NSObject>
- (void)StreamManagerProtocolMetaDataChanged:(NSString*)title;
@optional
- (void)StreamManagerProtocolRadioStateChanged:(NSNumber*) radioStateInt;
- (void)StreamManagerProtocolEndInterruption;
- (void)StreamManagerProtocolStationNotSupported;
@end

@interface StreamManager : NSObject <AVAudioRecorderDelegate> {
    id <StreamManagerProtocol> delegate;
}

+ (StreamManager *)        sharedInstance;
- (void) streamStation: (NSString*) stationURL;
@property (nonatomic) id <StreamManagerProtocol> delegate;
- (void)seekInTimeBackward;
- (void)seekInTimeForward;
- (NSString *)getStreamingTime;

@end
