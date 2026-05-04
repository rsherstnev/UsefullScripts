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
    report_warning "Данный скрипт должен быть запущен от имени ROOT"
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


directories_creating() {
    report_step "Создание необходимых директорий"

    for directory in \
        $HOME/.fonts \
        $HOME/.vim/colors \
        $HOME/.config/mc \
        $HOME/.config/nvim \
        $HOME/.config/alacritty \
        $HOME/.config/neomutt/themes \
        $HOME/.local/share/mc/skins \
        $HOME/.local/share/{themes,icons} \
        $HOME/.zsh-custom-completions \
        $HOME/.python-custom-completions \
        $HOME/opt/{docker-software,docker-volumes,docker-compose/{bloodhound-ce,},python-software,exploits/{potatoes,},ctf/{htb,thm,hackerlab},post/{docker,linux,windows,general},scripts,shells,software,custom-passwords} \
        /pictures \
        /opt/docker-volumes \
        /opt/docker-compose/{bloodhound-ce,};
    do
        if [[ ! -d $directory ]]; then
            if mkdir -p $directory &> /dev/null; then
                report_success "Директория \"$directory\" была успешно создана"
            else
                report_fail "При создании директории \"$directory\" произошла ошибка"
            fi
        else
            report_warning "Директория \"$directory\" уже существует"
        fi
    done
}


home_dirs_renaming() {
    report_step "Изменение наименований стандартных директорий хомяка на кастомные"

    if sed -Ei 's/DESKTOP=.*/DESKTOP=desktop/g' /etc/xdg/user-dirs.defaults &&
        sed -Ei 's/DOWNLOAD=.*/DOWNLOAD=downloads/g' /etc/xdg/user-dirs.defaults &&
        sed -Ei 's/TEMPLATES=.*/TEMPLATES=templates/g' /etc/xdg/user-dirs.defaults &&
        sed -Ei 's/PUBLICSHARE=.*/PUBLICSHARE=public/g' /etc/xdg/user-dirs.defaults &&
        sed -Ei 's/DOCUMENTS=.*/DOCUMENTS=documents/g' /etc/xdg/user-dirs.defaults &&
        sed -Ei 's/MUSIC=.*/MUSIC=music/g' /etc/xdg/user-dirs.defaults &&
        sed -Ei 's/PICTURES=.*/PICTURES=pictures/g' /etc/xdg/user-dirs.defaults &&
        sed -Ei 's/VIDEOS=.*/VIDEOS=videos/g' /etc/xdg/user-dirs.defaults;
    then
        report_success "Наименования стандартных директорий хомяка были успешно изменены на кастомные"
    else
        report_fail "При изменении наименований стандартных директорий хомяка на кастомные произошла ошибка"
    fi
}


russian_language_installing() {
    report_step "Установка русского языка в систему"

    if sed '/ru_RU.UTF-8 UTF-8/s/^# //' -i /etc/locale.gen && locale-gen &> /dev/null && update-locale LANG=ru_RU.UTF-8; then
        report_success "Русский язык был успешно установлен в систему"
    else
        report_fail "При установке русского языка в систему произошла ошибка"
    fi
}


system_updating() {
    report_step "Обновление системы"

    if apt update &> /dev/null && apt full-upgrade -y &> /dev/null; then
        report_success "Система была успешно обновлена"
    else
        report_fail "При обновлении системы произошла ошибка"
    fi
}


timezone_setting() {
    report_step "Задание необходимой временной зоны"

    if timedatectl set-timezone Asia/Krasnoyarsk &> /dev/null; then
        report_success "Временная зона \"Красноярск\" была успешно задана"
    else
        report_fail "При установке временной зоны \"Красноярск\" произошла ошибка"
    fi
}


usual_software_installing() {
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
        grc
        xfce4-goodies
        ripgrep-all
    )

    tools_install "${software_list[@]}"

    # Установка утилиты "Doggo"

    if curl -sS https://raw.githubusercontent.com/mr-karan/doggo/main/install.sh | sh &> /dev/null; then
        report_success "Go утилита \"Doggo\" была успешно установлена"
    else
        report_fail "При установке go утилиты \"Doggo\" возникли проблемы"
    fi

    # Установка текстового редактора VS Code

    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg &> /dev/null
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
    apt update &> /dev/null
    if apt install -y code &> /dev/null; then
        report_success "Утилита VSCode была успешно установлена в систему"
    else
        report_fail "При установке утилиты VSCode произошла ошибка"
    fi

    # Установка прогарммы "vim-plug" для управления плагинами Vim

    if curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &> /dev/null; then
        report_success "Прогармма \"vim-plug\" для управления плагинами Vim была установлена успешно"
    else
        report_fail "При установке прогарммы \"vim-plug\" для управления плагинами Vim произошла ошибка"
    fi

    # Установка прогарммы "vim-plug" для управления плагинами NeoVim

    if curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &> /dev/null; then
        report_success "Прогармма \"vim-plug\" для управления плагинами NeoVim была установлена успешно"
    else
        report_fail "При установке прогарммы \"vim-plug\" для управления плагинами NeoVim произошла ошибка"
    fi
}


