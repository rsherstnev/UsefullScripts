#!/usr/bin/env bash

_RED_COLOR="\e[1;31m"
_GREEN_COLOR="\e[1;32m"
_YELLOW_COLOR="\e[1;33m"
_COLOR_RESET="\e[0m"

if [[ $EUID != 0 ]]; then
    echo -e "${_RED_COLOR}!!! Данный скрипт должен быть запущен от имени root !!!${_COLOR_RESET}"
    exit 1
fi

function report_step {
    echo -e "${_YELLOW_COLOR}[STEP] $1...${_COLOR_RESET}"
}

function report_success {
    echo -e "  ${_GREEN_COLOR}[SUCCESS] $1.${_COLOR_RESET}"
}

function report_fail {
    echo -e "  ${_RED_COLOR}[FAIL] $1!${_COLOR_RESET}"
}

function file_download {
    # Так как wget не умеет перезаписывать файлы, нужно сначала удалить файл при его наличии
    if [ -f $2 ]; then
        rm -f $2 &> /dev/null
    fi
    # Скачивание файла
    file_name=$(echo $1 | awk -F '/' '{print $NF}')
    if wget $1 -O $2 &> /dev/null; then
        report_success "Файл $file_name был успешно скачан по адресу $2"
    else
        report_fail "При скачивании файла $file_name по адресу $2 произошла ошибка"
    fi
}

function git_clone {
    if git clone $1 $2 &> /dev/null; then
        report_success "Репозиторий \"$1\" был успешно склонирован в директорию $2"
    else
        report_fail "При клонировании репозитория \"$1\" в директорию $2 произошла ошибка"
    fi
}

function uv_install {
    if uv tool install $1 &> /dev/null; then
        report_success "Утилита \"$1\" была успешно установлена"
    else
        report_fail "При установке утилиты \"$1\" произошла ошибка"
    fi
}

function uv_github_install {
    if uv tool install git+https://github.com/$1.git &> /dev/null; then
        report_success "Утилита \"$1\" была успешно установлена"
    else
        report_fail "При установке утилиты \"$1\" произошла ошибка"
    fi
}

touch $HOME/.hushlogin

report_step "Разблокировка пользователя root, задайте ему пароль"
if passwd; then
    report_success "Пользователь root был успешно разблокирован"
else
    report_fail "При разблокировке пользователя root произошла ошибка"
fi

report_step "Создание необходимых директорий"
for directory in \
    $HOME/.fonts \
    $HOME/.vim/colors \
    $HOME/.config/xfce4/terminal \
    $HOME/.config/mc \
    $HOME/.config/nvim \
    $HOME/.config/alacritty \
    $HOME/.local/share/mc/skins \
    $HOME/.local/share/xfce4/terminal/colorschemes \
    $HOME/.local/share/{themes,icons} \
    $HOME/.zsh-custom-completions \
    $HOME/.python-custom-completions \
    /opt/{docker-software,docker-volumes,docker-compose,python-software,exploits,ctf/{htb,thm,hackerlab},post/{docker,linux,windows,general},scripts,shells,software,custom-passwords} \
    /pictures;
do
    if [[ ! -d $directory ]]; then
        if mkdir -p $directory &> /dev/null; then
            report_success "Директория \"$directory\" была успешно создана"
        else
            report_fail "При создании директории \"$directory\" произошла ошибка"
        fi
    fi
done

report_step "Установка русского языка в систему"
if sed '/ru_RU.UTF-8 UTF-8/s/^# //' -i /etc/locale.gen && locale-gen &> /dev/null && update-locale LANG=ru_RU.UTF-8; then
    report_success "Русский язык был успешно установлен в систему"
else
    report_fail "При установке русского языка в систему произошла ошибка"
fi

