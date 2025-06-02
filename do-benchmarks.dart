import 'dart:io';

const pause = 3000;
const benchtime = 3000;
const scriptNames = [
    "path-trace",
    "mandelbrot",
    "prime-factors",
    "gaussian-blur"
];

class Stats {
    double time;
    Stats({
        required this.time
    });
}

Map<String, Map<String, Object>> runtimes = {
    "zig safe": {
        "cmd": "./tempzigsafe"
    },
    "zig small": {
        "cmd": "./tempzigsmall"
    },
    "zig fast": {
        "cmd": "./tempzigfast"
    },
    "node": {
        "cmd": "node ./temp.js"
    },
    "node (jitless)": {
        "cmd": "node --jitless ./temp.js"
    },
    "bun": {
        "cmd": "bun run ./temp.js"
    },
    "hermes": {
        "cmd": "hermes ./temp.js"
    },
    "shermes": {
        "cmd": "shermes -O -exec ./temp.js"
    },
    "quickjs": {
        "cmd": "./qjs ./temp.js"
    },
    "kiesel": {
        "cmd": "./kiesel temp.js"
    },
    "boa": {
        "cmd": "./boa ./temp.js"
    },
    "dart run": {
        "cmd": "dart run ./temp.dart"
    },
    "dart exe": {
        "cmd": "./temp.exe"
    },
    "dart jit": {
        "cmd": "dart run ./temp.jit"
    },
    "dart js -O2": {
        "cmd": "node outO2.js"
    },
    "dart js -O3": {
        "cmd": "node outO3.js"
    },
    "dart js -O4": {
        "cmd": "node outO4.js"
    },
    "wasm (dart)": {
        "cmd": "node wasm-runner.js"
    },
    "python": {
        "cmd": "python3 ./temp.py"
    },
};

Future<void> wait() async {
    return Future.delayed(Duration(milliseconds: pause));
}

void runEngine(String engineName, String scriptName, String cmd) {
    final cmdArgs = cmd.split(" ");
    try {
        final processResult = Process.runSync(cmdArgs[0], cmdArgs.sublist(1));

        final res = processResult.stdout;
        // print("--${res}--");
        int endIdx = res.indexOf("\n");
        if (endIdx == -1) endIdx = res.length;
        
        final parsedValue = double.parse(res.substring(0, endIdx));
        if (parsedValue.isNaN) {
            return;
        }

        final engineNameKey = engineName;
        final engineStats = runtimes[engineNameKey]![scriptName]! as Stats;
        if (engineStats.time == -1) {
            engineStats.time = 0;
        }
        engineStats.time += parsedValue;

        print("${engineName} ${scriptName} complete");
    } catch (e) {
        print("${engineName} ${scriptName} errored");
    }
}

