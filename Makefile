all:
	c1541 -attach "petwolf.d81" -read petwolf.bin petwolf.bin
	c1541 -attach "petwolf.d81" -read 11.defaults -read 11.edit -read 11.parse -read 11.post -read 11.settings -read autoboot.c65
	c1541 -attach "petwolf.d81" -read "random test.asm,s" "random test.asm"
	cat "random test.asm" | sed "s/\x0d/\x0a/g" | sed "s/\xd2/_/g" | sed "s/\"//g" > "random test.asm"

push_eleven:
	c1541 -attach "/c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/11.D81" -delete 11.defaults -delete 11.edit -delete 11.parse -delete 11.post -delete 11.settings -delete autoboot.c65
	c1541 -attach "/c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/11.D81" -write 11.defaults -write 11.edit -write 11.parse -write 11.post -write 11.settings -write autoboot.c65

xemu:
	/c/projs/xemu/build/bin/xmega65.native -rom /c/projs/mega65-rom/newrom.bin -hdosvirt -uartmon :4510 -8 petwolf.d81 &> /dev/null &

fast_xemu:
	/c/projs/xemu/build/bin/xmega65.native -rom /c/projs/mega65-rom/newrom.bin -hdosvirt -uartmon :4510 -fastclock 200 -8 petwolf.d81 &> /dev/null &
define scr_putlogo

m65dbg -l tcp <<'EOF'
load logo.bin 40800
load logo.clr ff80000
quit
EOF
endef
export scr_putlogo

define scr_getlogo
m65dbg -l tcp <<'EOF'
save logo.bin 40800 fa0
save logo.clr ff80000 fa0
quit
EOF
endef
export scr_getlogo

define scr_putlogo_bg
m65dbg -l tcp <<'EOF'
load logo_bg.bin 40800
load logo_bg.clr ff80000
quit
EOF
endef
export scr_putlogo_bg

define scr_putlogo_b
m65dbg -l tcp <<'EOF'
load logo_b.bin 40800
load logo_b.clr ff80000
quit
EOF
endef
export scr_putlogo_b

define scr_putlogo_a
m65dbg -l tcp <<'EOF'
load logo_a.bin 40800
load logo_a.clr ff80000
quit
EOF
endef
export scr_putlogo_a

define scr_putlogo_s
m65dbg -l tcp <<'EOF'
load logo_s.bin 40800
load logo_s.clr ff80000
quit
EOF
endef
export scr_putlogo_s

getlogo:; @ eval "$$scr_getlogo"
putlogo:; @ eval "$$scr_putlogo"

putlogo_bg:; @ eval "$$scr_putlogo_bg"
putlogo_b:; @ eval "$$scr_putlogo_b"
putlogo_a:; @ eval "$$scr_putlogo_a"
putlogo_s:; @ eval "$$scr_putlogo_s"

megaplot.prg: megaplot.a
	acme --cpu m65 -l megaplot.sym -r megaplot.rep megaplot.a 

asmhelper.prg: asmhelper.a
	acme --cpu m65 -v4 -l asmhelper.sym -r asmhelper.rep asmhelper.a
