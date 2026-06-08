// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
@testable import image_picker_ios
import XCTest

class PigeonTests: XCTestCase {
    func testMaxSize_Equality() {
        let size1 = MaxSize(width: 100, height: 200)
        let size2 = MaxSize(width: 100, height: 200)
        let size3 = MaxSize(width: 101, height: 200)

        XCTAssertEqual(size1, size2)
        XCTAssertNotEqual(size1, size3)

        let size4 = MaxSize(width: 100, height: nil)
        let size5 = MaxSize(width: 100, height: nil)
        XCTAssertEqual(size4, size5)
        XCTAssertNotEqual(size1, size4)
    }

    func testMaxSize_Hash() {
        let size1 = MaxSize(width: 100, height: 200)
        let size2 = MaxSize(width: 100, height: 200)
        XCTAssertEqual(size1.hashValue, size2.hashValue)
    }

    func testMediaSelectionOptions_Equality() {
        let options1 = MediaSelectionOptions(
            maxSize: MaxSize(width: 10, height: 20),
            imageQuality: 80,
            requestFullMetadata: true,
            allowMultiple: false,
            limit: 1
        )
        let options2 = MediaSelectionOptions(
            maxSize: MaxSize(width: 10, height: 20),
            imageQuality: 80,
            requestFullMetadata: true,
            allowMultiple: false,
            limit: 1
        )
        XCTAssertEqual(options1, options2)

        var options3 = options1
        options3.imageQuality = 79
        XCTAssertNotEqual(options1, options3)

        var options4 = options1
        options4.requestFullMetadata = false
        XCTAssertNotEqual(options1, options4)
    }

    func testSourceSpecification_Equality() {
        let source1 = SourceSpecification(type: .camera, camera: .rear)
        let source2 = SourceSpecification(type: .camera, camera: .rear)
        let source3 = SourceSpecification(type: .gallery, camera: .rear)

        XCTAssertEqual(source1, source2)
        XCTAssertNotEqual(source1, source3)

        let source4 = SourceSpecification(type: .camera, camera: .front)
        XCTAssertNotEqual(source1, source4)
    }

    func testPigeonError_LocalizedDescription() {
        let error = PigeonError(code: "code", message: "msg", details: "details")
        XCTAssertTrue(error.localizedDescription.contains("code"))
        XCTAssertTrue(error.localizedDescription.contains("msg"))
        XCTAssertTrue(error.localizedDescription.contains("details"))
    }

