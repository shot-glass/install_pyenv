#!/bin/bash

# ansible ユーザーローカル実行環境インストール用スクリプト

: "変数定義" &&{
  python_version="3.6.8"
  ansible_version="2.7"

  yum_packages=(bzip2 bzip2-devel libbz2-dev openssl openssl-devel readline readline-devel zlib-devel libffi-devel sqlite sqlite-devel libsqlite3x libsqlite3x-devel git gcc curl)
  python_modules=(pywinrm pyvmomi)

  pyenv_url="https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer"
  pip_url="https://bootstrap.pypa.io/get-pip.py"

  pyenv_dir=${HOME}/.pyenv
  rc_file="${HOME}/.bashrc.pyenv"
}


: "前提条件確認" &&{
  error_msg=()
  
  egrep -qi 'Red Hat|CentOS|Fedra' /etc/redhat-release || {
    error_msg+=("Red Hat系ディストリビューションではありません")
  }
  
  curl "www.google.com" >/dev/null 2>&1 || {
    error_msg+=("Webへ接続できません")
  }
  
  which yum  >/dev/null 2>&1 || {
    error_msg+=("yumがインストールされていません")
  }

  sudo yum --version >/dev/null 2>&1 || {
    error_msg+=("yumの実行権限がありません")
  }

  test -d ${pyenv_dir} && {
    error_msg+=("${pyenv_dir} を削除してください")
  }

  test ${#error_msg[@]} -ne 0 && {
    temp=$IFS
    IFS=','

    for i in ${error_msg[@]}; do
      echo "エラー: $i" >/dev/stderr
    done
    
    IFS=${temp}
    exit 1
  }
}

: "OSパッケージインストール" && {
  sudo yum install -y ${yum_packages[*]}
}

: "pyenvインストール" && {
  curl -L ${pyenv_url} | bash
}

: "pyenv用rcファイル作成" &&{
  test -f ${rc_file} ||\
    cat <<-'EOF' >${rc_file}
	export PATH="/home/manager/.pyenv/bin:$PATH"
	eval "$(pyenv init -)"
	eval "$(pyenv virtualenv-init -)"
	EOF
  
  fgrep -q 'source ${HOME}/.bashrc.pyenv' ${HOME}/.bashrc ||\
    echo 'source ${HOME}/.bashrc.pyenv' >>${HOME}/.bashrc

  source ${rc_file}
}

: "pytrhon実行環境のインストールと有効化" && {
  pyenv install ${python_version}
  pyenv global ${python_version}
}

: "pipインストール" && {
  curl -sL ${pip_url} | python
}

: "pythonモジュールとansibleインストール" && {
  pip install ${python_modules[*]}
  pip install ansible==${ansible_version}
}
