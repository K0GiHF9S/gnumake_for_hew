CONFIG ?= Release
PYTHON ?= py -3

SCRIPT := hwp2makefile.py

SAMPLE := sample/sample.mak

subs := SAMPLE


all : $(subs)

define SUB_RULE
$(eval $1_PROJECT := $(basename $($1)).hwp)
$(eval $1_APPEND := $(basename $($1)).mak.$(CONFIG))
$(eval $1_LNK := $(basename $($1)).lnk.$(CONFIG))

$($1_APPEND) $($1_LNK) : $1_SCRIPT

$1_SCRIPT : $(SCRIPT) $($1_PROJECT)
	$(PYTHON) $(SCRIPT) $($1_PROJECT) $(CONFIG)

$1 : $($1_APPEND) $($1_LNK)
	@$(MAKE) -C $(dir $($1)) -f $(notdir $($1)) CONFIG=$(CONFIG) APPEND_MAKE=$(notdir $($1_APPEND)) LNK_SUBCOMMAND=$(notdir $($1_LNK))

endef

$(foreach sub,$(subs),$(eval $(call SUB_RULE,$(sub))))

.PHONY : all $(subs)