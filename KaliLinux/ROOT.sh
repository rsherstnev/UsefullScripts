#!/usr/bin/env bash

_GREEN_COLOR=$(printf '\033[1;32m')
_YELLOW_COLOR=$(printf '\033[1;33m')
_RED_COLOR=$(printf '\033[1;31m')
_BLUE_COLOR=$(printf '\033[1;34m')
_COLOR_RESET=$(printf '\033[0m')

report_step() {
    echo
    echo "${_BLUE_COLOR}[STEP]${_COLOR_RESET} $1..."
}

report_success() {
    echo "${_GREEN_COLOR}[SUCCESS]${_COLOR_RESET} $1."
}

report_warning() {
    echo "${_YELLOW_COLOR}[WARNING]${_COLOR_RESET} $1!"
}

report_fail() {
    echo "${_RED_COLOR}[FAIL]${_COLOR_RESET} $1!"
}

if [[ $EUID != 0 ]]; then
    report_warning "Данный скрипт должен быть запущен от имени root"
    exit 1
fi

file_download() {
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

tools_install() {
    local software_list=("$@")
    for software in ${software_list[@]}; do
        if apt install -y $software &> /dev/null; then
            report_success "Утилита \"$software\" была успешно установлена в систему"
        else
            report_fail "При установке утилиты \"$software\" произошла ошибка"
        fi
    done
}

git_clone() {
    if git clone $1 $2 &> /dev/null; then
        report_success "Репозиторий \"$1\" был успешно склонирован в директорию $2"
    else
        report_fail "При клонировании репозитория \"$1\" в директорию $2 произошла ошибка"
    fi
}

uv_install() {
    if uv tool install $1 &> /dev/null; then
        report_success "Утилита \"$1\" была успешно установлена"
    else
        report_fail "При установке утилиты \"$1\" произошла ошибка"
    fi
}

uv_github_install() {
    if uv tool install git+https://github.com/$1.git &> /dev/null; then
        report_success "Утилита \"$1\" была успешно установлена"
    else
        report_fail "При установке утилиты \"$1\" произошла ошибка"
    fi
}

touch $HOME/.hushlogin

directories_creating(){
    report_step "Создание необходимых директорий"

    for directory in \
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
}

russian_language_installing(){
    report_step "Установка русского языка в систему"

    if sed '/ru_RU.UTF-8 UTF-8/s/^# //' -i /etc/locale.gen && locale-gen &> /dev/null && update-locale LANG=ru_RU.UTF-8; then
        report_success "Русский язык был успешно установлен в систему"
    else
        report_fail "При установке русского языка в систему произошла ошибка"
    fi
}

system_updating(){
    report_step "Обновление системы"

    export DEBIAN_FRONTEND=noninteractive

    if apt update &> /dev/null && apt full-upgrade -y &> /dev/null; then
        report_success "Система была успешно обновлена"
    else
        report_fail "При обновлении системы произошла ошибка"
    fi
}

timezone_setting(){
    report_step "Задание необходимой временной зоны"

    if timedatectl set-timezone Asia/Krasnoyarsk &> /dev/null; then
        report_success "Временная зона \"Красноярск\" была успешно задана"
    else
        report_fail "При установке временной зоны \"Красноярск\" произошла ошибка"
    fi
}

usual_software_installing(){
    report_step "Установка необходимого для работы софта"

    software_list=(
        apt-file
        vim
        neovim
        less
        curl
        wget
        bash-completion
        zsh
        git
        python3-pip
        tmux
        fzf
        htop
        btop
        lnav
        tailspin
        openvpn
        wireguard
        resolvconf
        iptables
        tree
        mc
        rlwrap
        alacritty
        tcpdump
        tshark
        wireshark
        man-db
        gedit
        tig
        alacarte
        mawk
        sed
        ncdu
        du-dust
        pv
        gpg
        ripgrep
        jq
        bat
        gzip
        unrar
        p7zip-full
        rsync
        ffmpeg
        firefox-esr
        rofi
        meld
        filezilla
        viewnior
        flameshot
        cherrytree
        keepassxc-full
        traceroute
        remmina
        findutils
        locate
        smbclient
        dbeaver
        eza
        peco
        fd-find
        gdb
        breeze-cursor-theme
        arc-theme
        gparted
        golang-go
        thunderbird
        evolution
        powershell
        zoxide
        git-delta
        asciinema
        gping
        broot
        libcurl4-openssl-dev
        build-essential
        libssl-dev
        redis-tools
        sqlitebrowser
        krusader
        tigervnc-viewer
        fastfetch
        neomutt
        grub-customizer
        conky-all
        conky-manager
        gvfs
        gvfs-backends
        gvfs-common
        gvfs-daemons
        gvfs-fuse
        gvfs-libs
        thunar-volman
        obs-studio
        xclip
        gitg
        libreoffice
        libguestfs-tools
        qemu-utils
        dotnet-sdk-6.0
        engrampa
        shellcheck
        libimage-exiftool-perl
        snmp-mibs-downloader
        lftp
        lft
        whois
        bind9-dnsutils
    )

    tools_install "${software_list[@]}"

    report_step "Установка утилиты \"Doggo\""

    if curl -sS https://raw.githubusercontent.com/mr-karan/doggo/main/install.sh | sh &> /dev/null; then
        report_success "Go утилита \"Doggo\" была успешно установлена"
    else
        report_fail "При установке go утилиты \"Doggo\" возникли проблемы"
    fi

    report_step "Установка текстового редактора VS Code"

    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg &> /dev/null
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
    apt update &> /dev/null
    if apt install -y code &> /dev/null; then
        report_success "Утилита VSCode была успешно установлена в систему"
    else
        report_fail "При установке утилиты VSCode произошла ошибка"
    fi
}

pentest_software_installing(){
    report_step "Установка необходимого для тестирования на проникновение софта"

    software_list=(
        nmap
        zenmap
        sqlmap
        burpsuite
        caido
        caido-cli
        pyinstaller
        netexec
        commix
        httpie
        smbmap
        enum4linux-ng
        dnsrecon
        mycli
        theharvester
        donut
        pgcli
        bloodyad
        litecli
        arjun
        above
        wafw00f
        atuin
        sd
        procs
        tealdeer
        trippy
        certipy-ad
        ldeep
        dnstwist
        hoaxshell
        villain
        sharpshooter
        phpsploit
        havoc
        crawl
        gef
        lazygit
        duf
        coercer
        wapiti
        mitmproxy
        evil-winrm-py
        sshuttle
        sslyze
        ncat
        gowitness
        wpprobe
        goshs
        tinja
        impacket-scripts
        smtp-user-enum
        exploitdb
        metasploit-framework
        responder
        bettercap
        bettercap-caplets
        bettercap-ui
        freerdp3-x11
        freerdp3-shadow-x11
        chisel
        proxychains4
        ffuf
        fping
        arp-scan
        netdiscover
        mtr
        dsniff
        socat
        mimikatz
        wpscan
        powersploit
        nishang
        seclists
        webshells
        gobuster
        hydra
        evil-winrm
        cutycapt
        cewl
        hashcat
        hashcat-utils
        john
        maskprocessor
        crunch
        urlcrazy
        whatweb
        mdbtools
        pst-utils
        cadaver
        hexedit
        radare2
        checksec
        ltrace
        strace
        feroxbuster
        patator
        ligolo-ng
        ligolo-mp
        detect-it-easy
        macchanger
        arping
        snmp
        onesixtyone
        jxplorer
        nbtscan
        weevely
        wordlists
        subfinder
        swaks
        sliver
        trivy
        windows-binaries
        sbd
        rizin
        rizin-cutter
        ghidra
        edb-debugger
        jd-gui
        gitleaks
        trufflehog
        davtest
        nikto
        peass
        gpp-decrypt
        python3-pyftpdlib
        nuclei
    )

    tools_install "${software_list[@]}"

    report_step "Установка Pwndbg"

    if curl -qsL 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb &> /dev/null; then
        report_success "PwnDbg был успешно установлен"
    else
        report_fail "При установке PwnDbg произошла ошибка"
    fi
}

docker_installing(){
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
}

user_adding_to_docker_group(){
    report_step "Добавление обычного пользователя в группу для его работы с Docker без sudo прав"

    read -p "Введите логин добавляемого пользователя: " _USER

    if gpasswd -a "${_USER}" docker; then
        report_success "Пользователь \"$_USER\" был успешно добавлен в группу \"docker\""
    else
        report_fail "При добавлении пользователя \"$_USER\" в группу \"docker\" произошла ошибка"
    fi
}

show_tips(){
    report_step "
    Перезагрузите ПК перед запуском скрипта USER.sh для применения новых полномочий из группы docker

    Установить вручную:
    - DrawIo (https://github.com/jgraph/drawio-desktop/releases)
    - Bruno (https://github.com/usebruno/bruno)
    - NotepadNext (https://github.com/dail8859/NotepadNext/releases)
    - OpenIDE (https://openide.ru/download/)
    - Adalanche (https://github.com/lkarlslund/Adalanche/releases)
    - PingCastle (https://www.pingcastle.com/download)
    "
}

main(){
    directories_creating
    russian_language_installing
    system_updating
    timezone_setting
    usual_software_installing
    pentest_software_installing
    docker_installing
    user_adding_to_docker_group
    show_tips
}

main