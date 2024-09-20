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

function to_lower {
    echo $1 | awk '{print tolower($0)}'
}

function set_command_hotkey {
    if xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/$1" -t string -s "$2" &> /dev/null || xfconf-query -c xfce4-keyboard-shortcuts -n -p "/commands/custom/$1" -t string -s "$2" &> /dev/null; then
        report_success "Горячая клавиша \"$1\" для действия \"$2\" была успешно назначена"
    else
        report_fail "При назначении горячей клавиши \"$1\" для действия \"$2\" произошла ошибка"
    fi
}

function set_xfwm4_hotkey {
    if xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/$1" -t string -s "$2" &> /dev/null || xfconf-query -c xfce4-keyboard-shortcuts -n -p "/xfwm4/custom/$1" -t string -s "$2" &> /dev/null; then
        report_success "Горячая клавиша \"$1\" для действия \"$2\" была успешно назначена"
    else
        report_fail "При назначении горячей клавиши \"$1\" для действия \"$2\" произошла ошибка"
    fi
}

function set_xfce4_setting {
    if gsettings set $1 $2 "$3" &> /dev/null; then
        report_success "Для схемы \"$1\" ключ \"$2\" со значением \"$3\" был успешно задан"
    else
        report_fail "При задании для схемы \"$1\" ключа \"$2\" со значением \"$3\" произошла ошибка"
    fi
}

function set_custom_setting {
    if xfconf-query -c $1 -p "$2" -t string -s "$3" &> /dev/null || xfconf-query -c $1 -n -p "$2" -t string -s "$3" &> /dev/null; then
        report_success "В канале \"$1\" настройка \"$2\" была успешно выставлена в значение \"$3\""
    else
        report_fail "При выставлении в канале \"$1\" настройки \"$2\" в значение \"$3\" произошла ошибка"
    fi
}

function pipx_install {
    if pipx install $1 &> /dev/null; then
        report_success "Утилита \"$1\" была успешно установлена"
    else
        report_fail "При установке утилиты \"$1\" произошла ошибка"
    fi
}

function pipx_github_install {
    if pipx install git+https://github.com/$1.git &> /dev/null; then
        report_success "Утилита \"$1\" была успешно установлена"
    else
        report_fail "При установке утилиты \"$1\" произошла ошибка"
    fi
}

function create_symlink {
    if ln -s $1 $2 &> /dev/null; then
        report_success "Cимлинк на \"$1\" был успешно создан в \"$2\""
    else
        report_fail "При создании симлинка на \"$1\" в \"$2\" произошла ошибка"
    fi
}

function make_pipenv_to_system {
    PYTHON_PIPENV_TOOL_PATH=$1
    PYTHON_PIPENV_DIR=$(dirname $1)
    PYTHON_PIPENV_TOOL=$(basename $PYTHON_PIPENV_TOOL_PATH | cut -d . -f 1)
    cd $PYTHON_PIPENV_DIR
    pipenv install &> /dev/null
    PYTHON_PIPENV_VENV_DIR=$(env PWD=$PYTHON_PIPENV_DIR pipenv --venv)
    sed -i '1d' $PYTHON_PIPENV_TOOL_PATH
    SHEBANG="#!$PYTHON_PIPENV_VENV_DIR/bin/python"
    sed -i "1i ${SHEBANG}" $PYTHON_PIPENV_TOOL_PATH
    create_symlink $PYTHON_PIPENV_TOOL_PATH $HOME/.local/bin/$(to_lower $PYTHON_PIPENV_TOOL)
    cd
    chmod +x $PYTHON_PIPENV_TOOL_PATH
}

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
    $HOME/.local/share/mc/skins \
    $HOME/.local/share/xfce4/terminal/colorschemes \
    $HOME/.zsh-custom-completions \
    /opt/{docker-software/{c2,},docker-volumes,pipenv-software,python-venvs,exploits,htb,post/{docker,linux,windows,general},scripts,shells,software/{reverse,c2,},custom_passwords};
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
if sed '/ru_RU.UTF-8 UTF-8/s/^# //' -i /etc/locale.gen && locale-gen &> /dev/null; then
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

