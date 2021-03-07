CONFIG ?= Release
PYTHON ?= py -3

SCRIPT := hwp2makefile.py

TEST := test/test.mak
SAMPLE := sample/sample.mak
SAMPLE : TEST

subs := TEST SAMPLE

all : $(subs)

define SUB_RULE
$(eval $1_PROJECT := $(basename $($1)).hwp)
$(eval $1_APPEND := $(basename $($1)).mak.$(CONFIG))
$(eval $1_LNK := $(basename $($1)).lnk.$(CONFIG))

$($1_LNK) : $(SCRIPT) $($1_PROJECT)
$($1_APPEND) : $($1_LNK) $(SCRIPT) $($1_PROJECT)
	$(PYTHON) $(SCRIPT) $($1_PROJECT) $(CONFIG)

$1 : $($1_APPEND) $($1_LNK)

endef

$(foreach sub,$(subs),$(eval $(call SUB_RULE,$(sub))))

$(subs):
	@$(MAKE) -C $(dir $($@)) -f $(notdir $($@)) CONFIG=$(CONFIG) APPEND_MAKE=$(notdir $($@_APPEND)) LNK_SUBCOMMAND=$(notdir $($@_LNK))

.PHONY : all $(subs)