report_step "Изменение наименований стандартных директорий хомяка на кастомные"
if sed -Ei 's/DESKTOP=.*/DESKTOP=desktop/g' /etc/xdg/user-dirs.defaults &&
    sed -Ei 's/DOWNLOAD=.*/DOWNLOAD=downloads/g' /etc/xdg/user-dirs.defaults &&
    sed -Ei 's/TEMPLATES=.*/TEMPLATES=templates/g' /etc/xdg/user-dirs.defaults &&
    sed -Ei 's/PUBLICSHARE=.*/PUBLICSHARE=public/g' /etc/xdg/user-dirs.defaults &&
    sed -Ei 's/DOCUMENTS=.*/DOCUMENTS=documents/g' /etc/xdg/user-dirs.defaults &&
    sed -Ei 's/MUSIC=.*/MUSIC=music/g' /etc/xdg/user-dirs.defaults &&
    sed -Ei 's/PICTURES=.*/PICTURES=pictures/g' /etc/xdg/user-dirs.defaults &&
    sed -Ei 's/VIDEOS=.*/VIDEOS=videos/g' /etc/xdg/user-dirs.defaults &&
    echo en_US > $HOME/.config/user-dirs.locale; then
    report_success "Наименования стандартных директорий хомяка были успешно изменены на кастомные"
else
    report_fail "При изменении наименований стандартных директорий хомяка на кастомные произошла ошибка"
fi

report_step "Обновление системы"
export DEBIAN_FRONTEND=noninteractive
if apt update &> /dev/null && apt full-upgrade -y &> /dev/null; then
    report_success "Система была успешно обновлена"
else
    report_fail "При обновлении системы произошла ошибка"
fi

report_step "Задание необходимой временной зоны"
if timedatectl set-timezone Asia/Krasnoyarsk &> /dev/null; then
    report_success "Временная зона \"Красноярск\" была успешно задана"
else
    report_fail "При установке временной зоны \"Красноярск\" произошла ошибка"
fi

report_step "Установка необходимого для работы софта"
for software in \
    apt-file \
    vim \
    neovim \
    less \
    curl \
    wget \
    bash-completion \
    zsh \
    git \
    python3-pip \
    tmux \
    fzf \
    htop \
    btop \
    lnav \
    tailspin \
    openvpn \
    wireguard \
    resolvconf \
    iptables \
    tree \
    mc \
    rlwrap \
    alacritty \
    tcpdump \
    tshark \
    wireshark \
    man-db \
    gedit \
    tig \
    alacarte \
    mawk \
    sed \
    ncdu \
    du-dust \
    pv \
    colordiff \
    gpg \
    zulucrypt-cli \
    zulucrypt-gui \
    zulumount-cli \
    zulumount-gui \
    ripgrep \
    jq \
    bat \
    gzip \
    unrar \
    p7zip \
    rsync \
    ffmpeg \
    firefox-esr \
    rofi \
    meld \
    filezilla \
    viewnior \
    flameshot \
    cherrytree \
    keepassxc-full \
    traceroute \
    remmina \
    findutils \
    locate \
    smbclient \
    dbeaver \
    eza \
    peco \
    fd-find \
    gdb \
    breeze-cursor-theme \
    arc-theme \
    xfce4-goodies \
    gparted \
    obsidian \
    golang-go \
    thunderbird \
    evolution \
    powershell \
    zoxide \
    git-delta \
    asciinema \
    gping \
    broot \
    libcurl4-openssl-dev \
    build-essential \
    libssl-dev \
    redis-tools \
    sqlitebrowser \
    doublecmd-gtk \
    tigervnc-viewer \
    fastfetch \
    neomutt \
    grub-customizer \
    conky-all \
    conky-manager \
    gvfs \
    gvfs-backends \
    gvfs-common \
    gvfs-daemons \
    gvfs-fuse \
    gvfs-libs \
    thunar-volman \
    obs-studio \
    xclip \
    gitg \
    bind9-dnsutils;
do
    if apt install -y $software &> /dev/null; then
        report_success "Утилита \"$software\" была успешно установлена в систему"
    else
        report_fail "При установке утилиты \"$software\" произошла ошибка"
    fi
done

report_step "Установка Oh My Zsh"
file_download https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh /tmp/install.sh
bash /tmp/install.sh --unattended &> /dev/null
if [[ $? == 0 ]]; then
    report_success "Oh My Zsh был успешно установлен в систему"
else
    report_fail "При установке Oh My Zsh в систему произошла ошибка"
fi

