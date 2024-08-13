// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "include/url_launcher_linux/url_launcher_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <cstring>

#include "messages.g.h"
#include "url_launcher_plugin_private.h"

struct _FlUrlLauncherPlugin {
  GObject parent_instance;

  FlPluginRegistrar* registrar;
};

G_DEFINE_TYPE(FlUrlLauncherPlugin, fl_url_launcher_plugin, g_object_get_type())

// Checks if URI has launchable file resource.
static gboolean can_launch_uri_with_file_resource(FlUrlLauncherPlugin* self,
                                                  const gchar* url) {
  g_autoptr(GError) error = nullptr;
  g_autoptr(GFile) file = g_file_new_for_uri(url);
  g_autoptr(GAppInfo) app_info =
      g_file_query_default_handler(file, NULL, &error);
  return app_info != nullptr;
}

FulUrlLauncherApiCanLaunchUrlResponse* handle_can_launch_url(
    const gchar* url, gpointer user_data) {
  FlUrlLauncherPlugin* self = FL_URL_LAUNCHER_PLUGIN(user_data);

  gboolean is_launchable = FALSE;
  g_autofree gchar* scheme = g_uri_parse_scheme(url);
  if (scheme != nullptr) {
    g_autoptr(GAppInfo) app_info =
        g_app_info_get_default_for_uri_scheme(scheme);
    is_launchable = app_info != nullptr;

    if (!is_launchable) {
      is_launchable = can_launch_uri_with_file_resource(self, url);
    }
  }

  return ful_url_launcher_api_can_launch_url_response_new(is_launchable);
}

// Called when a URL should launch.
static FulUrlLauncherApiLaunchUrlResponse* handle_launch_url(
    const gchar* url, gpointer user_data) {
  FlUrlLauncherPlugin* self = FL_URL_LAUNCHER_PLUGIN(user_data);

  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  g_autoptr(GError) error = nullptr;
  gboolean launched;
  if (view != nullptr) {
    GtkWindow* window = GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
    launched = gtk_show_uri_on_window(window, url, GDK_CURRENT_TIME, &error);
  } else {
    launched = g_app_info_launch_default_for_uri(url, nullptr, &error);
  }
  if (!launched) {
    return ful_url_launcher_api_launch_url_response_new(error->message);
  }

  return ful_url_launcher_api_launch_url_response_new(nullptr);
}

static void fl_url_launcher_plugin_dispose(GObject* object) {
  FlUrlLauncherPlugin* self = FL_URL_LAUNCHER_PLUGIN(object);

  ful_url_launcher_api_clear_method_handlers(
      fl_plugin_registrar_get_messenger(self->registrar), nullptr);
  g_clear_object(&self->registrar);

  G_OBJECT_CLASS(fl_url_launcher_plugin_parent_class)->dispose(object);
}

static void fl_url_launcher_plugin_class_init(FlUrlLauncherPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = fl_url_launcher_plugin_dispose;
}

FlUrlLauncherPlugin* fl_url_launcher_plugin_new(FlPluginRegistrar* registrar) {
  FlUrlLauncherPlugin* self = FL_URL_LAUNCHER_PLUGIN(
      g_object_new(fl_url_launcher_plugin_get_type(), nullptr));

  self->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  static FulUrlLauncherApiVTable api_vtable = {
      .can_launch_url = handle_can_launch_url,
      .launch_url = handle_launch_url,
  };
  ful_url_launcher_api_set_method_handlers(
      fl_plugin_registrar_get_messenger(registrar), nullptr, &api_vtable,
      g_object_ref(self), g_object_unref);

  return self;
}

static void fl_url_launcher_plugin_init(FlUrlLauncherPlugin* self) {}

void url_launcher_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  FlUrlLauncherPlugin* plugin = fl_url_launcher_plugin_new(registrar);
  g_object_unref(plugin);
}
