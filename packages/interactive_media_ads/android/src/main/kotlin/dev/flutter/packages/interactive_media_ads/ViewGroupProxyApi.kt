package dev.flutter.packages.interactive_media_ads

import android.view.View
import android.view.ViewGroup

class ViewGroupProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiViewGroup(pigeonRegistrar) {
  override fun addView(pigeon_instance: ViewGroup, view: View) {
    pigeon_instance.addView(view)
  }
}
