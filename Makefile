VSIX := smt-lsp-$(shell node -p "require('./package.json').version").vsix
SRC  := extension.ts package.json tsconfig.json language-configuration.json smt.tmLanguage README.md

.PHONY: build install

build: $(VSIX)

install: .installed

$(VSIX): $(SRC)
	npm install
	vsce package

.installed: $(VSIX)
	code --install-extension $(VSIX)
	touch $@
