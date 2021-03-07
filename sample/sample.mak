OBJ_DIR := ./$(CONFIG)
TARGET := $(OBJ_DIR)/sample.bin
LIBGEN_TARGET := $(OBJ_DIR)/sample.lib

all : $(TARGET)

include $(APPEND_MAKE)

ifeq ($(CONFIG),Debug)
is_debug=1
endif

include ../makerules

LIBGENFLAGS =
LIBGENFLAGS += -cpu=sh4a
LIBGENFLAGS += -endian=little
LIBGENFLAGS += -gbr=auto
LIBGENFLAGS += -ecpp
LIBGENFLAGS += -head=runtime,new,ctype,math,mathf,stdarg,stdio,stdlib,string,ios,complex,cppstring

LINKFLAGS :=
LINKFLAGS += -noprelink
ifndef is_debug
LINKFLAGS += -nodebug
endif
LINKFLAGS += -rom=D=R
LINKFLAGS += -nomessage
LINKFLAGS += -list=$(patsubst %.bin,%.map,$(TARGET))
LINKFLAGS += -nooptimize
LINKFLAGS += -nologo
LINKFLAGS += -library=$(LIBGEN_TARGET)
LINKFLAGS += $(addprefix -library=,$(LIBS))

OBJ_ABS := $(patsubst %.bin,%.abs,$(TARGET))

$(LIBGEN_TARGET) :
	$(LIBGEN) $(LIBGENFLAGS) -output=$@

$(OBJ_ABS) : $(OBJS) $(LIBGEN_TARGET) $(LIBS) $(APPEND_MAKE) $(LNK_SUBCOMMAND)
	$(LINK) $(LINKFLAGS) -output=$@ -subcommand=$(LNK_SUBCOMMAND)

$(TARGET) : $(OBJ_ABS)
	$(LINK) -form=binary -output=$@ $<

.PHONY : all
