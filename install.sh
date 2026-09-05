#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/Infinitte/dotfiles.git"

# Verificar si git está instalado
if ! command -v git &> /dev/null; then
    echo "Error: git no está instalado. Por favor, instálalo primero."
    exit 1
fi

# Clonar o actualizar el repositorio
if [ -d "$DOTFILES_DIR" ]; then
    echo "El directorio $DOTFILES_DIR ya existe. Actualizando repositorio..."
    git -C "$DOTFILES_DIR" pull
else
    echo "Clonando repositorio de dotfiles en $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# Ejecutar el script post-instalación
if [ -f "$DOTFILES_DIR/setup.sh" ]; then
    chmod +x "$DOTFILES_DIR/setup.sh"
    bash "$DOTFILES_DIR/setup.sh"
else
    echo "Error: No se encontró setup.sh en $DOTFILES_DIR"
    exit 1
fi
