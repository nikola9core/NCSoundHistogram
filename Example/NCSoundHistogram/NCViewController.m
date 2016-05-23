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

@implementation NCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NCSoundHistogram *soundHistogramView = [[NCSoundHistogram alloc] initWithFrame:CGRectMake(20, 20, 335, 150)];
    soundHistogramView.waveColor = [UIColor redColor];
    
    //soundHistogramView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:soundHistogramView];
    
    //NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio.m4a" ofType:nil]];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"audio" withExtension:@"m4a"];

    soundHistogramView.soundURL = url;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
