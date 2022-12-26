#!/bin/zsh
# Ensure that the UTF-8 language is set for conversions
export LANG=en_US.UTF-8

# Make it easy for people
cd $HOME/Desktop/

FLASH="$1/Contents/Resources/Flash Player.app/"
INSTALLER="$2"


# Extract resource archive
mkdir arglbargl
unzip -d arglbargl "${INSTALLER}/Contents/Resources/Java/Disk1/InstData/Resource1.zip"

pushd arglbargl
# Find path to main app (there will be a few others, but find prints them first)
GAME_JAR=$(find . -name "*\.app*\.jar" | tail -n 1)
SUFFIX=$(echo "${GAME_JAR}" | sed 's/^.*\.app\(.*\)\.jar/\1/')


mkdir out
EXTRACT="$(dirname ${GAME_JAR})"
for JARF in ${EXTRACT}/*.jar; do
	JARF_DIR=$(basename ${JARF})
	JARF_DIR=$(echo ${JARF_DIR%.*} | sed s/${SUFFIX}//)
	JARF_DIR="out/${JARF_DIR}"
	mkdir "${JARF_DIR}"
	unzip "${JARF}" -d "${JARF_DIR}"
done

APP_NAME=$(basename ${GAME_JAR})
APP_NAME=${APP_NAME%.*.*}

pushd out
cp "${APP_NAME}.app/Contents/Resources/movie.swf" .
cp "${APP_NAME}.app/Contents/Resources/icon.icns" .

rm -r "${APP_NAME}.app"
NAPP_NAME=$(echo "${APP_NAME}" | sed 's/@u/\\U/g')
NAPP_NAME=$(printf "${NAPP_NAME}")
cp -R "${FLASH}" "${NAPP_NAME}.app/"

mv movie.swf "${NAPP_NAME}.app/Contents/Resources/movie.swf"
mv icon.icns "${NAPP_NAME}.app/Contents/Resources/FlashPlayer.icns"
touch "${NAPP_NAME}.app/Contents/Resources/FlashPlayer.icns"
xattr -r -d com.apple.quarantine "${NAPP_NAME}.app"

popd
mv out "../${NAPP_NAME}"

popd
rm -r arglbargl

