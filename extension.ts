import { ExtensionContext/* , workspace */ } from 'vscode';
import { LanguageClient, Executable } from 'vscode-languageclient/node';

let client: LanguageClient;

export function activate(_context: ExtensionContext) {

  /*
  const preludes = workspace.getConfiguration("smt-lsp").get("preludes") as string[]
  let args: string[] = []
  preludes.map((x) => x.trim()).filter((x) => x !== '').forEach((element) => {
    args.push("--prelude")
    args.push(element)
  })
  */

  const run: Executable = {
    command: 'dolmenls',
    /* args */
  };

  client = new LanguageClient(
    'dolmenls',
    'SMT Language Server Protocol',
    { run, debug: run },
    { documentSelector: [{ scheme: 'file', language: 'smt' }] },
  );

  client.start()
}

export function deactivate(): Thenable<void> | undefined {
  if (!client) {
    return undefined
  }
  return client.stop()
}
