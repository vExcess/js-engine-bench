import 'dart:io';

const pause = 3000;
// const timeout = 120000;
const benchtime = 3000;

class Stats {
    double time;
    double totalTime;
    Stats({
        required this.time,
        required this.totalTime,
    });
}

Map<String, Map<String, Stats>> runtimes = {
    "dart run": {},
    "dart exe": {},
    "dart jit": {},
};

Future<void> wait() async {
    return Future.delayed(Duration(milliseconds: pause));
}

int runtime = 0;

Future<void> runEngine(String engineName, String scriptName, String cmd) async {
    // wait for between runs to cool down the CPU
    await wait();

    runtime = -1;

    final start = DateTime.now().millisecondsSinceEpoch;
    final cmdArgs = cmd.split(" ");
    final processResult = await Process.run(cmdArgs[0], cmdArgs.sublist(1));
    final res = processResult.stdout;
    int endIdx = res.indexOf("\n");
    if (endIdx == -1) endIdx = res.length;
    final parsedValue = double.parse(res.substring(0, endIdx));
    if (!parsedValue.isNaN) {
        runtime = parsedValue.round();
    }
    final end = DateTime.now().millisecondsSinceEpoch;

    final engineNameKey = engineName;
    final engineStats = runtimes[engineNameKey]![scriptName]!;
    engineStats.time += runtime;
    engineStats.totalTime += end - start;

    print("${engineName} ${scriptName} complete");
}

Future<void> benchScript(String scriptName) async {
    // init stat storage
    for (final engineName in runtimes.keys) {
        Map<String, Stats> runTimeStats = runtimes[engineName]!;
        runTimeStats[scriptName] = Stats(
            time: 0,
            totalTime: 0
        );
    }

    // generate script
    final contents = File("./benchmark-scripts/dart/${scriptName}.dart").readAsStringSync();
    final endImportsIdx = contents.indexOf("// END IMPORTS");
    final importContents = contents.substring(0, endImportsIdx);
    final codeContents = contents.substring(endImportsIdx);
    final tempContents = importContents + """
        int get_milliseconds() {
            return DateTime.now().millisecondsSinceEpoch;
        }
        const TIME_LIMIT = ${benchtime};
    """ + "\n" + codeContents + """
        void main() {
            final start = get_milliseconds();
            int iterations = 0;
            while (get_milliseconds() - start < TIME_LIMIT) {
                benchit();
                iterations += 2;
            }
            final end = get_milliseconds();
            print((end - start) / iterations);
        }
    """;
    
    // create temp file
    File("./temp.dart").writeAsStringSync(tempContents);

    await Process.run("dart", ["compile", "exe", "temp.dart"]);
    await Process.run("dart", ["compile", "jit-snapshot", "temp.dart"]);

    // run benchmark
    await runEngine("dart run", scriptName, "dart run ./temp.dart");
    await runEngine("dart exe", scriptName, "./temp.exe");
    await runEngine("dart jit", scriptName, "dart run ./temp.jit");

    File("./temp.exe").deleteSync();
    File("./temp.jit").deleteSync();
}

void main() async {
    const scriptNames = [
        "path-trace",
        "mandelbrot",
        "prime-factors",
        "gaussian-blur"
    ];

    // run benchmarks
    for (int i = 0; i < scriptNames.length; i++) {
        await benchScript(scriptNames[i]);
    }

    // cleanup
    File("./temp.dart").deleteSync();

    // create table
    List<List<String>> statRows = [];
    for (final engineName in runtimes.keys) {
        final engineNameKey = engineName;
        final stats = runtimes[engineNameKey]!;

        List<String> row = [engineName];
        double avg = 0;
        int crashes = 0;
        for (int i = 0; i < scriptNames.length; i++) {
            double time = stats[scriptNames[i]]!.time;
            if (time != -1) {
                avg += time;
            } else {
                crashes++;
            }
            final str = "${time}";
            row.add(str);
        }
        row.add("${(avg / (scriptNames.length - crashes)).round()}");
        statRows.add(row);
    }

    statRows.sort((a, b) {
        return int.parse(a[scriptNames.length + 1]) - int.parse(b[scriptNames.length + 1]);
    });
    
    void displayRow(List<String> row) {
        row[0] = row[0].padRight(15, " ") + "|";
        for (int i = 1; i < row.length; i++) {
            row[i] = row[i].padLeft(14, " ") + "|";
        }
        print("| " + row.join(""));
    }

    // display results
    print("\nResults in milliseconds (lower is better):");
    displayRow(["", ...scriptNames, "average"]);
    statRows.forEach(displayRow);

}
