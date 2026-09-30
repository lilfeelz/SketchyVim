#include "workspace.h"
#include "buffer.h"
#include "event_tap.h"

static void set_front_app(NSRunningApplication* app);
static void window_detector_focus_changed(pid_t pid);

void workspace_begin(void **context) {
    workspace_context *ws_context = [workspace_context alloc];
    *context = ws_context;

    [ws_context init];

    window_detector_begin();
}

@implementation workspace_context
- (id)init {
    if ((self = [super init])) {
        [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                selector:@selector(appSwitched:)
                name:NSWorkspaceDidActivateApplicationNotification
                object:nil];

        window_detector_set_callback(window_detector_focus_changed);
    }

    return self;
}

- (void)dealloc {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)appSwitched:(NSNotification *)notification {
    NSRunningApplication* app = nil;
    if (notification && notification.userInfo)
      app = [notification.userInfo objectForKey:NSWorkspaceApplicationKey];
    set_front_app(app);
}

@end

static void set_front_app(NSRunningApplication* app) {
    char* name = app ? (char*)[[app localizedName] UTF8String] : NULL;
    char* bundle_id = app ? (char*)[[app bundleIdentifier] UTF8String] : NULL;

    __atomic_store_n(&g_event_tap.front_app_ignored,
                     event_tap_check_blacklist(&g_event_tap, name, bundle_id),
                     __ATOMIC_RELEASE);
    ax_front_app_changed(&g_ax, app ? app.processIdentifier : 0);
}

static void window_detector_focus_changed(pid_t pid) {
    set_front_app([NSRunningApplication runningApplicationWithProcessIdentifier:pid]);
}


void workspace_end(void **context) {
    if (context && *context) {
        workspace_context *ws_context = (workspace_context *)*context;
        [ws_context dealloc];
        *context = NULL;
    }

    window_detector_end();
}
