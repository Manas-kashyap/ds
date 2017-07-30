cmd_init_help() {
    cat <<_EOF
    init <app> [@<container>]
        Initialize a container directory by getting the file 'settings.sh'
        from the given app directory. If the second argument is missing,
        the current directory will be used to initialize the container,
        otherwise it will be done on '$CONTAINERS/<container>'.

_EOF
}

cmd_init() {
    # get app
    local app=$1
    [[ -n $app ]] || fail "Usage:\n$(cmd_init_help)"

    # get container
    local container=$2
    if [[ -n $container ]]; then
        [[ "${container:0:1}" == '@' ]] || fail "Usage:\n$(cmd_init_help)"
        local dir="$CONTAINERS/${container:1}"
        mkdir -p $dir
        cd $dir
    fi

    # check for overriding
    [[ -f settings.sh ]] \
        && fail "File '$(pwd)/settings.sh' already exists.\nInitialization failed."

    # check app dir
    local app_dir="$APPS/$app"
    [[ -d "$app_dir" ]] || fail "Cannot find directory '$app_dir'"
    [[ -f "$app_dir"/settings.sh ]] || fail "There is no file 'settings.sh' on '$app_dir'"

    # copy and update settings
    cp "$app_dir"/settings.sh .
    sed -i settings.sh -e "/^APP=/ c APP=$app"

    # notify
    cat <<-_EOF

Container initialized on '$(pwd)'.

Edit '$(pwd)/settings.sh'
and then run:
    $PROGRAM $2 build
    $PROGRAM $2 create
    $PROGRAM $2 config
    etc.

_EOF
}