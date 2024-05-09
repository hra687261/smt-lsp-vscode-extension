# SMT-LSP

A Language Server Protocol for the SMT-LIB Standard.

The LSP used by this extension is [Dolmen's language server (dolmenls)](https://github.com/Gbury/dolmen).

The syntax highlighting is a copy of [SMT.tmbundle](https://github.com/SRI-CSL/SMT.tmbundle).

# Dependencies

To use the extension you need to install [dolmenls](https://github.com/Gbury/dolmen) which can be installed with [opam](https://opam.ocaml.org/).

Checkout [opam's website](https://opam.ocaml.org/doc/Install.html) to see how to install opam.

- To install the latest release of `dolmenls` run:

  ```opam install dolmen_lsp```

- To install the dev version run:

  ```opam pin add https://github.com/Gbury/dolmen.git```

for more information checkout [Dolmen's doc](https://github.com/Gbury/dolmen/blob/master/doc/lsp.md)

# Installation

From the Visual Studio marketplace: https://marketplace.visualstudio.com/items?itemName=hra687261.smt-lsp

From the Open VSX registry: https://open-vsx.org/extension/hra687261/smt-lsp

From source:
```
vsce package
code --install-extension smt-lsp-X.X.X.vsix
```

# Configuration

The extension has the following settings:
- "smt-lsp.preludes": a list of paths to prelude files that will be parsed and typed before parsing and typing the files that are opened when using the extension.
- "smt-lsp.binary": a path to the `dolmenls` binary. By default, the extension runs the command `dolmenls`, but a path to the binary can be provided and will be used if provided.

# TODO
- Syntax highlighting for the latest version of the SMT-LIB standard. (only version 2.5 is supported for now)
- Syntax highlighting for the other languages supported by [Dolmen](https://github.com/Gbury/dolmen). (some day)