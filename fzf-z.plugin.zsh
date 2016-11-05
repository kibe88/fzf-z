#!/usr/bin/env zsh
#
# Based on https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh
# (MIT licensed, as of 2016-05-05).

if [[ $OSTYPE == darwin* ]]; then
    REVERSER='tail -r'
else
    REVERSER='tac'
fi

__fzfz() {
    if (($+FZFZ_EXCLUDE_PATTERN)); then
        EXCLUDER="egrep -v '$FZFZ_EXCLUDE_PATTERN'"
    else
        EXCLUDER="cat"
    fi

    if (($+FZFZ_EXTRA_DIRS)); then
        EXTRA_DIRS="{ find $FZFZ_EXTRA_DIRS -type d 2> /dev/null }"
    else
        EXTRA_DIRS="{ true }"
    fi

    FZFZ_SUBDIR_LIMIT=${FZFZ_SUBDIR_LIMIT:=50}

    REMOVE_FIRST="tail -n +2"
    LIMIT_LENGTH="head -n $(($FZFZ_SUBDIR_LIMIT+1))"

    SUBDIRS="{ find . -type d | $LIMIT_LENGTH | $REMOVE_FIRST }"
    RECENTLY_USED_DIRS="{ z -l | $REVERSER | sed 's/^[[:digit:].]*[[:space:]]*//' }"

    ABSOLUTE_PATH="tr '\n' '\0' | xargs -0 realpath"

    FZF_COMMAND='fzf --tiebreak=index -m --preview="ls -1 {} | head -$LINES"'

    local COMMAND="{ $SUBDIRS ; $RECENTLY_USED_DIRS ; $EXTRA_DIRS; } | $EXCLUDER | $ABSOLUTE_PATH | $FZF_COMMAND"

    eval "$COMMAND" | while read item; do
    printf '%q ' "$item"
  done
  echo
}

fzfz-file-widget() {
  LBUFFER="${LBUFFER}$(__fzfz)"
  zle redisplay
}

zle     -N   fzfz-file-widget
bindkey '^G' fzfz-file-widget
