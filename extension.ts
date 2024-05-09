import {
  ExtensionContext,
  workspace
} from 'vscode';
import {
  LanguageClient,
  Executable,
  DidChangeConfigurationNotification
} from 'vscode-languageclient/node';
import * as path from 'path';
import * as os from 'os';

let client: LanguageClient;

function get_binary(): string {
  let bin: string =
    workspace.getConfiguration("smt-lsp").get("binary") || "dolmenls"
  bin =
    bin.startsWith('~') ?
      path.join(os.homedir(), bin.slice(1)) :
      bin.startsWith('$HOME') ?
        path.join(os.homedir(), bin.slice(5)) :
        bin
  return bin
}

export function activate(_context: ExtensionContext) {

  let cmd = get_binary()
  const run: Executable = { command: cmd }

  client = new LanguageClient(
    cmd,
    'SMT Language Server Protocol',
    { run, debug: run },
    { documentSelector: [{ scheme: 'file', language: 'smt' }] }
  )

  client.start();
  let preludes: string[] = workspace.getConfiguration("smt-lsp").get("preludes", [])
  if (preludes.length)
    client.sendNotification(
      DidChangeConfigurationNotification.type,
      { settings: { "preludes": preludes } }
    )

  workspace.onDidChangeConfiguration(e => {
    if (e.affectsConfiguration("smt-lsp.preludes")) {
      client.sendNotification(
        DidChangeConfigurationNotification.type,
        { settings: workspace.getConfiguration("smt-lsp") }
      )
    }
  })
}

export function deactivate(): Thenable<void> | undefined {
  if (!client) {
    return undefined
  }
  return client.stop()
}
