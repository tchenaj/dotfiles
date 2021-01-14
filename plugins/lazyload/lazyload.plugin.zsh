lazyload() {
    local filename firstline
    filename=$1
    read -r firstline < $filename
    local cmd_list=(`echo ${firstline:1}`)
    if [ "${firstline:0:1}" != "#" ] || [ ${#cmd_list[@]} -eq 0 ]; then
        printf '%s\n' "Could not read triggering commands in the first line of $filename" \
            "Example first line:" \
            "# command1 command2 command3" >&2
        return 1
    else
        local unalias=''
        local cmd
        for cmd in $cmd_list; do
            unalias+="unalias $cmd;"
        done
        for cmd in $cmd_list; do
            alias "$cmd"="$unalias source $filename; $cmd"
        done
    fi
}

for file in ~/.lazyload.d/*; do
    lazyload "$file"
done

unset -f lazyload
