package io.flutter.plugins.videoplayer

import android.content.Context
import android.util.Log
import androidx.media3.common.util.UnstableApi
import androidx.media3.database.StandaloneDatabaseProvider
import androidx.media3.datasource.cache.LeastRecentlyUsedCacheEvictor
import androidx.media3.datasource.cache.SimpleCache
import androidx.work.Data
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import java.io.File
import java.lang.Exception

@UnstableApi
object VideoPlayerCache {
    const val TAG = "VideoPlayerCache"
    const val URL_PARAMETER = "url"
    const val CACHE_KEY_PARAMETER = "cacheKey"
    const val PRE_CACHE_SIZE_PARAMETER = "preCacheSize"
    const val MAX_CACHE_SIZE_PARAMETER = "maxCacheSize"
    const val MAX_CACHE_FILE_SIZE_PARAMETER = "maxCacheFileSize"
    const val HEADER_PARAMETER = "header_"

    //Clear cache without accessing BetterPlayerCache.
    fun clearCache(context: Context?) : Boolean{
        try {
            context?.let {
                val file = File(it.cacheDir, "videoPlayerCache")
                deleteDirectory(file)
            }
            return true
        } catch (exception: Exception) {
            Log.e(TAG, exception.toString())
            return false
        }
    }

    private fun deleteDirectory(file: File) {
        if (file.isDirectory) {
            val entries = file.listFiles()
            if (entries != null) {
                for (entry in entries) {
                    deleteDirectory(entry)
                }
            }
        }
        if (!file.delete()) {
            Log.e(TAG, "Failed to delete cache dir.")
        }
    }

    //Start pre cache of video. Invoke work manager job and start caching in background.
    @JvmStatic
    fun preCache(
        context: Context?, dataSource: String?, preCacheSize: Long,
        maxCacheSize: Long, maxCacheFileSize: Long, headers: Map<String, String?>,
        cacheKey: String?
    ) : Boolean{
        val dataBuilder = Data.Builder()
            .putString(URL_PARAMETER, dataSource)
            .putLong(PRE_CACHE_SIZE_PARAMETER, preCacheSize)
            .putLong(MAX_CACHE_SIZE_PARAMETER, maxCacheSize)
            .putLong(MAX_CACHE_FILE_SIZE_PARAMETER, maxCacheFileSize)
        if (cacheKey != null) {
            dataBuilder.putString(CACHE_KEY_PARAMETER, cacheKey)
        }
        for (headerKey in headers.keys) {
            dataBuilder.putString(
                HEADER_PARAMETER + headerKey,
                headers[headerKey]
            )
        }
        if (dataSource != null && context != null) {
            val cacheWorkRequest = OneTimeWorkRequest.Builder(CacheWorker::class.java)
                .addTag(dataSource)
                .setInputData(dataBuilder.build()).build()
            WorkManager.getInstance(context).enqueue(cacheWorkRequest)
        }
        return true
    }

    //Stop pre cache of video with given url. If there's no work manager job for given url, then
    //it will be ignored.
    fun stopPreCache(context: Context?, url: String?) : Boolean {
        if (url != null && context != null) {
            WorkManager.getInstance(context).cancelAllWorkByTag(url)
        }
        return true
    }

    @Volatile
    private var instance: SimpleCache? = null
    fun createCache(context: Context, cacheFileSize: Long): SimpleCache? {
        initCache(context, cacheFileSize)
        return instance
    }

    fun isCached(cacheKey: String, position: Long, length: Long): Boolean {
        if (instance != null) {
            return instance!!.isCached(cacheKey, position, length);
        }
        return false
    }

    fun initCache(context: Context, cacheFileSize: Long) {
        if (instance == null) {
            synchronized(VideoPlayerCache::class.java) {
                if (instance == null) {
                    instance = SimpleCache(
                        File(context.cacheDir, "videoPlayerCache"),
                        LeastRecentlyUsedCacheEvictor(cacheFileSize),
                        StandaloneDatabaseProvider(context)
                    )
                }
            }
        }
    }

    @JvmStatic
    fun releaseCache() {
        try {
            if (instance != null) {
                instance!!.release()
                instance = null
            }
        } catch (exception: Exception) {
            Log.e("BetterPlayerCache", exception.toString())
        }
    }
}