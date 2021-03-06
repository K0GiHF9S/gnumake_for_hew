CONFIG ?= Release
PYTHON ?= py -3

subs := sample/sample.mak
.PHONY : all $(subs)
all : $(subs)

sample/sample.mak : pre_sample

pre_sample :
	@$(PYTHON) hwp2makefile.py sample/sample.hwp $(CONFIG)

$(subs) :
	@cmd /E:ON /C if not exist $(subst /,\,$(dir $@))$(CONFIG) mkdir $(subst /,\,$(dir $@))$(CONFIG)
	@$(MAKE) -C $(dir $@) -f $(notdir $@) CONFIG=$(CONFIG)
