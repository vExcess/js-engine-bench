# js-engine-bench
A simple to use benchmark for JavaScript engines. This is not the most accurate benchmark and there is a bit of variance between runs, but it should give you a good estimate of how each JS engine will perform on your system. I created this benchmark because I wanted to compare how Static Hermes with its ahead of time compilation would compare to Node.

### Run the Benchmark
Install all the supported JS engines and then run:
```ts
npx tsx ./src/index.ts
```
or
```ts
bun run ./src/index.ts
```

### Benchmark Scripts
- path tracer :: renders a 3d scene of spheres
- mandelbrot :: renders a mandelbrot
- prime factors :: searches for number with the most prime factors
- gaussian blur :: computes a gaussian blur on an image

### Execution
Each benchmark is run on each engine for 3 seconds with a 3 second pause between each run to give the CPU a chance to cool down. The time to execute each script is then tracked in milliseconds. I've calibrated each script to take roughly same amount of time on Node.

### Results
Here are the results I got using Linux Mint 21.2 on an AMD Ryzen 5600H. Node and Bun are roughly the same speed, however in certain benchmarks Bun is slightly faster. In some benchmarks Static Hermes is over twice as fast as Hermes, but in other benchmarks there is less of a difference. For a small engine without JIT, QuickJS is surprisingly fast. Lastly Kiesel is by far the slowest JS engine of the ones tested.

|                |    path-trace|    mandelbrot| prime-factors| gaussian-blur|       average|
| --------- | ---------  | --------- | --------- | --------- | --------- |
| bun            |            10|            10|            10|             7|             9|
| node           |            12|            10|            10|            10|            11|
| shermes        |           162|            74|            58|           163|           114|
| hermes         |           162|           179|           156|           184|           170|
| node (jitless) |           201|           318|           122|           415|           264|
| quickjs        |           330|           483|           226|           493|           383|
| boa            |          2911|          4556|          3484|          6003|          4239|
| kiesel         |          4883|          8630|          3136|         10323|          6743|

### Relative to Node
|  |  |
| --------- | --------- |
| bun            |          0.9x slower|
| node           |            1x slower|
| shermes        |           10x slower|
| hermes         |           15x slower|
| node (jitless) |           24x slower|
| quickjs        |           34x slower|
| boa            |          385x slower|
| kiesel         |          613x slower|

### Note
Adding support for more engines is easy, but the engines benchmarked above are the only ones
that I was interested in.

### Temporarily Add Engines to Path
```
export PATH="./:$PATH"
```