String genDartWithBoilerplate(String contents) {
    final endImportsIdx = contents.indexOf("// END IMPORTS");
    if (endImportsIdx == -1) {
        print("SCRIPT REQUIRES '// END IMPORTS'");
    }
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
                iterations += 1;
            }
            final end = get_milliseconds();
            print((end - start) / iterations);
        }
    """;
    return tempContents;
}

String genZigWithBoilerplate(String contents) {
    final endImportsIdx = contents.indexOf("// END IMPORTS");
    if (endImportsIdx == -1) {
        print("SCRIPT REQUIRES '// END IMPORTS'");
    }
    final importContents = contents.substring(0, endImportsIdx);
    final codeContents = contents.substring(endImportsIdx);
    final tempContents = importContents + """
        var stdout: std.fs.File.Writer = undefined;
        const vexlib = @import("./vexlib.zig");
        const Float = vexlib.Float;
        fn print(x: f64) void {
            stdout.print("{s}\\n", .{ Float.toString(x, 10).raw() }) catch @panic("PRINT FAILED");
        }
        fn get_milliseconds() i64 {
            return @divTrunc(std.time.microTimestamp(), 1000);
        }
        const TIME_LIMIT = ${benchtime};
    """ + "\n" + codeContents + """
        pub fn main() void {
            var generalPurposeAllocator = std.heap.GeneralPurposeAllocator(.{}){};
            const allocator = generalPurposeAllocator.allocator();
            vexlib.init(&allocator);

            stdout = std.io.getStdOut().writer();

            const start = get_milliseconds();
            var iterations: f64 = 0;
            while (get_milliseconds() - start < TIME_LIMIT) {
                std.mem.doNotOptimizeAway(benchit());
                iterations += 1;
            }
            const end = get_milliseconds();
            print(@as(f64, @floatFromInt(end - start)) / iterations);
        }
    """;
    return tempContents;
}

String genJSWithBoilerplate(String contents) {
    final tempContents = """
        var print;
        if (typeof print === "undefined") {
            print = console.log;
        }
        const get_milliseconds = Date.now;
        const TIME_LIMIT = ${benchtime};
    """ + "\n" + contents + """
        const start = get_milliseconds();
        let iterations = 0;
        while (get_milliseconds() - start < TIME_LIMIT) {
            benchit();
            iterations += 1;
        }
        const end = get_milliseconds();
        print((end - start) / iterations);
    """;
    return tempContents;
}

String genPythonWithBoilerplate(String contents) {
    final tempContents = """
import time

def get_milliseconds():
    return round(time.time() * 1000)

TIME_LIMIT = ${benchtime}
""" + "\n" + contents + """
start = get_milliseconds()
iterations = 0
while (get_milliseconds() - start < TIME_LIMIT):
    benchit()
    iterations += 1

