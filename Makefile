VERSION := $(shell node -p "require('./package.json').version")
HOST    := $(shell node -p "process.platform + '-' + process.arch")
DOLMEN  := v0.10
SRC     := extension.ts package.json tsconfig.json language-configuration.json smt.tmLanguage README.md LICENSE.txt LICENSE-dolmen.txt
TARGETS := linux-x64 darwin-arm64 win32-x64

linux-x64    := dolmenls-linux-amd64
# Despite its name, this is a binary for ARM Macs.
darwin-arm64 := dolmenls-macos-amd64
win32-x64    := dolmenls-windows-amd64.exe

VSIXS     := $(TARGETS:%=smt-lsp-$(VERSION)-%.vsix) smt-lsp-$(VERSION).vsix
HOST_VSIX := smt-lsp-$(VERSION)$(if $(filter $(HOST),$(TARGETS)),-$(HOST)).vsix

.PHONY: build install clean bump-patch bump-minor bump-major \
        check-release publish publish-marketplace publish-openvsx github-release release
# Keep the downloaded binaries between builds (make deletes the files that are
# only built through pattern rules)
.SECONDARY: $(TARGETS:%=bin-cache/$(DOLMEN)/%)
.DELETE_ON_ERROR:
.NOTPARALLEL:

build: $(VSIXS)

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
	vsce package --allow-unused-files-pattern -o $@

.installed: $(HOST_VSIX)
	code --install-extension $< --force
	touch $@

clean:
	rm -rf bin bin-cache extension.js extension.js.map smt-lsp-*.vsix .installed

bump-patch bump-minor bump-major:
	npm version $(@:bump-%=%) --no-git-tag-version

check-release:
	git diff --quiet HEAD || { echo "error: uncommitted changes"; exit 1; }
	git branch -r --contains HEAD | grep -q . || { echo "error: HEAD is not pushed"; exit 1; }

# Needs `vsce login hra687261` (or VSCE_PAT to be set).
publish-marketplace: $(VSIXS)
	vsce publish --packagePath $(VSIXS)

# Needs OVSX_PAT to be set.
publish-openvsx: $(VSIXS)
	for f in $(VSIXS); do npx ovsx publish $$f || exit 1; done

publish: publish-marketplace publish-openvsx

# Creates the v$(VERSION) tag on HEAD and a GitHub release with the packages.
github-release: $(VSIXS)
	gh release create v$(VERSION) $(VSIXS) --target $$(git rev-parse HEAD)

release: check-release publish github-release
