import io.flutter.plugins.camerax.CameraXProxy;
import io.flutter.plugins.camerax.ImageAnalysisFlutterApiImpl;
import io.flutter.plugins.camerax.ImageAnalysisHostApiImpl;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageInformation;
import io.flutter.plugins.webviewflutter.InstanceManager;

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

public class ImageAnalysisTest {
    @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

    @Mock public ImageAnalysis mockImageAnalysis;
    @Mock public BinaryMessenger mockBinaryMessenger;
    @Mock public CameraXProxy mockCameraXProxy;
  
    InstanceManager testInstanceManager;
    private Context context;
    private MockedStatic<File> mockedStaticFile;
  
    @Before
    public void setUp() throws Exception {
      testInstanceManager = spy(InstanceManager.open(identifier -> {}));
      context = mock(Context.class);
    }
  
    @After
    public void tearDown() {
      testInstanceManager.close();
    }

    @Test
    public void create_buildsExpectedImageAnalysisInstance() {
        final ImageAnalysisHostApiImpl imageAnalysisHostApiImpl =
            new ImageAnalysisHostApiImpl(mockBinaryMessenger, testInstanceManager);
        final Long imageAnalysisIdentifier = 83L;
        final int targetResolutionWidth = 11;
        final int targetResolutionHeight = 51;
        final GeneratedCameraXLibrary.ResolutionInfo resolutionInfo =
            new GeneratedCameraXLibrary.ResolutionInfo.Builder()
                .setWidth(Long.valueOf(targetResolutionWidth))
                .setHeight(Long.valueOf(targetResolutionHeight))
                .build();
        final ImageAnalysis.Builder mockImageAnalysisBuilder = mock(ImageAnalysis.Builder.class);

        imageAnalysisHostApiImpl.cameraXProxy = mockCameraXProxy;
        when(mockCameraXProxy.createImageAnalysisBuilder()).thenReturn(mockImageAnalysisBuilder);
        when(mockImageAnalysisBuilder.build()).thenReturn(mockImageAnalysis);

        final ArgumentCaptor<Size> sizeCaptor = ArgumentCaptor.forClass(Size.class);

        imageAnalysisHostApiImpl.create(imageAnalysisIdentifier, resolutionInfo);

        verify(mockImageAnalysisBuilder).setTargetResolution(sizeCaptor.capture());
        assertEquals(sizeCaptor.getValue().getWidth(), targetResolutionWidth);
        assertEquals(sizeCaptor.getValue().getHeight(), targetResolutionHeight);
        verify(mockImageAnalysisBuilder).build();
        verify(testInstanceManager).addDartCreatedInstance(mockImageAnalysis, imageAnalysisIdentifier);
    }

    @Test
    public void setAnalyzer_() {
        final ImageAnalysisHostApiImpl imageAnalysisHostApiImpl =
            new ImageAnalysisHostApiImpl(mockBinaryMessenger, testInstanceManager);
        final Long mockImageAnalysisIdentifier = 37L;
        final ImageProxy mockImageProxy = mock(ImageProxy.class);

        testInstanceManager.addDartCreatedInstance(mockImageAnalysis, mockImageAnalysisIdentifier);

        final ArgumentCaptor<ImageAnalysis.Analyzer> analyzerCaptor = ArgumentCaptor.forClass(ImageAnalysis.Analyzer.class);

        imageAnalysisHostApiImpl.setAnalyzer(mockImageAnalysisIdentifier);

        // todo: try verifying executor, may need real context
        verify(mockImageAnalysis).setAnalyzer(any(Executor.class), analyzerCaptor.capture());
        ImageAnalysis.Analyzer analyzer = analyzerCaptor.getValue();

        when(mockImageProxy.getPlanes()).thenReturn();
        // mock at least one plane, give it values for everything. can use captor to verify

        // for the rest, give real/mock info and mock the flutter api. capture whatever it sends and check info with it
        when(mockImageProxy.getWidth()).thenReturn();
        when(mockImageProxy.getHeight()).thenReturn();
        when(mockImageProxy.getFormat()).thenReturn();


        analyzer.analyze(mockImageProxy);

        verify(mockImageAnalysisFlutterApiImpl).sendOnImageAnalyzedEvent(..., any());
        verify(mockImageProxy).close();


    }

    @Test
    public void clearAnalyzer_makesCallToClearAnalyzer() {
        final ImageAnalysisHostApiImpl imageAnalysisHostApiImpl =
            new ImageAnalysisHostApiImpl(mockBinaryMessenger, testInstanceManager);
        final Long mockImageAnalysisIdentifier = 12L;

        testInstanceManager.addDartCreatedInstance(mockImageAnalysis, mockImageAnalysisIdentifier);

        imageAnalysisHostApiImpl.clearAnalyzer(mockImageAnalysisIdentifier);

        verify(mockImageAnalysis).clearAnalyzer();
    }

    @Test
    public void sendOnImageAnalyzedEvent_callsOnImageAnalyzed() {
        final ImageAnalysisFlutterApiImpl spyFlutterApi =
            spy(new ImageAnalysisFlutterApiImpl(mockBinaryMessenger));
        final ImageInformation mockImageInformation = mock(ImageInformation.class);

        spyFlutterApi.sendOnImageAnalyzedEvent(mockImageInformation, reply -> {});

        verify(spyFlutterApi).onImageAnalyzed(eq(mockImageInformation), any());
    }
 }
