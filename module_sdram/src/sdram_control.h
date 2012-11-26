#ifndef SDRAM_CONTROL_H_
#define SDRAM_CONTROL_H_

/*                                 BURST                   LOAD
 *  signal  NOP  ACTIVE WRITE READ TERM  REFRESH PRECHARGE MODEREG
 *  RAS     1    0      1     1    1     0       0         0
 *  CAS     1    1      0     0    1     0       1         0
 *  WE      1    1      0     1    0     1       0         0
*/

//When using a 4 bit port for the control signals this is where they are defined
#define CTRL_EXTRA_PIN        0x3
#define CTRL_RAS_PIN          0x1
#define CTRL_CAS_PIN          0x2
#define CTRL_WE_PIN           0x0

#define CTRL_EXTRA_VAL        0x1

#define CTRL_RAS_NOP          0x1
#define CTRL_CAS_NOP          0x1
#define CTRL_WE_NOP           0x1
#define CTRL_NOP              (0xf&((CTRL_RAS_NOP<<CTRL_RAS_PIN) | (CTRL_CAS_NOP<<CTRL_CAS_PIN) | (CTRL_WE_NOP<<CTRL_WE_PIN) | (CTRL_EXTRA_VAL<<CTRL_EXTRA_PIN)))

#define CTRL_RAS_ACTIVE       0x0
#define CTRL_CAS_ACTIVE       0x1
#define CTRL_WE_ACTIVE        0x1
#define CTRL_ACTIVE           (0xf&((CTRL_RAS_ACTIVE<<CTRL_RAS_PIN) | (CTRL_CAS_ACTIVE<<CTRL_CAS_PIN) | (CTRL_WE_ACTIVE<<CTRL_WE_PIN) | (CTRL_EXTRA_VAL<<CTRL_EXTRA_PIN)))

#define CTRL_RAS_WRITE        0x1
#define CTRL_CAS_WRITE        0x0
#define CTRL_WE_WRITE         0x0
#define CTRL_WRITE            (0xf&((CTRL_RAS_WRITE<<CTRL_RAS_PIN) | (CTRL_CAS_WRITE<<CTRL_CAS_PIN) | (CTRL_WE_WRITE<<CTRL_WE_PIN) | (CTRL_EXTRA_VAL<<CTRL_EXTRA_PIN)))

#define CTRL_RAS_READ         0x1
#define CTRL_CAS_READ         0x0
#define CTRL_WE_READ          0x1
#define CTRL_READ             (0xf&((CTRL_RAS_READ<<CTRL_RAS_PIN) | (CTRL_CAS_READ<<CTRL_CAS_PIN) | (CTRL_WE_READ<<CTRL_WE_PIN) | (CTRL_EXTRA_VAL<<CTRL_EXTRA_PIN)))

#define CTRL_RAS_REFRESH      0x0
#define CTRL_CAS_REFRESH      0x0
#define CTRL_WE_REFRESH       0x1
#define CTRL_REFRESH          (0xf&((CTRL_RAS_REFRESH<<CTRL_RAS_PIN) | (CTRL_CAS_REFRESH<<CTRL_CAS_PIN) | (CTRL_WE_REFRESH<<CTRL_WE_PIN) | (CTRL_EXTRA_VAL<<CTRL_EXTRA_PIN)))

#define CTRL_RAS_PRECHARGE    0x0
#define CTRL_CAS_PRECHARGE    0x1
#define CTRL_WE_PRECHARGE     0x0
#define CTRL_PRECHARGE        (0xf&((CTRL_RAS_PRECHARGE<<CTRL_RAS_PIN) | (CTRL_CAS_PRECHARGE<<CTRL_CAS_PIN) | (CTRL_WE_PRECHARGE<<CTRL_WE_PIN) | (CTRL_EXTRA_VAL<<CTRL_EXTRA_PIN)))

#define CTRL_RAS_TERM         0x1
#define CTRL_CAS_TERM         0x1
#define CTRL_WE_TERM          0x0
#define CTRL_TERM             (0xf&((CTRL_RAS_TERM<<CTRL_RAS_PIN) | (CTRL_CAS_TERM<<CTRL_CAS_PIN) | (CTRL_WE_TERM<<CTRL_WE_PIN) | (CTRL_EXTRA_VAL<<CTRL_EXTRA_PIN)))

#define CTRL_RAS_LOAD_MODEREG 0x0
#define CTRL_CAS_LOAD_MODEREG 0x0
#define CTRL_WE_LOAD_MODEREG  0x0
#define CTRL_LOAD_MODEREG     (0xf&((CTRL_RAS_LOAD_MODEREG<<CTRL_RAS_PIN) | (CTRL_CAS_LOAD_MODEREG<<CTRL_CAS_PIN) | (CTRL_WE_LOAD_MODEREG<<CTRL_WE_PIN) | (CTRL_EXTRA_VAL<<CTRL_EXTRA_PIN)))

#endif /* SDRAM_CONTROL_H_ */
