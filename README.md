# js-engine-bench
A simple to use benchmark for JavaScript engines. This is certainly not the most accurate benchmark, but it should give you a reasonable idea of how each JS engine will perform on your system. I created this benchmark because I wanted to compare how Static Hermes with its ahead of time compilation would compare to Node.

### Run the Benchmark
Install all the supported JS engines and then run:
```ts
npx tsx ./src/index.ts
```
I normally use Bun for running TS, but for some reason the benchmark crashes when run with Bun and doesn't when run with Node.

### Benchmark Scripts
- path tracer :: renders a 3d scene of spheres
- mandelbrot :: renders a mandelbrot
- prime factors :: searches for number with the most prime factors
- gaussian blur :: computes a gaussian blur on an image

### Execution
Each benchmark is run on each engine for 3 seconds with a 3 second pause between each run to give the CPU a chance to cool down. The time to execute each script is then tracked in milliseconds. I've calibrated each script to take roughly same amount of time on Node.

### Results
Here are the results I got using Linux Mint 5.8.4 on an AMD Ryzen 5600H. Node and Bun are roughly the same speed, however in certain benchmarks Bun is slightly faster. In some benchmarks Static Hermes is over twice as fast as Hermes, but in other benchmarks there is less of a difference. For a small engine without JIT, QuickJS is surprisingly fast. Lastly Kiesel is
by far the slowest JS engine of the ones tested.

|                |    path-trace|    mandelbrot| prime-factors| gaussian-blur|       average|
| --------- | ---------  | --------- | --------- | --------- | --------- |
| bun            |            10|            10|            11|             8|            10|
| node           |            12|            11|            11|            11|            11|
| shermes        |           164|            76|            58|           169|           117|
| hermes         |           159|           183|           154|           196|           173|
| node (jitless) |           202|           332|           124|           415|           268|
| quickjs        |           341|           515|           237|           497|           398|
| boa            |          2989|          4546|          3400|          5809|          4186|
| kiesel         |         21231|Engine Crashed|          9304|         26490|         19008|

### Relative to Node
|  |  |
| --------- | --------- |
| bun            |            0.9|
| node           |            1.0|
| shermes        |           10.6|
| hermes         |           15.7|
| node (jitless) |           24.4|
| quickjs        |           36.2|
| boa            |          380.5|
| kiesel         |         1728.0|

### Note
Adding support for more engines is easy, but the engines benchmarked above are the only ones
that I was interested in.

### Temporarily Add Engines to Path
```
export PATH="./:$PATH"
```