report_step "Создание необходимых симлинков"
create_symlink $HOME/.local/share/pipx/venvs /opt/python-venvs/pipx-venvs
create_symlink $HOME/.local/share/virtualenvs /opt/python-venvs/pipenv-venvs

report_step "Установка необходимого для работы софта"
for software in \
    apt-file \
    vim \
    less \
    curl \
    wget \
    bash-completion \
    zsh \
    git \
    python3-pip \
    pipenv \
    pipx \
    tmux \
    fzf \
    neovim \
    btop \
    tailspin \
    openvpn \
    wireguard \
    tree \
    mc \
    rlwrap \
    tcpdump \
    tshark \
    wireshark \
    man-db \
    mousepad \
    tig \
    alacarte \
    mawk \
    sed \
    ncdu \
    pv \
    colordiff \
    gpg \
    zulucrypt-cli \
    zulucrypt-gui \
    zulumount-cli \
    zulumount-gui \
    whowatch \
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
    keepass2 \
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
    sqlmap \
    burpsuite \
    exploitdb \
    metasploit-framework \
    impacket-scripts \
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
    bloodhound \
    mdbtools \
    cadaver \
    hexedit \
    radare2 \
    checksec \
    ltrace \
    strace \
    feroxbuster \
    patator \
    wfuzz \
    weevely;
do
    if apt install -y $software &> /dev/null; then
        report_success "Утилита \"$software\" была успешно установлена в систему"
    else
        report_fail "При установке утилиты \"$software\" произошла ошибка"
    fi
done

report_step "Подготовка pipx к работе"
if pipx ensurepath &> /dev/null && pipx ensurepath --global &> /dev/null; then
    report_success "Pipx был успешно подготовлен к работе"
else
    report_fail "При подготовке к работе pipx возникли проблемы"
fi

# report_step "Установка необходимых Python утилит"
# for python_tool in \
#     sqlmap \
#     impacket;
# do
#     if pipx_install $python_tool &> /dev/null; then
#         report_success "Python утилита \"$python_tool\" была успешно установлена"
#     else
#         report_fail "При установке python утилиты \"$python_tool\" произошла ошибка"
#     fi
# done

report_step "Установка необходимых Python утилит с GitHub"
for python_repo in \
    "Pennyw0rth/NetExec" \
    "commixproject/commix" \
    "httpie/cli" \
    "sc0tfree/updog" \
    "ShawnDEvans/smbmap" \
    "calebstewart/pwncat" \
    "cddmp/enum4linux-ng" \
    "nvbn/thefuck" \
    "httpie/http-prompt" \
    "dbcli/mycli" \
    "dbcli/pgcli" \
    "skelsec/pypykatz" \
    "Hackndo/lsassy" \
    "s0md3v/Arjun" \
    "EnableSecurity/wafw00f" \
    "dirkjanm/BloodHound.py" \
    "elceef/dnstwist";
do
    if pipx_github_install $python_repo &> /dev/null; then
        report_success "Python утилита из GitHub репозитория \"https://github.com/$python_repo\" была успешно установлена"
    else
        report_fail "При установке python утилиты из GitHub репозитория \"https://github.com/$python_repo\" произошла ошибка"
    fi 
done

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

