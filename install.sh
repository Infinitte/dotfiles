#!/bin/bash

# Script de instalación de dotfiles usando GNU Stow

set -e

DOTFILES_DIR="$HOME/dotfiles"

echo "🔧 Instalando dotfiles..."

# Cambiar al directorio de dotfiles
cd "$DOTFILES_DIR"

# Lista de paquetes disponibles
PACKAGES=(
    "bash"
    "fish" 
    "kitty"
    "nvim"
)

# Función para instalar un paquete
install_package() {
    local package=$1
    echo "📦 Instalando $package..."
    stow -v "$package"
}

# Función para desinstalar un paquete
uninstall_package() {
    local package=$1
    echo "🗑️  Desinstalando $package..."
    stow -D -v "$package"
}

# Función para reinstalar un paquete
reinstall_package() {
    local package=$1
    echo "🔄 Reinstalando $package..."
    stow -R -v "$package"
}

# Procesar argumentos
case "${1:-install}" in
    "install")
        for package in "${PACKAGES[@]}"; do
            if [ -d "$package" ]; then
                install_package "$package"
            fi
        done
        ;;
    "uninstall")
        for package in "${PACKAGES[@]}"; do
            if [ -d "$package" ]; then
                uninstall_package "$package"
            fi
        done
        ;;
    "reinstall")
        for package in "${PACKAGES[@]}"; do
            if [ -d "$package" ]; then
                reinstall_package "$package"
            fi
        done
        ;;
    *)
        echo "Uso: $0 [install|uninstall|reinstall]"
        exit 1
        ;;
esac

echo "✅ Completado!"