pentest_software_installing() {
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
        exploitdb-papers
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
        python3-argcomplete
        python3-lsassy
        bloodhound-ce-python
        nuclei
        httpx-toolkit
        obsidian
    )

    tools_install "${software_list[@]}"

    report_step "Установка Pwndbg"

    if curl -qsL 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb &> /dev/null; then
        report_success "PwnDbg был успешно установлен"
    else
        report_fail "При установке PwnDbg произошла ошибка"
    fi
}


docker_installing() {
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


docker_tools_installing() {
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

    report_step "Создание постоянных хранилищ для docker контейнеров"

    for volume in \
        empire-data;
    do
        if docker volume create --name $volume &> /dev/null; then
            report_success "Постоянное хранилище \"$volume\" для docker контейнеров было успешно создано"
        else
            report_fail "При создании постоянного хранилища \"$volume\" для docker контейнеров произошла ошибка"
        fi
    done

    report_step "Создание удобных симлинков на постоянные хранилища docker контейнеров"

    for volume in \
        empire-data;
    do
        data_dir=$(docker volume inspect $volume | jq -r '.[0].Mountpoint')
        if ln -sf $data_dir /opt/docker-volumes/$volume &> /dev/null; then
            report_success "Удобный симлинк на постоянное хранилище \"$volume\" для docker контейнеров было успешно создано"
        else
            report_fail "При создании удобного симлинка на постоянное хранилище \"$volume\" для docker контейнеров произошла ошибка"
        fi
    done

    report_step "Создание необходимых Docker контейнеров"

    if docker create --name empire -v empire-data:/data -p 443:443 -p 127.0.0.1:1337:1337 -p 127.0.0.1:5000:5000 bcsecurity/empire:latest &> /dev/null; then
        report_success "Docker контейнер \"empire\" был успешно создан"
    else
        report_fail "При создании docker контейнера \"empire\" произошла ошибка"
    fi

    if docker create --name kali kalilinux/kali-rolling:latest &> /dev/null; then
        report_success "Docker контейнер \"kali\" был успешно создан"
    else
        report_fail "При создании docker контейнера \"kali\" произошла ошибка"
    fi

    report_step "Установка Bloodhound"

    local BLOODHOUND_COMPOSE_FILE="/opt/docker-compose/bloodhound-ce/bloodhound-ce.yml"

    if wget -q https://ghst.ly/getbhce -O $BLOODHOUND_COMPOSE_FILE && docker compose -f $BLOODHOUND_COMPOSE_FILE -p bloodhound-ce up --no-start &> /dev/null; then
        report_success "Bloodhound был успешно установлен"
    else
        report_fail "При установке Bloodhound произошла ошибка"
    fi
}


oh_my_zsh_installing() {
    report_step "Установка Oh My Zsh"

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &> /dev/null

    if [[ $? == 0 ]]; then
        report_success "Oh My Zsh был успешно установлен в систему"
    else
        report_fail "При установке Oh My Zsh в систему произошла ошибка"
    fi
}


uv_installing() {
    report_step "Установка uv"

    if curl -LsSf https://astral.sh/uv/install.sh | sh &> /dev/null; then
        report_success "UV был успешно установлен"
    else
        report_fail "При установке UV произошла ошибка"
    fi

    export PATH="$PATH:/root/.local/bin/"
}


pypi_tools_installing() {
    report_step "Установка необходимых Python утилит с PyPI"

    for python_tool in \
        defaultcreds-cheat-sheet \
        git-dumper \
        magika \
        ptftpd \
        flare-floss;
    do
        if uv_install $python_tool &> /dev/null; then
            report_success "Python утилита \"$python_tool\" была успешно установлена"
        else
            report_fail "При установке python утилиты \"$python_tool\" произошла ошибка"
        fi
    done

    if uv_install --with chardet wesng &> /dev/null; then
        report_success "Python утилита \"wes-ng\" была успешно установлена"
    else
        report_fail "При установке python утилиты \"wes-ng\" произошла ошибка"
    fi
}


github_python_tools_installing() {
    report_step "Установка необходимых Python утилит с GitHub"

    for python_repo in \
        "sc0tfree/updog" \
        "Chocapikk/pwncat-vl" \
        "brightio/penelope" \
        "httpie/http-prompt" \
        "skelsec/pypykatz" \
        "dirkjanm/adidnsdump" \
        "blacklanternsecurity/MANSPIDER" \
        "login-securite/DonPAPI" \
        "PShlyundin/ldap_shell" \
        "yaap7/ldapsearch-ad" \
        "aniqfakhrul/powerview.py" \
        "isd-project/isd" \
        "cogiceo/GPOHound" \
        "Hackndo/pyGPOAbuse" \
        "garrettfoster13/sccmhunter" \
        "garrettfoster13/pre2k";
    do
        if uv_github_install $python_repo &> /dev/null; then
            report_success "Python утилита из GitHub репозитория \"https://github.com/$python_repo\" была успешно установлена"
        else
            report_fail "При установке python утилиты из GitHub репозитория \"https://github.com/$python_repo\" произошла ошибка"
        fi
    done
}


go_tools_installing() {
    report_step "Установка необходимых Go утилит с GitHub"

    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin

    for go_tool in \
        "FalconOpsLLC/goexec" \
        "jesseduffield/lazydocker" \
        "asdf-vm/asdf/cmd/asdf" \
        "ropnop/kerbrute" \
        "xm1k3/cent" \
        "Macmod/godap" \
        "jfjallid/go-secdump" \
        "ropnop/go-windapsearch/cmd/windapsearch" \
        "projectdiscovery/katana/cmd/katana" \
        "rverton/webanalyze/cmd/webanalyze";
    do
        if go install github.com/$go_tool@latest &> /dev/null; then
            report_success "Go утилита \"$go_tool\" была успешно установлена"
        else
            report_fail "При установке go утилиты \"$go_tool\" возникли проблемы"
        fi
    done
}


rust_installing() {
    report_step "Установка Rust"

    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &> /dev/null; then
        report_success "Rust был успешно установлен"
    else
        report_fail "При установке Rust произошла ошибка"
    fi

    source "$HOME/.cargo/env"
}


rust_tools_installing() {
    report_step "Установка необходимых Rust утилит с crates.io"

    for rust_tool in \
        rusthound-ce \
        navi \
        bandwhich \
        htmlq \
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
}


config_installing() {
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
    file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/tmux/.tmux.conf $HOME/.tmux.conf
    file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/mc/user/ini $HOME/.config/mc/ini
    file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/mc/user/panels.ini $HOME/.config/mc/panels.ini
    file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/git/.gitconfig $HOME/.gitconfig
    file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/refs/heads/master/conky/.conkyrc $HOME/.conkyrc
    file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/refs/heads/master/terminal/alacritty/alacritty.toml $HOME/.config/alacritty/alacritty.toml

    # Установка тем
    git_clone https://github.com/dracula/mutt $HOME/.config/neomutt/themes/dracula
    file_download https://raw.githubusercontent.com/cocopon/iceberg.vim/master/colors/iceberg.vim $HOME/.vim/colors/iceberg.vim
    file_download https://raw.githubusercontent.com/dracula/midnight-commander/master/skins/dracula256.ini $HOME/.local/share/mc/skins/dracula256.ini

    # Установка личных скриптов
    file_download https://raw.githubusercontent.com/rsherstnev/searchnmapscript/refs/heads/master/searchnmapscript.py $HOME/opt/scripts/searchnmapscript.py
    file_download https://raw.githubusercontent.com/rsherstnev/revshellgen/refs/heads/master/revshellgen.py $HOME/opt/scripts/revshellgen.py
    file_download https://raw.githubusercontent.com/rsherstnev/CTF/master/Scripts/base64enpacker.py $HOME/opt/scripts/base64enpacker.py
    file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/tmux/vpn_ip.sh $HOME/opt/scripts/vpn_ip.sh; chmod +x $HOME/opt/scripts/vpn_ip.sh
}


github_tools_installing(){
    report_step "Клонирование необходимых репозиториев с GitHub"

    # My Custom
    git_clone https://github.com/rsherstnev/zshcompletions $HOME/.zsh-custom-completions
    git_clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    git_clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git_clone https://github.com/Aloxaf/fzf-tab $HOME/.oh-my-zsh/custom/plugins/fzf-tab
    git_clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
}


show_tips() {
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


main() {
    export DEBIAN_FRONTEND=noninteractive

    directories_creating
    home_dirs_renaming
    russian_language_installing
    system_updating
    timezone_setting
    usual_software_installing
    pentest_software_installing
    docker_installing
    docker_tools_installing
    oh_my_zsh_installing
    uv_installing
    pypi_tools_installing
    github_python_tools_installing
    go_tools_installing
    rust_installing
    rust_tools_installing
    config_installing
    github_tools_installing
    show_tips

    unset DEBIAN_FRONTEND
}


main