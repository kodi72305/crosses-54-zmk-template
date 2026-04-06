# crosses-54-zmk-template

### Default Firmware Keymap
![Keymap](keymap-drawer/crosses.svg)

## Trackball Modes
- **Automouse layer** – `zip_temp_layer` watches the PMW3610 split and автоматически включает слой 3 (Mouse) на 350 мс каждый раз, когда трекбол начинает движение. Поэтому мышиные кнопки и курсор всегда доступны без отдельного хоткея.
- **Навигация (`MO(4)`)** – большой палец на основной раскладке включает слой 4 (Left Arrows): домой/End, PgUp/PgDn и стрелки слева, как у jpatrolla.
- **Scroll/Sniper (`HT_MO5`)** – второй большой палец с `&ht_mo5` даёт короткое нажатие `MO(5)` и трёхсекундный временный переключатель слоя 5. Пока слой 5 активен, работают макросы `&msc MOVE_Y(...)`, `mclk_shift`, MB5 и альтернативные клики — это и есть «scroll» и «sniper» режимы из форка jpatrolla.

Обработчики `zip_temp_layer`, `zip_ble_report_rate_limit` и `msc` берутся из модулей `zmk-input-processor-xyz` и `zmk-report-rate-limit`, которые уже присутствуют через `gggw-zmk-keebs`. Никаких полей `automouse-layer` в драйвере PMW3610 теперь не нужно — всё переключение делается через input processors и макросы в `config/crosses.keymap`.