report_step "Установка необходимого для тестирования на проникновение софта"
for software in \
    nmap \
    zenmap \
    ncat \
    impacket-scripts \
    smtp-user-enum \
    burpsuite \
    exploitdb \
    metasploit-framework \
    responder \
    bettercap \
    bettercap-caplets \
    bettercap-ui \
    freerdp3-x11 \
    freerdp3-shadow-x11 \
    chisel \
    proxychains4 \
    fping \
    arp-scan \
    netdiscover \
    mtr \
    dsniff \
    socat \
    mimikatz \
    wpscan \
    powersploit \
    nishang \
    seclists \
    gobuster \
    hydra \
    evil-winrm \
    cutycapt \
    cewl \
    hashcat \
    hashcat-utils \
    john \
    maskprocessor \
    crunch \
    urlcrazy \
    whatweb \
    mdbtools \
    cadaver \
    hexedit \
    radare2 \
    checksec \
    ltrace \
    strace \
    feroxbuster \
    patator \
    ligolo-ng \
    macchanger \
    arping \
    snmp \
    onesixtyone \
    jxplorer \
    nbtscan \
    weevely \
    wordlists \
    subfinder \
    swaks \
    sliver \
    trivy \
    windows-binaries \
    sbd \
    rizin \
    rizin-cutter \
    ghidra \
    edb-debugger \
    jd-gui \
    gitleaks \
    trufflehog \
    nikto \
    peass \
    nuclei;
do
    if apt install -y $software &> /dev/null; then
        report_success "Утилита \"$software\" была успешно установлена в систему"
    else
        report_fail "При установке утилиты \"$software\" произошла ошибка"
    fi
done

report_step "Установка uv"
if curl -LsSf https://astral.sh/uv/install.sh | sh &> /dev/null; then
    report_success "UV был успешно установлен"
else
    report_fail "При установке UV произошла ошибка"
fi

export PATH="$PATH:/root/.local/bin/"

report_step "Установка необходимых Python утилит с PyPI"
for python_tool in \
    sqlmap \
    impacket \
    pyinstaller \
    litecli \
    certipy-ad \
    defaultcreds-cheat-sheet \
    coercer \
    wapiti3 \
    git-dumper \
    mitmproxy \
    argcomplete \
    sshuttle;
do
    if uv_install $python_tool &> /dev/null; then
        report_success "Python утилита \"$python_tool\" была успешно установлена"
    else
        report_fail "При установке python утилиты \"$python_tool\" произошла ошибка"
    fi
done

if uv_install wfuzz --python 3.8 &> /dev/null; then
    report_success "Python утилита \"wfuzz\" была успешно установлена"
else
    report_fail "При установке python утилиты \"wfuzz\" произошла ошибка"
fi

report_step "Установка необходимых Python утилит с GitHub"
for python_repo in \
    "Pennyw0rth/NetExec" \
    "commixproject/commix" \
    "httpie/cli" \
    "sc0tfree/updog" \
    "ShawnDEvans/smbmap" \
    "p0dalirius/smbclient-ng" \
    "Chocapikk/pwncat-vl" \
    "brightio/penelope" \
    "cddmp/enum4linux-ng" \
    "httpie/http-prompt" \
    "dbcli/mycli" \
    "dbcli/pgcli" \
    "skelsec/pypykatz" \
    "Hackndo/lsassy" \
    "s0md3v/Arjun" \
    "EnableSecurity/wafw00f" \
    "dirkjanm/BloodHound.py" \
    "darkoperator/dnsrecon" \
    "dirkjanm/adidnsdump" \
    "laramies/theHarvester" \
    "blacklanternsecurity/MANSPIDER" \
    "login-securite/DonPAPI" \
    "PShlyundin/ldap_shell" \
    "yaap7/ldapsearch-ad" \
    "CravateRouge/bloodyAD" \
    "aniqfakhrul/powerview.py" \
    "isd-project/isd" \
    "cogiceo/GPOHound" \
    "Hackndo/pyGPOAbuse" \
    "casterbyte/Above" \
    "garrettfoster13/sccmhunter" \
    "franc-pentest/ldeep" \
    "elceef/dnstwist";
do
    if uv_github_install $python_repo &> /dev/null; then
        report_success "Python утилита из GitHub репозитория \"https://github.com/$python_repo\" была успешно установлена"
    else
        report_fail "При установке python утилиты из GitHub репозитория \"https://github.com/$python_repo\" произошла ошибка"
    fi
done

if uv_github_install "calebstewart/pwncat" --python 3.9 &> /dev/null; then
    report_success "Python утилита из GitHub репозитория \"https://github.com/calebstewart/pwncat\" была успешно установлена"
