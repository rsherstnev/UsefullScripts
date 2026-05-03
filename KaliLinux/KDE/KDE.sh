#!/usr/bin/env bash

set -euo pipefail

KWINRC="${HOME}/.config/kwinrc"
KGLOBAL="${HOME}/.config/kglobalshortcutsrc"

backup() {
  local f="$1"
  if [[ -f "$f" ]]; then
    cp -a "$f" "${f}.bak.$(date +%Y%m%d-%H%M%S)"
  fi
}

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Не найдено: $1" >&2
    exit 1
  }
}

need kwriteconfig6
need qdbus

backup "$KWINRC"
backup "$KGLOBAL"

# Meta only -> Application Launcher (как Win)
kwriteconfig6 --file "$KWINRC" --group ModifierOnlyShortcuts --key Meta \
  "org.kde.plasmashell,/PlasmaShell,org.kde.PlasmaShell,activateLauncherMenu"

# Meta+Tab -> Switch Windows / Overview
kwriteconfig6 --file "$KGLOBAL" --group kwin --key Overview \
  "Meta+Tab,Meta+Tab,Toggle Overview"

# Meta+Shift+Tab -> Switch Windows Reverse
kwriteconfig6 --file "$KGLOBAL" --group kwin --key Switch Window \
  "Meta+Shift+Tab,Meta+Shift+Tab,Switch Window"

# Meta+D -> Show Desktop (toggle)
kwriteconfig6 --file "$KGLOBAL" --group kwin --key Show_Desktop \
  "Meta+D,Meta+D,Show Desktop"

# Meta+E -> Dolphin
kwriteconfig6 --file "$KGLOBAL" --group org.kde.dolphin-24.desktop --key _launch \
  "Meta+E,Meta+E,_launch"

# Meta+L -> Lock Screen
kwriteconfig6 --file "$KGLOBAL" --group org.kde.ksmserver.desktop --key lock_screen \
  "Meta+L,Meta+L,lock_session"

# Meta+S -> KRunner / Search
kwriteconfig6 --file "$KGLOBAL" --group krunner --key _launch \
  "Meta+S,Meta+S,_launch"

# Meta+R -> Run Dialog (clipboard)
kwriteconfig6 --file "$KGLOBAL" --group krunner --key Run_Clipboard \
  "Meta+R,Meta+R,Run Clipboard"

# Meta+I -> System Settings
kwriteconfig6 --file "$KGLOBAL" --group org.kde.systemsettings.desktop --key _launch \
  "Meta+I,Meta+I,_launch"

# Meta+N -> Notifications
kwriteconfig6 --file "$KGLOBAL" --group org.kde.plasma.notifications.desktop --key _launch \
  "Meta+N,Meta+N,_launch"

# Meta+V -> Clipboard History (если Plasma clipboard)
kwriteconfig6 --file "$KGLOBAL" --group klipper.desktop --key show \
  "Meta+V,Meta+V,show"

# Meta+Shift+S -> Screenshot tool (Spectacle)
kwriteconfig6 --file "$KGLOBAL" --group org.kde.spectacle.desktop --key _launch \
  "Meta+Shift+S,Meta+Shift+S,_launch"

# Meta+Ctrl+D -> Task Manager (ksysguard или plasma-systemmonitor)
kwriteconfig6 --file "$KGLOBAL" --group plasma-systemmonitor.desktop --key _launch \
  "Meta+Ctrl+D,Meta+Ctrl+D,_launch"

# Meta+1..9 -> Switch Desktop
for i in {1..9}; do
  kwriteconfig6 --file "$KGLOBAL" --group kwin --key "Switch to Desktop $i" \
    "Meta+$i,Meta+$i,Switch to Desktop $i"
done

# Alt+Tab -> Window switcher (если не конфликтует)
kwriteconfig6 --file "$KGLOBAL" --group kwin --key Switch_Window_1 \
  "Alt+Tab,Alt+Tab,Switch Window 1"

# Meta+T -> Terminal (konsole)
kwriteconfig6 --file "$KGLOBAL" --group org.kde.konsole.desktop --key _launch \
  "Meta+T,Meta+T,_launch"

