#include <platform.h>

#include "sdram_geometry_TEMPLATE.h"
#include "sdram_geometry.h"

#include "sdram_config_TEMPLATE.h"
#include "sdram_ports_TEMPLATE.h"

#include "sdram_control.h"
#include "sdram_conf_derived.h"

void sdram_init_TEMPLATE(struct sdram_ports_TEMPLATE &p) {
  /*
   * Initialise the SDRAM
   */
}

static inline void sdram_refresh_TEMPLATE(unsigned ncycles, struct sdram_ports_TEMPLATE &p) {
  /*
   * Send refresh commands to the SDRAM
   */
}

static inline void sdram_write_TEMPLATE(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports_TEMPLATE &ports) {
  /*
   * Write to the SDRAM
   */
}

static inline void sdram_read_TEMPLATE(unsigned row, unsigned col, unsigned bank,
    unsigned buffer, unsigned word_count, struct sdram_ports_TEMPLATE &ports) {
  /*
   * Read from the SDRAM
   */
}

#define CUR_IMPL TEMPLATE
#include "../sdram_server_common.inc"
