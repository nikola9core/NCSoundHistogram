//
//  NCSoundHistogram.m
//  Pods
//
//  Created by Marat Alekperov on 27.06.14.
//  Copyright (c) 2014 Favio Mobile. All rights reserved.
//

#import "NCSoundHistogram.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "UIView+Geometry.h"

@implementation UIImage (Tint)

- (UIImage *)tintedImageWithColor:(UIColor *)color {
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake (0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM (context, 1, -1);
    CGContextTranslateCTM (context, 0, -area.size.height);
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, area, self.CGImage);
    
    [color set];
    CGContextFillRect(context, area);
    
    CGContextRestoreGState(context);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
    CGContextDrawImage(context, area, self.CGImage);
    
    UIImage *colorizedImage = UIGraphicsGetImageFromCurrentImageContext ();
    
    UIGraphicsEndImageContext();
    
    return colorizedImage;
}

@end


@implementation NCSoundHistogram {
    
    NSURL* _soundURL;
    
    UIImageView* _waveImageView;
    UIImageView* _progressImageView;
}

- (id) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.waveColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
        self.animationColor = [UIColor lightGrayColor];
        self.progressColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        self.barLineWidth = 1.0;
        
        _drawSpaces = YES;
    }
    return self;
}

- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    if (_waveImageView == nil) {
        _waveImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _progressImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        _waveImageView.contentMode = UIViewContentModeLeft;
        _progressImageView.contentMode = UIViewContentModeLeft;
        _waveImageView.clipsToBounds = YES;
        _progressImageView.clipsToBounds = YES;
        
        [self addSubview:_waveImageView];
        [self addSubview:_progressImageView];
    }
}

- (void) render {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_soundURL options:nil];
    UIImage *renderedImage = [self renderWaveImageFromAudioAsset:asset];
    
    _waveImageView.image = renderedImage;
    _progressImageView.image = [renderedImage tintedImageWithColor:_progressColor];
    
    _waveImageView.width = renderedImage.size.width;
    _waveImageView.left = (self.width - renderedImage.size.width) / 2;
    _progressImageView.left = _waveImageView.left;
    _progressImageView.width = 0;
}

