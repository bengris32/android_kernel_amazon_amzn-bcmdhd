LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_PREBUILT_KERNEL),)
BCMDHD_PATH := kernel/amazon/bcmdhd

BCMDHD_PLAT_VERSION := $(PLATFORM_VERSION)

BUILD_TARGET := $(TARGET_DEVICE)
ifneq ($(filter $(BUILD_TARGET),rook),)
BCMDHD_DEVICE_PLAT := USB
endif

BCMDHD_CONFIGS := \
    CONFIG_$(BUILD_TARGET)=y \
    CONFIG_BCMDHD_$(BCMDHD_DEVICE_PLAT)=y \
    CONFIG_BCMDHD_ANDROID_VERSION=$(BCMDHD_PLAT_VERSION)

include $(CLEAR_VARS)

LOCAL_MODULE        := amzn-bcmdhd
LOCAL_MODULE_SUFFIX := .ko
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(TARGET_OUT_VENDOR)/lib/modules

_dhd_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_dhd_ko := $(_dhd_intermediates)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)
KERNEL_OUT := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
KERNEL_OUT_RELATIVE := ../../KERNEL_OBJ

$(_dhd_ko): $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/$(BOARD_KERNEL_IMAGE_NAME)
	@mkdir -p $(dir $@)
	@mkdir -p $(KERNEL_MODULES_OUT)/lib/modules
	@cp -R $(BCMDHD_PATH)/bcmdhd/* $(_dhd_intermediates)/
	$(hide) +$(KERNEL_MAKE_CMD) $(KERNEL_MAKE_FLAGS) -C $(KERNEL_OUT) M=$(abspath $(_dhd_intermediates)) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) $(BCMDHD_CONFIGS) modules
	modules=$$(find $(_dhd_intermediates) -type f -name '*.ko'); \
	for f in $$modules; do \
		$(KERNEL_TOOLCHAIN_PATH)strip --strip-unneeded $$f; \
		cp $$f $(KERNEL_MODULES_OUT)/lib/modules; \
	done;
	touch $(_dhd_ko)

include $(BUILD_SYSTEM)/base_rules.mk
endif
