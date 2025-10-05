#typer - written in go , quick typing test in the terminal
export PATH="$HOME/go/bin:$PATH" 

#lsd - fancy ls
alias ls="lsd"
alias ll="lsd -l"
alias la="lsd -a"
alias lla="lsd -la"


#fastfetch - get system data and a image on the console
alias ff="fastfetch"

#trash - replacing rm (trash rm permenant deletes, trash sends it to bin 
#(brew install trash)

alias rm="trash"

#export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
#eval "$(starship init zsh)"

alias fzfv="fzf --bind 'enter:become(vim {})'"
