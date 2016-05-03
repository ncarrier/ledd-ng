LOCAL_PATH := $(call my-dir)

################################################################################
# ledd
################################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := ledd
LOCAL_DESCRIPTION := Daemon handling leds behaviour
LOCAL_CATEGORY_PATH := tools/ledd

LOCAL_SRC_FILES := \
	ledd/src/ledd/main.c

LOCAL_LIBRARIES := \
	libledd \
	libulog

include $(BUILD_EXECUTABLE)

################################################################################
# ledd-static
################################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := ledd-static
LOCAL_DESCRIPTION := Daemon handling leds behaviour - static version. This \
	module is more of a tutorial on how to embedd ledd in a static executable, \
	with all the plugins provided by the base distribution of ledd
LOCAL_CATEGORY_PATH := tools/ledd

LOCAL_SRC_FILES := \
	ledd/src/ledd/main.c

LOCAL_WHOLE_STATIC_LIBRARIES := \
	libledd-static

LOCAL_LDFLAGS := -static

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/ledd/include

include $(BUILD_EXECUTABLE)

################################################################################
# libledd
################################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := libledd
LOCAL_DESCRIPTION := Base library of ledd
LOCAL_CATEGORY_PATH := tools/ledd

LOCAL_SRC_FILES := \
	$(call all-c-files-in,ledd/src) \
	$(call all-c-files-in,ledd/src/config)

LOCAL_LIBRARIES := \
	libpomp \
	liblua \
	libutils \
	librs \
	ledd_plugin \
	libulog

LOCAL_LDLIBS := -ldl

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/ledd_plugins/src \
	$(LOCAL_PATH)/ledd/src \
	$(LOCAL_PATH)/ledd/src/config

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/ledd/include

LOCAL_EXPORT_CFLAGS := -DLEDD_SKIP_PLUGINS=false

LOCAL_COPY_FILES := \
	config/20-ledd.rc:etc/boxinit.d/

include $(BUILD_LIBRARY)

################################################################################
# libledd-static
################################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := libledd-static
LOCAL_DESCRIPTION := Base library of ledd, embedds all the plugins provided by \
	the ledd package
LOCAL_CATEGORY_PATH := tools/ledd

LOCAL_SRC_FILES := \
	$(call all-c-files-in,ledd/src) \
	$(call all-c-files-in,ledd/src/config) \
	$(call all-c-files-under,ledd_plugins)

LOCAL_STATIC_LIBRARIES := \
	libutils \
	librs \
	libpomp \
	libulog \
	liblua-static

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/ledd_plugins/include \
	$(LOCAL_PATH)/ledd_plugins/src \
	$(LOCAL_PATH)/ledd/include \
	$(LOCAL_PATH)/ledd/src \
	$(LOCAL_PATH)/ledd/src/config

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/ledd/include

LOCAL_EXPORT_CFLAGS := -DLEDD_SKIP_PLUGINS=true

include $(BUILD_STATIC_LIBRARY)

################################################################################
# ledd_plugin
################################################################################

include $(CLEAR_VARS)

LOCAL_MODULE := ledd_plugin
LOCAL_DESCRIPTION := Library for the implementation of ledd plugins, drivers or\
	transitions
LOCAL_CATEGORY_PATH := tools/ledd

LOCAL_SRC_FILES := $(call all-c-files-in,ledd_plugins/src)

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/ledd_plugins

LOCAL_EXPORT_C_INCLUDES := \
	$(LOCAL_PATH)/ledd_plugins/include

LOCAL_LIBRARIES := \
	liblua \
	libulog \
	libutils \
	libpomp \
	librs

include $(BUILD_LIBRARY)
