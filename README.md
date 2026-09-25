# SDL 3 wrapper for Nim

Based on https://github.com/transmutrix/nim-sdl3 but heavily modified to use idiomatic Nim names.

# Installation

How to install the required SDL 3 binaries.

## Linux

### Ubuntu

```
sudo apt install libsdl3-0
sudo apt install libsdl3-dev
sudo apt install libsdl3-ttf-dev
sudo apt install libsdl3-image-dev
sudo apt install libsdl3-mixer-dev
```

### Arch

```
sudo pacman -S sdl3
sudo pacman -S sdl3_ttf
sudo pacman -S sdl3_image
sudo pacman -S sdl3_mixer
```

### Fedora

```
sudo dnf install SDL3-devel
sudo dnf install SDL3_ttf-devel
sudo dnf install SDL3_image-devel
```
SDL3_mixer is not packaged in Fedora yet, compile it manually if you want to use it.

## macOS

Via brew:

```
brew install sdl3
brew install sdl3_ttf
brew install sdl3_image
brew install sdl3_mixer
```

## Other OSes

To be determined.

