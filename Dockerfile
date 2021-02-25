FROM adoptopenjdk:11.0.10_9-jdk-openj9-0.24.0
MAINTAINER Uday Ananthu <udayk3469@gmail.com>

ENV ANDROID_SDK_URL=https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip
ENV ANDROID_HOME=/usr/local/android-sdk-linux
ENV PATH=$ANDROID_HOME/cmdline-tools:$ANDROID_HOME/cmdline-tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools:$PATH

USER root

RUN apt-get update && \
    apt-get install  --no-install-recommends -y --allow-unauthenticated \
    build-essential \
    git \
    qt5-default \
    ruby-full \
    unzip \
    wget && \
    # Clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean

RUN mkdir "$ANDROID_HOME" .android && \
    cd "$ANDROID_HOME" && \
    curl -o sdk.zip $ANDROID_SDK_URL && \
    unzip sdk.zip && \
    rm sdk.zip && \
    # Download Android SDK
    yes | sdkmanager --licenses --sdk_root=$ANDROID_HOME && \
    sdkmanager --update  --sdk_root=$ANDROID_HOME && \
    sdkmanager "build-tools;30.0.3"  --sdk_root=$ANDROID_HOME && \
    sdkmanager "platforms;android-30"  --sdk_root=$ANDROID_HOME && \
    sdkmanager "platform-tools"  --sdk_root=$ANDROID_HOME && \
    sdkmanager "extras;android;m2repository"  --sdk_root=$ANDROID_HOME && \
    sdkmanager "extras;google;m2repository"  --sdk_root=$ANDROID_HOME && \
    chmod 777 /usr/local/android-sdk-linux && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean

# Install Fastlane
RUN gem install rake && \
    gem install fastlane -NV && \
    gem install bundler && \
    # Clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean

ENV GRADLE_HOME=/opt/gradle/gradle-6.5.1
RUN wget https://services.gradle.org/distributions/gradle-6.5.1-bin.zip && \
    mkdir /opt/gradle && \
    unzip -d /opt/gradle gradle-6.5.1-bin.zip && \
    rm -f gradle-6.5.1-bin.zip
ENV PATH=$GRADLE_HOME/bin:$PATH

RUN gradle --version && \
    mkdir -p /.android && chmod 777 /.android && \
    touch /.robolectric-download-lock && chmod 777 /.robolectric-download-lock && \
    mkdir -p /.m2 && chmod 777 /.m2 && \
    chmod 777 /tmp && mkdir -p /.gem && chmod 777 /.gem && \
    mkdir -p /.fastlane && chmod 777 /.fastlane && chmod -R 777 /var/lib/gems/2.7.0/

RUN useradd -u 501 -s /bin/bash jenkins
RUN mkdir -p /home/jenkins
RUN usermod -d /home/jenkins jenkins
WORKDIR /home/jenkins
USER jenkins

