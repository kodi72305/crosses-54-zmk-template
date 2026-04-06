# crosses-54-zmk-template

### Default Firmware Keymap
![Keymap](keymap-drawer/crosses.svg)

## Trackball Modes
- **Automouse layer** - the mouse layer (layer 3) now enables itself whenever the PMW3610 sensor detects movement, so you always have access to the mouse buttons without holding a modifier.
- **Scroll mode** - while the mouse layer is active, hold the `1` key (second column) to momentarily engage the new `Scroll` layer. The firmware switches the trackball into smooth-scroll reporting until you release the key.
- **Sniper mode** - while on the mouse layer, hold the `2` key (third column) to drop into the low-CPI `Sniper` layer for high-precision cursor control.

You can adjust CPI values, scroll tick rate, and the automouse timeout inside `config/boards/shields/crosses/crosses_right.conf`. The device-tree overlay in `config/boards/shields/crosses/crosses_right.overlay` wires the new layers (3 automouse, 4 scroll, 5 sniper) into the PMW3610 driver.

