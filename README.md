# NEIMAN Autonomous OS — Omarchy Quattro Plugin (`io.github.aomine-c2c.neiman`)

Live NEIMAN Autonomous Organization bar widget, 14-state agent monitor, inline governance approval gates, and one-click full application installer for the Omarchy Quattro shell.

## Install

```sh
omarchy plugin add https://github.com/Aomine-c2c/omarchy-neiman-plugin.git --enable
```

Or install locally from the repository:
```sh
mkdir -p ~/.config/omarchy/plugins/io.github.aomine-c2c.neiman
cp -r apps/omarchy-plugin/* ~/.config/omarchy/plugins/io.github.aomine-c2c.neiman/
omarchy plugin enable io.github.aomine-c2c.neiman
omarchy-shell shell rescanPlugins
```

## Features
- **Bar Widget**: Compact live badge (`● NEIMAN <N>A · <M>!`) showing active agent count and pending approval gates.
- **Details Panel**: Live 14-state agent roster, inline **Approve / Reject** buttons for governance gates, quick **Desktop** and **Rust TUI** launchers, and an explicit **Install / Start NEIMAN Full Application** button (`install-neiman.sh`) when offline.
- **Privilege Boundary**: Runs strictly with user permissions; never starts a second Quickshell process; full application installation only runs when explicitly clicked by the user.

## Configure

```sh
omarchy bar move io.github.aomine-c2c.neiman --section right
```

## Remove

```sh
omarchy plugin remove io.github.aomine-c2c.neiman
```
