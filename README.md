# crosses-54-zmk-template

### Default Firmware Keymap
![Keymap](keymap-drawer/crosses.svg)

## Trackball / Pointer
- Automouse: `zip_temp_layer` keeps layer 8 (Mouse) active for 350 ms whenever the PMW3610 reports motion, so the mouse buttons are accessible even without holding a modifier.
- Manual scroll/sniper: the original `mouse` and `sniper` layers from your gggw-zmk-keebs config stay intact; trigger them with your existing combos or `MO()` bindings as before.
- No devicetree overlays are required for these features anymore?`config/crosses.keymap` wires the input processors directly.

## RU/EN Workflow
- Tap the left thumb combo (`lg_tog`) to send `Win+Space` and toggle layer 1 (Russian). Hold the same thumb key to reach the Navigation layer, just like in your original layout.
- `keys_ru.h` and `encoding_macros.dtsi` were copied over from your repo, so the Cyrillic base layer, symbol layers, and encoding layer behave exactly as before.
- Combos `num_lauer`, `en_sym`, and `ru_sym` were also preserved, so layer indices (0?10) match your previous build.

