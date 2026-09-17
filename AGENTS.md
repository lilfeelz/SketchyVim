# SketchyVim — vim bindings in macOS text fields

Fork of FelixKratz/SketchyVim. C, synchronizes an accessible macOS input field
with a real libvim buffer. Local commits are bug fixes on top of upstream.

## Commands

```sh
make            # builds bin/svim, codesigns it
make lib        # rebuilds the libvim static library, slow
make universal
make bundle
make clean
```

## Layout

`src/` the C sources, `lib/` prebuilt libvim archive, `libvim/` the vendored
upstream, `bin/` build output, `examples/` sample `svimrc`.

## Rules

- This is a fork. Keep the diff against upstream small and each change a focused
  commit, so rebasing onto upstream stays possible.
- Accessibility APIs are involved, so the binary must stay codesigned. The default
  target already signs it; an unsigned build silently loses permissions.
- `make lib` rebuilds a committed artifact. Only run it when libvim itself changes,
  and commit the result deliberately.

## Gotcha

Only `origin` is configured, pointing at the fork. There is no `upstream` remote,
so pulling FelixKratz's fixes means adding one first.
