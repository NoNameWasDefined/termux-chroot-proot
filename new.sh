#! /data/data/com.termux/files/usr/bin/bash

lsb_release -a
if [ ! $? ]; then
  echo "You shouln't run this script on a Linux host"
fi

if [ $ARCH = "" ]; then ARCH=$(uname -m); fi
case $(uname -m) in
aarch64 | arm64) arch=aarch64 && l=1;;
armv7l | armv8l) arch=arm && l=2;;
i686) arch=i686 && l=3;;
x86_64) arch=x86_64 && l=4;;
*) echo "Unsupported architecture : are you sure you are using Termux ?" && exit 1;;
esac

echo -n "Do you want to use pacman instead of pkg/apt ? "
read a
case $a in
y | yes) maint="termux-pacman";;
*) maint="termux";;
esac

file="bootstrap-$arch.zip"
url="https://github.com/$maint/termux-packages/releases/latest/download"

cd=/data/data/com.termux/files/usr/var/cache/$maint
mkdir -p $cd

if [ ! -r $cd/$file ]; then
  echo "Downloading $file"
  wget -P $cd $url/$file
fi

echo "Checking integrity"
if [ $(sha256sum $cd/$file) != $(curl "$url/CHECKSUMS-sha256.txt" | sed "$l!d;q") ]; then
  echo "Bootstrap file is corrupted, check your internet connexion and retry"
  rm $cd/$file
  exit 1
fi

su -c "exit"
if $?; then
  echo -n "You can use chroot because your phone is rooted, do you want to use proot instead (slower) ?"
  read a
  case $a in
  y | yes) su=0;;
  *) su=1;;
  esac
else
  echo "You phone is not rooted or you do not allowed Termux to run root shell so proot was selected"
  su=0
fi
  
echo "Please enter a folder name for your installation"
read name

source $PREFIX/etc/tcw

if [ $RootFS = "" ]; then
  rfsd=$RootFS
fi
rfsd=$(dirname $rfsd)
mkdir -p $rfsd

if [ -e $rfsd/$name]; then
  echo "It's seems that you have already installed a distro"
mkdir $rfsd/$name
if [ ! $? ]; then
  echo "Impossible to create directory \"$name\" in \"$rfsd\""
  exit 1
fi

exitc=256
until [ $exitc -ne 256 ]; do
  if [ $su -eq 1 ]; then
    $(dirname $0)/chroot.sh $cd $file $rfsd/$name
  else
    $(dirname $0)/proot.sh $cd/$file $rfsd $name
  fi

  if [ $? -eq 0 ]; then
    echo "Enjoy your Termux chroot with \"tcm -s $name\""
    exitc=p
  else
    echo -n "Something went wrong in the chroot creation, do you want to retry ?"
    read a
    echo
    case $a in
    y | yes) /dev/null;;
    *) exitc=1;;
    esac
  fi
done

exit $exitc
