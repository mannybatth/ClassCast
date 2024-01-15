//
//  RecordButton.m
//  ClassCast
//
//  Created by Manny on 4/26/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "RecordButton.h"

@interface RecordButton()
@property (nonatomic, strong) UIImage *startImage;
@property (nonatomic, strong) UIImage *stopImage;
@property (nonatomic, strong) UIImageView *outerImageView;
@end

@implementation RecordButton

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImage *image = [UIImage imageNamed:@"RecordButtonStart"];
        self.startImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self setImage:self.startImage
              forState:UIControlStateNormal];
        
        image = [UIImage imageNamed:@"RecordButtonStop"];
        self.stopImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        self.tintColor = [UIColor redColor];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self setupOuterImage];
    }
    return self;
}

- (void) setupOuterImage {
    self.outerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RecordButtonBorder"]];
    self.outerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.outerImageView];
}

- (void) updateConstraints {
    UIView *superview = self;
    NSDictionary *variables = NSDictionaryOfVariableBindings(_outerImageView, superview);
    NSArray *constraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:[superview]-(<=1)-[_outerImageView]"
                                            options: NSLayoutFormatAlignAllCenterX
                                            metrics:nil
                                              views:variables];
    [self addConstraints:constraints];
    
    constraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:[superview]-(<=1)-[_outerImageView]"
                                            options: NSLayoutFormatAlignAllCenterY
                                            metrics:nil
                                              views:variables];
    [self addConstraints:constraints];
    [super updateConstraints];
}

- (void) setIsRecording:(BOOL)isRecording {
    _isRecording = isRecording;
    if (_isRecording) {
        [self setImage:self.stopImage
              forState:UIControlStateNormal];
    } else {
        [self setImage:self.startImage
              forState:UIControlStateNormal];
    }
}

- (CGSize) intrinsicContentSize {
    return CGSizeMake(66, 66);
}

@end
