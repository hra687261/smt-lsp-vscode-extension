VERSION := $(shell node -p "require('./package.json').version")
HOST    := $(shell node -p "process.platform + '-' + process.arch")
DOLMEN  := v0.10
SRC     := extension.ts package.json tsconfig.json language-configuration.json smt.tmLanguage README.md LICENSE.txt
TARGETS := linux-x64 darwin-arm64 win32-x64

linux-x64    := dolmenls-linux-amd64
# Despite its name, this is a binary for ARM Macs.
darwin-arm64 := dolmenls-macos-amd64
win32-x64    := dolmenls-windows-amd64.exe

HOST_VSIX := smt-lsp-$(VERSION)$(if $(filter $(HOST),$(TARGETS)),-$(HOST)).vsix

.PHONY: build install clean
# Keep the downloaded binaries between builds (make deletes the files that are
# only built through pattern rules)
.SECONDARY: $(TARGETS:%=bin-cache/$(DOLMEN)/%)
.DELETE_ON_ERROR:
.NOTPARALLEL:

build: $(TARGETS:%=smt-lsp-$(VERSION)-%.vsix) smt-lsp-$(VERSION).vsix

install: .installed

node_modules: package.json package-lock.json
	npm install
	touch $@

bin-cache/$(DOLMEN)/%:
	curl -fL --create-dirs -o $@ https://github.com/Gbury/dolmen/releases/download/$(DOLMEN)/$($*)
	chmod +x $@

smt-lsp-$(VERSION)-%.vsix: bin-cache/$(DOLMEN)/% $(SRC) node_modules
	rm -rf bin && mkdir bin && cp $< bin/dolmenls$(suffix $($*))
	vsce package --target $* -o $@
	rm -rf bin

smt-lsp-$(VERSION).vsix: $(SRC) node_modules
	rm -rf bin
	vsce package -o $@

.installed: $(HOST_VSIX)
	code --install-extension $<
	touch $@

clean:
	rm -rf bin bin-cache extension.js extension.js.map smt-lsp-*.vsix .installed
