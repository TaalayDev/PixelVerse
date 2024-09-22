#!/bin/bash

check_flutter() {
  if ! command -v flutter &> /dev/null
  then
    echo "Flutter could not be found"
    exit
  fi
}

open_folder() {
  folderPath=$1
  open "$folderPath"
  if [ $? -eq 0 ]; then
    echo "Folder $folderPath opened"
  else
    echo "Opening folder $folderPath failed"
    exit 1
  fi
}

build() {
  buildType=""
  if [ $# -gt 0 ]; then
    buildType="$1"
  else
    read -p "Enter build type (apk, appbundle, ipa): " buildType
  fi

  if [ "$buildType" == "apk" ]; then
    echo "Building APK"
  elif [ "$buildType" == "appbundle" ] || [ "$buildType" == "aab" ]; then
    echo "Building AAB"
    buildType="appbundle"
  elif [ "$buildType" == "ios" ] || [ "$buildType" == "ipa" ]; then
    echo "Building iOS"
  else
    echo "Invalid build type"
    exit 1
  fi

  buildDir="build"

  if [ ! -d "$buildDir" ]; then
    pubGetResult=$(flutter pub get)
    if [ $? -eq 0 ]; then
      echo "Pub get success"
    else
      echo "Pub get failed"
      echo "$pubGetResult" >&2
      exit 1
    fi
  fi

  pubspecYaml="pubspec.yaml"
  pubspecYamlContent=$(cat "$pubspecYaml")
  versionLine=$(echo "$pubspecYamlContent" | grep -m 1 '^version:')
  version=$(echo "$versionLine" | awk '{print $2}')
  versionName=$(echo "$version" | cut -d'+' -f1)
  versionCode=$(echo "$version" | cut -d'+' -f2)

  echo "Version name: $versionName"
  echo "Version code: $versionCode"

  buildCommand="flutter build $buildType --release --dart-define VERSION_NAME=$versionName --dart-define VERSION_CODE=$versionCode --build-name=$versionName --build-number=$versionCode"

  buildResult=$(eval "$buildCommand")
  echo "$buildResult"

  if [ $? -eq 0 ]; then
    echo "Build success"

    if [ "$buildType" == "ipa" ]; then
      # Open transporter to upload ipa
      open "/Applications/Transporter.app"
      if [ $? -eq 0 ]; then
        echo "Transporter opened"
      else
        echo "Transporter failed"
        exit 1
      fi

      # Open ipa folder
      open_folder "build/ios/ipa"
    elif [ "$buildType" == "appbundle" ]; then
      # Open appbundle folder
      open_folder "build/app/outputs/bundle/release"

      # Open play console
      open "https://play.google.com/console"
    else
      # Open apk folder
      open_folder "build/app/outputs/flutter-apk"
    fi
  else
    echo "Build failed"
    exit 1
  fi
}

start() {
    echo "select device to start"
    devices=$(flutter devices)
    echo "$devices"
    deviceCount=$(echo "$devices" | grep -c '•')
    if [ $deviceCount -eq 0 ]; then
        echo "No device found"
        exit 1
    elif [ $deviceCount -eq 1 ]; then
        deviceName=$(echo "$devices" | grep '•' | awk '{print $1}')
        echo "Starting on $deviceName"
        flutter run -d "$deviceName"
    else
        read -p "Enter device number: " deviceNumber
        deviceName=$(echo "$devices" | grep '•' | awk '{print $1}' | sed -n "$deviceNumber"p)
        echo "Starting on $deviceName"
        flutter run -d "$deviceName"
    fi

    if [ $? -eq 0 ]; then
        echo "Start success"
    else
        echo "Start failed"
        exit 1
    fi
}

makeModel() {
  if [ $# -eq 0 ]; then
    echo "Please specify model name"
    exit 1
  fi

  modelName="$1"
  echo "Making model $modelName"

  modelDir="lib/data/models"
  modelFile="$modelDir/$modelName.dart"

  if [ ! -d "$modelDir" ]; then
    mkdir "$modelDir"
  fi

  if [ -f "$modelFile" ]; then
    echo "Model $modelName already exists"
    exit 1
  fi

  modelTemplate="lib/templates/model.dart"
  cp "$modelTemplate" "$modelFile"

  if [ $? -eq 0 ]; then
    echo "Model $modelName created"
  else
    echo "Model $modelName failed"
    exit 1
  fi
}

if [ $# -eq 0 ]; then
  echo "Please specify command (build, start, make-model)"
  exit 1
fi

check_flutter

command="$1"

if [ "$command" == "build" ]; then
  build "${@:2}"
elif [ "$command" == "start" ]; then
  start "${@:2}"
elif [ "$command" == "make-model" ]; then
  makeModel "${@:2}"
else
  echo "Invalid command"
fi