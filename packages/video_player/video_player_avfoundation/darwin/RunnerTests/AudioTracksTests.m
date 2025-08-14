// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import <AVFoundation/AVFoundation.h>
#import <OCMock/OCMock.h>

#import "video_player_avfoundation/FVPVideoPlayer.h"
#import "video_player_avfoundation/messages.g.h"

@interface AudioTracksTests : XCTestCase
@property(nonatomic, strong) FVPVideoPlayer *player;
@property(nonatomic, strong) id mockPlayer;
@property(nonatomic, strong) id mockPlayerItem;
@property(nonatomic, strong) id mockAsset;
@property(nonatomic, strong) id mockAVFactory;
@property(nonatomic, strong) id mockViewProvider;
@end

@implementation AudioTracksTests

- (void)setUp {
  [super setUp];
  
  // Create mocks
  self.mockPlayer = OCMClassMock([AVPlayer class]);
  self.mockPlayerItem = OCMClassMock([AVPlayerItem class]);
  self.mockAsset = OCMClassMock([AVAsset class]);
  self.mockAVFactory = OCMProtocolMock(@protocol(FVPAVFactory));
  self.mockViewProvider = OCMProtocolMock(@protocol(FVPViewProvider));
  
  // Set up basic mock relationships
  OCMStub([self.mockPlayer currentItem]).andReturn(self.mockPlayerItem);
  OCMStub([self.mockPlayerItem asset]).andReturn(self.mockAsset);
  OCMStub([self.mockAVFactory playerWithPlayerItem:OCMOCK_ANY]).andReturn(self.mockPlayer);
  
  // Create player with mocks
  self.player = [[FVPVideoPlayer alloc] initWithPlayerItem:self.mockPlayerItem
                                                 avFactory:self.mockAVFactory
                                              viewProvider:self.mockViewProvider];
}

- (void)tearDown {
  [self.player dispose];
  self.player = nil;
  [super tearDown];
}

#pragma mark - Asset Track Tests

- (void)testGetAudioTracksWithRegularAssetTracks {
  // Create mock asset tracks
  id mockTrack1 = OCMClassMock([AVAssetTrack class]);
  id mockTrack2 = OCMClassMock([AVAssetTrack class]);
  
  // Configure track 1
  OCMStub([mockTrack1 trackID]).andReturn(1);
  OCMStub([mockTrack1 languageCode]).andReturn(@"en");
  OCMStub([mockTrack1 estimatedDataRate]).andReturn(128000.0f);
  
  // Configure track 2
  OCMStub([mockTrack2 trackID]).andReturn(2);
  OCMStub([mockTrack2 languageCode]).andReturn(@"es");
  OCMStub([mockTrack2 estimatedDataRate]).andReturn(96000.0f);
  
  // Mock format descriptions for track 1
  id mockFormatDesc1 = OCMClassMock([NSObject class]);
  AudioStreamBasicDescription asbd1 = {0};
  asbd1.mSampleRate = 48000.0;
  asbd1.mChannelsPerFrame = 2;
  
  OCMStub([mockTrack1 formatDescriptions]).andReturn(@[mockFormatDesc1]);
  
  // Mock the asset to return our tracks
  NSArray *mockTracks = @[mockTrack1, mockTrack2];
  OCMStub([self.mockAsset tracksWithMediaType:AVMediaTypeAudio]).andReturn(mockTracks);
  
  // Mock no media selection group (regular asset)
  OCMStub([self.mockAsset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicAudible]).andReturn(nil);
  
  // Test the method
  FlutterError *error = nil;
  FVPNativeAudioTrackData *result = [self.player getAudioTracks:&error];
  
  // Verify results
  XCTAssertNil(error);
  XCTAssertNotNil(result);
  XCTAssertNotNil(result.assetTracks);
  XCTAssertNil(result.mediaSelectionTracks);
  XCTAssertEqual(result.assetTracks.count, 2);
  
  // Verify first track
  FVPAssetAudioTrackData *track1 = result.assetTracks[0];
  XCTAssertEqualObjects(track1.trackId, @1);
  XCTAssertEqualObjects(track1.language, @"en");
  XCTAssertTrue(track1.isSelected); // First track should be selected
  XCTAssertEqualObjects(track1.bitrate, @128000);
  
  // Verify second track
  FVPAssetAudioTrackData *track2 = result.assetTracks[1];
  XCTAssertEqualObjects(track2.trackId, @2);
  XCTAssertEqualObjects(track2.language, @"es");
  XCTAssertFalse(track2.isSelected); // Second track should not be selected
  XCTAssertEqualObjects(track2.bitrate, @96000);
}

