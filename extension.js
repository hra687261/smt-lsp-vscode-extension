"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deactivate = exports.activate = void 0;
var node_1 = require("vscode-languageclient/node");
var client;
function activate(_context) {
    /*
    const preludes = workspace.getConfiguration("smt-lsp").get("preludes") as string[]
    let args: string[] = []
    preludes.map((x) => x.trim()).filter((x) => x !== '').forEach((element) => {
      args.push("--prelude")
      args.push(element)
    })
    */
    var run = {
        command: 'dolmenls',
        /* args */
    };
    client = new node_1.LanguageClient('dolmenls', 'SMT Language Server Protocol', { run: run, debug: run }, { documentSelector: [{ scheme: 'file', language: 'smt' }] });
    client.start();
}
exports.activate = activate;
function deactivate() {
    if (!client) {
        return undefined;
    }
    return client.stop();
}
exports.deactivate = deactivate;
//# sourceMappingURL=extension.js.map