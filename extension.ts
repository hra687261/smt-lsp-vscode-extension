import {
  ExtensionContext,
  window,
  workspace
} from 'vscode';
import {
  LanguageClient,
  Executable,
  DidChangeConfigurationNotification
} from 'vscode-languageclient/node';
import * as path from 'path';
import * as os from 'os';
import * as fs from 'fs';

let client: LanguageClient;

// For Linux and Windows on x86-64 and for Apple Silicon Macs, the extension
// comes with dolmenls binary in bin/. On other platforms there is no bundled binary, so "smt-lsp.binary"
// must be set.
function get_binary(context: ExtensionContext): string {
  const bin = workspace.getConfiguration("smt-lsp").get<string>("binary")
  if (bin)
    return bin.startsWith('~') ?
      path.join(os.homedir(), bin.slice(1)) :
      bin.startsWith('$HOME') ?
        path.join(os.homedir(), bin.slice(5)) :
        bin
  const bundled = context.asAbsolutePath(
    path.join('bin', process.platform === 'win32' ? 'dolmenls.exe' : 'dolmenls')
  )
  if (!fs.existsSync(bundled))
    throw new Error(
      `no dolmenls binary is bundled for ${process.platform}-${process.arch}, ` +
      `install dolmenls (through opam \
      https://opam.ocaml.org/packages/dolmen_lsp/ or from sources \
      https://github.com/Gbury/dolmen) and set "smt-lsp.binary" to the path of \
      a dolmenls binary for the extension to work`
    )
  return bundled
}

export function activate(context: ExtensionContext) {

  let cmd: string
  try {
    cmd = get_binary(context)
  } catch (e) {
    window.showErrorMessage(`SMT LSP: ${e instanceof Error ? e.message : e}`)
    return
  }
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
