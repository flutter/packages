# Last updated 4/8/2020 (to rebuild the docker image, update this timestamp)
FROM cirrusci/flutter:latest

RUN sudo apt-get update && \
    sudo apt-get upgrade && \
    sudo apt-get install gpg-agent && \
    sudo apt-get clean

RUN yes | sdkmanager \
    "platforms;android-27" \
    "build-tools;27.0.3" \
    "extras;google;m2repository" \
    "extras;android;m2repository"
