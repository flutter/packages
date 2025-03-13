// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerTestImages.h"

@implementation ImagePickerTestImages

+ (NSData *)JPGTestData {
  NSBundle *bundle = [NSBundle bundleForClass:self];
  NSURL *url = [bundle URLForResource:@"jpgImage" withExtension:@"jpg"];
  NSData *data = [NSData dataWithContentsOfURL:url];
  if (!data.length) {
    // When the tests are run outside the example project (podspec lint) the image may not be
    // embedded in the test bundle. Fall back to the base64 string representation of the jpg.
    data = [[NSData alloc]
        initWithBase64EncodedString:
            @"/9j/4AAQSkZJRgABAQAASABIAAD/"
            @"4QCMRXhpZgAATU0AKgAAAAgABQESAAMAAAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgEoAAMAAAABA"
            @"AIAAIdpAAQAAAABAAAAWgAAAAAAAABIAAAAAQAAAEgAAAABAAOgAQADAAAAAQABAACgAgAEAAAAAQAAAAygAw"
            @"AEAAAAAQAAAAcAAAAA/8AAEQgABwAMAwERAAIRAQMRAf/"
            @"EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//"
            @"EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBka"
            @"JSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio"
            @"6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+v/"
            @"EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//"
            @"EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEX"
            @"GBkaJicoKSo1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZm"
            @"qKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/"
            @"bAEMAAgICAgICAwICAwUDAwMFBgUFBQUGCAYGBgYGCAoICAgICAgKCgoKCgoKCgwMDAwMDA4ODg4ODw8PDw8P"
            @"Dw8PD//"
            @"bAEMBAgMDBAQEBwQEBxALCQsQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQ"
            @"EBAQEP/dAAQAAv/aAAwDAQACEQMRAD8A9S8ZfsFeG/sH/IUboe7V/JHgR4t4v+2/4XVdj908aPHLG/2P/"
            @"B6PsfO5/YL8O7m/4mjdT3av966fi1ivZw/ddF2P8VZ+OeN9pP8Ac9X2P//Z"
                            options:0];
  }
  return data;
}

+ (NSData *)JPGTallTestData {
  NSBundle *bundle = [NSBundle bundleForClass:self];
  NSURL *url = [bundle URLForResource:@"jpgImageTall" withExtension:@"jpg"];
  NSData *data = [NSData dataWithContentsOfURL:url];
  if (!data.length) {
    // When the tests are run outside the example project (podspec lint) the image may not be
    // embedded in the test bundle. Fall back to the base64 string representation of the jpg.
    data = [[NSData alloc]
        initWithBase64EncodedString:
            @"/9j/4AAQSkZJRgABAQAAAAAAAAD/"
            @"2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQE"
            @"w8QEBD/"
            @"2wBDAQMDAwQDBAgEBAgQCwkLEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQE"
            @"BAQEBD/wAARCAAHAAQDAREAAhEBAxEB/8QAFAABAAAAAAAAAAAAAAAAAAAABP/"
            @"EAB0QAAECBwAAAAAAAAAAAAAAAAIABgQIFiVBQlH/xAAUAQEAAAAAAAAAAAAAAAAAAAAH/"
            @"8QAHBEAAQQDAQAAAAAAAAAAAAAABAAHI1EIFlIX/9oADAMBAAIRAxEAPwA76kLbdSxV/"
            @"PGxcTHjm7hXngUfVWgp+n0N3suLmqX/2Q=="
                            options:0];
  }
  return data;
}

