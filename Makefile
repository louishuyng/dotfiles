say_hello:
	@echo "      _       _         __ _ _"
	@echo "   __| | ___ | |_      / _(_) | ___  ___"
	@echo "  / _\` |/ _ \| __|____| |_| | |/ _ \/ __|"
	@echo " | (_| | (_) | ||_____|  _| | |  __/\__ \\"
	@echo "  \__,_|\___/ \__|    |_| |_|_|\___||___/"
	@echo ""
	@echo "Let's Make File With Louis"

macos: say_hello
	@chmod u+x ./os_sh/mac_os/macos.sh
	@./os_sh/mac_os/masos.sh
