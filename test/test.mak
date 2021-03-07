OBJ_DIR := ./$(CONFIG)
TARGET := $(OBJ_DIR)/test.lib

all : $(TARGET)

include $(APPEND_MAKE)

ifeq ($(CONFIG),Debug)
is_debug=1
endif

include ../makerules

LDFLAGS :=
LDFLAGS += -noprelink
LDFLAGS += -form=library
LDFLAGS += -nomessage
LDFLAGS += -list=$(patsubst %.lib,%.ldp,$(TARGET))
LDFLAGS += -nologo
LDFLAGS += $(addprefix -library=,$(LIBS))

$(TARGET) : $(OBJS) $(LIBS) $(APPEND_MAKE) $(LNK_SUBCOMMAND)
	$(LD) $(LDFLAGS) -output=$@ -subcommand=$(LNK_SUBCOMMAND)

clean:
	$(RM) $(TARGET) $(OBJS)

.PHONY : all clean