# Meta+W -> Overview (альтернатива)
kwriteconfig6 --file "$KGLOBAL" --group kwin --key Overview \
  "Meta+W,Meta+W,Toggle Overview"  # Добавляет вторую привязку

# Reload KWin и Plasma
qdbus org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
kquitapp6 plasmashell && kstart6 plasmashell >/dev/null 2>&1 || true


# Meta+Стрелки -> Resize/Move
kwriteconfig6 --file "$KGLOBAL" --group kwin --key "Quick Tile Window to the Left" \
  "Meta+Left,Meta+Left,Quick Tile Window to the Left"

kwriteconfig6 --file "$KGLOBAL" --group kwin --key "Quick Tile Window to the Right" \
  "Meta+Right,Meta+Right,Quick Tile Window to the Right"

kwriteconfig6 --file "$KGLOBAL" --group kwin --key "Quick Tile Window Up" \
  "Meta+Up,Meta+Up,Quick Tile Window Up"

kwriteconfig6 --file "$KGLOBAL" --group kwin --key "Quick Tile Window Down" \
  "Meta+Down,Meta+Down,Quick Tile Window Down"

# Meta+Shift+Стрелки -> Move to Next/Prev Desktop
kwriteconfig6 --file "$KGLOBAL" --group kwin --key "To Next Desktop" \
  "Meta+Shift+Right,Meta+Shift+Right,To Next Desktop"

kwriteconfig6 --file "$KGLOBAL" --group kwin --key "To Previous Desktop" \
  "Meta+Shift+Left,Meta+Shift+Left,To Previous Desktop"

# Meta+Home -> Maximize/Restore
kwriteconfig6 --file "$KGLOBAL" --group kwin --key Maximize_Window \
  "Meta+Home,Meta+Home,Maximize Window"

# Meta+Ctrl+Left/Right -> Snap to left/right (если поддерживается)
kwriteconfig6 --file "$KGLOBAL" --group kwin --key "Quick Tile Window to the Left" \
  "Meta+Ctrl+Left,Meta+Ctrl+Left,Quick Tile Window to the Left"

kwriteconfig6 --file "$KGLOBAL" --group kwin --key "Quick Tile Window to the Right" \
  "Meta+Ctrl+Right,Meta+Ctrl+Right,Quick Tile Window to the Right"

# Meta+M -> Minimize All / Show Desktop
kwriteconfig6 --file "$KGLOBAL" --group kwin --key Show_Desktop \
  "Meta+M,Meta+M,Show Desktop"

# Alt+Space -> Window Menu (KWin)
kwriteconfig6 --file "$KGLOBAL" --group kwin --key Window_Menu \
  "Alt+Space,Alt+Space,Window Menu"

# Переключение окон в текущем desktop (как Win+Tab, но точнее)
kwriteconfig6 --file "$KGLOBAL" --group kwin --key "Switch Window 1" \
  "Meta+Tab,Meta+Tab,Switch Window 1"

kwriteconfig6 --file "$KGLOBAL" --group kwin --key "Switch Window 2" \
  "Meta+Shift+Tab,Meta+Shift+Tab,Switch Window 2"

# Управление рабочими столами (Desktops)
# Meta+Ctrl+Left/Right -> Previous/Next Desktop
kwriteconfig6 --file "$KGLOBAL" --group kwin --key "Desktop Left" \
  "Meta+Ctrl+Left,Meta+Ctrl+Left,Desktop Left"

kwriteconfig6 --file "$KGLOBAL" --group kwin --key "Desktop Right" \
  "Meta+Ctrl+Right,Meta+Ctrl+Right,Desktop Right"

# Meta+PgUp/PgDn -> Switch Desktop
kwriteconfig6 --file "$KGLOBAL" --group kwin --key "Previous Desktop" \
  "Meta+PgUp,Meta+PgUp,Previous Desktop"

kwriteconfig6 --file "$KGLOBAL" --group kwin --key "Next Desktop" \
  "Meta+PgDown,Meta+PgDown,Next Desktop"

echo "✅ Окна и desktops добавлены!"

echo "✅ Полный Windows 11 preset готов!"
echo "🔄 Перелогиньтесь или перезапустите сессию для полной активации."
echo "⚠️ Проверьте конфликты в System Settings > Shortcuts."