end = get_milliseconds()
print((end - start) / iterations)
""";
    return tempContents;
}

Future<void> benchScript(String scriptName) async {
    // init stat storage
    for (final engineName in runtimes.keys) {
        final engine = runtimes[engineName]!;
        engine[scriptName] = Stats(
            time: -1
        );
    }

    // generate js temp source file
    final jsFile = File("./benchmark-scripts/js/${scriptName}.js");
    final jsContents = genJSWithBoilerplate(jsFile.readAsStringSync());
    File("./temp.js").writeAsStringSync(jsContents);

    // generate python temp source file
    final pyFile = File("./benchmark-scripts/python/${scriptName}.py");
    final pyContents = genPythonWithBoilerplate(pyFile.readAsStringSync());
    File("./temp.py").writeAsStringSync(pyContents);

    // generate dart temp source file
    final dartFile = File("./benchmark-scripts/dart/${scriptName}.dart");
    final dartContents = genDartWithBoilerplate(dartFile.readAsStringSync());
    File("./temp.dart").writeAsStringSync(dartContents);

    // generate zig temp source file
    final zigFile = File("./benchmark-scripts/zig/${scriptName}.zig");
    final zigContents = genZigWithBoilerplate(zigFile.readAsStringSync());
    File("./temp.zig").writeAsStringSync(zigContents);

    // compile code
    print("Compiling Dart code...");
    await Process.run("dart", ["compile", "exe", "temp.dart"]);
    await Process.run("dart", ["compile", "wasm", "temp.dart"]);
    await Process.run("dart", ["compile", "jit-snapshot", "temp.dart"]);
    await Process.run("dart", ["compile", "js", "temp.dart", "-O1", "-o", "outO1.js"]);
    await Process.run("dart", ["compile", "js", "temp.dart", "-O2", "-o", "outO2.js"]);
    await Process.run("dart", ["compile", "js", "temp.dart", "-O2", "-o", "outO3.js"]);
    await Process.run("dart", ["compile", "js", "temp.dart", "-O3", "-o", "outO4.js"]);

    print("Compiling Zig code...");
    await Process.run("zig", ["build-exe", "temp.zig", "-O", "ReleaseSafe", "-femit-bin=tempzigsafe"]);
    await Process.run("zig", ["build-exe", "temp.zig", "-O", "ReleaseSmall", "-femit-bin=tempzigsmall"]);
    await Process.run("zig", ["build-exe", "temp.zig", "-O", "ReleaseFast", "-femit-bin=tempzigfast"]);

    // run benchmark for each runtime
    for (String runtimeName in runtimes.keys) {
        final engine = runtimes[runtimeName]!;
        // wait for between runs to cool down the CPU
        await wait();
        runEngine(runtimeName, scriptName, engine["cmd"] as String);
    }
}

void cleanup() {
    Directory("./").listSync().forEach((file) {
        final fileName = file.uri.pathSegments.last;
        if (fileName.startsWith("temp") || fileName.startsWith("out")) {
            try {
                file.deleteSync();
            } catch (e) {
                // file probably doesn't exist
            }
        }
    });
}

int calcNumCrashes(Map<String, Object> engine) {
    int crashes = 0;
    for (int i = 0; i < scriptNames.length; i++) {
        final stats = engine[scriptNames[i]] as Stats;
        double time = stats.time;
        if (time == -1) {
            crashes++;
        }
    }
    return crashes;
}

double calcAvgTime(Map<String, Object> engine) {
    double avg = 0;
    double crashes = 0;

    for (int i = 0; i < scriptNames.length; i++) {
        final scriptStats = engine[scriptNames[i]] as Stats;
        double time = scriptStats.time;
        if (time == -1) {
            crashes++;
        } else {
            avg += time;
        }
    }

    return avg / (scriptNames.length - crashes);
}



List<List<String>> genStatsTable() {
    List<List<String>> statRows = [];

    double nodeAvgTime = calcAvgTime(runtimes["node"]!);

    for (final engineName in runtimes.keys) {
        final engineNameKey = engineName;
        final engine = runtimes[engineNameKey]!;

        List<String> row = [engineName];
        double avgTime = calcAvgTime(engine);
        int numCrashes = calcNumCrashes(engine);
        
        for (int i = 0; i < scriptNames.length; i++) {
            final stats = engine[scriptNames[i]] as Stats;
            row.add("${stats.time.toStringAsFixed(1)}");
        }
        
        // average column
        if (scriptNames.length != numCrashes) {
            row.add("${avgTime.toStringAsFixed(1)}");
        } else {
            row.add("Error");
        }

        // relative to node column
        if (scriptNames.length != numCrashes) {
            row.add("${(avgTime / nodeAvgTime).toStringAsFixed(2)}");
        } else {
            row.add("Error");
        }

        statRows.add(row);
    }

    statRows.sort((a, b) {
        final aStr = a[scriptNames.length + 1];
        final bStr = b[scriptNames.length + 1];
        final aNum = aStr.contains("Error") ? 1000000.0 : double.parse(aStr);
        final bNum = bStr.contains("Error") ? 1000000.0 : double.parse(bStr);

        return ((aNum - bNum) * 100).round();
    });

    statRows.insert(0, ["", ...scriptNames, "Average", "Relative to Node"]);

    return statRows;
}

void printTable(List<List<String>> table) {
    List<int> columnWidths = List.filled(table[0].length, 0);

    for (List<String> row in table) {
        for (int c = 0; c < row.length; c++) {
            if (row[c].length > columnWidths[c]) {
                columnWidths[c] = row[c].length;
            }
        }
    }

    for (List<String> row in table) {
        for (int c = 0; c < row.length; c++) {
            if (c == 0) {
                row[c] = row[c].padRight(columnWidths[c] + 1, " ") + ' |';
            } else {
                row[c] = row[c].padLeft(columnWidths[c] + 1, " ") + ' |';
            }
        }
        print("| " + row.join(""));
    }
}

void main() async {
    cleanup();

    // run benchmarks
    for (int i = 0; i < scriptNames.length; i++) {
        await benchScript(scriptNames[i]);
    }

    cleanup();

    // display results
    final table = genStatsTable();
    print("\nResults in milliseconds (lower is better):");
    printTable(table);

}
