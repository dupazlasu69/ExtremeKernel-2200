﻿/* individual sequence descriptor for CP control - init, reset, release, cp_active_clear, cp_reset_req_clear */
struct pmucal_seq cp_init[] = {
	PMUCAL_SEQ_DESC(PMUCAL_WRITE, "CP_CTRL_S", 0x15860000, 0x3914, (0x1 << 3), (0x1 << 3), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_WRITE, "CP_CONFIGURATION", 0x15860000, 0x3900, (0x1 << 0), (0x1 << 0), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_WAIT, "CP_STATUS", 0x15860000, 0x3904, (0x1 << 0), (0x1 << 0), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_WAIT, "CP_IN", 0x15860000, 0x3924, (0x1 << 4), (0x1 << 4), 0, 0, 0xffffffff, 0),
};

struct pmucal_seq cp_status[] = {
	PMUCAL_SEQ_DESC(PMUCAL_READ, "CP_STATUS", 0x15860000, 0x3904, (0x1 << 0), 0, 0, 0, 0xffffffff, 0),
};

struct pmucal_seq cp_reset_assert[] = {
	PMUCAL_SEQ_DESC(PMUCAL_SET_BIT_ATOMIC, "V_PWREN", 0x15860000, 0x3ef0, (0xffffffff << 0), (0xe << 0), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_DELAY, "delay", 0, 0, 0, 0x3e8, 0, 0, 0, 0),
	PMUCAL_SEQ_DESC(PMUCAL_SET_BIT_ATOMIC, "V_PWREN", 0x15860000, 0x3ef0, (0xffffffff << 0), (0xf << 0), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_DELAY, "delay", 0, 0, 0, 0x3e8, 0, 0, 0, 0),
	PMUCAL_SEQ_DESC(PMUCAL_SET_BIT_ATOMIC, "V_PWREN", 0x15860000, 0x3ef0, (0xffffffff << 0), (0x10 << 0), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_DELAY, "delay", 0, 0, 0, 0x3e8, 0, 0, 0, 0),
	PMUCAL_SEQ_DESC(PMUCAL_WRITE, "CP_INT_EN", 0x15860000, 0x3934, (0x1 << 3), (0x0 << 3), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_WRITE, "CP_INT_EN", 0x15860000, 0x3934, (0x1 << 5), (0x0 << 5), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_WRITE, "CP_CONFIGURATION", 0x15860000, 0x3900, (0x1 << 0), (0x0 << 0), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_WAIT, "CP_STATUS", 0x15860000, 0x3904, (0x1 << 0), (0x0 << 0), 0, 0, 0xffffffff, 0),
};

struct pmucal_seq cp_reset_release[] = {
#if IS_ENABLED(CONFIG_PROJECT_NAME_R11)
	PMUCAL_SEQ_DESC(PMUCAL_SET_BIT_ATOMIC, "V_PWREN", 0x15860000, 0x3ef0, (0xffffffff << 0), (0xe << 0), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_DELAY, "delay", 0, 0, 0, 0x3e8, 0, 0, 0, 0),
	PMUCAL_SEQ_DESC(PMUCAL_SET_BIT_ATOMIC, "V_PWREN", 0x15860000, 0x3ef0, (0xffffffff << 0), (0xf << 0), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_DELAY, "delay", 0, 0, 0, 0x3e8, 0, 0, 0, 0),
	PMUCAL_SEQ_DESC(PMUCAL_SET_BIT_ATOMIC, "V_PWREN", 0x15860000, 0x3ef0, (0xffffffff << 0), (0x10 << 0), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_DELAY, "delay", 0, 0, 0, 0x3e8, 0, 0, 0, 0),
#endif
	PMUCAL_SEQ_DESC(PMUCAL_WRITE, "CP_CONFIGURATION", 0x15860000, 0x3900, (0x1 << 0), (0x1 << 0), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_WAIT, "CP_STATUS", 0x15860000, 0x3904, (0x1 << 0), (0x1 << 0), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_WRITE, "CP_INT_EN", 0x15860000, 0x3934, (0x1 << 3), (0x1 << 3), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_WRITE, "CP_INT_EN", 0x15860000, 0x3934, (0x1 << 5), (0x1 << 5), 0, 0, 0xffffffff, 0),
	PMUCAL_SEQ_DESC(PMUCAL_WAIT, "CP_IN", 0x15860000, 0x3924, (0x1 << 4), (0x1 << 4), 0, 0, 0xffffffff, 0),
};

struct pmucal_seq cp_reset_req_clear[] = {
};

struct pmucal_seq cp_enable_dump_pc_no_pg[] = {
	PMUCAL_SEQ_DESC(PMUCAL_WRITE, "CP_OUT", 0x15860000, 0x3920, (0x1 << 16), (0x1 << 16), 0, 0, 0xffffffff, 0),
};

struct pmucal_seq cp_disable_dump_pc_no_pg[] = {
	PMUCAL_SEQ_DESC(PMUCAL_WRITE, "CP_OUT", 0x15860000, 0x3920, (0x1 << 16), (0x0 << 16), 0, 0, 0xffffffff, 0),
};

struct pmucal_cp pmucal_cp_list = {
		.init = cp_init,
		.status = cp_status,
		.reset_assert = cp_reset_assert,
		.reset_release = cp_reset_release,
		.cp_active_clear = 0,
		.cp_reset_req_clear = 0,
		.cp_enable_dump_pc_no_pg = cp_enable_dump_pc_no_pg,
		.cp_disable_dump_pc_no_pg = cp_disable_dump_pc_no_pg,
		.num_init = ARRAY_SIZE(cp_init),
		.num_status = ARRAY_SIZE(cp_status),
		.num_reset_assert = ARRAY_SIZE(cp_reset_assert),
		.num_reset_release = ARRAY_SIZE(cp_reset_release),
		.num_cp_active_clear = 0,
		.num_cp_reset_req_clear = 0,
		.num_cp_enable_dump_pc_no_pg = ARRAY_SIZE(cp_enable_dump_pc_no_pg),
		.num_cp_disable_dump_pc_no_pg = ARRAY_SIZE(cp_disable_dump_pc_no_pg),
};
unsigned int pmucal_cp_list_size = 1;
