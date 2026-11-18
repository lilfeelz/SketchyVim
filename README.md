# SketchyVim

Fork of [FelixKratz/SketchyVim](https://github.com/FelixKratz/SketchyVim) turning accessible macOS text fields into `libvim` buffers.

## Build & Install

Requires a local code-signing certificate named `svim-cert` in your keychain so macOS Accessibility permissions persist across builds:

```sh
make          # builds bin/svim and signs with svim-cert
```

Run `bin/svim` directly (or copy it onto `PATH`) and grant Accessibility access when prompted. Other targets: `make universal`, `make sign`, `make bundle`, `make clean`.

## Configuration

Files live in `~/.config/svim/` (samples in `examples/`):

- `svimrc`: vim configuration loaded on startup (comments are not supported; multikey remappings are not recognized)
- `blacklist`: one app name or bundle ID per line excluded from `svim` (terminal emulators, GUI vim)
- `svim.sh`: hook executed on mode or command-line changes with `$MODE` and `$CMDLINE` env vars

## Fork Notes

Adds SIGINT/SIGTERM cleanup, autorelease pool fixes on the window-detector thread, `svim-cert` codesigning in `makefile`, and `make check-lib`.
