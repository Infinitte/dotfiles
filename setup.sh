#!/usr/bin/env bash

set -e

DOTFILES_DIR="$HOME/dotfiles"

# Detectar Sistema Operativo y Arquitectura
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Darwin)
        if [ "$ARCH" = "arm64" ]; then
            DETECTION="macOS (ARM / Apple Silicon)"
            OS_FOLDER="darwin"
        else
            echo "Error: Esta configuración solo soporta macOS ARM."
            exit 1
        fi
        ;;
    Linux)
        if [ "$ARCH" = "x86_64" ]; then
            DETECTION="Linux (x64 / x86_64)"
            OS_FOLDER="linux"
        else
            echo "Error: Esta configuración solo soporta Linux x64."
            exit 1
        fi
        ;;
    *)
        echo "Error: Sistema no compatible ($OS - $ARCH)"
        exit 1
        ;;
esac

echo "=========================================="
echo " Sistema detectado: $DETECTION"
echo "=========================================="
echo ""

# --- Función para verificar e instalar dependencias de sistema ---
ensure_dependencies() {
    echo "➜  Verificando herramientas básicas (git, stow)..."

    local missing_pkgs=()

    if ! command -v git &> /dev/null; then
        missing_pkgs+=("git")
    fi

    if ! command -v stow &> /dev/null; then
        missing_pkgs+=("stow")
    fi

    # Si falta git o stow, intentamos instalarlos según el sistema operativo
    if [ ${#missing_pkgs[@]} -gt 0 ]; then
        echo "   Faltan por instalar: ${missing_pkgs[*]}"
        
        if [ "$OS" = "Linux" ]; then
            if command -v apt-get &> /dev/null; then
                echo "   Instalando paquetes vía apt-get..."
                sudo apt-get update
                sudo apt-get install -y "${missing_pkgs[@]}"
            elif command -v dnf &> /dev/null; then
                echo "   Instalando paquetes vía dnf..."
                sudo dnf install -y "${missing_pkgs[@]}"
            elif command -v pacman &> /dev/null; then
                echo "   Instalando paquetes vía pacman..."
                sudo pacman -S --noconfirm "${missing_pkgs[@]}"
            else
                echo "Error: No se encontró un gestor de paquetes compatible (apt/dnf/pacman)."
                exit 1
            fi
        elif [ "$OS" = "Darwin" ]; then
            if command -v brew &> /dev/null; then
                echo "   Instalando paquetes vía Homebrew..."
                brew install "${missing_pkgs[@]}"
            else
                echo "Error: Homebrew no está instalado. Instálalo primero para continuar en macOS."
                exit 1
            fi
        fi
    else
        echo "✔  git y stow ya están instalados."
    fi

    # --- Instalación de Starship ---
    echo "➜  Verificando Starship..."
    if ! command -v starship &> /dev/null; then
        echo "   Starship no está instalado. Instalando..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        echo "✔  Starship instalado correctamente."
    else
        echo "✔  Starship ya está instalado."
    fi
    echo ""
}

# Executar verificación/instalación de herramientas
ensure_dependencies

# --- Función para aplicar configuraciones con Stow ---
stow_config() {
    local target_rel_path="$1" # Ruta relativa respecto a $HOME (ej: .zshrc)
    local config_rel_path="$2" # Ruta dentro del repo (ej: zsh/linux)
    local target_full_path="$HOME/$target_rel_path"

    # Verificar si la ruta destino ya es un enlace simbólico que apunta dentro de ~/dotfiles
    if [ -L "$target_full_path" ]; then
        # Resolver la ruta absoluta real a la que apunta el enlace simbólico
        local target_link_dest
        target_link_dest="$(readlink -f "$target_full_path" 2>/dev/null || readlink "$target_full_path")"

        # Comprobar si la ruta de destino resuelta contiene el directorio del repositorio
        if echo "$target_link_dest" | grep -q "$DOTFILES_DIR"; then
            echo "✔  [$target_rel_path] Ya está configurado con Stow."
            return 0
        fi
    fi

    echo "➜  [$target_rel_path] No está vinculado con Stow."
    read -p "   ¿Quieres aplicar la versión de dotfiles para $target_rel_path? (s/N): " choice

    case "$choice" in
        [sS][oO]|[sS])
            echo "   Aplicando configuración..."
            
            if [ -e "$target_full_path" ] || [ -L "$target_full_path" ]; then
                rm -rf "$target_full_path"
            fi

            local stow_dir="$DOTFILES_DIR/$(dirname "$config_rel_path")"
            local package="$(basename "$config_rel_path")"

            stow -d "$stow_dir" -t "$HOME" "$package"
            echo "✔  [$target_rel_path] Configuración aplicada correctamente."
            ;;
        *)
            echo "⏭  [$target_rel_path] Se omitió el cambio."
            ;;
    esac
}

install_figurine() {
    echo "➜  Verificando Figurine..."

    if command -v figurine &> /dev/null; then
        echo "✔  Figurine ya está instalado."
        return 0
    fi

    echo "   Figurine no está instalado. Buscando la última versión..."

    # Determinar el sufijo del binario según el sistema y arquitectura
    local os_type arch_type
    case "$(uname -s)" in
        Linux) os_type="linux" ;;
        Darwin) os_type="darwin" ;;
    esac

    case "$(uname -m)" in
        x86_64) arch_type="amd64" ;;
        aarch64|arm64) arch_type="arm64" ;;
    esac

    # Obtener el tag de la última versión desde GitHub (ej: v1.3.0)
    LATEST_TAG=$(curl -s https://api.github.com/repos/arsham/figurine/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$LATEST_TAG" ]; then
        echo "Error: No se pudo obtener la última versión de Figurine desde GitHub."
        return 1
    fi

    # Eliminar la 'v' inicial del tag para el nombre del archivo (ej: v1.3.0 -> 1.3.0)
    VERSION_NUM="${LATEST_TAG#v}"

    # Construir el nombre del archivo y la URL de descarga
    # Estructura: figurine_linux_amd64_v1.3.0.tar.gz
    FILE_NAME="figurine_${os_type}_${arch_type}_${LATEST_TAG}.tar.gz"
    DOWNLOAD_URL="https://github.com/arsham/figurine/releases/download/${LATEST_TAG}/${FILE_NAME}"

    echo "   Descargando Figurine ${LATEST_TAG} (${os_type}/${arch_type})..."

    # Crear directorio temporal para la descarga y extracción
    TMP_DIR=$(mktemp -d)
    
    if curl -sSL "$DOWNLOAD_URL" -o "$TMP_DIR/deploy.tar.gz"; then
        tar -xzf "$TMP_DIR/deploy.tar.gz" -C "$TMP_DIR"
        
        # Mover el binario a /usr/local/bin
        if [ -f "$TMP_DIR/deploy/figurine" ]; then
            sudo mv "$TMP_DIR/deploy/figurine" /usr/local/bin/
        elif [ -f "$TMP_DIR/figurine" ]; then
            sudo mv "$TMP_DIR/figurine" /usr/local/bin/
        fi

        sudo chmod +x /usr/local/bin/figurine
        echo "✔  Figurine ${LATEST_TAG} instalado correctamente en /usr/local/bin."
    else
        echo "Error: Falló la descarga de Figurine desde $DOWNLOAD_URL"
    fi

    # Limpiar archivos temporales
    rm -rf "$TMP_DIR"
}

install_figurine

# --- Aplicar configuraciones ---

stow_config ".zshrc" "zsh/$OS_FOLDER"

echo ""
echo "=========================================="
echo " ¡Proceso de setup finalizado!"
echo "=========================================="
