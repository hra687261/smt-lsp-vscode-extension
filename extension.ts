import {
  ExtensionContext,
  workspace
} from 'vscode';
import {
  LanguageClient,
  Executable,
  DidChangeConfigurationNotification
} from 'vscode-languageclient/node';

let client: LanguageClient;

export function activate(_context: ExtensionContext) {

  const run: Executable = {
    command: 'dolmenls'
  };

  client = new LanguageClient(
    'dolmenls',
    'SMT Language Server Protocol',
    { run, debug: run },
    { documentSelector: [{ scheme: 'file', language: 'smt' }] },
  );

  client.start();
  client.sendNotification(
    DidChangeConfigurationNotification.type,
    { settings: workspace.getConfiguration("smt-lsp") }
  );

  workspace.onDidChangeConfiguration(e => {
    if (e.affectsConfiguration("smt-lsp.preludes")) {
      client.sendNotification(
        DidChangeConfigurationNotification.type,
        { settings: workspace.getConfiguration("smt-lsp") }
      );
    }
  })
}

export function deactivate(): Thenable<void> | undefined {
  if (!client) {
    return undefined
  }
  return client.stop()
}