- (void)testGetAudioTracksWithMediaSelectionOptions {
  // Create mock media selection group and options
  id mockMediaSelectionGroup = OCMClassMock([AVMediaSelectionGroup class]);
  id mockOption1 = OCMClassMock([AVMediaSelectionOption class]);
  id mockOption2 = OCMClassMock([AVMediaSelectionOption class]);
  
  // Configure option 1
  OCMStub([mockOption1 displayName]).andReturn(@"English");
  id mockLocale1 = OCMClassMock([NSLocale class]);
  OCMStub([mockLocale1 languageCode]).andReturn(@"en");
  OCMStub([mockOption1 locale]).andReturn(mockLocale1);
  
  // Configure option 2
  OCMStub([mockOption2 displayName]).andReturn(@"Español");
  id mockLocale2 = OCMClassMock([NSLocale class]);
  OCMStub([mockLocale2 languageCode]).andReturn(@"es");
  OCMStub([mockOption2 locale]).andReturn(mockLocale2);
  
  // Mock metadata for option 1
  id mockMetadataItem = OCMClassMock([AVMetadataItem class]);
  OCMStub([mockMetadataItem commonKey]).andReturn(AVMetadataCommonKeyTitle);
  OCMStub([mockMetadataItem stringValue]).andReturn(@"English Audio Track");
  OCMStub([mockOption1 commonMetadata]).andReturn(@[mockMetadataItem]);
  
  // Configure media selection group
  NSArray *options = @[mockOption1, mockOption2];
  OCMStub([mockMediaSelectionGroup options]).andReturn(options);
  OCMStub([mockMediaSelectionGroup.options count]).andReturn(2);
  
  // Mock the asset to return media selection group
  OCMStub([self.mockAsset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicAudible]).andReturn(mockMediaSelectionGroup);
  
  // Mock current selection
  OCMStub([self.mockPlayerItem selectedMediaOptionInMediaSelectionGroup:mockMediaSelectionGroup]).andReturn(mockOption1);
  
  // Test the method
  FlutterError *error = nil;
  FVPNativeAudioTrackData *result = [self.player getAudioTracks:&error];
  
  // Verify results
  XCTAssertNil(error);
  XCTAssertNotNil(result);
  XCTAssertNil(result.assetTracks);
  XCTAssertNotNil(result.mediaSelectionTracks);
  XCTAssertEqual(result.mediaSelectionTracks.count, 2);
  
  // Verify first option
  FVPMediaSelectionAudioTrackData *option1Data = result.mediaSelectionTracks[0];
  XCTAssertEqualObjects(option1Data.index, @0);
  XCTAssertEqualObjects(option1Data.displayName, @"English");
  XCTAssertEqualObjects(option1Data.languageCode, @"en");
  XCTAssertTrue(option1Data.isSelected);
  XCTAssertEqualObjects(option1Data.commonMetadataTitle, @"English Audio Track");
  
  // Verify second option
  FVPMediaSelectionAudioTrackData *option2Data = result.mediaSelectionTracks[1];
  XCTAssertEqualObjects(option2Data.index, @1);
  XCTAssertEqualObjects(option2Data.displayName, @"Español");
  XCTAssertEqualObjects(option2Data.languageCode, @"es");
  XCTAssertFalse(option2Data.isSelected);
}

- (void)testGetAudioTracksWithNoCurrentItem {
  // Mock player with no current item
  OCMStub([self.mockPlayer currentItem]).andReturn(nil);
  
  // Test the method
  FlutterError *error = nil;
  FVPNativeAudioTrackData *result = [self.player getAudioTracks:&error];
  
  // Verify results
  XCTAssertNil(error);
  XCTAssertNotNil(result);
  XCTAssertNil(result.assetTracks);
  XCTAssertNil(result.mediaSelectionTracks);
}

