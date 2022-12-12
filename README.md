# SMT-LSP

A Language Server Protocol for the SMT-LIB Standard.

The LSP used by this extension is [dolmenls](https://github.com/Gbury/dolmen).

The syntax highlighting is a copy of [SMT.tmbundle](https://github.com/SRI-CSL/SMT.tmbundle).

# Dependencies

To use the extension you need to install [dolmenls](https://github.com/Gbury/dolmen) which can be installed with [opam](https://opam.ocaml.org/).

Checkout [this page](https://opam.ocaml.org/doc/Install.html) to see how to install opam.

- To install the latest release run:

  ```opam install dolmen_lsp```

- To install the dev version run:

  ```opam pin add https://github.com/Gbury/dolmen.git```

for more information checkout [Dolmen's doc](https://github.com/Gbury/dolmen/blob/master/doc/lsp.md)

# TODO
- A way to extend the syntax highlighting and typechecking grammars from the user's side (through extension settings and preludes to the server maybe?).
- Syntax highlighting for the latest version of the SMT-LIB standard. (only version 2.5 is supported for now)
- Syntax highlighting for for the other languages supported by [Dolmen](https://github.com/Gbury/dolmen).
