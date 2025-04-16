const pause = 3000;
const timeout = 120000;
const benchtime = 3000;

const fs = require("fs");
const BashShell = require("./BashShell.js");

type ShellEvent = {
    process: string,
    type: string,
    data: string | null
};

const sh = new BashShell("runner");
let runtime = 0;
sh.handler = (e: ShellEvent) => {
    let res = e.data;
    if (res) {
        let endIdx = res.indexOf("\n");
        if (endIdx === -1) endIdx = res.length;
        const parsedValue = Number(res.slice(0, endIdx));
        if (typeof parsedValue === "number" && !Number.isNaN(parsedValue)) {
            runtime = Math.round(parsedValue);
        }
    }
};

type Stats = {
    time: number,
    totalTime: number
};

let runtimes = {
    "node": new Map() as Map<string, Stats>,
    "node (jitless)": new Map() as Map<string, Stats>,
    "bun": new Map() as Map<string, Stats>,
    "hermes": new Map() as Map<string, Stats>,
    "shermes": new Map() as Map<string, Stats>,
    "quickjs": new Map() as Map<string, Stats>,
    "kiesel": new Map() as Map<string, Stats>,
    "boa": new Map() as Map<string, Stats>,
};

async function wait() {
    return new Promise((resolve) => {
        setTimeout(resolve, pause);
    });
}

async function runEngine(engineName: string, scriptName: string, cmd: string) {
    // wait for between runs to cool down the CPU
    await wait();

    runtime = -1;

    const start = Date.now();
    await sh.send(cmd, timeout);
    const end = Date.now();

    const engineNameKey = engineName as keyof typeof runtimes;
    const engineStats = runtimes[engineNameKey].get(scriptName) as Stats;
    engineStats.time += runtime;
    engineStats.totalTime += end - start;

    console.log(`${engineName} ${scriptName} complete`);
}

async function benchScript(scriptName: string) {
    // init stat storage
    for (const engineName in runtimes) {
        const runTimeStats: Map<string, Stats> = runtimes[engineName as keyof typeof runtimes];
        runTimeStats.set(scriptName, {
            time: 0,
            totalTime: 0
        });
    }

    // generate script
    const contents = fs.readFileSync(`./benchmark-scripts/js/${scriptName}.js`);
    const tempContents = `
        var print;
        if (typeof print === "undefined") {
            print = console.log;
        }
        const get_milliseconds = Date.now;
        const TIME_LIMIT = ${benchtime};
    ` + "\n" + contents + `
        const start = get_milliseconds();
        let iterations = 0;
        while (get_milliseconds() - start < TIME_LIMIT) {
            benchit();
            iterations += 2;
        }
        const end = get_milliseconds();
        print((end - start) / iterations);
    `;
    
    // create temp file
    fs.writeFileSync("./temp.js", tempContents);

    // run benchmark
    // await runEngine("bun", scriptName, "bun run ./temp.js");
    // await runEngine("node", scriptName, "node ./temp.js");
    // await runEngine("node (jitless)", scriptName, "node --jitless ./temp.js");
    // await runEngine("hermes", scriptName, "hermes ./temp.js");
    await runEngine("shermes", scriptName, "shermes -O -exec ./temp.js");
    // await runEngine("quickjs", scriptName, "qjs ./temp.js");
    // await runEngine("kiesel", scriptName, "kiesel temp.js");
    // await runEngine("boa", scriptName, "boa ./temp.js");
}

async function main() {
    const scriptNames = [
        "path-trace",
        "mandelbrot",
        "prime-factors",
        "gaussian-blur"
    ];

    // run benchmarks
    for (let i = 0; i < scriptNames.length; i++) {
        await benchScript(scriptNames[i]);
    }

    // cleanup
    sh.kill();
    fs.unlinkSync("./temp.js");

    // create table
    const statRows = [];
    for (const engineName in runtimes) {
        const engineNameKey = engineName as keyof typeof runtimes;
        const stats = runtimes[engineNameKey];

        let row = [engineName];
        let avg = 0;
        let crashes = 0;
        for (let i = 0; i < scriptNames.length; i++) {
            const time = stats.get(scriptNames[i])?.time as number;
            if (time !== -1) {
                avg += time;
            } else {
                crashes++;
            }
            const str = "" + time;
            row.push(str);
        }
        row.push("" + Math.round(avg / (scriptNames.length - crashes)));
        statRows.push(row);
    }

    statRows.sort((a, b) => {
        return Number(a[scriptNames.length + 1]) - Number(b[scriptNames.length + 1]);
    });
    
    function displayRow(row: string[]) {
        row[0] = row[0].padEnd(15, " ") + "|";
        for (let i = 1; i < row.length; i++) {
            row[i] = row[i].padStart(14, " ") + "|";
        }
        console.log("| " + row.join(""));
    }

    // display results
    console.log("\nResults in milliseconds (lower is better):");
    displayRow(["", ...scriptNames, "average"]);
    statRows.forEach(displayRow);
}

main();

