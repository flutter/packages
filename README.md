# Changes

Made onUrlChanged accessible

added getCopyBackForwardList

set setMixedContentMode(WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE) to match Chrome behaviour

set     

    @Override
    public Bitmap getDefaultVideoPoster() {
      return Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888);
    }
    
to make video tags without a poster attribute not display the ugly gray play button