    func testDeepEqualsMessages() {
        XCTAssertTrue(deepEqualsMessages(nil, nil))
        XCTAssertFalse(deepEqualsMessages(1, nil))
        XCTAssertFalse(deepEqualsMessages(nil, 1))
        XCTAssertTrue(deepEqualsMessages([1, 2], [1, 2]))
        XCTAssertFalse(deepEqualsMessages([1, 2], [1, 3]))
        XCTAssertFalse(deepEqualsMessages([1, 2], [1]))
        XCTAssertTrue(deepEqualsMessages(["a": 1], ["a": 1]))
        XCTAssertFalse(deepEqualsMessages(["a": 1], ["a": 2]))
        XCTAssertFalse(deepEqualsMessages(["a": 1], ["b": 1]))
        XCTAssertFalse(deepEqualsMessages(["a": 1, "b": 2], ["a": 1]))
        XCTAssertFalse(deepEqualsMessages(["a": 1], ["a": 1, "b": 2]))
        XCTAssertTrue(deepEqualsMessages(1.0, 1.0))
        XCTAssertTrue(deepEqualsMessages(Double.nan, Double.nan))
        XCTAssertTrue(deepEqualsMessages([1.0, 2.0] as [Double], [1.0, 2.0] as [Double]))
        XCTAssertFalse(deepEqualsMessages([1.0, 2.0] as [Double], [1.0, 3.0] as [Double]))
        XCTAssertFalse(deepEqualsMessages([1.0, 2.0] as [Double], [1.0] as [Double]))
        XCTAssertFalse(deepEqualsMessages([1.0] as [Double], [1.0, 2.0] as [Double]))
        XCTAssertFalse(deepEqualsMessages([1.0] as [Double], [1]))

        // Identity check
        let obj = NSObject()
        XCTAssertTrue(deepEqualsMessages(obj, obj))

        // Void check
        XCTAssertTrue(deepEqualsMessages((), ()))
        XCTAssertFalse(deepEqualsMessages((), 1))

        // Double Array check
        let d1: [Double] = [1.1, 2.2]
        let d2: [Double] = [1.1, 2.2]
        let d3: [Double] = [1.1, 2.3]
        XCTAssertTrue(deepEqualsMessages(d1, d2))
        XCTAssertFalse(deepEqualsMessages(d1, d3))
        XCTAssertFalse(deepEqualsMessages(d1, [1.1]))

        // Mixed types
        XCTAssertFalse(deepEqualsMessages([1], ["1"]))

        // Nested mixed types
        XCTAssertTrue(deepEqualsMessages(["a": [1, 2]], ["a": [1, 2]]))
        XCTAssertFalse(deepEqualsMessages(["a": [1, 2]], ["a": [1, 3]]))
        XCTAssertFalse(deepEqualsMessages(["a": 1], ["a": 2]))
        XCTAssertFalse(deepEqualsMessages(["a": 1], ["b": 1]))
        XCTAssertFalse(deepEqualsMessages(["a": 1], ["a": 1, "b": 2]))
        XCTAssertFalse(deepEqualsMessages(["a": 1, "b": 2], ["c": 1, "d": 2]))
        XCTAssertFalse(deepEqualsMessages(["a": 1, "b": 2], ["a": 1, "c": 2]))
        XCTAssertFalse(deepEqualsMessages(["a": 1, "b": 2], ["a": 2, "b": 1]))

        // AnyHashable
        XCTAssertTrue(deepEqualsMessages("test" as AnyHashable, "test" as AnyHashable))
        XCTAssertFalse(deepEqualsMessages("test" as AnyHashable, "other" as AnyHashable))

        // Mixed lists
        XCTAssertFalse(deepEqualsMessages([1.0] as [Double], [1.0] as [Any?]))
        XCTAssertFalse(deepEqualsMessages([1.0] as [Any?], [1.0] as [Double]))
    }

    func testDeepHashMessages() {
        var hasher1 = Hasher()
        deepHashMessages(value: ["a": [1, 2, ["b": 3.3]]], hasher: &hasher1)

        var hasher2 = Hasher()
        deepHashMessages(value: ["a": [1, 2, ["b": 3.3]]], hasher: &hasher2)

        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }

    func testDeepHashMessages_Basic() {
        var hasher1 = Hasher()
        deepHashMessages(value: ["a": 1], hasher: &hasher1)

        var hasher2 = Hasher()
        deepHashMessages(value: ["a": 1], hasher: &hasher2)

        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())

        var hasher3 = Hasher()
        deepHashMessages(value: ["a": 1, "b": 2], hasher: &hasher3)

