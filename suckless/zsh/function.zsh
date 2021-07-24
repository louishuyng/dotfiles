function b64() {
  cat $1 | base64 | pbcopy;
}

function br() {
  str="$*"
  brightness $str
}

function work() {
  name="$1"

  nv ~/Dev/Projects/$1
}

function gg() {
  str="$*"
  open -a 'Brave Browser' 'https://www.google.com/search?q='$str
}

function yt() {
  str="$*"
  open -a 'Brave Browser' 'https://www.youtube.com/results?search_query='$str
}

function sd() {
  sudo shutdown -h +$*
}

## DEV TOOLS
function Dev() {
  str="$*"
  tm new -s $str
}

function prettierGitDiff() {
  extension=$1;

  prettier --write '$(git diff --name-only | grep '.$extension' | xargs)'
}


# Create a new directory and enter it
function mkd() {
  mkdir -p "$@" && cd "$_";
}

# SSH add name
function sshadd() {
  name=$1;

  ssh-add -D

  if [ -z "${name}" ]; then
    ssh-add -K ~/.ssh/id_rsa
  else
    ssh-add -K ~/.ssh/id_rsa_$name
  fi
}

# Git clone + npm install
function gcn() {
  url=$1;
  if [ -n "${1}" ]; then
    echo 'OK'
  else
    echo 'Koooooooooooooooo'
  fi
  cd ~/code;
  reponame=$(echo $url | awk -F/ '{print $NF}' | sed -e 's/.git$//');
  git clone $url $reponame;
  cd $reponame;
  npm install;
}