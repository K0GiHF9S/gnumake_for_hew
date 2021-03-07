OBJ_DIR := ./$(CONFIG)
TARGET := $(OBJ_DIR)/test.lib

all : $(TARGET)

include $(APPEND_MAKE)

ifeq ($(CONFIG),Debug)
is_debug=1
endif

include ../makerules

LINKFLAGS :=
LINKFLAGS += -noprelink
LINKFLAGS += -form=library
LINKFLAGS += -nomessage
LINKFLAGS += -list=$(patsubst %.lib,%.ldp,$(TARGET))
LINKFLAGS += -nologo
LINKFLAGS += $(addprefix -library=,$(LIBS))

$(TARGET) : $(OBJS) $(LIBS) $(APPEND_MAKE) $(LNK_SUBCOMMAND)
	$(LINK) $(LINKFLAGS) -output=$@ -subcommand=$(LNK_SUBCOMMAND)

.PHONY : all
