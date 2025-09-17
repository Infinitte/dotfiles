# Dotfiles

Mis archivos de configuración personal gestionados con [GNU Stow](https://www.gnu.org/software/stow/).

## Estructura

```
dotfiles/
├── bash/           # Configuración de Bash
├── fish/           # Configuración de Fish shell
├── kitty/          # Configuración de Kitty terminal
├── nvim/           # Configuración de Neovim
├── install.sh      # Script de instalación
└── README.md       # Este archivo
```

## Instalación

### Prerrequisitos

- GNU Stow instalado (`brew install stow` en macOS)

### Instalación completa

```bash
git clone <tu-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Instalación selectiva

```bash
cd ~/dotfiles
stow bash    # Solo configuración de bash
stow nvim    # Solo configuración de neovim
```

## Comandos útiles

```bash
# Instalar todas las configuraciones
./install.sh install

# Desinstalar todas las configuraciones
./install.sh uninstall

# Reinstalar (útil después de cambios)
./install.sh reinstall

# Instalar paquete específico
stow <nombre-paquete>

# Desinstalar paquete específico
stow -D <nombre-paquete>

# Ver qué haría stow sin ejecutar
stow -n -v <nombre-paquete>
```

## Agregar nuevas configuraciones

1. Crear directorio para la aplicación: `mkdir nueva-app`
2. Recrear la estructura de directorios desde `$HOME`
3. Mover archivos de configuración al directorio
4. Agregar a la lista de PACKAGES en `install.sh`
5. Ejecutar `stow nueva-app`

## Notas

- Los archivos se enlazan simbólicamente desde `~/dotfiles/` a su ubicación final
- Hacer backup de configuraciones existentes antes de la primera instalación
- Usar `stow -R` para reinstalar después de cambios
