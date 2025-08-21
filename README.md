# 🎨 alideskram-tmux Theme

A modern **tmux theme** with built-in plugins for productivity, performance monitoring, and a clean cyber look.  
Supports Linux (Debian, Ubuntu, Arch, Fedora) and macOS.

---

## ✨ Features

- 📊 **System Monitors**
  - CPU usage + temperature
  - RAM usage
  - GPU usage
  - Network speed + bandwidth
  - Uptime

- 🌍 **Environment & Productivity**
  - Current working directory
  - Git branch + status
  - Weather info
  - Pomodoro timer
  - Session + Group info
  - Ping latency

- ⏱ **Utilities**
  - Battery status
  - Clock / Date
  - Custom plugin hooks

- 🎨 **Beautiful Nerd Font Icons**
  - Designed for **3270 Nerd Font Mono**
  - Works with any Nerd Font (fallback supported)

![Screenshot](assets/image/screenshot.png)
---

## 🚀 Installation

Clone and run the installer:

```bash
git clone https://github.com/deskram/alideskram-tmux.git
cd alideskram-tmux
./install.sh
````

### What the installer does

* Copies files into:

  * `~/.tmux/alideskram-tmux`
  * `~/.tmux.conf` (backs up your existing config)
* Installs **3270 Nerd Font Mono** (optional)
* Adds **auto-start tmux on zsh** (optional)

---

## 🔠 Font Setup

For best icons, set your terminal font to:

**3270 Nerd Font Mono**

👉 If you see **boxes or question marks**, it means your terminal doesn’t use a Nerd Font.

Download from: [Nerd Fonts Releases](https://github.com/ryanoasis/nerd-fonts/releases)

---

## ⚙️ Auto-start tmux (optional)

The installer can add this snippet to your `~/.zshrc`:

```bash
if [ -z "$TMUX" ] && [ -z "$TMUX_STARTED" ]; then
  export TMUX_STARTED=1
  exec tmux new-session || exit
fi
```

This makes **tmux start by default** every time you open Termux or zsh.

---

## 🖥️ Usage

Start tmux:

```bash
tmux
```

Reload config without restarting session:

```bash
tmux source-file ~/.tmux.conf
```

---

## 📦 Supported Systems

* ✅ Linux

  * Debian / Ubuntu
  * Arch Linux
  * Fedora
* ✅ macOS

---

## ❌ Uninstall

Remove everything:

```bash
rm -rf ~/.tmux/alideskram-tmux
rm -f ~/.tmux.conf
```

If you enabled **zsh auto-start**, edit your `~/.zshrc` and remove that snippet.

---


## 🤝 Contributing

Pull requests welcome! Add new plugins under `plugins/` and update `main.sh`.
Keep code **DRY** and **well-commented**.

---

## 📜 License

MIT – free to use, modify, and share 🚀
