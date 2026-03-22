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
    workspace.getConfiguration("smt-lsp").get<string>("binary") || "dolmenls"
  bin =
    bin.startsWith('~') ?
      path.join(os.homedir(), bin.slice(1)) :
      bin.startsWith('$HOME') ?
        path.join(os.homedir(), bin.slice(5)) :
        bin
  return bin
}

export function activate(context: ExtensionContext) {

  const cmd: string = get_binary()
  const run: Executable = { command: cmd }

  client = new LanguageClient(
    'smt-lsp',
    'SMT Language Server Protocol',
    { run, debug: run },
    { documentSelector: [{ scheme: 'file', language: 'smt' }] }
  )

  client.start();
  let preludes: string[] =
    workspace.getConfiguration("smt-lsp").get("preludes", [])
  if (preludes.length)
    client.sendNotification(
      DidChangeConfigurationNotification.type,
      { settings: { "preludes": preludes } }
    )

  // Doesn't seem to work because the server does not rerun the analysis after
  // settings are updated. (also does not work when closing/reopening the file
  // which is more suprising)
  context.subscriptions.push(
    workspace.onDidChangeConfiguration(e => {
      if (e.affectsConfiguration("smt-lsp")) {
        client.sendNotification(
          DidChangeConfigurationNotification.type,
          { settings: workspace.getConfiguration("smt-lsp") }
        )
      }
    })
  )
}

export function deactivate(): Thenable<void> | undefined {
  return client ? client.stop() : undefined;
}
