# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.zsh

# Theme - Look in ~/.oh-my-zsh/themes/
export ZSH_THEME="josh"

export DISABLE_AUTO_UPDATE="true"

# Plugins - Look in ~/.oh-my-zsh/plugins/
plugins=(git osx rails tmuxinator zsh-syntax-highlighting rbenv)

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

export TERM="xterm-256color"

export GPGKEY=12ED223E

# git aliases
alias -- --="git checkout -"
alias ga='git add -A'
alias gam='git commit --amend -v'
alias gap='git add -p'
alias gclean='git branch --merged | grep -v master | xargs -n 1 git branch -d'
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
alias gs='git status'
alias gst='git stash'
alias gsta='git stash apply'
alias gstp='git stash pop'
alias gsup='git branch --set-upstream-to=origin/`git symbolic-ref --short HEAD`'
alias gt="git tag -n | ruby -e \"puts STDIN.read.lines.sort_by { |t| t.split.first.sub(/^v/, '').sub(/\-rc/, '.1').sub(/\.beta/, '').split('.').map(&:to_i).tap { |v| v << 99 if v.length < 5 } }\""
alias master='git checkout master && spring stop &>/dev/null'
alias staging='git checkout staging && spring stop &>/dev/null'

function reset_test_db() {
  if [[ -e db/structure.sql ]]; then
    schema="db:structure:load"
  else
    schema="db:schema:load"
  fi
  RAILS_ENV=test bundle exec rake db:drop db:create $schema db:migrate
}

function ship() {
  if [[ -z "$(git diff --shortstat 2> /dev/null)" && -z "$(git diff --cached --shortstat 2> /dev/null)" ]]; then
    echo "Shipping..."
    pco vpn && \
    git checkout staging && \
    git fetch origin && \
    git reset --hard origin/staging && \
    git merge --no-edit - && \
    git push && \
    pco deploy && \
    git checkout -
  else
    echo "Index is dirty."
  fi
}

function gco() {
  git checkout $1
  bundle exec spring stop &>/dev/null
}

function gbranches() {
  current=$(git symbolic-ref --short HEAD)
  git branch | \
    grep -v "master\|staging\|$current" | \
    ruby -e "puts STDIN.read.split(/\n/).map { |b| [b.strip, %x(git log --format='%ai %h %s' #{b} | head -1)] }.sort_by(&:last).map(&:first)"
}

unalias gcl
function gcl() {
  git checkout $(gbranches | tail -1)
  spring stop &>/dev/null
}

function grs() {
  if [[ $(git symbolic-ref --short HEAD) == 'staging' ]]; then
    git fetch origin && git reset --hard origin/staging
  fi
}

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

function github_url() {
  echo `git remote -v | grep origin | head -1 | ruby -e "puts ARGF.read.split[1].sub(/.*github\\.com./, 'https://github.com/').sub(/\\.git$/, '')"`
}

function github_branch() {
  echo `git symbolic-ref --short HEAD`
}

function browser_open() {
  if [[ $(psgrep Applications/Safari.app) != "" ]]; then
    open -a Safari $@
  else
    open $@
  fi
}

function ghcompare() {
  if [ -z "$1" ]; then
    other_branch="master"
  else
    other_branch=$1
  fi
  url="$(github_url)/compare/$other_branch...$(github_branch)"
  if [ -n "$2" ]; then
    url="$url?expand=1";
  fi
  browser_open "$url"
}

function ghpull() {
  ghcompare "$1" "expand"
}

function ghcommit() {
  if [ -z "$1" ]; then
    commit=`git rev-parse HEAD`
  else
    commit=$1
  fi
  browser_open "$(github_url)/commit/$commit"
}

function circleci_url() {
  echo `git remote -v | grep origin | head -1 | ruby -e "puts ARGF.read.split[1].sub(/.*github\\.com./, 'https://circleci.com/gh/').sub(/\\.git$/, '')"`
}

function circle() {
  branch=`git symbolic-ref --short HEAD | ruby -r cgi -e "puts CGI.escape(ARGF.read.strip)"`
  browser_open "$(circleci_url)/tree/$branch"
}

function wip() {
  git add .
  git commit -m "wip" $@
}

function unwip() {
  git log --oneline | head -1 | grep wip && git reset HEAD\^
}

# vagrant aliases
alias vup='vagrant up --provision'
alias vh='vagrant halt'

# rails aliases
alias b='bundle exec'
alias bi="bundle install --jobs 4"
alias bo="bundle open"
alias bu='bundle update'
alias esl='eslint --fix app/assets/javascripts/**/*.js app/assets/javascripts/**/*.jsx'
alias fs='foreman start'
alias ow='observr .watchr'
alias pr='bundle exec pry -r ./config/environment.rb'
alias rc="bundle exec spring rails console"
alias rd="bundle exec spring rails dbconsole"
alias rdm="bundle exec spring rake db:migrate && bundle exec spring rake db:migrate RAILS_ENV=test"
alias rg="bundle exec spring rails generate"
alias rs="bundle exec spring rails server"
alias tld='tail -f log/development.log'
alias tlp='tail -f log/production.log'
alias tlt='tail -f log/test.log'

function rdm_down() {
  version=$(ls db/migrate | tail -1)
  bundle exec spring rake db:migrate:down VERSION=$version
  bundle exec spring rake db:migrate:down VERSION=$version RAILS_ENV=test
}

function bcd() {
  cd $(bundle show $1)
}

# hide (rename) file
function hide() {
  mv $1{,.hide}
}
function show() {
  mv $1{.hide,}
}

# global aliases
alias -g hosts='/etc/hosts'

function crush() {
  pngcrush $1 $1.crushed && mv $1.crushed $1
}

function mov2gif() {
  base="${1%%.*}"
  palette="/tmp/palette.png"
  filters="fps=15,scale=${2:-700}:-1:flags=lanczos"

  ffmpeg -i $1 -vf "$filters,palettegen" -y $palette
  ffmpeg -i $1 -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $base.gif
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

# weather
function w() {
  if [[ -z "$1" ]]; then
    curl http://wttr.in/Tulsa
  else
    curl http://wttr.in/$1
  fi
}

# yarn
function npm() {
  if [[ -e yarn.lock ]]; then
    echo "Use yarn silly."
  else
    /usr/local/bin/npm $@
  fi
}

# annoying auto-correct
unsetopt correct_all

# fix home and end keys
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line

#export PATH="$HOME/opt/bin:$HOME/code/pco/bin:$HOME/.cargo/bin:$PATH"
export PATH="$HOME/opt/bin:$HOME/.cargo/bin:$PATH"
export CDPATH="$CDPATH:$HOME/wp:$HOME/pp:$HOME/cp"

which keychain > /dev/null
[[ $? == 0 ]] && eval $(keychain --eval --agents ssh -Q --quiet id_rsa)

[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

[[ -e $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

# prefer brew-installed binaries
PATH=$HOME/bin:/usr/local/bin:$PATH

export PULSAR_CONF_REPO="ministrycentered/pco-deploy"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

export GOPATH="$HOME/Code/go"

# added by travis gem
[ -f /Users/timmorgan/.travis/travis.sh ] && source /Users/timmorgan/.travis/travis.sh

source /Users/timmorgan/.iterm2_shell_integration.zsh

alias dc="docker-compose"

eval "$(rbenv init -)"

eval "$(~/Code/pco/bin/pco init -)"

# pco-box
export PATH="$HOME/pco-box/bin:$PATH"
function pco() {
  if [[ "$1" == "box" ]]; then
    shift
    $HOME/pco-box/bin/box "$@"
  else
    command pco "$@"
  fi
}

