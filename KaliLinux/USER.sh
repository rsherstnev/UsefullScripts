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
        $HOME/opt/{docker-software,docker-volumes,docker-compose/{bloodhound-ce,},python-software,exploits/{potatoes,},ctf/{htb,thm,hackerlab},post/{docker,linux,windows,general},scripts,shells,software,custom-passwords};
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

home_dirs_renaming(){
    report_step "Изменение наименований стандартных директорий хомяка на кастомные"

    if sed -Ei 's/DESKTOP=.*/DESKTOP=desktop/g' $HOME/.config/user-dirs.dirs &&
        sed -Ei 's/DOWNLOAD=.*/DOWNLOAD=downloads/g' $HOME/.config/user-dirs.dirs &&
        sed -Ei 's/TEMPLATES=.*/TEMPLATES=templates/g' $HOME/.config/user-dirs.dirs &&
        sed -Ei 's/PUBLICSHARE=.*/PUBLICSHARE=public/g' $HOME/.config/user-dirs.dirs &&
        sed -Ei 's/DOCUMENTS=.*/DOCUMENTS=documents/g' $HOME/.config/user-dirs.dirs &&
        sed -Ei 's/MUSIC=.*/MUSIC=music/g' $HOME/.config/user-dirs.dirs &&
        sed -Ei 's/PICTURES=.*/PICTURES=pictures/g' $HOME/.config/user-dirs.dirs &&
        sed -Ei 's/VIDEOS=.*/VIDEOS=videos/g' $HOME/.config/user-dirs.dirs &&
        echo en_US > $HOME/.config/user-dirs.dirs; then
        report_success "Наименования стандартных директорий хомяка были успешно изменены на кастомные"
    else
        report_fail "При изменении наименований стандартных директорий хомяка на кастомные произошла ошибка"
    fi
}

oh_my_zsh_installing(){
    report_step "Установка Oh My Zsh"

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &> /dev/null

    if [[ $? == 0 ]]; then
        report_success "Oh My Zsh был успешно установлен в систему"
    else
        report_fail "При установке Oh My Zsh в систему произошла ошибка"
    fi
}

uv_installing(){
    report_step "Установка uv"

    if curl -LsSf https://astral.sh/uv/install.sh | sh &> /dev/null; then
        report_success "UV был успешно установлен"
    else
        report_fail "При установке UV произошла ошибка"
    fi

    export PATH="$PATH:/root/.local/bin/"
}

