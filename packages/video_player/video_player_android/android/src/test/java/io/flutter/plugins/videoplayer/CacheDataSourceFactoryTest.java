// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.mockito.Mockito.*;

@RunWith(MockitoJUnitRunner.class)

public class CacheDataSourceFactoryTest {

    @Mock
    Context mockContext;

    @Mock
    DataSource.Factory mockUpstreamDataSourceFactory;

    @Test
    public void testCreateDataSource() {
        long maxCacheSize = 100 * 1024 * 1024; // 100MB
        long maxFileSize = 10 * 1024 * 1024;   // 10MB

        CacheDataSourceFactory factory = new CacheDataSourceFactory(
                mockContext, maxCacheSize, maxFileSize, mockUpstreamDataSourceFactory);

        DataSource dataSource = factory.createDataSource();

        assertTrue(dataSource instanceof CacheDataSource);
    }

    @Test
    public void testCreateDataSourceWithExistingCache() {
        long maxCacheSize = 100 * 1024 * 1024; // 100MB
        long maxFileSize = 10 * 1024 * 1024;   // 10MB

        // Simulate an existing downloadCache
        SimpleCache mockDownloadCache = mock(SimpleCache.class);
        when(mockDownloadCache.getCacheSpace()).thenReturn(maxCacheSize);
        CacheDataSourceFactory.downloadCache = mockDownloadCache;

        CacheDataSourceFactory factory = new CacheDataSourceFactory(
                mockContext, maxCacheSize, maxFileSize, mockUpstreamDataSourceFactory);

        DataSource dataSource = factory.createDataSource();

        assertTrue(dataSource instanceof CacheDataSource);
    }
}