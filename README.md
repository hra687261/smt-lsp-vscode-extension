# SMT-LSP

Type checking and syntax highlighting the SMT-LIB Standard.

The LSP used by this extension is [Dolmen's language server (dolmenls)](https://github.com/Gbury/dolmen).

The syntax highlighting is a copy of [SMT.tmbundle](https://github.com/SRI-CSL/SMT.tmbundle).

# Dependencies

The extension comes with [dolmenls](https://github.com/Gbury/dolmen) on Linux and Windows (x86-64) and on Apple Silicon Macs. On other platforms, or to use another version of `dolmenls`, you need to install it:

- With [opam](https://opam.ocaml.org/) (Checkout [opam's website](https://opam.ocaml.org/doc/Install.html) to see how to install it):

  - To install the latest release of `dolmenls` run:

    ```opam install dolmen_lsp```

  - To install the dev version run:

    ```opam pin add https://github.com/Gbury/dolmen.git```

- By downloading it from the binaries provided in [dolmen's releases](https://github.com/Gbury/dolmen/releases/latest)

and for the extension to use that version of the `dolmenls` binary (installed manually or downloaded), set the `smt-lsp.binary` option in the extension's settings to the path of the binary

for more information on `dolmenls` checkout [Dolmen's doc](https://github.com/Gbury/dolmen/blob/master/doc/lsp.md)

# Installation

From the Visual Studio marketplace: https://marketplace.visualstudio.com/items?itemName=hra687261.smt-lsp

From the Open VSX registry: https://open-vsx.org/extension/hra687261/smt-lsp

From source (requires `npm`, `curl`, [vsce](https://github.com/microsoft/vscode-vsce) and `code`):
```
make          # builds smt-lsp-X.X.X-<platform>.vsix for each platform, and smt-lsp-X.X.X.vsix (without dolmenls)
make install  # builds them if needed, then installs the one for this platform in VS Code
make clean    # removes the built packages and the downloaded dolmenls binary
```
where `X.X.X` is the `version` field of `package.json`.

# Configuration

The extension has the following settings:
- "smt-lsp.preludes": a list of paths to prelude files that will be parsed and typed before parsing and typing the files that are opened when using the extension.
- "smt-lsp.binary": a path to the `dolmenls` binary. By default, the extension uses the `dolmenls` it comes with.

# TODO
- Syntax highlighting for the latest version of the SMT-LIB standard. (only version 2.5 is supported for now)
- Syntax highlighting for the other languages supported by [Dolmen](https://github.com/Gbury/dolmen). (some day)