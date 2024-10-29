#!/data/data/com.termux/files/usr/bin/bash
basedir=$(dirname $0)

#unset LD_PRELOAD in case termux-exec is installed. If termux-exec is also installed inside the jail it will set again.
unset LD_PRELOAD

command="proot"
command+=" -r $basedir/termux-fs"
command+=" -b /system"
command+=" -b /dev/"
command+=" -b /sys/"
command+=" -b /etc/"
command+=" -b /proc/"
command+=" -b /vendor"
command+=" -b /data/dalvik-cache/"
command+=" -b /property_contexts"
if [ -n "$(ls -A $basedir/binds)" ]; then
    for f in $basedir/binds/* ;do
        . $f
    done
fi
command+=" -w /data/data/com.termux/files/home/"
command+=" /data/data/com.termux/files/usr/bin/env -i"
command+=" HOME=/data/data/com.termux/files/home"
command+=" PATH=/data/data/com.termux/files/usr/bin:/data/data/com.termux/files/usr/bin/applets"
command+=" TERM=$TERM"
command+=" ANDROID_DATA=/data"
command+=" ANDROID_ROOT=/system"
command+=" EXTERNAL_STORAGE=/sdcard"
command+=" LANG=$LANG"
command+=" LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib"
command+=" PREFIX=/data/data/com.termux/files/usr"
command+=" TMPDIR=/data/data/com.termux/files/usr/tmp"
com="$@"
if [ -z "$com" ];then
    eval "exec $command login"
else
    eval "exec $command login -c '$com'"
fi
