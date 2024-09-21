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

function set_xfce4-terminal_setting {
    if xfconf-query -c xfce4-terminal -p "/$1" -t $2 -s "$3" &> /dev/null || xfconf-query -c xfce4-terminal -n -p "/$1" -t $2 -s "$3" &> /dev/null; then
        report_success "Настройка xfce4-terminal \"$1\" была успешно задана в значение \"$3\""
    else
        report_fail "При задании значения \"$3\" настройке xfce4-terminal \"$1\" произошла ошибка"
    fi
}

function set_custom_setting {
    if xfconf-query -c $1 -p "$2" -t $3 -s "$4" &> /dev/null || xfconf-query -c $1 -n -p "$2" -t $3 -s "$4" &> /dev/null; then
        report_success "В канале \"$1\" настройка \"$2\" была успешно выставлена в значение \"$3\""
    else
        report_fail "При выставлении в канале \"$1\" настройки \"$2\" в значение \"$3\" произошла ошибка"
    fi
}

function set_xfce4_setting {
    if gsettings set $1 $2 "$3" &> /dev/null; then
        report_success "Для схемы \"$1\" ключ \"$2\" со значением \"$3\" был успешно задан"
    else
        report_fail "При задании для схемы \"$1\" ключа \"$2\" со значением \"$3\" произошла ошибка"
    fi
}

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

report_step "Задание необходимых настроек xfce4-terminal"
set_xfce4-terminal_setting background-darkness double 0.950000
set_xfce4-terminal_setting background-mode string "TERMINAL_BACKGROUND_TRANSPARENT"
set_xfce4-terminal_setting color-background string "#282A36"
set_xfce4-terminal_setting color-background-vary bool false
set_xfce4-terminal_setting color-bold-is-bright bool true
set_xfce4-terminal_setting color-bold-use-default bool true
set_xfce4-terminal_setting color-cursor string "#F8F8F2"
set_xfce4-terminal_setting color-cursor-use-default bool true
set_xfce4-terminal_setting color-foreground string "#F8F8F2"
set_xfce4-terminal_setting color-palette string "#21222C;#FF5555;#50FA7B;#F1FA8C;#BD93F9;#FF79C6;#8BE9FD;#F8F8F2;#6272A4;#FF6E6E;#69FF94;#FFFFA5;#D6ACFF;#FF92DF;#A4FFFF;#FFFFFF"
set_xfce4-terminal_setting color-selection-use-default bool true
set_xfce4-terminal_setting color-use-theme bool false
set_xfce4-terminal_setting font-name string "CaskaydiaMono Nerd Font Mono 11"
set_xfce4-terminal_setting font-use-system bool false
set_xfce4-terminal_setting misc-confirm-close bool false
set_xfce4-terminal_setting misc-copy-on-select bool true
set_xfce4-terminal_setting misc-cursor-blinks bool true
set_xfce4-terminal_setting misc-default-geometry string "160x42"
set_xfce4-terminal_setting misc-right-click-action string "TERMINAL_RIGHT_CLICK_ACTION_PASTE_CLIPBOARD"
set_xfce4-terminal_setting misc-show-unsafe-paste-dialog bool false
set_xfce4-terminal_setting scrolling-on-output bool true
set_xfce4-terminal_setting scrolling-unlimited bool true
set_xfce4-terminal_setting shortcuts-no-menukey bool true
set_xfce4-terminal_setting tab-activity-color string "#aa0000"
set_xfce4-terminal_setting title-initial string "Hack them all"
set_xfce4-terminal_setting title-mode string "TERMINAL_TITLE_HIDE"

report_step "Задание необходимых настроек XFCE4 окружения"
set_custom_setting xfce4-power-manager /xfce4-power-manager/dpms-on-ac-off int 0