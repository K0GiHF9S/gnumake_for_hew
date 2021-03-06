OBJ_DIR := ./$(CONFIG)
TARGET := $(OBJ_DIR)/sample.bin
LINK_COMMAND := $(OBJ_DIR)/lnk.sub
LIBGEN_TARGET := $(OBJ_DIR)/sample.lib

include sample.mak.$(CONFIG)
LIBS := $(LIBGEN_TARGET)

ifeq ($(CONFIG),Debug)
is_debug=1
endif

all : $(TARGET)

include ../makerules

$(LINK_COMMAND) : sample.hwp
	$(file >  $(LINK_COMMAND),noprelink)
ifndef is_debug
	$(file >>  $(LINK_COMMAND),nodebug)
endif
	$(file >> $(LINK_COMMAND),rom D=R)
	$(file >> $(LINK_COMMAND),nomessage)
	$(file >> $(LINK_COMMAND),list $(patsubst %.bin,%.map,$(TARGET)))
	$(file >> $(LINK_COMMAND),nooptimize)
	$(file >> $(LINK_COMMAND),-start=$(START))
	$(file >> $(LINK_COMMAND),nologo)
	$(foreach obj,$(OBJS),$(file >> $(LINK_COMMAND),-input=$(obj)))
	$(foreach obj,$(LIBS),$(file >> $(LINK_COMMAND),-library=$(obj)))
	$(file >> $(LINK_COMMAND),-output=$(patsubst %.bin,%.abs,$(TARGET)))
	$(file >> $(LINK_COMMAND),end)
	$(file >> $(LINK_COMMAND),-input=$(patsubst %.bin,%.abs,$(TARGET)))
	$(file >> $(LINK_COMMAND),form binary)
	$(file >> $(LINK_COMMAND),output $(TARGET))
	$(file >> $(LINK_COMMAND),-exit)

$(TARGET) : $(LIBS) $(OBJS) $(LINK_COMMAND)
	$(LINK) -subcommand=$(LINK_COMMAND)

.PHONY : all
