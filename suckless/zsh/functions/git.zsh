function prettierGitDiff() {
  extension=$1;

  prettier --write '$(git diff --name-only | grep '.$extension' | xargs)'
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

# Git lab merge requests Oivan
function glm() {
  open https://gitlab.iwa.fi/moho/$(basename -s .git `git config --get remote.origin.url`)/-/merge_requests
}

# Git hub merge requests
function ghm() {
  open https://github.$(git config remote.origin.url | cut -f2 -d. | tr ':' /)/pulls
}