report_step "Установка необходимых конфигов, скриптов, тем"
# Установка личных конфигов
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/bash/.bashrc $HOME/.bashrc
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/bash/.bash_aliases $HOME/.bash_aliases
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/bash/.inputrc $HOME/.inputrc
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/zsh/.zshrc $HOME/.zshrc
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/zsh/.zsh_aliases $HOME/.zsh_aliases
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/zsh/.zprofile $HOME/.zprofile
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/vim/.vimrc $HOME/.vimrc
file_download https://raw.githubusercontent.com/cocopon/iceberg.vim/master/colors/iceberg.vim $HOME/.vim/colors/iceberg.vim
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/tmux/.tmux.conf $HOME/.tmux.conf
file_download https://raw.githubusercontent.com/dracula/midnight-commander/master/skins/dracula256.ini $HOME/.local/share/mc/skins/dracula256.ini
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/mc/ini $HOME/.config/mc/ini
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/mc/panels.ini $HOME/.config/mc/panels.ini
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/git/.gitconfig $HOME/.gitconfig
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/xfce4-terminal/terminalrc $HOME/.config/xfce4/terminal/terminalrc
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/btop/btop.conf $HOME/.config/btop/btop.conf
# Установка тем
file_download https://raw.githubusercontent.com/dracula/xfce4-terminal/master/Dracula.theme $HOME/.local/share/xfce4/terminal/colorschemes/Dracula.theme
# Установка личных скриптов
file_download https://raw.githubusercontent.com/rsherstnev/CTF/master/Scripts/searchnmapscript.py /opt/scripts/searchnmapscript.py
file_download https://raw.githubusercontent.com/rsherstnev/CTF/master/Scripts/revshellgen.py /opt/scripts/revshellgen.py
file_download https://raw.githubusercontent.com/rsherstnev/CTF/master/Scripts/base64enpacker.py /opt/scripts/base64enpacker.py
file_download https://raw.githubusercontent.com/rsherstnev/LinuxConfigs/master/tmux/vpn_ip.sh /opt/scripts/vpn_ip.sh

report_step "Копирование настроек vim в neovim"
if ln -s $HOME/.vimrc $HOME/.config/nvim/init.vim &> /dev/null; then
    report_success "Настройки vim были успешно скопированы в neovim"
else
    report_fail "При копировании настроек vim в neovim произошла ошибка"
fi

report_step "Установка Docker"
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list && \
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &> /dev/null && \
apt update &> /dev/null && \
apt install -y docker-ce docker-ce-cli containerd.io &> /dev/null
if [[ $? == 0 ]]; then
    report_success "Docker был успешно установлен"
else
    report_fail "При установке docker произошла ошибка"
fi

report_step "Скачивание необходимых docker файлов"
if git clone --recurse-submodules https://github.com/cobbr/Covenant /opt/docker-software/c2/covenant &> /dev/null; then
    report_success "Docker файл \"covenant\" был успешно загружен"
else
    report_fail "При загрузке docker файла \"covenant\" произошла ошибка"
fi

report_step "Скачивание необходимых docker образов"
for repo in \
    bcsecurity/empire:latest;
do
    if docker pull $repo &> /dev/null; then
        report_success "Docker образ \"$repo\" был успешно загружен"
    else
        report_fail "При загрузке docker образа \"$repo\" произошла ошибка"
    fi
done

