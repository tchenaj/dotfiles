exists_cmd(){
    type $1 >/dev/null 2>&1
}

if ! exists_cmd git; then
    echo "Installing git"
    sudo apt install git -y
fi

if ! exists_cmd zsh; then
    echo "Installing zsh"
    sudo apt install zsh -y
fi

if ! exists_cmd lua; then
    echo "Installing lua"
    sudo apt install lua5.3 -y
    if ! exists_cmd lua; then
        LUA=$(which lua5.3)
        sudo ln -s $LUA ${LUA/lua5.3/lua}
    fi
fi

BIN=$HOME/bin
mkdir -p $BIN
export PATH=$BIN:$PATH
if ! exists_cmd antibody || [ "$1" = "overwrite" ]; then
    echo "Installing antibody"
    mkdir -p $BIN
    curl -sfL git.io/antibody | sh -s - -b $BIN
fi


echo "Creating ~/.zsh_plugins.sh"
antibody bundle "
    ohmyzsh/ohmyzsh
    ohmyzsh/ohmyzsh path:themes/robbyrussell.zsh-theme
    ohmyzsh/ohmyzsh path:plugins/git
    ohmyzsh/ohmyzsh path:plugins/colored-man-pages
    zsh-users/zsh-autosuggestions
    chrissicool/zsh-256color
    zdharma-continuum/fast-syntax-highlighting
    skywind3000/z.lua
    tchenaj/dotfiles path:plugins/lazyload
" > ~/.zsh_plugins.sh

echo "Creating ~/.zshrc"
echo "export ZSH=\"$(antibody path ohmyzsh/ohmyzsh)\"" >~/.zshrc
# adding "" to EOF prevents variable expansion
cat <<"EOF" >>~/.zshrc
export PATH=$HOME/bin:$PATH
_ZL_CMD=j
export _ZL_HYPHEN=1
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=245"

# disable update prompt of oh-my-zsh
DISABLE_UPDATE_PROMPT=true
# disable auto-update of oh-my-zsh
#DISABLE_AUTO_UPDATE=true

source ~/.zsh_plugins.sh

[[ -f ~/.aliases ]] && . ~/.aliases
[[ -v VSCODE_GIT_IPC_HANDLE ]] && conda --version >/dev/null 2>&1
EOF

echo "Creating ~/.aliases"
cat <<"EOF" >~/.aliases
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tl='tmux ls'
alias hg='history | grep'
alias gpa='git remote | xargs -L1 git push --all'
EOF

sudo chsh -s $(which zsh) $(whoami)