- (UIImage*) drawImageFromSamples:(SInt16*)samples
                         maxValue:(SInt16)maxValue
                      sampleCount:(NSInteger)sampleCount {
    
    CGSize imageSize = CGSizeMake(sampleCount * (_drawSpaces ? 2*_barLineWidth : 0), self.height);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextSetAlpha(context, 1.0);
    
    CGRect rect;
    rect.size = imageSize;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGColorRef waveColor = self.waveColor.CGColor;
    
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 1.0*_barLineWidth);
    
    float channelCenterY = imageSize.height / 2;
    float sampleAdjustmentFactor = imageSize.height / (float)maxValue;
    
    for (NSInteger i = 0; i < sampleCount; i++) {
        float val = *samples++;
        val = val * sampleAdjustmentFactor;
        if ((int)val == 0)
            val = 1.0; // draw dots instead of emptyness
        CGContextMoveToPoint(context, i * (_drawSpaces ? 2*_barLineWidth : 1*_barLineWidth), channelCenterY - val / 2.0);
        CGContextAddLineToPoint(context, i * (_drawSpaces ? 2*_barLineWidth : 1*_barLineWidth), channelCenterY + val / 2.0);
        CGContextSetStrokeColorWithColor(context, waveColor);
        CGContextStrokePath(context);
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage*) renderWaveImageFromAudioAsset:(AVURLAsset *)songAsset {
    
    NSError* error = nil;
    
    AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    
    AVAssetTrack* songTrack = [songAsset.tracks objectAtIndex:0];
    
    NSDictionary* outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                        [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                                        [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        nil];
    
    AVAssetReaderTrackOutput* output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    
    [reader addOutput:output];
    
    UInt32 sampleRate, channelCount = 0;
    
    NSArray* formatDesc = songTrack.formatDescriptions;
    
    for (int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription (item);
        if (fmtDesc) {
            sampleRate = fmtDesc->mSampleRate;
            channelCount = fmtDesc->mChannelsPerFrame;
        }
    }
    
    UInt32 bytesPerSample = 2 * channelCount;
    SInt16 maxValue = 0;
    
    NSMutableData *fullSongData = [[NSMutableData alloc] init];
    
    [reader startReading];
    
    UInt64 totalBytes = 0;
    SInt64 totalLeft = 0;
    SInt64 totalRight = 0;
    NSInteger sampleTally = 0;
    
    NSInteger samplesPerPixel = 100; // enougth for most of ui and fast
    
    int buffersCount = 0;
    while (reader.status == AVAssetReaderStatusReading) {
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        
        if (sampleBufferRef) {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            
            size_t length = CMBlockBufferGetDataLength(blockBufferRef);
            totalBytes += length;
            
            @autoreleasepool {
                NSMutableData *data = [NSMutableData dataWithLength:length];
                CMBlockBufferCopyDataBytes(blockBufferRef, 0, length, data.mutableBytes);
                
                SInt16 * samples = (SInt16*) data.mutableBytes;
                int sampleCount = (int) length / bytesPerSample;
                
                for (int i = 0; i < sampleCount; i++) {
                    SInt16 left = *samples++;
                    
                    totalLeft += left;
                    
                    SInt16 right = 0;
                    
                    if (channelCount == 2) {
                        right = *samples++;
                        totalRight += right;
                    }
                    
                    sampleTally++;
                    
                    if (sampleTally > samplesPerPixel) {
                        left = (totalLeft / sampleTally);
                        
                        if (channelCount == 2) {
                            right = (totalRight / sampleTally);
                        }
                        
                        SInt16 val = right ? ((right + left) / 2) : left;
                        
                        [fullSongData appendBytes:&val length:sizeof(val)];
                        
                        totalLeft = 0;
                        totalRight = 0;
                        sampleTally = 0;
                    }
                }
                CMSampleBufferInvalidate(sampleBufferRef);
                
                CFRelease(sampleBufferRef);
            }
        }
        
        buffersCount++;
    }
    
    NSMutableData *adjustedSongData = [[NSMutableData alloc] init];
    
    int sampleCount = (int) fullSongData.length / 2;
    int adjustFactor = ceilf((float)sampleCount / (self.width / (_drawSpaces ? 2.0*_barLineWidth : 1.0*_barLineWidth)));
    
    SInt16 *samples = (SInt16*) fullSongData.mutableBytes;
    
    int i = 0;
    
    while (i < sampleCount) {
        SInt16 val = 0;
        
        for (int j = 0; j < adjustFactor; j++) {
            val += samples[i + j];
        }
        val /= adjustFactor;
        if (ABS(val) > maxValue) {
            maxValue = ABS(val);
        }
        [adjustedSongData appendBytes:&val length:sizeof(val)];
        i += adjustFactor;
    }
    
    sampleCount = (int) adjustedSongData.length / 2;
    
    if (reader.status == AVAssetReaderStatusCompleted) {
        UIImage *image = [self drawImageFromSamples:(SInt16 *)adjustedSongData.bytes
                                           maxValue:maxValue
                                        sampleCount:sampleCount];
        return image;
    }
    return nil;
}

- (NSURL*) soundURL {
    
    return _soundURL;
}

- (void) setSoundURL:(NSURL*)soundURL {
    
    _soundURL = soundURL;
    
    [self render];
}

- (void) setProgress:(float)progress {
    
    _progressImageView.left = _waveImageView.left;
    _progressImageView.width = _waveImageView.width * progress;
}

-(UIImage *)getAsImage {
    
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)animatePlayingWithDuration:(float)seconds {
    
    UIImageView *tintedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
    tintedImageView.image = [self.getAsImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [tintedImageView setTintColor:self.animationColor];
    [tintedImageView setContentMode:UIViewContentModeLeft];
    tintedImageView.clipsToBounds = YES;
    
    [self addSubview:tintedImageView];
    
    [UIView animateWithDuration:seconds delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        tintedImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [tintedImageView removeFromSuperview];
    }];
}

@end
