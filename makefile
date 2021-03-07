CONFIG ?= Release

subs := test/test.mak sample/sample.mak
sample/sample.mak : test/test.mak

all clean : $(subs)

$(subs): %.mak :
	@$(MAKE) -C $(@D) -f $(@F) CONFIG=$(CONFIG) APPEND_MAKE=$(*F).mak.$(CONFIG) LNK_SUBCOMMAND=$(*F).lnk.$(CONFIG) PROJECT=$(*F).hwp $(MAKECMDGOALS)

.PHONY : all clean $(subs)
