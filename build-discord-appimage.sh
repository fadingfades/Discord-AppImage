#!/bin/bash
set -e

APP=discord
ARCH=x86_64

WORKDIR=$(mktemp -d)
trap 'echo "Cleaning up temporary directory..."; rm -r "$WORKDIR"' EXIT
cd "$WORKDIR"

echo "✅ Working in temporary directory: $WORKDIR"

echo "🔽 Downloading tools and the Discord .deb package..."
wget -q "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage" -O appimagetool
chmod a+x appimagetool

wget -q "https://github.com/AppImage/AppImageKit/releases/download/continuous/AppRun-x86_64" -O AppRun
chmod a+x AppRun

wget -q "https://discord.com/api/download?platform=linux&format=deb" -O discord.deb

echo "📦 Extracting .deb package..."
ar x discord.deb
tar xf data.tar.gz

echo "🏗️ Assembling the AppDir..."
mkdir "$APP".AppDir
mv ./usr ./"$APP".AppDir/

echo "📝 Configuring desktop and icon files..."
mv ./"$APP".AppDir/usr/share/discord/discord.desktop ./"$APP".AppDir/
sed -i 's#^Exec=.*#Exec=discord#' ./"$APP".AppDir/discord.desktop
sed -i 's#^Icon=.*#Icon=discord#' ./"$APP".AppDir/discord.desktop
cp ./"$APP".AppDir/usr/share/pixmaps/discord.png ./"$APP".AppDir/discord.png
mv ./AppRun ./"$APP".AppDir/

echo "🔎 Determining application version..."
VERSION=$(dpkg-deb -f discord.deb Version)
APPIMAGE_NAME="$APP-$VERSION-$ARCH.AppImage"
echo "Building $APPIMAGE_NAME..."

ARCH=$ARCH ./appimagetool --comp zstd ./"$APP".AppDir "$GITHUB_WORKSPACE"/"$APPIMAGE_NAME"

echo "🎉 Build complete!"
echo "AppImage created in the workspace."

echo "version=$VERSION" >> "$GITHUB_OUTPUT"
echo "appimage_name=$APPIMAGE_NAME" >> "$GITHUB_OUTPUT"
