# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.zsh

# Theme - Look in ~/.oh-my-zsh/themes/
export ZSH_THEME="josh"

export DISABLE_AUTO_UPDATE="true"

# Plugins - Look in ~/.oh-my-zsh/plugins/
plugins=(git osx rails tmuxinator zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

ZSH_THEME_GIT_PROMPT_PREFIX="%{$green%}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$green%}) %{$fg[yellow]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$green%})"

ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=white,bold,bg=red')
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

export EDITOR="vim"
export GIT_EDITOR="vim"
export READNULLCMD="less"

alias e='emacs'

export TERM="xterm-256color"

export GPGKEY=12ED223E

# git aliases
alias -- --="git checkout -"
alias ga='git add -A'
alias gam='git commit --amend'
alias gap='git add -p'
alias gbranches="git branch | ruby -e \"puts STDIN.read.split(/\\n/).map { |b| [b.strip, %x(git log --format='%ai %h %s' #{b} | head -1), ''] }.sort_by { |_, c, _| c }\""
alias gclean='git branch --merged | grep -v master | xargs -n 1 git branch -d'
alias gco='git checkout'
alias gcob="git checkout -b"
alias gd='git diff'
alias gdt='git tag -d $1 && git push origin :$1'
alias gfo='git fetch origin'
alias gl='git log --stat'
alias gp='git pull'
alias gph='git push'
alias gpl='git pull'
alias gpr='git pull --rebase'
alias gr='git reset HEAD'
alias grb='git rebase'
alias grc='git rebase --continue'
alias grs="[[ $(git symbolic-ref --short HEAD) == 'staging' ]] && git fetch origin && git reset --hard origin/staging"
alias gs='git status'
alias gst='git stash'
alias gsta='git stash apply'
alias gsup='git branch --set-upstream-to=origin/`git symbolic-ref --short HEAD`'
alias gt="git tag -n | ruby -e \"puts STDIN.read.lines.sort_by { |t| t.split.first.sub(/^v/, '').sub(/\-rc/, '.1').sub(/\.beta/, '').split('.').map(&:to_i).tap { |v| v << 99 if v.length < 5 } }\""

function gcot() {
  git checkout --theirs $1
  git add $1
}

function gri() {
  if [ -z "$1" ]; then
    sha1=$(git log --format="format:%h %ae" | ruby -e "authors=ARGF.read.split(\"\\n\"); me=authors.first.split.last; puts authors.detect { |a| a.split.last != me }.split.first")
  else
    count=$1
  fi
  git rebase -i $sha1
}

function ghpull() {
  url=`git remote -v | grep origin | head -1 | ruby -e "puts ARGF.read.split[1].sub(/.+?:/, 'https://github.com/').sub(/\\.git$/, '')"`
  branch=`git symbolic-ref --short HEAD`
  if [ -z "$1" ]; then
    other_branch="master"
  else
    other_branch=$1
  fi
  open "$url/compare/$other_branch...$branch?expand=1"
}

function ghcommit() {
  url=`git remote -v | grep origin | head -1 | ruby -e "puts ARGF.read.split[1].sub(/.+?:/, 'https://github.com/').sub(/\\.git$/, '')"`
  branch=`git symbolic-ref --short HEAD`
  if [ -z "$1" ]; then
    commit=`git rev-parse HEAD`
  else
    commit=$1
  fi
  open "$url/commit/$commit"
}

# vagrant aliases
alias vup='vagrant up --provision'
alias vh='vagrant halt'

# rails aliases
alias rc="spring rails console"
alias rs="spring rails server"
alias rg="spring rails generate"
alias rd="spring rails dbconsole"
alias rdm="spring rake db:migrate && spring rake db:migrate RAILS_ENV=test"
alias bi="bundle install"
alias bo="bundle open"
alias bu='bundle update'
alias pr='pry -r ./config/environment.rb'
alias tld='tail -f log/development.log'
alias tlt='tail -f log/test.log'
alias tlp='tail -f log/production.log'
alias fs='foreman start'
alias ow='observr .watchr'

function bcd() {
  cd $(bundle show $1)
}

function h2h() {
  html2haml $1.erb $1.haml && rm $1.erb
}

# hide (rename) file
function hide() {
  mv $1{,.hide}
}
function show() {
  mv $1{.hide,}
}

# emacs client
function e() {
  if [[ -z "$1" ]]; then
    emacsclient -n .
  else
    emacsclient -n $@
  fi
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
alias chrome-proxy='chrome --proxy-server=socks5://localhost:9999 %U --proxy-bypass-list=localhost,127.0.0.1'
alias clip='xclip -selection clipboard'
alias screenshot='gnome-screenshot --interactive'
alias tx='tmuxinator'
alias ts='tmuxinator start'

function crush() {
  pngcrush $1 $1.crushed && mv $1.crushed $1
}

function mov2gif() {
  base="${1%%.*}"
  ffmpeg -i $1 -pix_fmt pal8 -r 12 -vf scale=iw/2:ih/2 -loop 0 $base.temp.gif
  gifsicle --optimize=3 $base.temp.gif > $base.gif
}

# web server for the current directory
function serve() {
  default_port=3000
  ruby -rwebrick -e "s=WEBrick::HTTPServer.new(:Port => ${1:-$default_port}, :DocumentRoot => Dir.pwd); trap(%q(INT)){ s.shutdown }; s.start"
}

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
# put IMGUR_CLIENT_ID in .zshrc.local
function imgur() {
  curl -F "image=@$1" -H "Authorization: Client-ID $IMGUR_CLIENT_ID" https://api.imgur.com/3/image | ruby -rjson -e "puts JSON.parse(ARGF.read)['data']['link']"
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

export PATH="$HOME/opt/bin:$PATH:$HOME/code/pco/bin"
export CDPATH="$CDPATH:$HOME/wp:$HOME/wp/devup/apps:$HOME/pp:$HOME/cp"

which keychain > /dev/null
[[ $? == 0 ]] && eval $(keychain --eval --agents ssh -Q --quiet id_rsa)

[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

[[ -e $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

# prefer brew-installed binaries
PATH=$HOME/bin:/usr/local/bin:$PATH

export PULSAR_CONF_REPO="ministrycentered/pco-deploy"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

export GOPATH="$HOME/go"

[[ -d $HOME/.rvm ]] && source $HOME/.rvm/scripts/rvm
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
