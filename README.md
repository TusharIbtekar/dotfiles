# Dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/) for easy symlink management.

## Prerequisites

```bash
# macOS
brew install stow

# Linux
sudo apt install stow      # Debian/Ubuntu
```

## Quick Start

```bash
cd ~/dotfiles
stow -t ~ <package>  # e.g., stow -t ~ zsh
```

## Managing Packages
From the dotfiles directory:

### Install (symlink) a package
```bash
stow -t ~ <package>
```

### Remove (unlink) a package
```bash
stow -D -t ~ <package>
```

### Re-symlink (after updates)
```bash
stow -R -t ~ <package>
```

### Install all packages
```bash
stow -t ~ */
```

## Adding New Configurations

1. Create package directory: `mkdir -p <package>/.config/<app>`
2. Add config files following the home directory structure
3. Symlink with `stow -t ~ <package>`

**How it works:**
Stow creates symlinks by mirroring the directory structure from the package to the target directory (`~`). Files inside each package are structured as if the package directory itself is your home directory.

**Example structure:**
```
dotfiles/
├── zsh/
│   └── .zshrc              → symlinks to ~/.zshrc
└── btop/
    └── .config/
        └── btop/
            └── btop.conf   → symlinks to ~/.config/btop/btop.conf
```

## Setup

* Setup ssh key ⇒ `ssh-keygen -t rsa`

---

![image](https://user-images.githubusercontent.com/61447870/167311343-6dd521d4-7a45-42bd-8140-e2f29b0798a5.png)