report_step "Построение необходимых docker образов"
if docker build -t covenant /opt/docker-software/c2/covenant/Covenant &> /dev/null; then
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
if cp -r /opt/docker-software/c2/covenant/Covenant/Data/* /opt/docker-volumes/covenant-data/ &> /dev/null; then
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
if docker create --name covenant -v covenant-data:/app/Data covenant -p 80:80 -p 443:443 -p 127.0.0.1:7443:7443 &> /dev/null; then
    report_success "Docker контейнер \"covenant\" был успешно создан"
else
    report_fail "При создании docker контейнера \"covenant\" произошла ошибка"
fi

report_step "Клонирование необходимых репозиториев с GitHub"
git_clone https://github.com/rsherstnev/zshcompletions $HOME/.zsh-custom-completions
git_clone https://github.com/carlospolop/PEASS-ng /opt/post/general/peass-ng
git_clone https://github.com/rebootuser/LinEnum /opt/post/linux/linenum
git_clone https://github.com/The-Z-Labs/linux-exploit-suggester /opt/post/linux/linux-exploit-suggester
git_clone https://github.com/jondonas/linux-exploit-suggester-2 /opt/post/linux/linux-exploit-suggester-2
git_clone https://github.com/diego-treitos/linux-smart-enumeration /opt/post/linux/linux-smart-enumeration
git_clone https://github.com/sleventyeleven/linuxprivchecker /opt/post/linux/linuxprivchecker
git_clone https://github.com/redcode-labs/Bashark /opt/post/linux/bashark
git_clone https://github.com/DominicBreuker/pspy /opt/post/linux/pspy
git_clone https://github.com/rasta-mouse/Sherlock /opt/post/windows/sherlock
git_clone https://github.com/rasta-mouse/Watson /opt/post/windows/watson
git_clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester /opt/post/windows/windows-exploit-suggester
git_clone https://github.com/itm4n/PrivescCheck /opt/post/windows/privesccheck
git_clone https://github.com/pentestmonkey/windows-privesc-check /opt/post/windows/windows-privesc-check
git_clone https://github.com/411Hall/JAWS /opt/post/windows/jaws
git_clone https://github.com/bitsadmin/wesng /opt/post/windows/wesng
git_clone https://github.com/Flangvik/SharpCollection /opt/post/windows/sharpcollection
git_clone https://github.com/stealthcopter/deepce /opt/post/docker/deepce
git_clone https://github.com/besimorhino/powercat /opt/shells/powercat
git_clone https://github.com/antonioCoco/ConPtyShell /opt/shells/conptyshell
git_clone https://github.com/3v4Si0N/HTTP-revshell /opt/shells/http-revshell
git_clone https://github.com/flozz/p0wny-shell /opt/shells/p0wny-shell
git_clone https://github.com/Arrexel/phpbash /opt/shells/phpbash
git_clone https://github.com/b374k/b374k /opt/shells/b374k
git_clone https://github.com/pwndbg/pwndbg /opt/software/reverse/pwndbg/
git_clone https://github.com/hugsy/gef /opt/software/reverse/gef
git_clone https://github.com/cyrus-and/gdb-dashboard /opt/software/reverse/gdb-dashboard
git_clone https://github.com/ropnop/windapsearch /opt/pipenv-software/windapsearch
git_clone https://github.com/t3l3machus/Villain /opt/pipenv-software/villain
git_clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git_clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git_clone https://github.com/Aloxaf/fzf-tab $HOME/.oh-my-zsh/custom/plugins/fzf-tab

report_step "Установка pyenv"
file_download https://pyenv.run /tmp/pyenv.run
if bash /tmp/pyenv.run &> /dev/null; then
    report_success "Pyenv был успешно установлен"
else
    report_fail "При установке pyenv произошла ошибка"
fi

report_step "Задание горячих клавиш XFCE4 окружения"
set_xfwm4_hotkey "<Alt>F4" "close_window_key"
set_xfwm4_hotkey "<Super>d" "show_desktop_key"
set_xfwm4_hotkey "<Alt>Tab" "cycle_windows_key"
set_xfwm4_hotkey "<Shift><Alt>Tab" "cycle_reverse_windows_key"
set_xfwm4_hotkey "<Super>Tab" "switch_window_key"
set_xfwm4_hotkey "<Super>Up" "tile_up_key"
set_xfwm4_hotkey "<Super>KP_Home" "tile_up_left_key"
set_xfwm4_hotkey "<Super>Left" "tile_left_key"
set_xfwm4_hotkey "<Super>KP_End" "tile_down_left_key"
set_xfwm4_hotkey "<Super>Down" "tile_down_key"
set_xfwm4_hotkey "<Super>KP_Page_Down" "tile_down_right_key"
set_xfwm4_hotkey "<Super>Right" "tile_right_key"
set_xfwm4_hotkey "<Super>KP_Page_Up" "tile_up_right_key"
set_xfwm4_hotkey "<Control><Super>Left" "left_workspace_key"
set_xfwm4_hotkey "<Control><Super>Right" "right_workspace_key"
set_xfwm4_hotkey "<Control><Super>1" "workspace_1_key"
set_xfwm4_hotkey "<Control><Super>2" "workspace_2_key"
set_xfwm4_hotkey "<Control><Super>3" "workspace_3_key"
set_xfwm4_hotkey "<Control><Super>4" "workspace_4_key"
set_xfwm4_hotkey "<Control><Super>5" "workspace_5_key"
set_xfwm4_hotkey "<Control><Super>6" "workspace_6_key"
set_xfwm4_hotkey "<Control><Super>7" "workspace_7_key"
set_xfwm4_hotkey "<Control><Super>8" "workspace_8_key"
set_xfwm4_hotkey "<Control><Super>9" "workspace_9_key"
set_xfwm4_hotkey "<Control><Super><Shift>Left" "move_window_left_workspace_key"
set_xfwm4_hotkey "<Control><Super><Shift>Right" "move_window_right_workspace_key"
set_xfwm4_hotkey "<Control><Super><Shift>1" "move_window_workspace_1_key"
set_xfwm4_hotkey "<Control><Super><Shift>2" "move_window_workspace_2_key"
set_xfwm4_hotkey "<Control><Super><Shift>3" "move_window_workspace_3_key"
set_xfwm4_hotkey "<Control><Super><Shift>4" "move_window_workspace_4_key"
set_xfwm4_hotkey "<Control><Super><Shift>5" "move_window_workspace_5_key"
set_xfwm4_hotkey "<Control><Super><Shift>6" "move_window_workspace_6_key"
set_xfwm4_hotkey "<Control><Super><Shift>7" "move_window_workspace_7_key"
set_xfwm4_hotkey "<Control><Super><Shift>8" "move_window_workspace_8_key"
set_xfwm4_hotkey "<Control><Super><Shift>9" "move_window_workspace_9_key"
set_command_hotkey "<Alt>F1" "xfce4-popup-whiskermenu"
set_command_hotkey "<Alt>F2" "rofi -show run -font \"monaco 12\" -lines 20 -hide-scrollbar -scroll-method 1 -width 40 -icon-theme \"Papirus\" -show-icons"
set_command_hotkey "<Alt>F3" "xfce4-appfinder"
set_command_hotkey "<Alt>Print" "xfce4-screenshooter -w"
set_command_hotkey "<Ctrl><Alt>Delete" "xfce4-session-logout"
set_command_hotkey "<Shift>Print" "xfce4-screenshooter -r"
set_command_hotkey "<Super>e" "exo-open --launch FileManager"
set_command_hotkey "<Super>l" "xflock4"
set_command_hotkey "<Super>r" "xfce4-appfinder -c"
set_command_hotkey "<Super>Return" "xfce4-terminal --drop-down"
set_command_hotkey "<Ctrl><Alt>t" "exo-open --launch TerminalEmulator"
set_command_hotkey "Print" "xfce4-screenshooter"
set_command_hotkey "<Ctrl><Shift>Escape" "xfce4-taskmanager"

report_step "Задание необходимых настроек XFCE4 окружения"
set_xfce4_setting org.gnome.desktop.interface gtk-theme 'Mc-OS-CTLina-XFCE-Dark'
set_xfce4_setting org.gnome.desktop.interface icon-theme 'Flat-Remix-Teal-Dark'
set_xfce4_setting org.gnome.desktop.interface cursor-theme 'Breeze_Default'
set_xfce4_setting org.gnome.desktop.wm.preferences num-workspaces 4
set_custom_setting xfce4-power-manager /xfce4-power-manager/dpms-on-ac-off 0
set_custom_setting xfce4-desktop /desktop-icons/file-icons/show-filesystem false
set_custom_setting xfce4-desktop /desktop-icons/file-icons/show-home false
set_custom_setting xfce4-desktop /desktop-icons/file-icons/show-removable true
set_custom_setting xfce4-desktop /desktop-icons/file-icons/show-trash false

report_step "Генерация и скачивание необходимых файлов zsh completions"
if gobuster completion zsh > $HOME/.zsh-custom-completions/_gobuster; then
    report_success "Файл с дополнениями для утилиты \"gobuster\" был успешно сгенерирован по адресу \"$HOME/.zsh-custom-completions/_gobuster\""
else
    report_fail "При генерации файла с дополнениями для утилиты \"gobuster\" по адресу \"$HOME/.zsh-custom-completions/_gobuster\" произошла ошибка"
fi
file_download https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker $HOME/.zsh-custom-completions/_docker
file_download https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/pip/_pip $HOME/.zsh-custom-completions/_pip

report_step "Установка необходимых python утилит в виртуальные окружения"
for tool_path in \
    /opt/pipenv-software/windapsearch/windapsearch.py \
    /opt/pipenv-software/villain/Villain.py;
do
    if make_pipenv_to_system $tool_path; then
        report_success "Python утилита по адресу $tool_path успешно установлена в виртуальное окружение"
    else
        report_fail "При установке python утилиты по адресу $tool_path в виртуальное окружение произошла ошибка"
    fi
done