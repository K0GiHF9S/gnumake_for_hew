OBJ_DIR := ./$(CONFIG)
TARGET := $(OBJ_DIR)/sample.bin
LIBGEN_TARGET := $(OBJ_DIR)/sample.lib

all : $(TARGET)

include $(APPEND_MAKE)

ifeq ($(CONFIG),Debug)
is_debug=1
endif

include ../makerules

ARFLAGS =
ARFLAGS += -cpu=sh4a
ARFLAGS += -endian=little
ARFLAGS += -gbr=auto
ARFLAGS += -ecpp
ARFLAGS += -head=runtime,new,ctype,math,mathf,stdarg,stdio,stdlib,string,ios,complex,cppstring

LDFLAGS :=
LDFLAGS += -noprelink
ifndef is_debug
LDFLAGS += -nodebug
endif
LDFLAGS += -rom=D=R
LDFLAGS += -nomessage
LDFLAGS += -list=$(patsubst %.bin,%.map,$(TARGET))
LDFLAGS += -nooptimize
LDFLAGS += -nologo
LDFLAGS += -library=$(LIBGEN_TARGET)
LDFLAGS += $(addprefix -library=,$(LIBS))

OBJ_ABS := $(patsubst %.bin,%.abs,$(TARGET))

$(LIBGEN_TARGET) :
	$(AR) $(ARFLAGS) -output=$@

$(OBJ_ABS) : $(OBJS) $(LIBGEN_TARGET) $(LIBS) $(APPEND_MAKE) $(LNK_SUBCOMMAND)
	$(LD) $(LDFLAGS) -output=$@ -subcommand=$(LNK_SUBCOMMAND)

$(TARGET) : $(OBJ_ABS)
	$(LD) -form=binary -output=$@ $<

clean:
	$(RM) $(TARGET) $(OBJ_ABS) $(OBJS) $(LIBGEN_TARGET)

.PHONY : all clean
