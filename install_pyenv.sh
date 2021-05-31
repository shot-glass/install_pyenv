#!/bin/bash -eu

# pyenvインストール用スクリプト

: "変数定義" &&{
  python_version="3.6.8"

  yum_packages=(bzip2 bzip2-devel libbz2-dev openssl openssl-devel readline readline-devel zlib-devel libffi-devel sqlite sqlite-devel libsqlite3x libsqlite3x-devel git gcc curl)
  apt_packages=(git gcc make sshpass libsqlite3-dev libssl-dev libffi-dev zlib1g zlib1g-dev libbz2-dev libreadline-dev)

  pyenv_url="https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer"
  pyenv_virtualenv_url="https://github.com/pyenv/pyenv-virtualenv.git"
  pip_url="https://bootstrap.pypa.io/get-pip.py"

  pyenv_dir=${HOME}/.pyenv
  rc_file="pyenv.sh"
}

: "OSパッケージインストール" && {
  echo "install packages."
  source /etc/os-release
  case ${ID_LIKE} in
    "rhel fedora")
      sudo yum update
      sudo yum install -y ${yum_packages[*]}
    ;;
    debian)
      sudo apt update
      sudo apt install -y ${apt_packages[*]}
    ;;
    *) echo "${ID} is not supported." ;;
  esac
}

: "pyenvインストール" && {
  curl -L ${pyenv_url} | bash
}

: "pyenv用rcファイル作成" &&{
  test -f /tmp/${rc_file} ||\
  cat <<-'EOF' >/tmp/${rc_file}
pyenv_dir=${HOME}/.pyenv
pyenv_virtualenv_dir=${pyenv_dir}/plugins/pyenv-virtualenv
if [ -d ${pyenv_dir} ]; then
	source <(${pyenv_dir}/bin/pyenv init 2>&1)
	test -d ${pyenv_virtualenv_dir} && eval "$(pyenv virtualenv-init - 2>&1)"
fi
EOF

  sudo chown root:root  /tmp/${rc_file}
  sudo mv /{tmp,etc/profile.d}/${rc_file}

  source /etc/profile.d/${rc_file}
}

: "pyenv-virtualenvインストール" && {
  git clone ${pyenv_virtualenv_url} $(pyenv root)/plugins/pyenv-virtualenv
}

: "pytrhon実行環境のインストールと有効化" && {
  pyenv install ${python_version}
  pyenv global ${python_version}
}

: "pipインストール" && {
  bash -lc "curl -sL ${pip_url} | python"
}

: "終了メッセージを表示" && {
  echo 'pyenv setup is completed.'
  echo 'run command "exec bash -l".'
}