else
    report_fail "При установке python утилиты из GitHub репозитория \"https://github.com/calebstewart/pwncat\" произошла ошибка"
fi

report_step "Установка необходимых Ruby утилит"
for ruby_tool in \
    haiti-hash;
do
    if gem install $ruby_tool &> /dev/null; then
        report_success "Ruby утилита \"$ruby_tool\" была успешно установлена"
    else
        report_fail "При установке ruby утилиты \"$ruby_tool\" возникли проблемы"
    fi
done

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

report_step "Установка необходимых Go утилит с GitHub"
for go_tool in \
    "FalconOpsLLC/goexec" \
    "projectdiscovery/httpx/cmd/httpx" \
    "jesseduffield/lazygit" \
    "jesseduffield/lazydocker" \
    "asdf-vm/asdf/cmd/asdf" \
    "muesli/duf" \
    "ropnop/kerbrute" \
    "xm1k3/cent" \
    "Macmod/godap" \
    "jfjallid/go-secdump" \
    "ropnop/go-windapsearch/cmd/windapsearch" \
    "sensepost/gowitness" \
    "Chocapikk/wpprobe" \
    "patrickhener/goshs" \
    "projectdiscovery/katana/cmd/katana" \
    "Hackmanit/TInjA" \
    "rverton/webanalyze/cmd/webanalyze";
do
    if go install github.com/$go_tool@latest &> /dev/null; then
        report_success "Go утилита \"$go_tool\" была успешно установлена"
    else
        report_fail "При установке go утилиты \"$go_tool\" возникли проблемы"
    fi
done

report_step "Установка Rust"
if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &> /dev/null; then
    report_success "Rust был успешно установлен"
else
    report_fail "При установке Rust произошла ошибка"
fi
source "$HOME/.cargo/env"

report_step "Установка необходимых Rust утилит с crates.io"
for rust_tool in \
    rusthound-ce \
    atuin \
    navi \
    bandwhich \
    ripgrep_all \
    htmlq \
    sd \
    procs \
    tealdeer \
    trippy \
    hwatch \
    xcp \
    rustcat \
    rustscan;
do
    if cargo install $rust_tool &> /dev/null; then
        report_success "Rust утилита \"$rust_tool\" была успешно установлена"
    else
        report_fail "При установке rust утилиты \"$rust_tool\" возникли проблемы"
    fi
done

report_step "Установка необходимых конфигов, скриптов, тем"
# Установка личных конфигов
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/bash/.bashrc $HOME/.bashrc
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/bash/.inputrc $HOME/.inputrc
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/zsh/.zshrc $HOME/.zshrc
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/zsh/.zprofile $HOME/.zprofile
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/refs/heads/master/common/.aliases $HOME/.aliases
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/refs/heads/master/common/.functions $HOME/.functions
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/vim/.vimrc $HOME/.vimrc
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/vim/init.vim $HOME/.config/nvim/init.vim
file_download https://raw.githubusercontent.com/cocopon/iceberg.vim/master/colors/iceberg.vim $HOME/.vim/colors/iceberg.vim
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/tmux/.tmux.conf $HOME/.tmux.conf
file_download https://raw.githubusercontent.com/dracula/midnight-commander/master/skins/dracula256.ini $HOME/.local/share/mc/skins/dracula256.ini
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/mc/ini $HOME/.config/mc/ini
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/mc/panels.ini $HOME/.config/mc/panels.ini
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/git/.gitconfig $HOME/.gitconfig
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/refs/heads/master/conky/.conkyrc $HOME/.conkyrc
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/refs/heads/master/terminal/alacritty/alacritty.toml $HOME/.config/alacritty/alacritty.toml
# Установка тем
file_download https://raw.githubusercontent.com/dracula/xfce4-terminal/master/Dracula.theme $HOME/.local/share/xfce4/terminal/colorschemes/Dracula.theme
# Установка личных скриптов
file_download https://raw.githubusercontent.com/rsherstnev/CTF/master/Scripts/searchnmapscript.py /opt/scripts/searchnmapscript.py
file_download https://raw.githubusercontent.com/rsherstnev/CTF/master/Scripts/revshellgen.py /opt/scripts/revshellgen.py
file_download https://raw.githubusercontent.com/rsherstnev/CTF/master/Scripts/base64enpacker.py /opt/scripts/base64enpacker.py
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/tmux/vpn_ip.sh /opt/scripts/vpn_ip.sh
chmod +x /opt/scripts/vpn_ip.sh

