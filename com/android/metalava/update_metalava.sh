#!/bin/bash
set -e

function usage() {
  echo "Updates metalava*.jar"
  echo "Usage: update_metalava.sh <build-id>"
  exit 1
}


buildId="$1"
if [ "$buildId" == "" ]; then
  usage
fi

tempDir=/tmp
destDir="$(cd $(dirname $0) && pwd)"

function downloadArtifact() {
  cd "$tempDir"
  echo "Downloading metalava from build $buildId"
  /google/data/ro/projects/android/fetch_artifact --bid "$buildId" --target sdk_phone_armv7-sdk 'metalava.jar'
}
downloadArtifact

function getVersionNumber() {
  versionNumber="$(java -jar metalava.jar --version 2>/dev/null || echo 'unknown')"
  if echo "$versionNumber" | grep "unknown" >/dev/null; then
    versionNumber="1.2.5-SNAPSHOT"
    echo "Could not parse version number of metalava.jar; assuming version $versionNumber"
  fi
}
getVersionNumber

function removeOldMetalava() {
  find "$destDir" -mindepth 1 -maxdepth 1 -type d | xargs --no-run-if-empty rm -rf
  #find "$destDir" -mindepth 1 -maxdepth 1 -type d | xargs echo removing
}
removeOldMetalava

function copyNewMetalava() {
  subdir="${destDir}/${versionNumber}"
  mkdir -p "$subdir"
  cp metalava.jar "${subdir}/metalava-${versionNumber}-shadow.jar"
}
copyNewMetalava

function gitCommit() {
  cd "${destDir}"
  git add .
  git commit -m "Import metalava ${versionNumber} from build ${buildId}"
}
gitCommit
