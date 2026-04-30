# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# Function to get git branch
parse_git_branch() {
    # Get the branch name, hide errors if not in a git repo
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    
    # If the branch string is not empty, print it with your formatting
    if [ -n "$branch" ]; then
        echo " > git:$branch"
    fi
}

# Set the prompt
# \u = username, \w = current directory
export PS1="\[\e[36m\]\u \[\e[m\]> \[\e[32m\]\W\[\e[m\]\$(parse_git_branch) \[\e[m\]> "

fastfetch

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
