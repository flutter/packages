# Last updated 02/04/2022 (to rebuild the docker image, update this timestamp)
# The Flutter version is not important here, since the CI scripts update Flutter
# before running. What matters is that the base image is pinned to minimize
# unintended changes when modifying this file.
FROM cirrusci/flutter@sha256:02607513bf0b3daf303ab54c495efc4dd5cabf889a201be75c88b1e9888e0f5d

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
