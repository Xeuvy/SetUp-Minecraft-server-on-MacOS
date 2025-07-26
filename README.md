# 🍎 macOS Minecraft Server Setup

A simple script to set up a **PaperMC** Minecraft server on macOS with minimal configuration.

## ✨ Features

- **One-command installation** for PaperMC server (supports 1.16.5 - 1.21.8)
- Automatic **Java installation & configuration** (or use your existing Java)
- Customizable **server folder name** (changeable anytime without breaking functionality)
- Includes **start/restart scripts** for easy management

## 🛠️ How It Works

The script:
1. Creates a server folder on your Desktop (name it during setup)
2. Downloads and configures:
   - Selected PaperMC version
   - Optimal Java runtime (if needed)
3. Generates two management scripts:
   - `StartServer.sh` - Launch your server
   - `RestartServer.sh` - Quick restart *(currently experimental)*

## 📦 Requirements
- macOS (Intel/Apple Silicon)
- Basic terminal knowledge
- ~2GB free disk space

> Note: The restart script is still being improved - manual restart may work better currently.
