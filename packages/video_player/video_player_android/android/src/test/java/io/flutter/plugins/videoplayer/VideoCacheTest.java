import android.content.Context;
import com.google.android.exoplayer2.database.DatabaseProvider;
import com.google.android.exoplayer2.database.StandaloneDatabaseProvider;
import com.google.android.exoplayer2.upstream.cache.LeastRecentlyUsedCacheEvictor;
import com.google.android.exoplayer2.upstream.cache.SimpleCache;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import java.io.File;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

public class VideoCacheTest {

    @Mock
    Context mockContext;

    @Before
    public void setup() {
        MockitoAnnotations.initMocks(this);
    }

    @After
    public void teardown() {
        // Clear the static cache after each test
        VideoCache.sDownloadCache = null;
    }

    @Test
    public void testGetInstanceCreatesCache() {
        long maxCacheSize = 100 * 1024 * 1024; // 100MB

        DatabaseProvider mockDatabaseProvider = mock(StandaloneDatabaseProvider.class);
        when(mockContext.getCacheDir()).thenReturn(new File("dummy/cache/dir"));

        SimpleCache cache = VideoCache.getInstance(mockContext, maxCacheSize);

        assertNotNull(cache);
        assertEquals(maxCacheSize, cache.getCacheSpace());

        // Ensure that the cache is initialized only once
        SimpleCache cachedCache = VideoCache.getInstance(mockContext, maxCacheSize);
        assertEquals(cache, cachedCache);
    }

    @Test
    public void testClearVideoCache() {
        // Create a mock directory and file
        File mockCacheDir = mock(File.class);
        when(mockContext.getCacheDir()).thenReturn(mockCacheDir);

        // Stub the directory and file deletion
        when(mockCacheDir.list()).thenReturn(new String[]{"file1", "file2"});
        when(mockCacheDir.isDirectory()).thenReturn(true);
        when(mockCacheDir.isFile()).thenReturn(false);
        when(mockCacheDir.delete()).thenReturn(true);

        assertTrue(VideoCache.clearVideoCache(mockContext));
        verify(mockCacheDir, times(2)).delete(); // Should delete both files and the directory
    }

    @Test
    public void testClearVideoCacheFailure() {
        File mockCacheDir = mock(File.class);
        when(mockContext.getCacheDir()).thenReturn(mockCacheDir);

        // Simulate an exception during deletion
        when(mockCacheDir.list()).thenReturn(new String[]{"file1", "file2"});
        when(mockCacheDir.isDirectory()).thenReturn(true);
        when(mockCacheDir.isFile()).thenReturn(false);
        when(mockCacheDir.delete()).thenReturn(false);

        assertFalse(VideoCache.clearVideoCache(mockContext));
    }
}