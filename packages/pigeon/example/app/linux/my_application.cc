// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"
#include "messages.g.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;

  PigeonExamplePackageMessageFlutterApi* flutter_api;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// #docregion vtable
static PigeonExamplePackageExampleHostApiGetHostLanguageResponse*
handle_get_host_language(gpointer user_data) {
  return pigeon_example_package_example_host_api_get_host_language_response_new(
      "C++");
}

static PigeonExamplePackageExampleHostApiAddResponse* handle_add(
    int64_t a, int64_t b, gpointer user_data) {
  if (a < 0 || b < 0) {
    g_autoptr(FlValue) details = fl_value_new_string("details");
    return pigeon_example_package_example_host_api_add_response_new_error(
        "code", "message", details);
  }

  return pigeon_example_package_example_host_api_add_response_new(a + b);
}

static void handle_send_message(
    PigeonExamplePackageMessageData* message,
    PigeonExamplePackageExampleHostApiResponseHandle* response_handle,
    gpointer user_data) {
  PigeonExamplePackageCode code =
      pigeon_example_package_message_data_get_code(message);
  if (code == PIGEON_EXAMPLE_PACKAGE_CODE_ONE) {
    g_autoptr(FlValue) details = fl_value_new_string("details");
    pigeon_example_package_example_host_api_respond_error_send_message(
        response_handle, "code", "message", details);
    return;
  }

  pigeon_example_package_example_host_api_respond_send_message(response_handle,
                                                               TRUE);
}

static PigeonExamplePackageExampleHostApiVTable example_host_api_vtable = {
    .get_host_language = handle_get_host_language,
    .add = handle_add,
    .send_message = handle_send_message};
// #enddocregion vtable

// #docregion flutter-method-callback
static void flutter_method_cb(GObject* object, GAsyncResult* result,
                              gpointer user_data) {
  g_autoptr(GError) error = nullptr;
  g_autoptr(
      PigeonExamplePackageMessageFlutterApiFlutterMethodResponse) response =
      pigeon_example_package_message_flutter_api_flutter_method_finish(
          PIGEON_EXAMPLE_PACKAGE_MESSAGE_FLUTTER_API(object), result, &error);
  if (response == nullptr) {
    g_warning("Failed to call Flutter method: %s", error->message);
    return;
  }

  g_printerr(
      "Got result from Flutter method: %s\n",
      pigeon_example_package_message_flutter_api_flutter_method_response_get_return_value(
          response));
}
// #enddocregion flutter-method-callback

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "pigeon_example_app");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "pigeon_example_app");
  }

  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  FlBinaryMessenger* messenger =
      fl_engine_get_binary_messenger(fl_view_get_engine(view));
  pigeon_example_package_example_host_api_set_method_handlers(
      messenger, nullptr, &example_host_api_vtable, self, nullptr);

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));

  // #docregion flutter-method
  self->flutter_api =
      pigeon_example_package_message_flutter_api_new(messenger, nullptr);
  pigeon_example_package_message_flutter_api_flutter_method(
      self->flutter_api, "hello", nullptr, flutter_method_cb, self);
  // #enddocregion flutter-method
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}
