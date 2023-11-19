FROM debian:stable-20230612-slim

LABEL Maintainer="billcoding <bill07wang@gmail.com>"
LABEL Description="The Docker Android Flutter Packing Dockerfile based on Debian 12"

RUN apt update && apt install -y wget unzip xz-utils imagemagick

RUN wget -O /tmp/flutter_linux_3.16.0-stable.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz && \
tar xvf /tmp/flutter_linux_3.16.0-stable.tar.xz -C /tmp && \
mv /tmp/flutter /opt && \
rm -rf /tmp/flutter_linux_3.16.0-stable.tar.xz

ENV PATH=$PATH:/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin

RUN wget -O /tmp/bellsoft-jdk17.0.9+11-linux-amd64.tar.gz https://download.bell-sw.com/java/17.0.9+11/bellsoft-jdk17.0.9+11-linux-amd64.tar.gz && \
tar xvf /tmp/bellsoft-jdk17.0.9+11-linux-amd64.tar.gz -C /tmp && \
mkdir -p /opt/jdk && \
mv /tmp/jdk-17.0.9 /opt/jdk/openjdk17 && \
rm -rf /tmp/bellsoft-jdk17.0.9+11-linux-amd64.tar.gz

ENV PATH=$PATH:/opt/jdk/openjdk17/bin

ENV JAVA_HOME=/opt/jdk/openjdk17

# android command line tools
ARG SDKMANAGER="sdkmanager --sdk_root=/opt/android/sdk"

RUN wget -O /tmp/commandlinetools-linux_latest.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
mkdir -p /opt/android && \
unzip -d /opt/android /tmp/commandlinetools-linux_latest.zip && \
rm -rf /tmp/commandlinetools-linux_latest.zip

ENV PATH=$PATH:/opt/android/cmdline-tools/bin
RUN yes|$SDKMANAGER --licenses

RUN sdkmanager --sdk_root=/opt/android/sdk --install "build-tools;34.0.0-rc3"

ENV ANDROID_HOME=/opt/android/sdk

ENV ANDROID_SDK_BUILD_TOOLS_VERSION=34.0.0-rc3

# apktool
RUN wget -O /tmp/apktool_2.7.0.jar https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.7.0.jar && \
mkdir -p /opt/apktool && \
cp -rf /tmp/apktool_2.7.0.jar /opt/apktool && \
rm -rf /tmp/apktool_2.7.0.jar

ENV APK_TOOL_JAR_FILE=/opt/apktool/apktool_2.7.0.jar

# download minio client
RUN wget -O /tmp/mc https://dl.min.io/client/mc/release/linux-amd64/mc && \
mkdir -p /opt/minio/bin && \
cp -rf /tmp/mc /opt/minio/bin && \
chmod +x /opt/minio/bin/mc && \
rm -rf /tmp/mc

ENV PATH=$PATH:/opt/minio/bin

ENV MC_BIN_FILE=/opt/minio/bin/mc

RUN flutter doctor -vv

RUN flutter precache