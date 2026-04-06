#include <zephyr/sys/util.h>
#include <zmk/adaptive_feedback.h>

#if !IS_ENABLED(CONFIG_ZMK_ADAPTIVE_FEEDBACK)

void zaf_error_trigger(int id)
{
    ARG_UNUSED(id);
}

void zaf_error_clear(int id)
{
    ARG_UNUSED(id);
}

#endif /* !CONFIG_ZMK_ADAPTIVE_FEEDBACK */
