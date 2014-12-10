#
# Enables local erlang installation.
#
# Authors:
#   Michael Coles <michael.coles@gmail.com>
#

#echo "DEBUG: erlang/init.zsh $SHLVL"

# Return if requirements are not found.
if (( ! $+commands[kerl] )); then
  return 1
fi

sdir="$(dirname $0)"
fpath=("${sdir}/functions" $fpath)


kerl_deactivate() { # {{{1
    if [ -n "$_KERL_PATH_REMOVABLE" ]; then
        PATH=${PATH//${_KERL_PATH_REMOVABLE}:/}
        export PATH
        unset _KERL_PATH_REMOVABLE
    fi
    if [ -n "$_KERL_MANPATH_REMOVABLE" ]; then
        MANPATH=${MANPATH//${_KERL_MANPATH_REMOVABLE}:/}
        export MANPATH
        unset _KERL_MANPATH_REMOVABLE
    fi
    if [ -n "$_KERL_SAVED_REBAR_PLT_DIR" ]; then
        REBAR_PLT_DIR="$_KERL_SAVED_REBAR_PLT_DIR"
        export REBAR_PLT_DIR
        unset _KERL_SAVED_REBAR_PLT_DIR
    fi
    if [ -n "$_KERL_ACTIVE_DIR" ]; then
        unset _KERL_ACTIVE_DIR
    fi 
    if [ -n "$_KERL_SAVED_PS1" ]; then
        PS1="$_KERL_SAVED_PS1"
        export PS1
        unset _KERL_SAVED_PS1
    fi
    if [ -n "$BASH" -o -n "$ZSH_VERSION" ]; then
        hash -r
    fi
} #}}}

kerl_activate () {
    if [ -d "$1" ]; then
        installdir="$1"
    elif [ -d "${KERL_INSTALL_DIR}/${1}" ]; then
        installdir="${KERL_INSTALL_DIR}/${1}"
    else
        return 2
    fi
    _KERL_SAVED_REBAR_PLT_DIR="$REBAR_PLT_DIR"
    export _KERL_SAVED_REBAR_PLT_DIR
    _KERL_PATH_REMOVABLE="${installdir}/bin"

    PATH="${_KERL_PATH_REMOVABLE}:$PATH"
    export PATH _KERL_PATH_REMOVABLE
    _KERL_MANPATH_REMOVABLE="${installdir}/man"

    MANPATH="${_KERL_MANPATH_REMOVABLE}:$MANPATH"
    export MANPATH _KERL_MANPATH_REMOVABLE
    REBAR_PLT_DIR="${installdir}"

    export REBAR_PLT_DIR
    _KERL_ACTIVE_DIR="${installdir}"
    export _KERL_ACTIVE_DIR
    if [ -f "~/.kerlrc" ]; then . "~/.kerlrc"; fi
    if [ -n "$KERL_ENABLE_PROMPT" ]; then
        _KERL_SAVED_PS1="$PS1"
        export _KERL_SAVED_PS1
        PS1="(17.0)$PS1"
        export PS1
    fi
    if [ -n "$BASH" -o -n "$ZSH_VERSION" ]; then
        hash -r
    fi
}

__kerl=$(which kerl)
kerl () {
    # These would normally be inside the 'kerl' script, but in order to operate they need
    # to be executed in the context of the user's $SHELL (i.e. $SHLVL == 1).
    case "$1" in
        deactivate)
            kerl_deactivate
            ;;
        activate | switch)
            kerl_deactivate
            kerl_activate "$2"
            ;;
        *)
            $__kerl $@
    esac
}

# TODO: Identify which kerl installation to use: from ~/.kerlrc ?
. ~/.kerlrc
if [ ! -z "$KERL_INSTALL" ]; then
    kerl switch "$KERL_INSTALL"
fi
