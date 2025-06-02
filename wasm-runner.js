const fs = require("fs");

async function main() {
    const bytes = fs.readFileSync('./temp.wasm');
    const dart = await import('./temp.mjs');
    const compiledApp = await dart.compile(bytes);
    const instantiatedApp = await compiledApp.instantiate();
    instantiatedApp.invokeMain();
}
main();