// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation
import MobileCoreServices
import PhotosUI
import UniformTypeIdentifiers

typealias GetSavedPath = (String?, Error?) -> Void

@available(iOS 14, *)
final class PHPickerSaveImageToPathOperation: Operation, @unchecked Sendable {
    private let itemProvider: NSItemProvider
    private let maxHeight: Double?
    private let maxWidth: Double?
    private let desiredImageQuality: Double?
    private let requestFullMetadata: Bool
    private let savedPathBlock: GetSavedPath

    private var _executing: Bool = false
    override var isExecuting: Bool {
        get { return _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _finished: Bool = false
    override var isFinished: Bool {
        get { return _finished }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    init(
        itemProvider: NSItemProvider,
        maxHeight: Double?,
        maxWidth: Double?,
        desiredImageQuality: Double?,
        fullMetadata: Bool,
        savedPathBlock: @escaping GetSavedPath
    ) {
        self.itemProvider = itemProvider
        self.maxHeight = maxHeight
        self.maxWidth = maxWidth
        self.desiredImageQuality = desiredImageQuality
        requestFullMetadata = fullMetadata
        self.savedPathBlock = savedPathBlock
        super.init()
    }

    override var isAsynchronous: Bool {
        return true
    }

    override func start() {
        if isCancelled {
            isFinished = true
            return
        }

        isExecuting = true

        let imageTypeIdentifier = UTType.image.identifier
        let movieTypeIdentifier = UTType.movie.identifier

        if itemProvider.hasItemConformingToTypeIdentifier(imageTypeIdentifier) {
            itemProvider.loadDataRepresentation(forTypeIdentifier: imageTypeIdentifier) {
                [weak self] data, error in
                guard let self = self else { return }
                if let data = data {
                    self.processImage(data)
                } else {
                    let pigeonError = PigeonError(
                        code: "invalid_image",
                        message: error?.localizedDescription,
                        details: (error as NSError?)?.domain
                    )
                    self.completeOperation(path: nil, error: pigeonError)
                }
            }
        } else if itemProvider.hasItemConformingToTypeIdentifier(movieTypeIdentifier) {
            processVideo()
        } else {
            let pigeonError = PigeonError(
                code: "invalid_source",
                message: "Invalid media source.",
                details: nil
            )
            completeOperation(path: nil, error: pigeonError)
        }
    }

    private func completeOperation(path: String?, error: Error?) {
        savedPathBlock(path, error)
        isExecuting = false
        isFinished = true
    }

    private func processImage(_ pickerImageData: Data) {
        guard var localImage = UIImage(data: pickerImageData) else {
            let error = PigeonError(
                code: "invalid_image", message: "Could not decode image from data.", details: nil
            )
            completeOperation(path: nil, error: error)
            return
        }

        if maxWidth != nil || maxHeight != nil {
            localImage = ImagePickerImageUtil.scaledImage(
                localImage,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                isMetadataAvailable: true
            )
        }

        let savedPath = ImagePickerPhotoAssetUtil.saveImage(
            with: pickerImageData,
            image: localImage,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: desiredImageQuality
        )

        if let savedPath = savedPath {
            completeOperation(path: savedPath, error: nil)
        } else {
            let error = PigeonError(
                code: "image_save_failed", message: "Could not save image to disk.", details: nil
            )
            completeOperation(path: nil, error: error)
        }
    }

    private func processVideo() {
        guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first else {
            let error = PigeonError(
                code: "invalid_source", message: "No registered type identifiers.", details: nil
            )
            completeOperation(path: nil, error: error)
            return
        }

        itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) {
            [weak self] videoURL, error in
            guard let self = self else { return }
            if let error = error {
                let pigeonError = PigeonError(code: "invalid_image", message: error.localizedDescription, details: (error as NSError).domain)
                self.completeOperation(path: nil, error: pigeonError)
                return
            }

            guard let videoURL = videoURL else {
                self.completeOperation(
                    path: nil,
                    error: PigeonError(
                        code: "invalid_image", message: "Video URL was nil", details: nil
                    )
                )
                return
            }

            let destination = ImagePickerPhotoAssetUtil.saveVideo(from: videoURL)
            if let destination = destination {
                self.completeOperation(path: destination.path, error: nil)
            } else {
                self.completeOperation(
                    path: nil,
                    error: PigeonError(
                        code: "flutter_image_picker_copy_video_error",
                        message: "Could not cache the video file.",
                        details: nil
                    )
                )
            }
        }
    }
}