+ (NSData *)PNGTestData {
  NSBundle *bundle = [NSBundle bundleForClass:self];
  NSURL *url = [bundle URLForResource:@"pngImage" withExtension:@"png"];
  NSData *data = [NSData dataWithContentsOfURL:url];
  if (!data.length) {
    // When the tests are run outside the example project (podspec lint) the image may not be
    // embedded in the test bundle. Fall back to the base64 string representation of the png.
    data = [[NSData alloc]
        initWithBase64EncodedString:
            @"iVBORw0KGgoAAAANSUhEUgAAAAwAAAAHEAIAAADjQOcwAAAABGdBTUEAALGPC/"
            @"xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAhGVYSWZNTQAqAAAACAA"
            @"FARIAAwAAAAEAAQAAARoABQAAAAEAAABKARsABQAAAAEAAABSASgAAwAAAAEAAgAAh2kABAAAAAEAAABaAAAA"
            @"AAAAAEgAAAABAAAASAAAAAEAA6ABAAMAAAABAAEAAKACAAQAAAABAAAADKADAAQAAAABAAAABwAAAACX5qZPA"
            @"AAACXBIWXMAAAsTAAALEwEAmpwYAAACx2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bW"
            @"xuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNi4wLjAiPgogICA8cmRmOlJERiB4bWx"
            @"uczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRm"
            @"OkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvY"
            @"mUuY29tL3RpZmYvMS4wLyIKICAgICAgICAgICAgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leG"
            @"lmLzEuMC8iPgogICAgICAgICA8dGlmZjpZUmVzb2x1dGlvbj43MjwvdGlmZjpZUmVzb2x1dGlvbj4KICAgICA"
            @"gICAgPHRpZmY6UmVzb2x1dGlvblVuaXQ+"
            @"MjwvdGlmZjpSZXNvbHV0aW9uVW5pdD4KICAgICAgICAgPHRpZmY6WFJlc29sdXRpb24+"
            @"NzI8L3RpZmY6WFJlc29sdXRpb24+"
            @"CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+"
            @"CiAgICAgICAgIDxleGlmOlBpeGVsWERpbWVuc2lvbj4xMjwvZXhpZjpQaXhlbFhEaW1lbnNpb24+"
            @"CiAgICAgICAgIDxleGlmOkNvbG9yU3BhY2U+"
            @"MTwvZXhpZjpDb2xvclNwYWNlPgogICAgICAgICA8ZXhpZjpQaXhlbFlEaW1lbnNpb24+"
            @"NzwvZXhpZjpQaXhlbFlEaW1lbnNpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+"
            @"CjwveDp4bXBtZXRhPgqm8GvmAAAAUElEQVQYGWP4/58BCJDJV6sYGERD9wPFHRimhjIwZK3KAopMDXUAqtv/"
            @"XxQoAlKBquf/fyaQEDUACwOD2W0qGeSlSiWDPFWoZBB1vEa1wAYAWgsa+7/A1uQAAAAASUVORK5CYII="
                            options:0];
  }
  return data;
}

+ (NSData *)GIFTestData {
  NSBundle *bundle = [NSBundle bundleForClass:self];
  NSURL *url = [bundle URLForResource:@"gifImage" withExtension:@"gif"];
  NSData *data = [NSData dataWithContentsOfURL:url];
  if (!data.length) {
    // When the tests are run outside the example project (podspec lint) the image may not be
    // embedded in the test bundle. Fall back to the base64 string representation of the gif.
    data = [[NSData alloc]
        initWithBase64EncodedString:
            @"R0lGODlhDAAHAPAAAOpCNQAAACH5BABkAAAAIf8LTkVUU0NBUEUyLjADAQAAACwAAAAADAAHAAACCISP"
             "qcvtD1UBACH5BABkAAAALAAAAAAMAAcAhuc/JPA/K+49Ne4+PvA7MrhYHoB+A4N9BYh+BYZ+E4xyG496HZJ"
             "8F5J4GaRtE6tsH7tWIr9SK7xVKJl3IKpvI7lrKc1FLc5PLNJILsdTJMFVJsZWJshWIM9XIshWJNBWLd1SK9"
             "BUMNFRNOlAI+9CMuNJMetHPnuCAF66F1u8FVu7GV27HGytG3utGH6rHGK1G3WxFWeuIHqlIG60IGi4JTnTDz"
             "jZDy/VEy/eFTnVEDzXFxflABfjBRPmBRbnBxPrABvpARntAxLuCBXuCQTyAAb1BgvwACnmDSPpDSLjECPpED"
             "HhFFDLGIeAFoiBFoqCF4uCHYWnHJGVJqSNJQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
             "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
             "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAdWgAIXCjE3PTtAPDUuByQfCzQ4Qj9BPjktBgAcC"
             "StJRURGQzYwJyMdDDM6SkhHS0xRCAEgD1IsKikoLzJTDgQlEBQNT05NUBMVBQMmGCEZHhsaEhEiFoEAIfkEAG"
             "QAAAAsAAAAAAwABwCFB+8ACewACu0ACe4ACO8AC+4ACu8ADOwAD+wAEOYAEekAA/EABfAAB/IAAfUAA/UAAP"
             "cAAfcAAvYAA/cBBPQABfUABvQAB/UBBvYBCfAACPEAC/AACvIACvMBAPgAAPkAAPgBAPkBAvgBAPoAAPoBA"
             "PsBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
             "AAAAAAAAAAAAAAAAAAAAAAAABkfAAadjeUxEEYnk8QBoLhUHCASJJCWLyiTiIZFG3lAoO4F4SiUwScywYCQQ8"
             "ScEEokCG06D8pA4mBUWCQoIBwIGGQQGBgUFQQA7"
                            options:0];
  }
  return data;
}

@end
