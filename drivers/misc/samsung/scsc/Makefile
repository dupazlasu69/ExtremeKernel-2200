#############################################################################
#
# Copyright (c) 2014 - 2021 Samsung Electronics Co., Ltd. All rights reserved
#
#############################################################################

# Needed since this subdir is symlinked in the main Kernel tree
# without this our samsung subdir is NOT cleaned.
clean-files := *.o *.ko

ifneq ($(CONFIG_SCSC_CORE),n)

ccflags-y +=  -Iinclude/scsc
ccflags-y += $(CONFIG_SAMSUNG_MAXWELL_EXTRA)

obj-$(CONFIG_SCSC_LOG_COLLECTION) += scsc_log_collection.o
scsc_log_collection-$(CONFIG_SCSC_LOG_COLLECTION) += scsc_log_collector.o scsc_log_collector_proc.o scsc_log_collector_mmap.o

obj-$(CONFIG_SCSC_LOGRING) += scsc_logring.o
scsc_logring-$(CONFIG_SCSC_LOGRING) += scsc_logring_main.o scsc_logring_ring.o scsc_logring_debugfs.o


ifeq ($(CONFIG_SCSC_MXLOGGER), m)
ccflags-y += -DCONFIG_SCSC_MXLOGGER
endif

ifeq ($(CONFIG_SCSC_LOG_COLLECTION), m)
ccflags-y += -DCONFIG_SCSC_LOG_COLLECTION
endif

ifeq ($(CONFIG_SCSC_INDEPENDENT_SUBSYSTEM), m)
ccflags-y += -DCONFIG_SCSC_INDEPENDENT_SUBSYSTEM
endif

##
## The following cumbersome ifeq/else is the only way to make
## this CONFIG_SCSC_PRINTK propagate correctly in any scenario (y,m,n)
## Otherwise using ONLY the else branch when CONFIG_SCSC_DEBUG evaluates
## to m ==>> ccflags-m does NOT work correctly in every build scenario:
## - kernel debug modules : builtin with scsc_logring support
## - kernel nodebug modules : builtins without scsc_logring support
## - kernel debug|nodebug nomodules : no builtin / no scsclogring
##
ccflags-y += -DCONFIG_SCSC_PRINTK

ifneq ($(CONFIG_SCSC_DEBUG),n)
ccflags-$(CONFIG_SCSC_STATIC_RING)	+= -DCONFIG_SCSC_STATIC_RING_SIZE=$(CONFIG_SCSC_STATIC_RING_SIZE)
endif

#obj-$(CONFIG_SCSC_WIFILOGGER) +=  scsc_wifilogger.o
#scsc_wifilogger-y += scsc_wifilogger_api.o \
#		     scsc_wifilogger_internal.o \
#		     scsc_wifilogger_core.o \
#		     scsc_wifilogger_module.o \
#		     scsc_wifilogger_ring_connectivity.o \
#		     scsc_wifilogger_ring_wakelock.o \
#		     scsc_wifilogger_ring_pktfate.o

#scsc_wifilogger-$(CONFIG_SCSC_WIFILOGGER_DEBUGFS) += scsc_wifilogger_debugfs.o
#scsc_wifilogger-$(CONFIG_SCSC_WIFILOGGER_TEST) += scsc_wifilogger_ring_test.o

# GDB channels for MoreDump
ccflags-$(CONFIG_SCSC_MX450_GDB_SUPPORT) += -DCONFIG_SCSC_MX450_GDB_SUPPORT

ifeq ($(CONFIG_SCSC_PCIE), m)
ccflags-y += -DCONFIG_SCSC_PCIE
ifeq ($(CONFIG_SCSC_PCIE_PAEAN_X86), y)
ccflags-y += -DCONFIG_SCSC_PCIE_PAEAN_X86
else
ccflags-y += -DCONFIG_SCSC_PCIE_SNOW
endif
endif

