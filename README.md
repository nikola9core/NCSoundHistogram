# NCSoundHistogram

[![Version](https://img.shields.io/cocoapods/v/NCSoundHistogram.svg?style=flat)](http://cocoapods.org/pods/NCSoundHistogram)
[![License](https://img.shields.io/cocoapods/l/NCSoundHistogram.svg?style=flat)](http://cocoapods.org/pods/NCSoundHistogram)
[![Platform](https://img.shields.io/cocoapods/p/NCSoundHistogram.svg?style=flat)](http://cocoapods.org/pods/NCSoundHistogram)

Based on https://github.com/faviomob/FVSoundWaveDemo with improvements:

* Added playing animation
* More customizations such setting bar line width

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Example:

![alt tag](http://i.giphy.com/3o6EhD4JSv3oqYPrd6.gif)

## Requirements

* iOS 8 sdk

## Installation

NCSoundHistogram is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "NCSoundHistogram"
```

## Usage

Import header
```objective-c
#import "NCSoundHistogram.h"
```

Initialize NCSoundHistogram and add as a view
```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NCSoundHistogram *soundHistogramView = [[NCSoundHistogram alloc] initWithFrame:CGRectMake(50, 50, 200, 100)];
    
    soundHistogramView.waveColor = [UIColor blueColor];
    soundHistogramView.animationColor = [UIColor cyanColor];
    soundHistogramView.drawSpaces = YES;
    soundHistogramView.barLineWidth = 2.5;
    
    [self.view addSubview:soundHistogramView];
}
```

Set audio file on some button click or when view appears
```objective-c
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"audio.m4a" ofType:nil]];
    soundHistogramView.soundURL = url;
    
    [soundHistogramView animatePlayingWithDuration:4];
}
```

## License

NCSoundHistogram is available under the MIT license. See the LICENSE file for more info.
