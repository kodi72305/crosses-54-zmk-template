#include <zephyr/sys/util.h>

#if !IS_ENABLED(CONFIG_ZMK_ADAPTIVE_FEEDBACK)

__attribute__((weak)) void zaf_error_trigger(int id)
{
    ARG_UNUSED(id);
}

__attribute__((weak)) void zaf_error_clear(int id)
{
    ARG_UNUSED(id);
}

#endif /* !CONFIG_ZMK_ADAPTIVE_FEEDBACK */
