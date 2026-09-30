#pragma once
#include <sys/types.h>

void window_detector_begin(void);

void window_detector_end(void);

typedef void (*window_detector_callback)(pid_t pid);

void window_detector_set_callback(window_detector_callback callback);
