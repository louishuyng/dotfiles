#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <mach/mach.h>
#include <stdbool.h>
#include <time.h>

struct cpu {
  host_t host;
  mach_msg_type_number_t count;
  host_cpu_load_info_data_t load;
  host_cpu_load_info_data_t prev_load;
  bool has_prev_load;

  char command[256];
};

static inline void cpu_init(struct cpu* cpu) {
  cpu->host = mach_host_self();
  cpu->count = HOST_CPU_LOAD_INFO_COUNT;
  cpu->has_prev_load = false;
  cpu->command[0] = '\0';
}

static inline void cpu_update(struct cpu* cpu) {
  kern_return_t error = host_statistics(cpu->host,
                                        HOST_CPU_LOAD_INFO,
                                        (host_info_t)&cpu->load,
                                        &cpu->count                );

  if (error != KERN_SUCCESS) {
    cpu->command[0] = '\0';
    return;
  }

  if (cpu->has_prev_load) {
    uint32_t delta_user = cpu->load.cpu_ticks[CPU_STATE_USER]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_USER];

    uint32_t delta_system = cpu->load.cpu_ticks[CPU_STATE_SYSTEM]
                            - cpu->prev_load.cpu_ticks[CPU_STATE_SYSTEM];

    uint32_t delta_idle = cpu->load.cpu_ticks[CPU_STATE_IDLE]
                          - cpu->prev_load.cpu_ticks[CPU_STATE_IDLE];

    uint32_t total = delta_user + delta_system + delta_idle;
    double total_perc = total > 0
        ? (double)(delta_user + delta_system) / (double)total
        : 0.0;

    // Quoted value preserves the space between the Nerd Font CPU glyph and the
    // number; the helper's command splitter strips quotes but keeps spaces inside.
    snprintf(cpu->command, sizeof(cpu->command),
             "--set cpu label=\"\xef\x92\xbc %.0f%%\"",
             total_perc * 100.0);
  } else {
    cpu->command[0] = '\0';
  }

  cpu->prev_load = cpu->load;
  cpu->has_prev_load = true;
}
