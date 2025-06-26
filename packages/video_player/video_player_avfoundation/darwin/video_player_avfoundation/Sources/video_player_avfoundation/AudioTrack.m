#import "AudioTrack.h"

@implementation AudioTrack

- (instancetype)initWithGroupId:(int)groupId
                        trackId:(int)trackId
                       language:(NSString *)language
                          label:(NSString *)label {
  self = [super init];
  if (self) {
    _groupId = groupId;
    _trackId = trackId;
    _language = [language copy];
    _label = [label copy];
  }
  return self;
}

- (instancetype)initWithGroupId:(int)groupId trackId:(int)trackId {
  return [self initWithGroupId:groupId trackId:trackId language:nil label:nil];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<AudioTrack: groupId=%d, trackId=%d, language=%@, label=%@>",
                                    self.groupId, self.trackId, self.language, self.label];
}

- (NSDictionary<NSString *, id> *)asMap {
  return @{
    @"groupId" : @(self.groupId),
    @"trackId" : @(self.trackId),
    @"language" : self.language ?: [NSNull null],
    @"label" : self.label ?: [NSNull null]
  };
}

#pragma mark - NSSecureCoding (The equivalent of Java's Serializable)

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeInt:self.groupId forKey:@"groupId"];
  [coder encodeInt:self.trackId forKey:@"trackId"];
  [coder encodeObject:self.language forKey:@"language"];
  [coder encodeObject:self.label forKey:@"label"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  int groupId = [coder decodeIntForKey:@"groupId"];
  int trackId = [coder decodeIntForKey:@"trackId"];
  NSString *language = [coder decodeObjectOfClass:[NSString class] forKey:@"language"];
  NSString *label = [coder decodeObjectOfClass:[NSString class] forKey:@"label"];

  return [self initWithGroupId:groupId trackId:trackId language:language label:label];
}

@end