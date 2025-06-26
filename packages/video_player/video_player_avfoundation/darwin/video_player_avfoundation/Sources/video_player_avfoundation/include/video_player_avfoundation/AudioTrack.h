#import <Foundation/Foundation.h>

/**
 * @brief A model object representing a single audio track and its metadata.
 *
 * @discussion An AudioTrack object is an immutable, type-safe container for information
 * about a specific audio option available in a media asset. It is designed to be a
 * safer replacement for using a generic NSDictionary.
 *
 * This class conforms to NSSecureCoding to allow for serialization (archiving).
 */
@interface AudioTrack : NSObject <NSSecureCoding>

/// The numeric identifier for the group this audio track belongs to.
@property(nonatomic, assign) int groupId;

/// The numeric identifier for this specific track within its group.
@property(nonatomic, assign) int trackId;

/// The language of the audio track, if available. This can be nil if the language is unknown.
@property(nonatomic, copy, nullable) NSString *language;

/// A human-readable label for the audio track, if available. This can be nil if no label is
/// provided.
@property(nonatomic, copy, nullable) NSString *label;

/**
 * Initializes and returns a newly allocated AudioTrack object with all properties.
 *
 * @discussion This is the designated initializer for the class.
 *
 * @param groupId The identifier for the media group.
 * @param trackId The identifier for the track within its group.
 * @param language The language for the track.
 * @param label The descriptive label for the track.
 *
 * @return A newly initialized AudioTrack object.
 */
- (instancetype)initWithGroupId:(int)groupId
                        trackId:(int)trackId
                       language:(nullable NSString *)language
                          label:(nullable NSString *)label NS_DESIGNATED_INITIALIZER;

/**
 * A convenience initializer that creates an AudioTrack with only its required identifiers.
 *
 * @param groupId The identifier for the media group.
 * @param trackId The identifier for the track within its group.
 *
 * @return An initialized AudioTrack object with nil language and label.
 */
- (instancetype)initWithGroupId:(int)groupId trackId:(int)trackId;

/**
 * Converts the AudioTrack object into a dictionary representation.
 *
 * @discussion This is useful for serialization or for interoperating with systems that expect
 * simple key-value data.
 *
 * @return An NSDictionary containing the track's properties.
 */
- (NSDictionary<NSString *, id> *)asMap;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end