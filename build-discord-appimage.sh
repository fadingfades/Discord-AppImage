#!/bin/sh

APP=discord
wget https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
chmod a+x appimagetool

wget "https://discord.com/api/download?platform=linux" -O discord.deb
ar x discord.deb
tar xf data.tar.gz
mkdir "$APP".AppDir
mv ./usr/share/discord/* ./"$APP".AppDir/
sed -i "s#Exec=/usr/share/discord/Discord#Exec=Discord#g" ./"$APP".AppDir/"$APP".desktop
tar xf ./control.tar.gz
VERSION=$(cat control | grep Version | cut -c 10-)

cat <<-'HEREDOC' >> ./"$APP".AppDir/AppRun
#!/bin/sh
APP=Discord
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
exec "${HERE}"/$APP "$@"
HEREDOC

chmod a+x ./"$APP".AppDir/AppRun
ARCH=x86_64 ./appimagetool --comp zstd --mksquashfs-opt -Xcompression-level --mksquashfs-opt 20 ./"$APP".AppDir "$APP"-"$VERSION"-x86_64.AppImage
