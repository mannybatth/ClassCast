//
//  CNHLSManifestGenerator.h
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CNHLSManifestPlaylistType) {
    CNHLSManifestPlaylistTypeLive = 0,
    CNHLSManifestPlaylistTypeVOD,
    CNHLSManifestPlaylistTypeEvent
};

@interface CNHLSManifestGenerator : NSObject

@property (nonatomic) double targetDuration;
@property (nonatomic) NSInteger mediaSequence;
@property (nonatomic) NSUInteger version;
@property (nonatomic) CNHLSManifestPlaylistType playlistType;

- (id) initWithTargetDuration:(float)targetDuration playlistType:(CNHLSManifestPlaylistType)playlistType;

- (void) appendFileName:(NSString *)fileName duration:(float)duration mediaSequence:(NSUInteger)mediaSequence;
- (void) appendFromLiveManifest:(NSString*)liveManifest;

- (void) finalizeManifest;

- (NSString*) manifestString;

@end
