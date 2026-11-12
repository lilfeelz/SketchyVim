#include "Carbon/Carbon.h"
#include "Cocoa/Cocoa.h"
#include "event_tap.h"
#include "ax.h"
#include "workspace.h"
#include <signal.h>
#include <dispatch/dispatch.h>

void* g_workspace;

static void cleanup_and_exit(void *context) {
  (void)context;
  event_tap_end(&g_event_tap);
  ax_end(&g_ax);
  workspace_end(&g_workspace);

  exit(0);
}

// Cleanup frees memory and calls into Cocoa, which a signal() handler must not do. A dispatch
// source runs it on the main queue (drained by CFRunLoopRun) instead; SIG_IGN only stops the
// default action, the source still sees the signal. The source is never released.
static void handle_signal(int sig) {
  signal(sig, SIG_IGN);
  dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, sig, 0,
                                                    dispatch_get_main_queue());
  dispatch_source_set_event_handler_f(source, cleanup_and_exit);
  dispatch_resume(source);
}

static void acquire_lockfile(void) {
  char *user = getenv("USER");
  if (!user) printf("Error: User variable not set.\n"), exit(1);

  char buffer[256];
  snprintf(buffer, 256, "/tmp/svim_%s.lock" , user);

  int handle = open(buffer, O_CREAT | O_WRONLY, 0600);
  if (handle == -1) {
    printf("Error: Could not create lock-file.\n");
    exit(1);
  }

  struct flock lockfd = {
    .l_start  = 0,
    .l_len    = 0,
    .l_pid    = getpid(),
    .l_type   = F_WRLCK,
    .l_whence = SEEK_SET
  };

  if (fcntl(handle, F_SETLK, &lockfd) == -1) {
    printf("Error: Could not acquire lock-file.\nsvim already running?\n");
    exit(1);
  }
}

int main (int argc, char *argv[]) {
  NSApplicationLoad();
  signal(SIGCHLD, SIG_IGN);
  signal(SIGPIPE, SIG_IGN);
  handle_signal(SIGINT);
  handle_signal(SIGTERM);

  acquire_lockfile();
  ax_begin(&g_ax);
  event_tap_begin(&g_event_tap);
  workspace_begin(&g_workspace);

  CFRunLoopRun();
  return 0;
}