pypi_tools_installing(){
    report_step "Установка необходимых Python утилит с PyPI"

    for python_tool in \
        defaultcreds-cheat-sheet \
        git-dumper \
        argcomplete \
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

github_python_tools_installing(){
    report_step "Установка необходимых Python утилит с GitHub"

    for python_repo in \
        "sc0tfree/updog" \
        "Chocapikk/pwncat-vl" \
        "brightio/penelope" \
        "httpie/http-prompt" \
        "skelsec/pypykatz" \
        "Hackndo/lsassy" \
        "dirkjanm/BloodHound.py" \
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
        "franc-pentest/" \
        "garrettfoster13/pre2k";
    do
        if uv_github_install $python_repo &> /dev/null; then
            report_success "Python утилита из GitHub репозитория \"https://github.com/$python_repo\" была успешно установлена"
        else
            report_fail "При установке python утилиты из GitHub репозитория \"https://github.com/$python_repo\" произошла ошибка"
        fi
    done
}

ruby_tools_installing(){
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
}

go_tools_installing(){
    report_step "Установка необходимых Go утилит с GitHub"

    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin

    for go_tool in \
        "FalconOpsLLC/goexec" \
        "projectdiscovery/httpx/cmd/httpx" \
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

rust_installing(){
    report_step "Установка Rust"

    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &> /dev/null; then
        report_success "Rust был успешно установлен"
    else
        report_fail "При установке Rust произошла ошибка"
    fi

    source "$HOME/.cargo/env"
}

rust_tools_installing(){
    report_step "Установка необходимых Rust утилит с crates.io"

    for rust_tool in \
        rusthound-ce \
        navi \
        bandwhich \
        ripgrep_all \
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

docker_tools_installing(){
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
        if ln -s $data_dir $HOME/opt/docker-volumes/$volume &> /dev/null; then
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

    if docker create --name kali kalilinux/kali-rolling:latest; then
        report_success "Docker контейнер \"kali\" был успешно создан"
    else
        report_fail "При создании docker контейнера \"kali\" произошла ошибка"
    fi

    report_step "Установка Bloodhound"

    local BLOODHOUND_COMPOSE_FILE="$HOME/opt/docker-compose/bloodhound-ce/bloodhound-ce.yml"

    if wget -q https://ghst.ly/getbhce -O $BLOODHOUND_COMPOSE_FILE && docker compose -f $BLOODHOUND_COMPOSE_FILE -p bloodhound-ce up --no-start; then
        report_success "Bloodhound был успешно установлен"
    else
        report_fail "При установке Bloodhound произошла ошибка"
    fi
}

config_installing(){
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

software_installing(){
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
}

github_tools_installing(){
    report_step "Клонирование необходимых репозиториев с GitHub"

    # My Custom
    git_clone https://github.com/rsherstnev/zshcompletions $HOME/.zsh-custom-completions
    git_clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
    git_clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git_clone https://github.com/Aloxaf/fzf-tab $HOME/.oh-my-zsh/custom/plugins/fzf-tab
    git_clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

    # General Post Recon and Exploitation
    git_clone https://github.com/peass-ng/PEASS-ng $HOME/opt/post/general/peass-ng
    git_clone https://github.com/61106960/adPEAS $HOME/opt/post/general/adpeas
    git_clone https://github.com/moonD4rk/HackBrowserData $HOME/opt/post/general/hack-browser-data
    git_clone https://github.com/Goodies365/YandexDecrypt $HOME/opt/post/general/yandexdecrypt
    git_clone https://github.com/hackerschoice/hackshell $HOME/opt/post/general/hackshell

    # Linux Post Recon and Exploitation
    git_clone https://github.com/rebootuser/LinEnum $HOME/opt/post/linux/linenum
    git_clone https://github.com/The-Z-Labs/linux-exploit-suggester $HOME/opt/post/linux/linux-exploit-suggester
    git_clone https://github.com/jondonas/linux-exploit-suggester-2 $HOME/opt/post/linux/linux-exploit-suggester-2
    git_clone https://github.com/diego-treitos/linux-smart-enumeration $HOME/opt/post/linux/linux-smart-enumeration
    git_clone https://github.com/sleventyeleven/linuxprivchecker $HOME/opt/post/linux/linuxprivchecker
    git_clone https://github.com/redcode-labs/Bashark $HOME/opt/post/linux/bashark
    git_clone https://github.com/DominicBreuker/pspy $HOME/opt/post/linux/pspy
    git_clone https://github.com/liamg/traitor $HOME/opt/post/linux/traitor

    # Windows Post Recon and Exploitation
    git_clone https://github.com/lefayjey/linWinPwn $HOME/opt/post/windows/linwinpwn
    git_clone https://github.com/rasta-mouse/Sherlock $HOME/opt/post/windows/sherlock
    git_clone https://github.com/rasta-mouse/Watson $HOME/opt/post/windows/watson
    git_clone https://github.com/BC-SECURITY/Moriarty $HOME/opt/post/windows/moriarty
    git_clone https://github.com/sensepost/goLAPS/ $HOME/opt/post/windows/golaps
    git_clone https://github.com/TheManticoreProject/FindGPPPasswords $HOME/opt/post/windows/findgpppasswords
    git_clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester $HOME/opt/post/windows/windows-exploit-suggester
    git_clone https://github.com/itm4n/PrivescCheck $HOME/opt/post/windows/privesccheck
    git_clone https://github.com/411Hall/JAWS $HOME/opt/post/windows/jaws
    git_clone https://github.com/Flangvik/SharpCollection $HOME/opt/post/windows/sharpcollection
    git_clone https://github.com/Group3r/Group3r $HOME/opt/post/windows/group3r
    git_clone https://github.com/S3cur3Th1sSh1t/WinPwn $HOME/opt/post/windows/winpwn

    # Docker Post Recon and Exploitation
    git_clone https://github.com/stealthcopter/deepce $HOME/opt/post/docker/deepce

    # Shells
    git_clone https://github.com/besimorhino/powercat $HOME/opt/shells/powercat
    git_clone https://github.com/antonioCoco/ConPtyShell $HOME/opt/shells/conptyshell
    git_clone https://github.com/flozz/p0wny-shell $HOME/opt/shells/p0wny-shell
    git_clone https://github.com/Arrexel/phpbash $HOME/opt/shells/phpbash
    git_clone https://github.com/b374k/b374k $HOME/opt/shells/b374k

    # Python Tools
    git_clone https://github.com/sud0Ru/NauthNRPC $HOME/opt/python-software/nauthnrpc

    # Tools
    git_clone https://github.com/Adaptix-Framework/AdaptixC2 $HOME/opt/software/AdaptixC2
    git_clone https://github.com/internetwache/GitTools $HOME/opt/software/gittools
    git_clone https://github.com/akhomlyuk/btconverter $HOME/opt/software/btconverter
    git_clone https://github.com/urbanadventurer/username-anarchy $HOME/opt/software/username-anarchy

    # Exploits
    git_clone https://github.com/cybrly/badsuccessor $HOME/opt/exploits/badsuccessor
    git_clone https://github.com/topotam/PetitPotam $HOME/opt/exploits/petitpotam
    git_clone https://github.com/worawit/MS17-010 $HOME/opt/exploits/ms17-010
    git_clone https://github.com/risksense/zerologon $HOME/opt/exploits/zerologon
    git_clone https://github.com/p0dalirius/Coercer $HOME/opt/exploits/coercer
    git_clone https://github.com/cube0x0/CVE-2021-1675 $HOME/opt/exploits/printnightmare

    # Exploits. Картошки
    git_clone https://github.com/Re4son/Churrasco $HOME/opt/exploits/potatoes/churrasco
    git_clone https://github.com/ohpe/juicy-potato $HOME/opt/exploits/potatoes/juicy-potato
    git_clone https://github.com/S3cur3Th1sSh1t/MultiPotato $HOME/opt/exploits/potatoes/multi-potato
    git_clone https://github.com/Kevin-Robertson/Tater $HOME/opt/exploits/potatoes/tater
    git_clone https://github.com/uknowsec/SweetPotato $HOME/opt/exploits/potatoes/sweet-potato
    git_clone https://github.com/TsukiCTF/Lovely-Potato $HOME/opt/exploits/potatoes/lovely-potato
    git_clone https://github.com/breenmachine/RottenPotatoNG $HOME/opt/exploits/potatoes/rotten-potato-ng
    git_clone https://github.com/BeichenDream/BadPotato $HOME/opt/exploits/potatoes/bad-potato

    # Docker Software
    git_clone https://github.com/SabyasachiRana/WebMap $HOME/opt/docker-software/webmap

    # Docker Compose Software
    git_clone https://github.com/its-a-feature/Mythic $HOME/opt/docker-compose/mythic
}

zshcompletions_configuring(){
    report_step "Генерация и скачивание необходимых файлов zsh completions"

    file_download https://raw.githubusercontent.com/docker/cli/master/contrib/completion/zsh/_docker $HOME/.zsh-custom-completions/_docker

    file_download https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/pip/_pip $HOME/.zsh-custom-completions/_pip

    if uv generate-shell-completion zsh > $HOME/.zsh-custom-completions/_uv; then
        report_success "Файл с дополнениями для утилиты \"uv\" был успешно сгенерирован по адресу \"$HOME/.zsh-custom-completions/_uv\""
    else
        report_fail "При генерации файла с дополнениями для утилиты \"uv\" по адресу \"$HOME/.zsh-custom-completions/_uv\" произошла ошибка"
    fi
}

post_configure(){
    echo "" >> $HOME/.zprofile
    echo 'source "$HOME/.cargo/env"' >> $HOME/.zprofile
    echo 'export "GOPATH=$HOME/go"' >> $HOME/.zprofile
    echo 'export "PATH=$PATH:$GOPATH/bin"' >> $HOME/.zprofile
}

main(){
    directories_creating
    home_dirs_renaming
    oh_my_zsh_installing
    uv_installing
    pypi_tools_installing
    github_python_tools_installing
    ruby_tools_installing
    go_tools_installing
    rust_installing
    rust_tools_installing
    docker_tools_installing
    config_installing
    software_installing
    github_tools_installing
    zshcompletions_configuring
    post_configure
}

main