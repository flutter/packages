import AVKit
import Cache
import HLSCachingReverseProxyServer
import GCDWebServer
import PINCache

@objc public class CacheManager: NSObject {
    var diskCacheSize: UInt = 1024 * 1024 * 1024
    
    // We store the last pre-cached CachingPlayerItem objects to be able to play even if the download
    // has not finished.
    var _preCachedURLs = Dictionary<String, CachingPlayerItem>()
    
    var completionHandler: ((_ success:Bool) -> Void)? = nil
    
    lazy var diskConfig = DiskConfig(name: "VideoPlayerCache", expiry: .date(Date().addingTimeInterval(3600*24*30)),
                                     maxSize: diskCacheSize)
    
    // Flag whether the CachingPlayerItem was already cached.
    var _existsInStorage: Bool = false
    
    let memoryConfig = MemoryConfig(
        // Expiry date that will be applied by default for every added object
        // if it's not overridden in the `setObject(forKey:expiry:)` method
        expiry: .never,
        // The maximum number of objects in memory the cache should hold
        countLimit: 0,
        // The maximum total cost that the cache can hold before it starts evicting objects, 0 for no limit
        totalCostLimit: 0
    )
    
    var server: HLSCachingReverseProxyServer?
    
    lazy var storage: Cache.Storage<String,Data>? = {
        return try? Cache.Storage<String,Data>(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: Data.self))
    }()
    
    
    ///Setups cache server for HLS streams
    @objc public func setup(_ maxCacheSize: NSInteger){
        GCDWebServer.setLogLevel(4)
        let webServer = GCDWebServer()
        let cache = PINCache.shared
        cache.diskCache.byteLimit = UInt(maxCacheSize)
        cache.diskCache.ageLimit = 30 * 24 * 60 * 60
        let urlSession = URLSession.shared
        server = HLSCachingReverseProxyServer(webServer: webServer, urlSession: urlSession, cache: cache)
        server?.start(port: 8080)
    }

    @objc public func isVideoCached(_ url: URL) -> Bool {
        let cache = PINCache.shared
        // Check if the object exists in cache
        if cache.containsObject(forKey: url.absoluteString) {
            return true // The video is cached
        } else {
            return false // The video is not cached
        }
    }
    
    @objc public func setMaxCacheSize(_ maxCacheSize: NSNumber?){
        if let unsigned = maxCacheSize {
            let _maxCacheSize = unsigned.uintValue
            diskConfig = DiskConfig(name: "VideoPlayerCache", expiry: .date(Date().addingTimeInterval(3600*24*30)), maxSize: _maxCacheSize)
        }
    }
    
    // MARK: - Logic
    @objc public func preCacheURL(_ url: URL, cacheKey: String?, videoExtension: String?, withHeaders headers: Dictionary<NSObject,AnyObject>, completionHandler: ((_ success:Bool) -> Void)?) {
        self.completionHandler = completionHandler
        
        let _key: String = cacheKey ?? url.absoluteString
        // Make sure the item is not already being downloaded
        if self._preCachedURLs[_key] == nil {
            if let item = self.getCachingPlayerItem(url, cacheKey: _key, videoExtension: videoExtension, headers: headers){
                if !self._existsInStorage {
                    self._preCachedURLs[_key] = item
                    item.download()
                } else {
                    self.completionHandler?(true)
                }
            } else {
                self.completionHandler?(false)
            }
        } else {
            self.completionHandler?(true)
        }
    }
    
    @objc public func stopPreCache(_ url: URL, cacheKey: String?, completionHandler: ((_ success:Bool) -> Void)?){
        let _key: String = cacheKey ?? url.absoluteString
        if self._preCachedURLs[_key] != nil {
            let playerItem = self._preCachedURLs[_key]!
            playerItem.stopDownload()
            self._preCachedURLs.removeValue(forKey: _key)
            self.completionHandler?(true)
            return
        }
        self.completionHandler?(false)
    }
    
    ///Gets caching player item for normal playback.
    @objc public func getCachingPlayerItemForNormalPlayback(_ url: URL, cacheKey: String?, videoExtension: String?, headers: Dictionary<NSObject,AnyObject>) -> AVPlayerItem? {
        let mimeTypeResult = getMimeType(url:url, explicitVideoExtension: videoExtension)
        if (mimeTypeResult.1 == "application/vnd.apple.mpegurl"){
            let reverseProxyURL = server?.reverseProxyURL(from: url)!
            let playerItem = AVPlayerItem(url: reverseProxyURL!)
            return playerItem
        } else {
            return getCachingPlayerItem(url, cacheKey: cacheKey, videoExtension: videoExtension, headers: headers)
        }
    }
    
    
    // Get a CachingPlayerItem either from the network if it's not cached or from the cache.
    @objc public func getCachingPlayerItem(_ url: URL, cacheKey: String?,videoExtension: String?, headers: Dictionary<NSObject,AnyObject>) -> CachingPlayerItem? {
        let playerItem: CachingPlayerItem
        let _key: String = cacheKey ?? url.absoluteString
        // Fetch ongoing pre-cached url if it exists
        if self._preCachedURLs[_key] != nil {
            playerItem = self._preCachedURLs[_key]!
            self._preCachedURLs.removeValue(forKey: _key)
        } else {
            // Trying to retrieve a track from cache syncronously
            let data = try? storage?.object(forKey: _key)
            if data != nil {
                // The file is cached.
                self._existsInStorage = true
                let mimeTypeResult = getMimeType(url:url, explicitVideoExtension: videoExtension)
                if (mimeTypeResult.1.isEmpty){
                    NSLog("Cache error: couldn't find mime type for url: \(url.absoluteURL). For this URL cache didn't work and video will be played without cache.")
                    playerItem = CachingPlayerItem(url: url, cacheKey: _key, headers: headers)
                } else {
                    playerItem = CachingPlayerItem(data: data!, mimeType: mimeTypeResult.1, fileExtension: mimeTypeResult.0)
                }
            } else {
                // The file is not cached.
                playerItem = CachingPlayerItem(url: url, cacheKey: _key, headers: headers)
                self._existsInStorage = false
            }
        }
        playerItem.delegate = self
        return playerItem
    }
    
    // Remove all objects
    @objc public func clearCache(){
        try? storage?.removeAll()
        self._preCachedURLs = Dictionary<String,CachingPlayerItem>()
    }
    
    private func getMimeType(url: URL, explicitVideoExtension: String?) -> (String,String){
        var videoExtension = url.pathExtension
        if (explicitVideoExtension != nil){
            videoExtension = explicitVideoExtension!
        }
        var mimeType = ""
        switch (videoExtension){
        case "m3u":
            mimeType = "application/vnd.apple.mpegurl"
        case "m3u8":
            mimeType = "application/vnd.apple.mpegurl"
        case "3gp":
            mimeType = "video/3gpp"
        case "mp4":
            mimeType = "video/mp4"
        case "m4a":
            mimeType = "video/mp4"
        case "m4p":
            mimeType = "video/mp4"
        case "m4b":
            mimeType = "video/mp4"
        case "m4r":
            mimeType = "video/mp4"
        case "m4v":
            mimeType = "video/mp4"
        case "m1v":
            mimeType = "video/mpeg"
        case "mpg":
            mimeType = "video/mpeg"
        case "mp2":
            mimeType = "video/mpeg"
        case "mpeg":
            mimeType = "video/mpeg"
        case "mpe":
            mimeType = "video/mpeg"
        case "mpv":
            mimeType = "video/mpeg"
        case "ogg":
            mimeType = "video/ogg"
        case "mov":
            mimeType = "video/quicktime"
        case "qt":
            mimeType = "video/quicktime"
        case "webm":
            mimeType = "video/webm"
        case "asf":
            mimeType = "video/ms-asf"
        case "wma":
            mimeType = "video/ms-asf"
        case "wmv":
            mimeType = "video/ms-asf"
        case "avi":
            mimeType = "video/x-msvideo"
        default:
            mimeType = ""
        }
        
        return (videoExtension, mimeType)
    }
    
    ///Checks wheter pre cache is supported for given url.
    @objc public func isPreCacheSupported(url: URL, videoExtension: String?) -> Bool{
        let mimeTypeResult = getMimeType(url:url, explicitVideoExtension: videoExtension)
        return !mimeTypeResult.1.isEmpty && mimeTypeResult.1 != "application/vnd.apple.mpegurl"
    }
}

// MARK: - CachingPlayerItemDelegate
extension CacheManager: CachingPlayerItemDelegate {
    func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingData data: Data) {
        // A track is downloaded. Saving it to the cache asynchronously.
        storage?.async.setObject(data, forKey: playerItem.cacheKey ?? playerItem.url.absoluteString, completion: { _ in })
        self.completionHandler?(true)
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int){
        /// Is called every time a new portion of data is received.
        let percentage = Double(bytesDownloaded)/Double(bytesExpected)*100.0
        let str = String(format: "%.1f%%", percentage)
        //NSLog("Downloading... %@", str)
    }
    
    func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error){
        /// Is called on downloading error.
        NSLog("Error when downloading the file %@", error as NSError);
        self.completionHandler?(false)
    }
}
