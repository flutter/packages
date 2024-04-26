package dev.flutter.packages.interactive_media_ads

import android.net.Uri
import android.widget.VideoView

class VideoViewProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiVideoView(pigeonRegistrar) {
    override fun pigeon_defaultConstructor(): VideoView {
        return VideoView((pigeonRegistrar as ProxyApiRegistrar).context)
    }

    override fun setVideoUri(pigeon_instance: VideoView, uri: String) {
        pigeon_instance.setVideoURI(Uri.parse(uri))
    }

    override fun getCurrentPosition(pigeon_instance: VideoView): Long {
        return pigeon_instance.currentPosition.toLong()
    }
}
