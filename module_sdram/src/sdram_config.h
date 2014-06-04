#ifndef SDRAM_CONFIG_H_
#define SDRAM_CONFIG_H_

#ifdef __sdram_conf_h_exists__
#include "sdram_conf.h" // This is from the application
#endif

/*
 * Given in the SDRAM spec is the interval, SDRAM_REFRESH_MS, during
 * which SDRAM_REFRESH_CYCLES refresh instructions must be issued.
 */
#ifndef SDRAM_REFRESH_MS
#define SDRAM_REFRESH_MS 64
#endif

#ifndef SDRAM_REFRESH_CYCLES
#define SDRAM_REFRESH_CYCLES 4096
#endif

/*
 * Define the amount of time that the SDRAM is allowed to go before the server
 * refreshes. The unit is given in refresh periods. For example, the value N
 * would mean that the SDRAM is allowed to go
 *
 *        SDRAM_REFRESH_MS/SDRAM_REFRESH_CYCLES*N milliseconds
 *
 * before refreshing. The larger the number (up to SDRAM_REFRESH_CYCLES) the
 * smaller the constant time impact but the larger the overall impact. If set
 * above SDRAM_REFRESH_CYCLES then the SDRAM will fail.
 */
#ifndef SDRAM_ACCEPTABLE_REFRESH_GAP
#define SDRAM_ACCEPTABLE_REFRESH_GAP 8
#endif
/*
 * Define the minimum time between refreshes in SDRAM Clk cycles. Must be in
 * the range from 2 to 4 inclusive.
 */
#ifndef SDRAM_CMDS_PER_REFRESH
#define SDRAM_CMDS_PER_REFRESH 2
#endif

/*
 * Define if the memory is accessed by another device(other than the xCORE).
 * If not defined then faster code will be produced.
 */
#ifndef SDRAM_EXTERNAL_MEMORY_ACCESSOR
#define SDRAM_EXTERNAL_MEMORY_ACCESSOR 0
#endif

/*
 * Set SDRAM_CLOCK_DIVIDER to divide down the reference clock to get the desired
 * SDRAM Clock. The reference clock is divided by 2*SDRAM_CLOCK_DIVIDER.
 */
#ifndef SDRAM_CLOCK_DIVIDER
#define SDRAM_CLOCK_DIVIDER 1
#endif

/*
 * Define the configuration of the SDRAM. This is the value to be loaded
 * into the mode register.
 */
#ifndef SDRAM_MODE_REGISTER
#define SDRAM_MODE_REGISTER 0x0027 //CAS 2
#endif

#ifndef SDRAM_CLIENT_COUNT
#define SDRAM_CLIENT_COUNT 1
#endif
#endif /* SDRAM_CONFIG_H_ */
