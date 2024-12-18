#! /data/data/com.termux/files/usr/bin/bash

echo -e "\nYou did it\n"

mkdir -p binds
folder=termux-fs/data/data/com.termux/files
if [ -d "$folder" ]; then
    first=1
    echo "skipping downloading"
fi
if [ "$first" != 1 ];then
    if [ ! -f "bootstrap.zip" ]; then
        echo "downloading bootstrap package"
        wget https://termux.net/bootstrap/bootstrap-`dpkg --print-architecture`.zip -O bootstrap.zip
    fi
    cur=`pwd`
    mkdir -p $folder/usr
    cd $folder/usr
    echo "decompressing bootstrap image image"
    unzip $cur/bootstrap.zip
    while read p; do
        echo "creating symlink for $p"
        ln -s ${p/←/ }
    done <SYMLINKS.txt
    rm SYMLINKS.txt
    for f in bin libexec lib/apt/methods;do
        echo "making files in $f executable"
        chmod -R 700 $f/*
    done
    cd $cur
    mkdir -p $folder/home
    echo "Setting permissions of root directory"
    chmod -rw termux-fs
    chmod -rw termux-fs/data
    chmod -rw termux-fs/data/data/
fi
ff=/data/data/com.termux/files
bin=start.sh
echo "writing launch script"

cat > $bin <<- EOF
#!/bin/bash
basedir=\$(dirname \$0)

#unset LD_PRELOAD in case termux-exec is installed. If termux-exec is also installed inside the jail it will set again.
unset LD_PRELOAD

command="proot"
command+=" -r \$basedir/termux-fs"
command+=" -b /system"
command+=" -b /dev/"
command+=" -b /sys/"
command+=" -b /etc/"
command+=" -b /proc/"
command+=" -b /vendor"
command+=" -b /data/dalvik-cache/"
command+=" -b /property_contexts"
if [ -n "\$(ls -A \$basedir/binds)" ]; then
    for f in \$basedir/binds/* ;do
        . \$f
    done
fi
command+=" -w /data/data/com.termux/files/home/"
command+=" $ff/usr/bin/env -i"
command+=" HOME=$ff/home"
command+=" PATH=$ff/usr/bin:$ff/usr/bin/applets"
command+=" TERM=\$TERM"
command+=" ANDROID_DATA=/data"
command+=" ANDROID_ROOT=/system"
command+=" EXTERNAL_STORAGE=/sdcard"
command+=" LANG=\$LANG"
command+=" LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib"
command+=" PREFIX=/data/data/com.termux/files/usr"
command+=" TMPDIR=/data/data/com.termux/files/usr/tmp"
com="\$@"
if [ -z "\$com" ];then
    eval "exec \$command login"
else
    eval "exec \$command login -c '\$com'"
fi
EOF
echo "fixing shebang of $bin"
termux-fix-shebang $bin
echo "making $bin executable"
chmod +x $bin