report_step "Установка прогарммы \"vim-plug\" для управления плагинами Vim"
if curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &> /dev/null; then
    report_success "Прогармма \"vim-plug\" для управления плагинами Vim была установлена успешно"
else
    report_fail "При установке прогарммы \"vim-plug\" для управления плагинами Vim произошла ошибка"
fi

report_step "Установка прогарммы \"vim-plug\" для управления плагинами NeoVim"
if curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &> /dev/null; then
    report_success "Прогармма \"vim-plug\" для управления плагинами NeoVim была установлена успешно"
else
    report_fail "При установке прогарммы \"vim-plug\" для управления плагинами NeoVim произошла ошибка"
fi

report_step "Установка Docker"
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list && \
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &> /dev/null && \
apt update &> /dev/null && \
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin &> /dev/null
if [[ $? == 0 ]]; then
    report_success "Docker был успешно установлен"
else
    report_fail "При установке docker произошла ошибка"
fi

report_step "Скачивание необходимых docker файлов"
if git clone --recurse-submodules https://github.com/cobbr/Covenant /opt/docker-software/covenant &> /dev/null; then
    report_success "Docker файл \"covenant\" был успешно загружен"
else
    report_fail "При загрузке docker файла \"covenant\" произошла ошибка"
fi

report_step "Скачивание необходимых docker образов"
for repo in \
    bcsecurity/empire:latest \
    kalilinux/kali-rolling;
do
    if docker pull $repo &> /dev/null; then
        report_success "Docker образ \"$repo\" был успешно загружен"
    else
        report_fail "При загрузке docker образа \"$repo\" произошла ошибка"
    fi
done

report_step "Построение необходимых docker образов"
if docker build -t covenant /opt/docker-software/covenant/Covenant &> /dev/null; then
    report_success "Докер образ \"covenant\" был успешно построен"
else
    report_fail "При построении docker образа \"covenant\" произошла ошибка"
fi

report_step "Создание постоянных хранилищ для docker контейнеров"
for volume in \
    empire-data \
    covenant-data;
do
    if docker volume create --name $volume &> /dev/null; then
        report_success "Постоянное хранилище \"$volume\" для docker контейнеров было успешно создано"
    else
        report_fail "При создании постоянного хранилища \"$volume\" для docker контейнеров произошла ошибка"
    fi
done

report_step "Создание удобных симлинков на постоянные хранилища docker контейнеров"
for volume in \
    empire-data \
    covenant-data;
do
    data_dir=$(docker volume inspect $volume | jq -r '.[0].Mountpoint')
    if ln -s $data_dir /opt/docker-volumes/$volume &> /dev/null; then
        report_success "Удобный симлинк на постоянное хранилище \"$volume\" для docker контейнеров было успешно создано"
    else
        report_fail "При создании удобного симлинка на постоянное хранилище \"$volume\" для docker контейнеров произошла ошибка"
    fi
done

