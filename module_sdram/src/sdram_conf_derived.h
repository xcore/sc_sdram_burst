
#ifndef SDRAM_CONF_DERIVED_H_
#define SDRAM_CONF_DERIVED_H_

#ifdef __sdram_conf_h_exists__
#include "sdram_conf.h" // This is from the application
#endif

#ifndef ADD_SUFFIX
#define _ADD_SUFFIX(A,B) A ## _ ## B
#define ADD_SUFFIX(A,B) _ADD_SUFFIX(A,B)
#endif


#endif /* SDRAM_CONF_DERIVED_H_ */

