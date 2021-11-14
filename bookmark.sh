#!/usr/bin/sh

alias bm='source bookmark.sh'

if [ ! -e $HOME/.config/bookmarks/bookmarks.conf ]
then
    mkdir -p $HOME/.config/bookmarks  
    echo "$BOOKMARKS=\"\""  > $HOME/.config/bookmarks/bookmarks.conf && echo "file bookmark.conf created at $(echo $HOME/.config/bookmark)"
    BOOKMARKS=""
    if [ -e $HOME/.bashrc ]
    then
        echo "source bookmark.sh -L" >> $HOME/.bashrc
    fi
fi

add(){
    SHORTCUT=$1
    SHORTCUT_PATH=$(pwd)
    BOOKMARKS="$BOOKMARKS$SHORTCUT:$SHORTCUT_PATH|"
    echo $BOOKMARKS > $HOME/.config/bookmarks/bookmarks.conf
    eval  "alias @$SHORTCUT='cd $SHORTCUT_PATH'"
}

delete(){
    SHORTCUT=$1
    eval "unalias @$SHORTCUT"  
    BOOKMARKS="$(echo $BOOKMARKS | sed 's/|/\n/g' | awk -v sc="$SHORTCUT" 'BEGIN { ORS = "|"; FS = ":" }; { if ( $1 != sc && NF > 0 ) print $0 }')"
    echo $BOOKMARKS > $HOME/.config/bookmarks/bookmarks.conf

}

deleteAll(){
    B_TO_REMOVE="$(echo $BOOKMARKS | sed 's/|/\n/g' | awk  'BEGIN { ORS = ";"; FS = ":" }; { if ( NF > 0 ) print " unalias @"$1 }')"
    eval $B_TO_REMOVE
    BOOKMARKS="" 
    echo "" > $HOME/.config/bookmarks/bookmarks.conf

}

list(){
    echo $BOOKMARKS | sed 's/|/\n/g' | awk 'BEGIN { OFS = "\t"; FS = ":"}; { if ( NF > 0 ) print $1, $2 }'
}

load(){
    PATH_BOOKCONF=$HOME/.config/bookmarks/bookmarks.conf
    BOOKMARKS="$( cat $PATH_BOOKCONF)"
    ALIASES="$( cat $HOME/.config/bookmarks/bookmarks.conf | sed 's/|/\n/g' | awk 'BEGIN { ORS = ";"; FS = ":" }; { if (NF > 0)  print "alias @"$1"=\47cd "$2"\47" }')"
    eval $ALIASES
}

help(){
        cat << eof
Usage: bookmark.sh [-d] [-D] [-l] [-L] [-h] name_bookmark
bookmark.sh is a little script which  creates bookmark directories in order to simplify the navigation beetween folders.
bookmark.sh will save your bookmarks in $HOME/.config/bookmarks/bookmarks.conf.
For bash users, the line 'source bookmark.sh -L' will be added to your bashrc, in order to load your bookmarks in a new shell.
How to use it:

-d          delete one bookmark
-D          delete all bookmark 
-l          list all bookmarks
-L          load bookmark save from bookmarks.conf
-h/--help   help message

By default bookmarks.sh takes only the bookmark name as an arguments to add a bookmark.
In order to use the script, I highly recommend to add an alias to your shell configuration:
alias alias_name='source bookmark.sh'. Otherwise you must use 'source bookmark.sh' as a command in your shell.

Examples:
to add a bookmark:
let's say that your are in $HOME/Documents
    bookmark.sh  foo
create the bookmark foo to target the current directory.

to use the bookmarks created:
    @foo
with the above example, it will change the directory to $HOME/Documents.

to delete a bookmark
    bookmark.sh  -d foo

to delete all bookmarks
    bookmark.sh  -D

to list/ to load
    bookmark.sh  -l/-L 

eof
}

if [ -z $1 ]
then
    echo "ERROR: There is no argument, try bm --help/-h"
    exit 1
else
    case $1 in
        -d) 
            load &&  delete $2
            ;;
        -D)
            load && deleteAll
            ;;
        -l)
            load && list
            ;;
        -L) 
            load
            ;;
        -h) 
            help
            ;;
        --help)
            help
            ;;
        *)
            load && add $1
            ;;
    esac
fi