# PCI-E MIF
obj-$(CONFIG_SCSC_PCIE) += scsc_pcie_mif.o
ifeq ($(CONFIG_SCSC_PCIE_PAEAN_X86), y)
scsc_pcie_mif-$(CONFIG_SCSC_PCIE) += \
    pcie_mif_module.o \
	pcie_mif_paean.o \
	pcie_proc.o
else
scsc_pcie_mif-$(CONFIG_SCSC_PCIE) += \
    pcie_mif_module.o \
	pcie_mif.o \
	pcie_proc.o
endif

obj-$(CONFIG_SCSC_PLATFORM) += scsc_platform_mif.o

scsc_platform_mif-$(CONFIG_SCSC_PLATFORM) += \
	platform_mif_module.o

ifeq ($(CONFIG_SOC_EXYNOS9610),y)
	scsc_platform_mif-$(CONFIG_SCSC_PLATFORM) += platform_mif_9610.o
endif
ifeq ($(CONFIG_SOC_EXYNOS9630),y)
	scsc_platform_mif-$(CONFIG_SCSC_PLATFORM) += platform_mif_9630.o
endif
ifeq ($(CONFIG_SOC_EXYNOS3830),y)
	scsc_platform_mif-$(CONFIG_SCSC_PLATFORM) += platform_mif_3830.o
endif
ifeq ($(CONFIG_SOC_EXYNOS7570),y)
	scsc_platform_mif-$(CONFIG_SCSC_PLATFORM) += platform_mif.o
endif
ifeq ($(CONFIG_SOC_EXYNOS7872),y)
	scsc_platform_mif-$(CONFIG_SCSC_PLATFORM) += platform_mif.o
endif
ifeq ($(CONFIG_SOC_EXYNOS7885),y)
	scsc_platform_mif-$(CONFIG_SCSC_PLATFORM) += platform_mif_7885.o
endif
ifeq ($(CONFIG_SOC_S5E9815),y)
	scsc_platform_mif-$(CONFIG_SCSC_PLATFORM) += platform_mif_9815.o
endif
ifeq ($(CONFIG_SOC_S5E5515),y)
	scsc_platform_mif-$(CONFIG_SCSC_PLATFORM) += platform_mif_s5e5515.o
	scsc_platform_mif-$(CONFIG_WLBT_AUTOGEN_PMUCAL) += pmu_cal.o
	scsc_platform_mif-$(CONFIG_WLBT_AUTOGEN_PMUCAL) += pmu_cal_data_5515.o
endif
ifeq ($(CONFIG_SOC_S5E8825),y)
	scsc_platform_mif-$(CONFIG_SCSC_PLATFORM) += platform_mif_s5e8825.o
	scsc_platform_mif-$(CONFIG_WLBT_AUTOGEN_PMUCAL) += pmu_cal.o
	scsc_platform_mif-$(CONFIG_WLBT_AUTOGEN_PMUCAL) += pmu_cal_data_8825.o
endif
ifeq ($(CONFIG_SOC_S5E9925),y)
	scsc_platform_mif-$(CONFIG_SCSC_PLATFORM) += platform_mif_s5e9925.o
	scsc_platform_mif-$(CONFIG_SCSC_PLATFORM) += pcie_s5e9925.o
	scsc_platform_mif-$(CONFIG_SCSC_PLATFORM) += pcie_proc.o
endif
#core_module for static functions and registration client module (all the service driver modules -wlan, bt,...-)
#core for instance
obj-$(CONFIG_SCSC_CORE_CM) += scsc_mx.o
scsc_mx-y += \
	mxlog_transport.o \
	fw_panic_record.o \
	panicmon.o \
	suspendmon.o \
	mxlog.o \
	mxproc.o \
	scsc_service.o \
	scsc_mx_module.o \
	scsc_mx_impl.o \
	miframman.o \
	mifmboxman.o \
	mifproc.o \
	mifintrbit.o \
	fwimage.o \
	cpacket_buffer.o \
	mifstream.o \
	mxmgmt_transport.o \
	gdb_transport.o \
	scsc_lerna.o \
	mxsyserr.o \
	mxfwconfig.o \
	mx140_file.o

