#include "window_detector.h"
#include <Carbon/Carbon.h>

static CFRunLoopTimerRef timer = NULL;
static AXUIElementRef system_element = NULL;
static window_detector_callback user_callback = NULL;
static pid_t last_pid = -1;

// Polls the app owning keyboard focus. Catches focus changes that never
// emit NSWorkspaceDidActivateApplicationNotification (e.g. a second instance
// of an already active app, or windows raised without app activation).
static void tick(CFRunLoopTimerRef t, void* info) {
  (void)t; (void)info;
  CFTypeRef app = NULL;
  if (AXUIElementCopyAttributeValue(system_element,
                                    kAXFocusedApplicationAttribute,
                                    &app) != kAXErrorSuccess || !app)
    return;

  pid_t pid = 0;
  AXUIElementGetPid((AXUIElementRef)app, &pid);
  CFRelease(app);

  if (pid == last_pid) return;
  last_pid = pid;
  if (user_callback) user_callback(pid);
}

void window_detector_set_callback(window_detector_callback callback) {
  user_callback = callback;
}

void window_detector_begin(void) {
  if (timer) return;
  system_element = AXUIElementCreateSystemWide();
  timer = CFRunLoopTimerCreate(kCFAllocatorDefault,
                               CFAbsoluteTimeGetCurrent(),
                               0.5, 0, 0, tick, NULL);
  CFRunLoopAddTimer(CFRunLoopGetMain(), timer, kCFRunLoopCommonModes);
}

void window_detector_end(void) {
  if (!timer) return;
  CFRunLoopTimerInvalidate(timer);
  CFRelease(timer);
  timer = NULL;
  CFRelease(system_element);
  system_element = NULL;
}
