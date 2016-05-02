/*
 * REPTAR Spartan6 FPGA emulation
 * Emulation "logic" part. Gateway between the emulation code and the backend.
 *
 * Copyright (c) 2013 HEIG-VD / REDS
 * Written by Romain Bornet
 *
 * This code is licensed under the GPL.
 */

#ifndef REPTAR_SP6_EMUL_H_
#define REPTAR_SP6_EMUL_H_

#include "cJSON.h"

#define PERID_LED 		"led"
#define PERID_LCD 		"lcd"
#define PERID_SEVEN_SEG	"7seg"
#define PERID_BTN		"btn"

#define SET				"set"
#define UPDATE			"update"
#define CLEAR			"clear"

void *sp6_emul_cmd_post(cJSON *packet);
int sp6_emul_init(void);
int sp6_emul_exit(void);

#endif /* REPTAR_SP6_EMUL_H_ */
