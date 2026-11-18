# SketchyVim: vim bindings in macOS text fields

Fork of `FelixKratz/SketchyVim`. C and Objective-C (`.c`, `.m`), synchronizes accessible macOS text fields with `libvim`.

## Commands

```sh
make            # build bin/svim and codesign with svim-cert
make x86        # x86_64 build (bin/svim_x86); make arm64 -> bin/svim_arm64
make universal  # lipo x86_64 + arm64 -> bin/svim; make sign -> universal + codesign
make bundle     # signed universal binary + examples/ tarball
make lib        # rebuild lib/libvim.a and run check-lib (slow)
make check-lib  # verify lib/libvim.a embeds no local paths or hostname
make clean      # remove bin/
```

## Layout

- `src/`: `.c` and Objective-C `.m` sources + headers (`bin/` holds build output)
- `lib/`: prebuilt `libvim.a` + headers (`libvim/`: vendored submodule)
- `examples/`: `blacklist`, `svimrc`, `svim.sh`, `demo.mp4`

## Rules

- Keep changes small and focused so rebasing onto upstream stays possible.
- Accessibility APIs require codesigning (`svim-cert`); unsigned builds lose permissions.
- `make lib` updates committed `lib/libvim.a` and runs `check-lib`; only run when `libvim/` changes.
- Only `origin` is configured; add `upstream` before pulling from `FelixKratz/SketchyVim`.