scsc_mx-$(CONFIG_SCSC_SMAPPER) += mifsmapper.o

scsc_mx-$(CONFIG_SCSC_WLBTD) += scsc_wlbtd.o

scsc_mx-$(CONFIG_SCSC_QOS) += mifqos.o

scsc_mx-$(CONFIG_SCSC_LAST_PANIC_IN_DRAM) += scsc_log_in_dram.o

scsc_mx-$(CONFIG_EXYNOS_SYSTEM_EVENT) += mxman_sysevent.o

ifeq ($(CONFIG_SCSC_INDEPENDENT_SUBSYSTEM), m)
ccflags-y += -DCONFIG_SCSC_INDEPENDENT_SUBSYSTEM
endif

ifeq ($(CONFIG_SCSC_INDEPENDENT_SUBSYSTEM), m)
ccflags-y += -DCONFIG_SCSC_WLBTD
endif

ifneq ($(CONFIG_SCSC_INDEPENDENT_SUBSYSTEM),)
scsc_mx-$(CONFIG_SCSC_MXLOGGER) += mxlogger_split.o
scsc_mx-y += mxman_split.o
scsc_mx-y += mxman_res.o
scsc_mx-y += mxman_if.o
scsc_mx-y += whdr.o
scsc_mx-y += fhdr.o
scsc_mx-y += bhdr.o
scsc_mx-y += mifpmuman.o
scsc_mx-y += fw_obj_index.o
else
scsc_mx-$(CONFIG_SCSC_MXLOGGER) += mxlogger.o
scsc_mx-y += mxman.o
scsc_mx-y += fwhdr.o
endif

ifneq ($(CONFIG_SCSC_CM_MX_CLIENT_TEST),n)
obj-$(CONFIG_SCSC_CM_MX_CLIENT_TEST) += mx_client_test.o
mx_client_test-y += client_test.o
endif

ifneq ($(CONFIG_SCSC_MMAP),n)
obj-$(CONFIG_SCSC_MMAP) += scsc_mmap.o
scsc_mmap-y += mx_mmap.o
endif

ifneq ($(CONFIG_SCSC_CLK20MHZ),n)
obj-$(CONFIG_SCSC_CLK20MHZ) += scsc_mx140_clk.o
scsc_mx140_clk-y += mx140_clk.o
ifeq ($(CONFIG_SCSC_CLK20MHZ_TEST),y)
scsc_mx140_clk-y += mx140_clk_test.o
endif
endif

ifneq ($(CONFIG_SCSC_FM),n)
obj-$(CONFIG_SCSC_FM) += scsc_mx250_fm.o
scsc_mx250_fm-y += mx250_fm.o
ifeq ($(CONFIG_SCSC_FM_TEST),y)
scsc_mx250_fm-y += mx250_fm_test.o
endif
endif

obj-$(CONFIG_SCSC_DBG_SAMPLER) += scsc_dbg_sampler.o
scsc_dbg_sampler-y += mx_dbg_sampler.o

endif

ccflags-y += -DSCSC_SEP_VERSION=12

# The below section is only for DTE purpose. It is controlled by the flag SCSC_DTE_BUILD which is set only by the
# DTE top level Makefile. Hence, no risk.
# In the below include dir the KERNEL_DIR comes from the DTE top level makefile.
ifeq ($(SCSC_DTE_BUILD),y)
obj-m := scsc_mx.o
obj-m += mx_client_test.o
mx_client_test-y += client_test.o

ccflags-y +=  -I$(KERNEL_DIR)/include/scsc/
ccflags-y +=  -I$(KERNEL_DIR)/include
ccflags-y +=  -I$(KERNEL_DIR)/drivers/misc/samsung/scsc
ccflags-y +=  -I$(KERNEL_DIR)/drivers/net/wireless/scsc

endif
