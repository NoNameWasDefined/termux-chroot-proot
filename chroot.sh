#! /data/data/com.termux/files/usr/bin/bash

if [ $1 = '' -or $2 = '' -or $3 = '' ]; then
  echo "Wrong call"
  exit 1
fi

echo -e "\nYou did it\n"
cd $2/$3
unzip $1
while read p; do
  ln -s ${p/←/ }
done <SYMLINKS.txt
rm SYMLINKS.txt

exit

if [ "$first" != 1 ];then
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
bin=chroot.sh
wrap=start.sh
user=$(whoami)
echo "writing launch script"


cat > $wrap <<- EOM
#!/bin/bash
export basedir=\$(dirname \$0)
    export  APPEND_SYSTEM_PATH=1
    exec $PREFIX/bin/tsu -c "sh -c \"cd \\\\\\"$PWD\\\\\\";export TERM=\$TERM;exec unshare -mf \$basedir/chroot.sh \\\\\\"\$@\\\\\\"\""
EOM

cat > $bin <<- EOM
#!/bin/bash
export user=$user
export ff=data/data/com.termux/files
export basedir=\$(dirname \$0)
export j=\$basedir/termux-fs

mounts="system dev etc proc vendor data/dalvik-cache sys"

#unset LD_PRELOAD in case termux-exec is installed. If termux-exec is also installed inside the jail it will set again.
unset LD_PRELOAD

for m in \$mounts;do
    mkdir -p "\$j/\$m"
    mount -o rbind "/\$m" "\$j/\$m"
done
mount devpts \$j/dev/pts -t devpts
if [ -n "\$(ls -A \$basedir/binds)" ]; then
    for f in \$basedir/binds/* ;do
        . \$f
    done
fi
groups=${user},inet,everybody,${user}_cache,all_$(echo $user|cut -d "_" -f 2)
command="chroot --userspec=\$user:\$user --groups=\$groups \$j"
command+=" /\$ff/usr/bin/env -i"
command+=" HOME=/\$ff/home"
command+=" PATH=/\$ff/usr/bin:/\$ff/usr/bin/applets"
command+=" TERM=\$TERM"
command+=" ANDROID_DATA=/data"
command+=" ANDROID_ROOT=/system"
command+=" EXTERNAL_STORAGE=/sdcard"
command+=" LANG=\$LANG"
command+=" LD_LIBRARY_PATH=/data/data/com.termux/files/usr/lib"
command+=" PREFIX=/data/data/com.termux/files/usr"
command+=" TMPDIR=/data/data/com.termux/files/usr/tmp"
execute="cd /\$ff/home;"
execute+="umask 077;"
com="\$@"
if [ -z "\$com" ];then
    execute+="exec /\$ff/usr/bin/login"
else
    execute+="exec /\$ff/usr/bin/login -c '\$com'"
fi
eval "exec \$command sh -c \"\$execute\""
EOM

termux-fix-shebang $bin
termux-fix-shebang $wrap
chmod +x $bin $wrap
