FROM gitpod/workspace-full-vnc:2022-07-20-05-50-58
SHELL ["/bin/bash", "-c"]
ENV ANDROID_HOME=$HOME/androidsdk \
    FLUTTER_VERSION=3.0.2-stable \
    QTWEBENGINE_DISABLE_SANDBOX=1
ENV PATH="$HOME/flutter/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# Install Open JDK for android and other dependencies
USER root
RUN install-packages openjdk-8-jdk -y \
        libgtk-3-dev \
        libnss3-dev \
        fonts-noto \
        fonts-noto-cjk \
    && update-java-alternatives --set java-1.8.0-openjdk-amd64

# Make some changes for our vnc client and flutter chrome
# RUN sed -i 's|resize=scale|resize=remote|g' /opt/novnc/index.html \
#     && _gc_path="$(command -v google-chrome)" \
#     && rm "$_gc_path" && printf '%s\n' '#!/usr/bin/env bash' \
#                                         'chromium --start-fullscreen "$@"' > "$_gc_path" \
#     && chmod +x "$_gc_path" 

# Insall flutter and dependencies
USER gitpod
RUN wget -q "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz" -O - \
    | tar xpJ -C "$HOME" \
    && _file_name="commandlinetools-linux-8092744_latest.zip" && wget "https://dl.google.com/android/repository/$_file_name" \
    && unzip "$_file_name" -d $ANDROID_HOME \
    && rm -f "$_file_name" \
    && mkdir -p $ANDROID_HOME/cmdline-tools/latest \
    && mv $ANDROID_HOME/cmdline-tools/{bin,lib} $ANDROID_HOME/cmdline-tools/latest \
    && yes | sdkmanager "platform-tools" "build-tools;31.0.0" "platforms;android-31" \
    && flutter precache && for _plat in web linux-desktop; do flutter config --enable-${_plat}; done \
    && flutter config --android-sdk $ANDROID_HOME \
    && yes | flutter doctor --android-licenses \
    && flutter doctor