        XCTAssertNotEqual(hasher1.finalize(), hasher3.finalize())
    }

    func testDeepHashMessages_List() {
        var hasher1 = Hasher()
        deepHashMessages(value: [1, 2], hasher: &hasher1)

        var hasher2 = Hasher()
        deepHashMessages(value: [1, 2], hasher: &hasher2)

        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }

    func testDeepHashMessages_Doubles() {
        var hasher1 = Hasher()
        deepHashMessages(value: 1.0, hasher: &hasher1)
        var hasher2 = Hasher()
        deepHashMessages(value: 1.0, hasher: &hasher2)
        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())

        var hasher3 = Hasher()
        deepHashMessages(value: Double.nan, hasher: &hasher3)
        var hasher4 = Hasher()
        deepHashMessages(value: Double.nan, hasher: &hasher4)
        XCTAssertEqual(hasher3.finalize(), hasher4.finalize())

        var hasher5 = Hasher()
        deepHashMessages(value: 0.0, hasher: &hasher5)
        var hasher6 = Hasher()
        deepHashMessages(value: -0.0, hasher: &hasher6)
        XCTAssertEqual(hasher5.finalize(), hasher6.finalize())
    }

    func testDeepHashMessages_DoubleArray() {
        var hasher1 = Hasher()
        deepHashMessages(value: [1.0, 2.0] as [Double], hasher: &hasher1)

        var hasher2 = Hasher()
        deepHashMessages(value: [1.0, 2.0] as [Double], hasher: &hasher2)

        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())

        var hasher3 = Hasher()
        deepHashMessages(value: [1.0, 3.0] as [Double], hasher: &hasher3)
        XCTAssertNotEqual(hasher1.finalize(), hasher3.finalize())
    }

    func testDeepHashMessages_Dictionary() {
        var hasher1 = Hasher()
        deepHashMessages(value: ["a": 1, "b": 2], hasher: &hasher1)

        var hasher2 = Hasher()
        deepHashMessages(value: ["b": 2, "a": 1], hasher: &hasher2)

        // Order shouldn't matter for dictionary hashing in Pigeon
        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }

    func testDeepHashMessages_UnhandledType() {
        let obj = NSObject()
        var hasher1 = Hasher()
        deepHashMessages(value: obj, hasher: &hasher1)

        var hasher2 = Hasher()
        deepHashMessages(value: obj, hasher: &hasher2)

        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())

        // Different objects should ideally have different hashes
        var hasher3 = Hasher()
        deepHashMessages(value: NSObject(), hasher: &hasher3)
        // Not strictly guaranteed, but likely
        XCTAssertNotEqual(hasher1.finalize(), hasher3.finalize())
    }

    func testDeepHashMessages_Nil() {
        var hasher1 = Hasher()
        deepHashMessages(value: nil, hasher: &hasher1)

        var hasher2 = Hasher()
        deepHashMessages(value: NSNull(), hasher: &hasher2)

        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }

    func testPigeonError_LocalizedDescription_NilValues() {
        let error = PigeonError(code: "code", message: nil, details: nil)
        XCTAssertTrue(error.localizedDescription.contains("<nil>"))
    }

    func testPigeonError_LocalizedDescription_WithDetails() {
        let error = PigeonError(code: "code", message: "message", details: "some details")
        XCTAssertTrue(error.localizedDescription.contains("some details"))
    }

    func testPigeonError_Equality() {
        // PigeonError doesn't implement Equatable, but we can test its properties
        let error = PigeonError(code: "a", message: "b", details: "c")
        XCTAssertEqual(error.code, "a")
        XCTAssertEqual(error.message, "b")
        XCTAssertEqual(error.details as? String, "c")
    }

    func testDeepEquals_DifferentTypes() {
        XCTAssertFalse(deepEqualsMessages(1, "1"))
        XCTAssertFalse(deepEqualsMessages([1], 1))
        XCTAssertFalse(deepEqualsMessages(["a": 1], [1]))
    }

    func testDeepEquals_NaN() {
        XCTAssertTrue(deepEqualsMessages(Double.nan, Double.nan))
        XCTAssertFalse(deepEqualsMessages(Double.nan, 1.0))
    }

    func testMaxSize_fromList_NilValues() {
        let size = MaxSize.fromList([NSNull(), NSNull()])
        XCTAssertNil(size?.width)
        XCTAssertNil(size?.height)
    }

    func testCodec() {
        let codec = MessagesPigeonCodec.shared

        // Test MaxSize
        let maxSize = MaxSize(width: 10, height: 20)
        let maxSizeData = codec.encode(maxSize)
        let decodedMaxSize = codec.decode(maxSizeData) as? MaxSize
        XCTAssertEqual(maxSize, decodedMaxSize)

        // Test MediaSelectionOptions
        let options = MediaSelectionOptions(
            maxSize: MaxSize(width: nil, height: nil),
            imageQuality: 50,
            requestFullMetadata: true,
            allowMultiple: false,
            limit: nil
        )
        let optionsData = codec.encode(options)
        let decodedOptions = codec.decode(optionsData) as? MediaSelectionOptions
        XCTAssertEqual(options, decodedOptions)

        // Test SourceSpecification
        let source = SourceSpecification(type: .gallery, camera: .front)
        let sourceData = codec.encode(source)
        let decodedSource = codec.decode(sourceData) as? SourceSpecification
        XCTAssertEqual(source, decodedSource)

        // Test Enums
        XCTAssertEqual(codec.decode(codec.encode(SourceCamera.front)) as? SourceCamera, .front)
        XCTAssertEqual(codec.decode(codec.encode(SourceType.gallery)) as? SourceType, .gallery)
        XCTAssertEqual(codec.decode(codec.encode(SourceCamera.rear)) as? SourceCamera, .rear)
        XCTAssertEqual(codec.decode(codec.encode(SourceType.camera)) as? SourceType, .camera)

        // Test Nil Enums
        let nilCamera: SourceCamera? = nil
        XCTAssertNil(codec.decode(codec.encode(nilCamera as Any)))

        // Test CoverageModel
        let coverage = CoverageModel(list: ["a", 1], map: ["k": "v"])
        XCTAssertEqual(coverage, codec.decode(codec.encode(coverage)) as? CoverageModel)
    }

    func testModelsFromList() {
        XCTAssertEqual(MaxSize.fromList([10.0, 20.0]), MaxSize(width: 10, height: 20))
        XCTAssertEqual(
            SourceSpecification.fromList([SourceType.camera.rawValue, SourceCamera.front.rawValue]),
            SourceSpecification(type: .camera, camera: .front)
        )

        let options = MediaSelectionOptions(
            maxSize: MaxSize(width: 10, height: 20),
            imageQuality: 50,
            requestFullMetadata: true,
            allowMultiple: false,
            limit: 5
        )
        let optionsList: [Any?] = [
            options.maxSize,
            options.imageQuality,
            options.requestFullMetadata,
            options.allowMultiple,
            options.limit,
        ]
        XCTAssertEqual(MediaSelectionOptions.fromList(optionsList), options)
    }

    func testSourceSpecification_fromList() {
        let source = SourceSpecification(type: .gallery, camera: .front)
        let list: [Any?] = [SourceType.gallery.rawValue, SourceCamera.front.rawValue]
        XCTAssertEqual(SourceSpecification.fromList(list), source)
    }

    func testDeepEquals_Void() {
        XCTAssertTrue(deepEqualsMessages((), ()))
    }

    func testDeepEquals_DoubleArray() {
        let d1: [Double] = [1.0, 2.0]
        let d2: [Double] = [1.0, 2.0]
        let d3: [Double] = [1.0, 3.0]
        XCTAssertTrue(deepEqualsMessages(d1, d2))
        XCTAssertFalse(deepEqualsMessages(d1, d3))
        XCTAssertFalse(deepEqualsMessages(d1, [1.0]))
    }

    func testDeepHash_DoubleArray() {
        var hasher1 = Hasher()
        deepHashMessages(value: [1.0, 2.0] as [Double], hasher: &hasher1)
        var hasher2 = Hasher()
        deepHashMessages(value: [1.0, 2.0] as [Double], hasher: &hasher2)
        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }

    func testPigeonCodec_UnknownType() {
        let reader = MessagesPigeonCodec.shared.makeReader(for: Data([200])) // 200 is an unknown type
        XCTAssertNil(reader.readValue())
    }

    func testDeepHash_ComplexDictionary() {
        var hasher1 = Hasher()
        deepHashMessages(value: ["a": 1, 2: "b"], hasher: &hasher1)
        var hasher2 = Hasher()
        deepHashMessages(value: [2: "b", "a": 1], hasher: &hasher2)
        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }

    func testPigeonError_LocalizedDescription_Full() {
        let error = PigeonError(code: "C", message: "M", details: "D")
        XCTAssertEqual(error.localizedDescription, "PigeonError(code: C, message: M, details: D")
    }

    func testModels_toList() {
        let size = MaxSize(width: 1.0, height: 2.0)
        XCTAssertEqual(size.toList()[0] as? Double, 1.0)
        XCTAssertEqual(size.toList()[1] as? Double, 2.0)

        let source = SourceSpecification(type: .camera, camera: .front)
        XCTAssertEqual(source.toList()[0] as? Int, SourceType.camera.rawValue)
        XCTAssertEqual(source.toList()[1] as? Int, SourceCamera.front.rawValue)

        let options = MediaSelectionOptions(maxSize: size, imageQuality: 50, requestFullMetadata: true, allowMultiple: false, limit: 1)
        let list = options.toList()
        XCTAssertEqual(list.count, 5)
    }

    func testCoverageModel_DeepEquals() {
        let m1 = CoverageModel(list: [1], map: ["a": 1])
        let m2 = CoverageModel(list: [1], map: ["a": 1])
        XCTAssertEqual(m1, m2)

        let m3 = CoverageModel(list: [2], map: ["a": 1])
        XCTAssertNotEqual(m1, m3)
    }
}
