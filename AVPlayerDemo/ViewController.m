//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by TomerGlick on 16/09/2017.
//  Copyright © 2017 TomerGlick. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    NSTimer *playTimer;
}
@property (weak, nonatomic) IBOutlet UILabel *lblRadioTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onBtnPlay:(id)sender {
    [[StreamManager sharedInstance] streamStation:@"http://star.jointil.net/proxy/jrn_reggae?mp=/stream"];
    playTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                 target:self
                                               selector:@selector(updateTime)
                                               userInfo:nil
                                                repeats:YES];
    
}

- (void) updateTime {
    self.lblTime.text = [[StreamManager sharedInstance] getStreamingTime];
}

- (IBAction)onSeekBkw:(id)sender {
    [[StreamManager sharedInstance] seekInTimeBackward];
}


- (IBAction)onSeekFwd:(id)sender {
    [[StreamManager sharedInstance] seekInTimeForward];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)StreamManagerProtocolMetaDataChanged:(NSString*)title {
    self.lblRadioTitle.text = title;
}

@end
