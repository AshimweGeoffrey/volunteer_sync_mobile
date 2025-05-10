#!/bin/bash
# OPTIMIZED-GRADLE-CONFIG by AshimweGeoffrey - 2025-03-26

# Fix gradle wrapper properties with correct URI format
mkdir -p ~/Desktop/Repos-Git/Side_Projects/volunteer_sync/android/gradle/wrapper
cat > ~/Desktop/Repos-Git/Side_Projects/volunteer_sync/android/gradle/wrapper/gradle-wrapper.properties << EOF
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

# Enable AndroidX
mkdir -p ~/Desktop/Repos-Git/Side_Projects/volunteer_sync/android
cat > ~/Desktop/Repos-Git/Side_Projects/volunteer_sync/android/gradle.properties << EOF
android.useAndroidX=true
android.enableJetifier=true
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
org.gradle.parallel=true
org.gradle.daemon=true
EOF

# Create fresh gradlew script
cd ~/Desktop/Repos-Git/Side_Projects/volunteer_sync/android
curl -s -o gradlew https://raw.githubusercontent.com/gradle/gradle/v7.5.0/gradle/wrapper/gradlew
chmod 755 gradlew

# Execute with optimized parameters
cd ~/Desktop/Repos-Git/Side_Projects/volunteer_sync
flutter clean
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 flutter run --verbose
