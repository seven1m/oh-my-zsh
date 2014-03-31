# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.zsh

# Theme - Look in ~/.oh-my-zsh/themes/
export ZSH_THEME="josh"

export DISABLE_AUTO_UPDATE="true"

# Plugins - Look in ~/.oh-my-zsh/plugins/
plugins=(git osx rails tmuxinator)

source $ZSH/oh-my-zsh.sh

ZSH_THEME_GIT_PROMPT_PREFIX="%{$green%}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$green%}) %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$green%})"

export EDITOR="vim"
export GIT_EDITOR="vim"
export READNULLCMD="less"

export TERM="xterm-256color"

export GPGKEY=12ED223E

# git aliases
alias gs='git status'
alias gco='git checkout'
alias gph='git push'
alias gpl='git pull'
alias ga='git add -A'
alias gd='git diff'
alias gap='git add -p'
alias gam='git commit --amend'
alias gl='git log --stat'
alias gp='git pull'
alias gpr='git pull --rebase'
alias gfo='git fetch origin'
alias grc='git rebase --continue'
alias gr='git reset HEAD'
alias grb='git rebase'
alias gt="git tag -n | ruby -e \"puts STDIN.read.lines.sort_by { |t| t.split.first.sub(/^v/, '').sub(/\-rc/, '.1').split('.').map(&:to_i).tap { |v| v << 99 if v.length < 5 } }\""
alias gdt='git tag -d $1 && git push origin :$1'
alias gst='git stash'
alias gsta='git stash apply'
alias gnotrack='git update-index --assume-unchanged'
alias gtrack='git update-index --no-assume-unchanged'
alias glistnotrack='git ls-files -v | grep "^h"'
function gsu() {
  branch=`git status | head -n1 | awk '{ print $4 }'`
  alias gsu='git br --set-upstream-to=origin/$branch $branch'
}

# vagrant aliases
alias vup='vagrant up --provision'
alias vh='vagrant halt'

# rails aliases
alias rc="rails console"
alias rs="rails server"
alias rg="rails generate"
alias rd="rails dbconsole"
alias bi="bundle install"
alias bu='bundle update'
alias pr='pry -r ./config/environment.rb'

# hide (rename) file
function hide() {
  mv $1{,.hide}
}
function show() {
  mv $1{.hide,}
}

# zeus
alias zw='while [ ! -e .zeus.sock ]; do sleep 1; done; $@'
alias zc='zeus cucumber -r features --no-source'
function zr() {
  if [[ -z "$1" ]]; then
    zeus rspec spec
  else
    zeus rspec $@
  fi
}

# global aliases
alias -g hosts='/etc/hosts'

# misc aliases
alias chrome-proxy='chromium --proxy-server=socks5://localhost:9999 %U --proxy-bypass-list=localhost,127.0.0.1'
alias clip='xclip -selection clipboard'
alias serve='ruby -rwebrick -e"s=WEBrick::HTTPServer.new(:Port => 3000, :DocumentRoot => Dir.pwd); trap(%q(INT)){ s.shutdown }; s.start"'
alias screenshot='gnome-screenshot --interactive'
alias tx='tmuxinator'
alias ts='tmuxinator start'

# open csv file in vim formatted
function csvim() {
  ruby -rcsv -e "puts CSV.read('$1').to_a.map { |r| r.join('|') }" | vim -c "Tabularize /|" -
}

# write history to a file every day
function precmd() {
  if [ "$(id -u)" -ne 0 ]; then
    FULL_CMD_LOG="$HOME/.logs/zsh-history-$(date -u "+%Y-%m-%d").log"
    echo "$USER@`hostname`:`pwd` [$(date -u)] `\history -1`" >> ${FULL_CMD_LOG}
  fi
}

# upload image to imgur
function imgur() {
  curl -F "image=@$1" -F "key=$IMGUR_API_KEY" http://api.imgur.com/2/upload.xml | tail -n 1 | sed 's/.*<original>\([^\<]*\).*/\1/'
}

# productivity
function h() {
  if [[ -z "$1" ]]; then
    ruby -r$HOME/opt/timetrack.rb -e "puts TimeTrack::Parser.new_from_glob('$HOME/vimwiki/*.wiki').each { |t| t.parse.to_s }.join"
  else
    ruby -r$HOME/opt/timetrack.rb -e "puts TimeTrack::Parser.new_from_file('$1').parse.to_s"
  fi
}

# annoying auto-correct
unsetopt correct_all

# fix home and end keys
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line

export PATH="$HOME/opt/bin:$PATH"
export CDPATH="$CDPATH:$HOME/wp:$HOME/wp/devup/apps:$HOME/pp:$HOME/cp"

which keychain > /dev/null
[[ $? == 0 ]] && eval $(keychain --eval --agents ssh -Q --quiet id_rsa)

[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

[[ -e $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

[[ -d $HOME/.rvm ]] && source $HOME/.rvm/scripts/rvm
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
