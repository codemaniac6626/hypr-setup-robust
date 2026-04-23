# 🌌 Antigravity Hyprland Themer & Setup

A robust, modular, and aesthetically stunning theming system and configuration manager for Hyprland. 

This repository solves the ultimate rice problem: **How do you change how your desktop *looks* without breaking how it *works*?** By strictly decoupling aesthetic components (colors, wallpapers, UI styles) from functional components (keybindings, window rules, monitors, autostart), you can mix and match themes on the fly without losing your core workflow.

To top it all off, it comes with **Antigravity Themer**—a sleek, frameless, neon-pulsing GUI application built with PyWebview to manage it all.

---

## ✨ Features

- **Decoupled Architecture:** Strict separation between `aesthetic` (look and feel) and `functional` (behavior and workflow) configurations.
- **Manifest-Based Backups:** Easily define exactly which files belong to your aesthetic or functional setup using simple manifest files (`aesthetic-manifest` and `functional-manifest`).
- **One-Click Apply:** Scripts seamlessly symlink or copy your saved setups back to their proper destinations in your `~/.config` directories.
- **State Saving:** Found the perfect new color scheme? Save your current live config as a new theme right from the GUI.
- **Integrated Keybinding Viewer:** Stop searching through config files! The GUI parses your active `keybindings.conf` on the fly, providing a beautifully searchable list of your shortcuts.

---

## 📁 Repository Structure

```text
.
├── aesthetic/              # Saved aesthetic themes (e.g., iron-man-red, great-wave-minimal)
├── aesthetic-manifest      # List of file paths defining what constitutes an "aesthetic" theme
├── functional/             # Saved functional configurations (e.g., classic-sriram)
├── functional-manifest     # List of file paths defining what constitutes a "functional" theme
└── themer/                 # The Antigravity Themer GUI application
    ├── app.py              # PyWebview Python backend & logic
    ├── launch.sh           # Wrapper script to launch the GUI (useful for Hyprland window rules)
    ├── requirements.txt    # Python dependencies
    └── web/                # HTML/CSS/JS frontend for the UI
```

---

## ⚙️ How It Works: The Manifest System

The magic relies on two simple files: `aesthetic-manifest` and `functional-manifest`. These text files contain absolute paths to the configuration files on your system.

**Aesthetic Manifest typically includes:**
- Waybar styles (`style.css`, `looknfeel.jsonc`)
- Hyprland aesthetic rules (`looknfeel.conf`, `hyprpaper.conf`)
- Rofi/Wofi themes
- Kitty/Alacritty color configurations
- Dunst/Mako notification styles
- Wallpapers

**Functional Manifest typically includes:**
- Hyprland core behavior (`hyprland.conf`, `keybindings.conf`, `windows.conf`)
- Waybar functional modules (`modules.jsonc`, `config.jsonc`)
- Launch scripts and utilities

### `make-setup.sh` & `apply-setup.sh`
Inside the `aesthetic/` and `functional/` directories are worker scripts. 
- `make-setup.sh <theme-name>` reads the manifest, grabs all those files from your system, and packages them into a new folder.
- `apply-setup.sh <theme-name>` does the reverse, taking the files from the theme folder and injecting them back into your system configurations.

---

## 🖥️ The Antigravity Themer GUI

The **Antigravity Themer** is a custom pywebview application designed to look like a futuristic, glassmorphic HUD.

### Features
1. **Apply Mode:** View available Aesthetic and Functional themes side-by-side. Mix and match, then hit "EXECUTE SEQUENCE" to apply them instantly.
2. **Save Mode:** Tweak your configs manually? Go to the Save tab, enter a name, and save your current live config as a new theme in one click.
3. **Keybindings Viewer:** A searchable, live-parsed table of all your Hyprland keybindings extracted directly from your active functional theme.

### Installation & Launch

1. **Install Python Dependencies:**
   Ensure you have Python 3 installed. Then, install the required packages:
   ```bash
   pip install pywebview
   # Note: on Linux, pywebview requires PyGObject and WebKit2GTK.
   # e.g., on Arch: sudo pacman -S webkit2gtk python-gobject
   ```

2. **Launch the Themer:**
   Run the wrapper script:
   ```bash
   ./themer/launch.sh
   ```

3. **Hyprland Window Rules (Optional but Recommended):**
   The `launch.sh` wrapper script sets the window class to `antigravity-themer`. You can use this to make the app float and center in your `hyprland.conf`:
   ```hyprland
   windowrulev2 = float, class:^(antigravity-themer)$
   windowrulev2 = center, class:^(antigravity-themer)$
   windowrulev2 = size 800 600, class:^(antigravity-themer)$
   ```

---

## 🛠️ Creating Your Own Themes

1. Configure your desktop exactly how you like it.
2. Open the **Antigravity Themer**.
3. Toggle to **Save Mode**.
4. Enter a name (e.g., `cyberpunk-night`) under Aesthetic or Functional.
5. Click **Save**. The app will use the manifest to package your setup!

Enjoy a desktop that can look entirely different every day of the week, while your muscle-memory shortcuts stay exactly the same. 🚀
