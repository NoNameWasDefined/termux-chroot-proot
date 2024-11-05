#! /data/data/com.termux/files/usr/bin/bash



c='?'
rfsd="$PREFIX/var/lib/tcw/"



source $PREFIX/etc/tcw.env
if [ ! -d $rfsd ]; then
  if [ -e $rfsd ]; then
    echo "\"$rfsd\" is not a directory"
    exit 1
  fi
  mkdir -p $rfsd
fi


delete () {
  if [ $2 = '' ]; then
    echo 'You must specify a name'
    return 1
  if [ ! -e "$rfsd/$2" ]; then
    echo "$c \"$2 doesn't exist, passing"
    return 1
  fi
  if [ ! -w "$rfsd/$2.conf" ]; then
    echo "No logger file was found for \"$2\" !"
  echo "Are you sure to delete the $c \"$2\" ?"
  read a
  case $a in
  y | yes) rm -rf "$rfsd/$2";;
  *) return 1;;
  esac
}


start () {
  if [ $2 = '' ]; then
    echo 'You must specify a name'
    return $1
  fi
  if [ ! -d "$rfsd/$2" ]; then
    echo "It seems that the $c \"$2\" doesn't exist"
  return
  echo "Not implemented yet"
}

case $1 in
-d | --delete) exit $(delete $2);;
-h | --help) exit $(help $2);;
-n | --new) exit $($(basedir $0)/new.sh $2);;
-s | --start) exit $(start $2);;
*)
  if [ "$2" = '' ]; then
    echo "You must specify a name"
    exit 1
  if [ -d "$rfsd/$2" ]; then exit $(start $2); else exit $(new $2); fi
;;
esac
  