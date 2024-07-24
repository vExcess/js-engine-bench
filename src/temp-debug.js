const BashShell = require("./BashShell.js");
async function main() {
    const sh = new BashShell("runner");

    sh.handler = (e) => {
        if (e.data) {
            console.log(e.data);
        }
    };

    await sh.send("kiesel ./temp.js", 30000);

    sh.kill();
}

main();