FROM debian:stable-20230612-slim

LABEL Maintainer="billcoding <bill07wang@gmail.com>"
LABEL Description="The Docker Android Flutter Packing Dockerfile based on Debian 12"

RUN apt update && apt install -y curl wget unzip xz-utils git locales 

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8 \
LC_ALL=en_US.UTF-8 \
FLUTTER_HOME=/opt/flutter \
JAVA_HOME=/opt/jdk \
CMDLINETOOLS_HOME=/opt/android/sdk/cmdline-tools \
ANDROID_HOME=/opt/android/sdk \
ANDROID_SDK_ROOT=/opt/android/sdk \
MC_HOME=/opt/minio \
MC_BIN_FILE=/opt/minio/bin/mc \
PATH=$PATH:/opt/flutter/bin:/opt/jdk/bin:/opt/android/sdk/cmdline-tools/bin:/opt/minio/bin

ARG SDKMANAGER="sdkmanager --sdk_root=$ANDROID_SDK_ROOT"

RUN wget -O /tmp/flutter_linux_3.16.0-stable.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz && \
tar xvf /tmp/flutter_linux_3.16.0-stable.tar.xz -C /tmp && \
mv /tmp/flutter /opt && \
rm -rf /tmp/flutter_linux_3.16.0-stable.tar.xz && \
git config --global --add safe.directory /opt/flutter

RUN wget -O /tmp/bellsoft-jdk17.0.9+11-linux-amd64.tar.gz https://download.bell-sw.com/java/17.0.9+11/bellsoft-jdk17.0.9+11-linux-amd64.tar.gz && \
tar xvf /tmp/bellsoft-jdk17.0.9+11-linux-amd64.tar.gz -C /tmp && \
mv /tmp/jdk-17.0.9 /opt/jdk && \
rm -rf /tmp/bellsoft-jdk17.0.9+11-linux-amd64.tar.gz

RUN wget -O /tmp/commandlinetools-linux_latest.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
mkdir -p /opt/android/sdk && \
unzip -d /opt/android/sdk /tmp/commandlinetools-linux_latest.zip && \
rm -rf /tmp/commandlinetools-linux_latest.zip

RUN yes|$SDKMANAGER --licenses

RUN $SDKMANAGER --install "build-tools;30.0.3"

# download minio client
RUN wget -O /tmp/mc https://dl.min.io/client/mc/release/linux-amd64/mc && \
mkdir -p /opt/minio/bin && \
cp -rf /tmp/mc /opt/minio/bin && \
chmod +x /opt/minio/bin/mc && \
rm -rf /tmp/mc

RUN flutter config --android-sdk=/opt/android/sdk --jdk-dir=/opt/jdk && \
flutter precache && \
flutter doctor -v && \
cd /tmp && \
flutter create myapp --verbose && \
cd myapp && flutter build apk --verbose

RUN rm -rf /tmp/*