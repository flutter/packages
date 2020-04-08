# Last updated 4/8/2020 (to rebuild the docker image, update this timestamp)
FROM cirrusci/flutter:latest

RUN sudo apt-get update && \
    sudo apt-get upgrade --yes && \
    sudo apt-get install --yes gpg-agent && \
    sudo apt-get clean --yes

# This must occur after the install of gpg-agent
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add - && \
    sudo apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-5.0 main" && \
    sudo apt-get update && \
    sudo apt-get install --yes --allow-unauthenticated clang-format-5.0 && \
    sudo apt-get clean --yes

RUN yes | sdkmanager \
    "platforms;android-27" \
    "build-tools;27.0.3" \
    "extras;google;m2repository" \
    "extras;android;m2repository"
