#!/usr/bin/env bash

set -e

# Detectar Sistema Operativo
OS="$(uname -s)"
# Detectar Arquitectura
ARCH="$(uname -m)"

# Normalizar la identificación del sistema
case "$OS" in
    Darwin)
        if [ "$ARCH" = "arm64" ]; then
            DETECTION="macOS (ARM / Apple Silicon)"
        else
            DETECTION="macOS (Intel / x86_64)"
        fi
        ;;
    Linux)
        if [ "$ARCH" = "x86_64" ]; then
            DETECTION="Linux (x64 / x86_64)"
        elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
            DETECTION="Linux (ARM64)"
        else
            DETECTION="Linux ($ARCH)"
        fi
        ;;
    *)
        DETECTION="Sistema no reconocido ($OS - $ARCH)"
        ;;
esac

echo ""
echo "=========================================="
echo " Sistema detectado: $DETECTION"
echo " ¡Todo listo! Los dotfiles están en ~/dotfiles"
echo "=========================================="
echo ""
