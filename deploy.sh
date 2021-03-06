#!/bin/bash

is_first_run=false

# ========================= Setup external tools =========================
if [ ! -f yara/yara ] || [ ! -f chkrootkit/chkrootkit ] ; then

    is_first_run=true

    if [ -f /etc/redhat-release ]; then

      sudo yum -y install wget

    fi

    if [ -f /etc/lsb-release ]; then

      sudo apt-get install wget

    fi

fi

if [ ! -f yara/yara ]; then

    if [ -f /etc/redhat-release ]; then
      echo "Installing dependencies for yara/CentOS..."

      # YARA
      sudo yum -y install automake libtool make gcc

    fi

    if [ -f /etc/lsb-release ]; then
      echo "Installing dependencies for yara/Ubuntu..."

      # YARA
      sudo apt-get install -y automake libtool make gcc

    fi

    # Build YARA from source
    rm master.tar.gz
    wget https://github.com/VirusTotal/yara/archive/master.tar.gz -O master.tar.gz
    tar -zxf master.tar.gz
    mv yara-master yara
    cd yara
    ./bootstrap.sh
    ./configure
    make # build without install. we'll use the binaries directly.
    cd ..

fi

if [ ! -f chkrootkit/chkrootkit ] ; then

    # Build chkrootkit from source
    rm master.tar.gz
    wget https://github.com/omri9741/chkrootkit/archive/master.tar.gz -O master.tar.gz
    tar -zxf master.tar.gz
    mv chkrootkit-master chkrootkit
    rm master.tar.gz
    cd chkrootkit
    make sense
    cd ..

fi

# ========================= Install Python pip if needed =========================
if [ ! -x "$(command -v pip)" ] ; then
    echo "pip not installed! installing pip..."

    is_first_run=true

    if [ -f /etc/redhat-release ]; then

      sudo yum -y install gcc python-devel

      wget "https://bootstrap.pypa.io/get-pip.py" -O "get-pip.py"
      sudo python get-pip.py

    fi

    if [ -f /etc/lsb-release ]; then

      sudo apt-get install python-pip

    fi

fi

# ========================= 1st run =========================
if [ "$is_first_run" = true ] ; then

# ========================= Install requirements =========================
    sudo pip install -r requirements.txt

# ========================= Update YARA signatures =========================
    echo -e "\033[33m[*] fetching up-to-date yara signatures...\033[0m"
    ./update_signatures.sh

fi

# ========================= Start Linux Expl0rer =========================
echo -e "\033[33m[*] starting Linux Expl0rer...\033[0m"
sudo python linux_explorer.py