- (void)testGetAudioTracksWithNoAsset {
  // Mock player item with no asset
  OCMStub([self.mockPlayerItem asset]).andReturn(nil);
  
  // Test the method
  FlutterError *error = nil;
  FVPNativeAudioTrackData *result = [self.player getAudioTracks:&error];
  
  // Verify results
  XCTAssertNil(error);
  XCTAssertNotNil(result);
  XCTAssertNil(result.assetTracks);
  XCTAssertNil(result.mediaSelectionTracks);
}

- (void)testGetAudioTracksCodecDetection {
  // Create mock asset track with format description
  id mockTrack = OCMClassMock([AVAssetTrack class]);
  OCMStub([mockTrack trackID]).andReturn(1);
  OCMStub([mockTrack languageCode]).andReturn(@"en");
  
  // Mock format description with AAC codec
  id mockFormatDesc = OCMClassMock([NSObject class]);
  OCMStub([mockTrack formatDescriptions]).andReturn(@[mockFormatDesc]);
  
  // Mock the asset
  OCMStub([self.mockAsset tracksWithMediaType:AVMediaTypeAudio]).andReturn(@[mockTrack]);
  OCMStub([self.mockAsset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicAudible]).andReturn(nil);
  
  // Test the method
  FlutterError *error = nil;
  FVPNativeAudioTrackData *result = [self.player getAudioTracks:&error];
  
  // Verify results
  XCTAssertNil(error);
  XCTAssertNotNil(result);
  XCTAssertNotNil(result.assetTracks);
  XCTAssertEqual(result.assetTracks.count, 1);
  
  FVPAssetAudioTrackData *track = result.assetTracks[0];
  XCTAssertEqualObjects(track.trackId, @1);
  XCTAssertEqualObjects(track.language, @"en");
}

- (void)testGetAudioTracksWithEmptyMediaSelectionOptions {
  // Create mock media selection group with no options
  id mockMediaSelectionGroup = OCMClassMock([AVMediaSelectionGroup class]);
  OCMStub([mockMediaSelectionGroup options]).andReturn(@[]);
  OCMStub([mockMediaSelectionGroup.options count]).andReturn(0);
  
  // Mock the asset
  OCMStub([self.mockAsset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicAudible]).andReturn(mockMediaSelectionGroup);
  OCMStub([self.mockAsset tracksWithMediaType:AVMediaTypeAudio]).andReturn(@[]);
  
  // Test the method
  FlutterError *error = nil;
  FVPNativeAudioTrackData *result = [self.player getAudioTracks:&error];
  
  // Verify results - should fall back to asset tracks
  XCTAssertNil(error);
  XCTAssertNotNil(result);
  XCTAssertNotNil(result.assetTracks);
  XCTAssertNil(result.mediaSelectionTracks);
  XCTAssertEqual(result.assetTracks.count, 0);
}

- (void)testGetAudioTracksWithNilMediaSelectionOption {
  // Create mock media selection group with nil option
  id mockMediaSelectionGroup = OCMClassMock([AVMediaSelectionGroup class]);
  NSArray *options = @[[NSNull null]]; // Simulate nil option
  OCMStub([mockMediaSelectionGroup options]).andReturn(options);
  OCMStub([mockMediaSelectionGroup.options count]).andReturn(1);
  
  // Mock the asset
  OCMStub([self.mockAsset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicAudible]).andReturn(mockMediaSelectionGroup);
  
  // Test the method
  FlutterError *error = nil;
  FVPNativeAudioTrackData *result = [self.player getAudioTracks:&error];
  
  // Verify results - should handle nil option gracefully
  XCTAssertNil(error);
  XCTAssertNotNil(result);
  XCTAssertNotNil(result.mediaSelectionTracks);
  XCTAssertEqual(result.mediaSelectionTracks.count, 0); // Should skip nil options
}

@end
