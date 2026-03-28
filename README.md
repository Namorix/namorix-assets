# 🎨 Namorix Brand Assets

Official logos, icons, and brand guidelines for the **Namorix** ecosystem.

## 📥 Source layout

Edit **master** SVGs by hand under **`icons/`** only (flat names, no `logo/` folder):

- **`icons/namorix-<name>.svg`** — artwork in the “box dark” style (rounded rect + glyph). Examples: `namorix-addon.svg`, `namorix-logo.svg`, `namorix-thread.svg`.

Do **not** commit generated names in `icons/`: `*-symbol-*` (those are produced under `dist/`).

## 🔧 Build

From the repo root of `namorix-assets`:

```bash
bash exif.sh
```

Outputs go to **`dist/`**:

- `namorix-<name>-symbol-dark.svg`
- `namorix-<name>-symbol-light.svg`

RDF/metadata and optional `xmllint` formatting run **only** on files under **`dist/`**; your sources in `icons/` stay untouched.

Override output root: `DIST=build bash exif.sh` (default `DIST=dist`).

## 🔗 Consumers

Apps that imported old paths such as `logo/namorix-logo-*.svg` should be updated to the built files under **`dist/`** (or your package alias that points there).

## 🎨 Brand Colors
| Purpose | Color | Hex |
| :--- | :--- | :--- |
| Primary Blue | ![#007BFF](https://via.placeholder.com/15/007BFF?text=+) | `#007BFF` |
| Deep Backbone | ![#1A1A1A](https://via.placeholder.com/15/1A1A1A?text=+) | `#1A1A1A` |

## ⚖️ License
This work is licensed under a [Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International License](https://creativecommons.org/licenses/by-nc-nd/4.0/).
