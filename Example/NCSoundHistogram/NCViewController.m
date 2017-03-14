//
//  NCViewController.m
//  NCSoundHistogram
//
//  Created by Nikola Corlija on 05/23/2016.
//  Copyright (c) 2016 Nikola Corlija. All rights reserved.
//

#import "NCViewController.h"
#import "NCSoundHistogram.h"

@interface NCViewController ()

@end

@implementation NCViewController {
    NCSoundHistogram *soundHistogramView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    soundHistogramView = [[NCSoundHistogram alloc] initWithFrame:CGRectMake(20, 50, 335, 100)];
    
    soundHistogramView.waveColor = [UIColor blackColor];
    soundHistogramView.animationColor = [UIColor cyanColor];
    soundHistogramView.drawSpaces = YES;
    soundHistogramView.barLineWidth = 2.5;
    
    [self.view addSubview:soundHistogramView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound.m4a" ofType:nil]];
    soundHistogramView.soundURL = url;
    
    [soundHistogramView animatePlayingWithDuration:4];
}

@end
