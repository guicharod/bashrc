#!/bin/bash
# Instala zsh + Oh My Zsh + plugins y edita ~/.zshrc (tema bira).
# Se puede correr varias veces sin romper nada.
set -e

ZSH_DIR="$HOME/.oh-my-zsh"
PLUGINS_DIR="$ZSH_DIR/custom/plugins"

# 1. Paquetes necesarios
sudo apt-get update -qq
sudo apt-get install -y zsh git curl

# 2. Oh My Zsh (solo si no esta instalado)
if [ ! -d "$ZSH_DIR" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3. Plugins externos (clona si no existen, actualiza si ya estan)
instalar_plugin() {
  local nombre="$1"
  local destino="$PLUGINS_DIR/$nombre"
  if [ -d "$destino/.git" ]; then
    git -C "$destino" pull -q
  else
    git clone -q --depth 1 "https://github.com/zsh-users/$nombre" "$destino"
  fi
}
instalar_plugin zsh-autosuggestions
instalar_plugin zsh-syntax-highlighting

# 4. Editar ~/.zshrc: tema bira, plugins y sin auto-update (guarda copia)
ZSHRC="$HOME/.zshrc"
cp "$ZSHRC" "$ZSHRC.bak"
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="bira"/' "$ZSHRC"
sed -i 's/^plugins=.*/plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"
sed -i "s/^# *zstyle ':omz:update' mode disabled.*/zstyle ':omz:update' mode disabled/" "$ZSHRC"

# 5. zsh como shell por defecto del usuario actual
ZSH_BIN="$(command -v zsh)"
if [ "$(getent passwd "$(whoami)" | cut -d: -f7)" != "$ZSH_BIN" ]; then
  sudo chsh -s "$ZSH_BIN" "$(whoami)"
fi

echo "Listo. Cerra sesion y volve a entrar."