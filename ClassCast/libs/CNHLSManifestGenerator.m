//
//  CNHLSManifestGenerator.m
//  ClassCast
//
//  Created by Manny on 4/25/14.
//  Copyright (c) 2014 Manpreet. All rights reserved.
//

#import "CNHLSManifestGenerator.h"
//#import "KFLog.h"

@interface CNHLSManifestGenerator()

@property (nonatomic, strong) NSMutableString *segmentsString;
@property (nonatomic) BOOL finished;

@end

@implementation CNHLSManifestGenerator

- (NSMutableString*) header {
    NSMutableString *header = [NSMutableString stringWithFormat:@"#EXTM3U\n#EXT-X-VERSION:%d\n#EXT-X-TARGETDURATION:%g\n", self.version, self.targetDuration];
    NSString *type = nil;
    if (self.playlistType == CNHLSManifestPlaylistTypeVOD) {
        type = @"VOD";
    } else if (self.playlistType == CNHLSManifestPlaylistTypeEvent) {
        type = @"EVENT";
    }
    if (type) {
        [header appendFormat:@"#EXT-X-PLAYLIST-TYPE:%@\n", type];
    }
    [header appendFormat:@"#EXT-X-MEDIA-SEQUENCE:%d\n", self.mediaSequence];
    return header;
}

- (NSString*) footer {
    return @"#EXT-X-ENDLIST\n";
}

- (id) initWithTargetDuration:(float)targetDuration playlistType:(CNHLSManifestPlaylistType)playlistType {
    if (self = [super init]) {
        self.targetDuration = targetDuration;
        self.playlistType = playlistType;
        self.version = 3;
        self.mediaSequence = -1;
        self.segmentsString = [NSMutableString string];
        self.finished = NO;
    }
    return self;
}

- (void) appendFileName:(NSString *)fileName duration:(float)duration mediaSequence:(NSUInteger)mediaSequence {
    if (self.finished) {
        return;
    }
    self.mediaSequence = mediaSequence;
    if (duration > self.targetDuration) {
        self.targetDuration = duration;
    }
    [self.segmentsString appendFormat:@"#EXTINF:%g,\n%@\n", duration, fileName];
}

- (void) finalizeManifest {
    self.finished = YES;
    self.mediaSequence = 0;
}

- (NSString*) stripToNumbers:(NSString*)string {
    return [[string componentsSeparatedByCharactersInSet:
             [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
            componentsJoinedByString:@""];
}

- (void) appendFromLiveManifest:(NSString *)liveManifest {
    NSArray *rawLines = [liveManifest componentsSeparatedByString:@"\n"];
    NSMutableArray *lines = [NSMutableArray arrayWithCapacity:rawLines.count];
    for (NSString *line in rawLines) {
        if (!line.length) {
            continue;
        }
        if ([line isEqualToString:@"#EXT-X-ENDLIST"]) {
            continue;
        }
        [lines addObject:line];
    }
    if (lines.count < 6) {
        return;
    }
    NSString *extInf = lines[lines.count-2];
    NSString *extInfNumberString = [self stripToNumbers:extInf];
    NSString *segmentName = lines[lines.count-1];
    NSString *segmentNumberString = [self stripToNumbers:segmentName];
    float duration = [extInfNumberString floatValue];
    NSInteger sequence = [segmentNumberString integerValue];
    if (sequence > self.mediaSequence) {
        [self appendFileName:segmentName duration:duration mediaSequence:sequence];
    }
}

- (NSString*) manifestString {
    NSMutableString *manifest = [self header];
    [manifest appendString:self.segmentsString];
    if (self.finished) {
        [manifest appendString:[self footer]];
    }
    NSLog(@"Latest manifest:\n%@", manifest);
    return manifest;
}


@end
