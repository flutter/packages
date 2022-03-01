# Last updated 02/04/2022 (to rebuild the docker image, update this timestamp)
# The Flutter version is not important here, since the CI scripts update Flutter
# before running. What matters is that the base image is pinned to minimize
# unintended changes when modifying this file.
FROM cirrusci/flutter@sha256:283f328d162adfc345bec5e070f79201edcb28f5483addf238c57d78bad0da23

RUN sudo apt-get update && \
    sudo apt-get upgrade --yes && \
    sudo apt-get install --yes gpg-agent && \
    sudo apt-get clean --yes

# This must occur after the install of gpg-agent
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -

# Install formatter for C-based languages.
RUN apt-get install -y clang-format

# Needed for web_benchmarks
RUN sudo apt-get install -y libgbm-dev

RUN yes | sdkmanager \
    "platforms;android-27" \
    "build-tools;27.0.3" \
    "extras;google;m2repository" \
    "extras;android;m2repository"

RUN yes | sdkmanager --licenses