report_step "Копирование необходимых данных в постоянное хранилище \"covenant-data\" для docker контейнеров"
if cp -r /opt/docker-software/covenant/Covenant/Data/* /opt/docker-volumes/covenant-data/ &> /dev/null; then
    report_success "Необходимые данные в постоянное хранилище \"covenant-data\" были успешно скопированы"
else
    report_fail "При копировании необходимых данных в постоянное хранилище \"covenant-data\" произошла ошибка"
fi

report_step "Создание необходимых Docker контейнеров"
if docker create --name empire -v empire-data:/data -p 443:443 -p 127.0.0.1:1337:1337 -p 127.0.0.1:5000:5000 bcsecurity/empire:latest &> /dev/null; then
    report_success "Docker контейнер \"empire\" был успешно создан"
else
    report_fail "При создании docker контейнера \"empire\" произошла ошибка"
fi
if docker create --name covenant -v covenant-data:/app/Data -p 80:80 -p 443:443 -p 127.0.0.1:7443:7443 covenant &> /dev/null; then
    report_success "Docker контейнер \"covenant\" был успешно создан"
else
    report_fail "При создании docker контейнера \"covenant\" произошла ошибка"
fi
if docker create --name kali kalilinux/kali-rolling:latest; then
    report_success "Docker контейнер \"kali\" был успешно создан"
else
    report_fail "При создании docker контейнера \"kali\" произошла ошибка"
fi

report_step "Клонирование необходимых репозиториев с GitHub"
# My Custom
git_clone https://github.com/rsherstnev/zshcompletions $HOME/.zsh-custom-completions
git_clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git_clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git_clone https://github.com/Aloxaf/fzf-tab $HOME/.oh-my-zsh/custom/plugins/fzf-tab
git_clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
# General Post Recon and Exploitation
git_clone https://github.com/peass-ng/PEASS-ng /opt/post/general/peass-ng
git_clone https://github.com/61106960/adPEAS /opt/post/general/adpeas
git_clone https://github.com/moonD4rk/HackBrowserData /opt/post/general/hack-browser-data
git_clone https://github.com/Goodies365/YandexDecrypt /opt/post/general/yandexdecrypt
git_clone https://github.com/hackerschoice/hackshell /opt/post/general/hackshell
# Linux Post Recon and Exploitation
git_clone https://github.com/rebootuser/LinEnum /opt/post/linux/linenum
git_clone https://github.com/The-Z-Labs/linux-exploit-suggester /opt/post/linux/linux-exploit-suggester
git_clone https://github.com/jondonas/linux-exploit-suggester-2 /opt/post/linux/linux-exploit-suggester-2
git_clone https://github.com/diego-treitos/linux-smart-enumeration /opt/post/linux/linux-smart-enumeration
git_clone https://github.com/sleventyeleven/linuxprivchecker /opt/post/linux/linuxprivchecker
git_clone https://github.com/redcode-labs/Bashark /opt/post/linux/bashark
git_clone https://github.com/DominicBreuker/pspy /opt/post/linux/pspy
git_clone https://github.com/liamg/traitor /opt/post/linux/traitor
# Windows Post Recon and Exploitation
git_clone https://github.com/lefayjey/linWinPwn /opt/post/windows/linwinpwn
git_clone https://github.com/rasta-mouse/Sherlock /opt/post/windows/sherlock
git_clone https://github.com/rasta-mouse/Watson /opt/post/windows/watson
git_clone https://github.com/BC-SECURITY/Moriarty /opt/post/windows/moriarty
git_clone https://github.com/GhostPack/Seatbelt /opt/post/windows/seatbelt
git_clone https://github.com/sensepost/goLAPS/ /opt/post/windows/golaps
git_clone https://github.com/TheManticoreProject/FindGPPPasswords /opt/post/windows/findgpppasswords
git_clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester /opt/post/windows/windows-exploit-suggester
git_clone https://github.com/itm4n/PrivescCheck /opt/post/windows/privesccheck
git_clone https://github.com/pentestmonkey/windows-privesc-check /opt/post/windows/windows-privesc-check
git_clone https://github.com/411Hall/JAWS /opt/post/windows/jaws
git_clone https://github.com/bitsadmin/wesng /opt/post/windows/wesng
git_clone https://github.com/Flangvik/SharpCollection /opt/post/windows/sharpcollection
git_clone https://github.com/AlessandroZ/LaZagne /opt/post/windows/lazagne
git_clone https://github.com/Group3r/Group3r /opt/post/windows/group3r
git_clone https://github.com/S3cur3Th1sSh1t/WinPwn /opt/post/windows/winpwn
git_clone https://github.com/rootm0s/WinPwnage /opt/post/windows/winpwnage
# Docker Post Recon and Exploitation
git_clone https://github.com/stealthcopter/deepce /opt/post/docker/deepce
# Shells
git_clone https://github.com/besimorhino/powercat /opt/shells/powercat
git_clone https://github.com/antonioCoco/ConPtyShell /opt/shells/conptyshell
git_clone https://github.com/flozz/p0wny-shell /opt/shells/p0wny-shell
git_clone https://github.com/Arrexel/phpbash /opt/shells/phpbash
git_clone https://github.com/b374k/b374k /opt/shells/b374k
# Python Tools
git_clone https://github.com/t3l3machus/hoaxshell /opt/python-software/hoaxshell
git_clone https://github.com/t3l3machus/Villain /opt/python-software/villain
git_clone https://github.com/mdsecactivebreach/SharpShooter /opt/python-software/sharpshooter
git_clone https://github.com/sud0Ru/NauthNRPC /opt/python-software/nauthnrpc
# Tools
git_clone https://github.com/Adaptix-Framework/AdaptixC2 /opt/software/AdaptixC2
git_clone https://github.com/HavocFramework/Havoc /opt/software/Havoc
git_clone https://github.com/internetwache/GitTools /opt/software/gittools
git_clone https://github.com/akhomlyuk/btconverter /opt/software/btconverter
git_clone https://github.com/s0i37/crawl /opt/software/crawl
git_clone https://github.com/hugsy/gef /opt/software/gef
git_clone https://github.com/urbanadventurer/username-anarchy /opt/software/username-anarchy
# Exploits
git_clone https://github.com/cybrly/badsuccessor /opt/exploits/badsuccessor
git_clone https://github.com/topotam/PetitPotam /opt/exploits/petitpotam
git_clone https://github.com/worawit/MS17-010 /opt/exploits/ms17-010
git_clone https://github.com/risksense/zerologon /opt/exploits/zerologon
git_clone https://github.com/p0dalirius/Coercer /opt/exploits/coercer
git_clone https://github.com/cube0x0/CVE-2021-1675 /opt/exploits/printnightmare
# Docker
git_clone https://github.com/SabyasachiRana/WebMap /opt/docker-software/webmap
# Docker Compose
git_clone https://github.com/its-a-feature/Mythic /opt/docker-compose/mythic

report_step "Установка Bloodhound"
if wget -q https://ghst.ly/getbhce -O /opt/docker-compose/bloodhound-ce.yml && docker compose -f /opt/docker-compose/bloodhound-ce.yml -p bloodhound-ce up --no-start; then
    report_success "Bloodhound был успешно установлен"
else
    report_fail "При установке Bloodhound произошла ошибка"
fi

report_step "Генерация и скачивание необходимых файлов zsh completions"
if gobuster completion zsh > $HOME/.zsh-custom-completions/_gobuster; then
    report_success "Файл с дополнениями для утилиты \"gobuster\" был успешно сгенерирован по адресу \"$HOME/.zsh-custom-completions/_gobuster\""
else
    report_fail "При генерации файла с дополнениями для утилиты \"gobuster\" по адресу \"$HOME/.zsh-custom-completions/_gobuster\" произошла ошибка"
fi
file_download https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker $HOME/.zsh-custom-completions/_docker
file_download https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/pip/_pip $HOME/.zsh-custom-completions/_pip

report_step "Установка текстового редактора VS Code"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg &> /dev/null
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
apt update &> /dev/null
if apt install -y code &> /dev/null; then
    report_success "Утилита VSCode была успешно установлена в систему"
else
    report_fail "При установке утилиты VSCode произошла ошибка"
fi

report_step "Установка текстового редактора Zed"
if curl -fs https://zed.dev/install.sh | sh &> /dev/null; then
    report_success "Zed был успешно установлен"
else
    report_fail "При установке Zed произошла ошибка"
fi

report_step "Установка Pwndbg"
if curl -qsL 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb &> /dev/null; then
    report_success "PwnDbg был успешно установлен"
else
    report_fail "При установке PwnDbg произошла ошибка"
fi

report_step "Установка GEF"
if echo 'source /opt/software/gef/gef.py' > /opt/software/gef/.gdbinit; then
    report_success "GEF был успешно установлен"
else
    report_fail "При установке GEF произошла ошибка"
fi

echo "" >> $HOME/.zprofile
echo 'source "$HOME/.cargo/env"' >> $HOME/.zprofile
echo 'export "GOPATH=$HOME/go"' >> $HOME/.zprofile
echo 'export "PATH=$PATH:$GOPATH/bin"' >> $HOME/.zprofile

report_step "
Установить вручную:
- Yandex Browser (https://browser.yandex.ru/)
- DrawIo (https://github.com/jgraph/drawio-desktop/releases)
- Bruno (https://github.com/usebruno/bruno)
- NotepadNext (https://github.com/dail8859/NotepadNext/releases)
- OpenIDE (https://openide.ru/download/)
- Detect It Easy (https://github.com/horsicq/DIE-engine/releases)
- Adalanche (https://github.com/lkarlslund/Adalanche/releases)
- PingCastle (https://www.pingcastle.com/download)
- Remote Desktop Manager (https://devolutions.net/remote-desktop-manager/downloadfree)"