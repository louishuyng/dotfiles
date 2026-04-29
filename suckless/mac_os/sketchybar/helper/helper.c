#include "cpu.h"
#include "sketchybar.h"

#define UPDATE_INTERVAL_SEC 5

int main(int argc, char** argv) {
  struct cpu cpu;
  cpu_init(&cpu);

  // First call seeds prev_load; produces no command. Subsequent calls
  // compute delta CPU% over the sleep interval.
  for (;;) {
    cpu_update(&cpu);
    if (cpu.command[0]) sketchybar(cpu.command);
    sleep(UPDATE_INTERVAL_SEC);
  }
  return 0;
}
