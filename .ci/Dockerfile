# The Flutter version is not important here, since the CI scripts update Flutter
# before running. What matters is that the base image is pinned to minimize
# unintended changes when modifying this file.
FROM cirrusci/flutter@sha256:d99b1ba2602240a74722970b5c0cd704bbe60a7eba7557157c784f2f693c393f

RUN apt-get update -y

# Set up Firebase Test Lab requirements.
RUN apt-get install -y --no-install-recommends gnupg
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get install -y google-cloud-sdk && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true
