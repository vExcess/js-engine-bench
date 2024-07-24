# js-engine-bench
A simple to use benchmark for JavaScript engines. This is certainly not the most accurate benchmark, but it should give you a reasonable idea of how each JS engine will perform on your system. I created this benchmark because I wanted to compare how Static Hermes with its ahead of time compilation would compare to Node.

### Run the Benchmark
Install all the supported JS engines and then run:
```ts
bun run ./src/index.ts 
```

### Benchmark Scripts
- path tracer :: renders a 3d scene of spheres
- mandelbrot :: renders a mandelbrot
- prime factors :: searches for number with the most prime factors
- gaussian blur :: computes a gaussian blur on an image

### Supported Engines
- Node
- Bun
- Hermes
- Static Hermes
- QuickJS

Support for more engines is very easy to add, but these are the only engines that I'm interested it.

### Execution
Each benchmark is run on each engine for 3 seconds with a 3 second pause between each run to give the CPU a chance to cool down. The time to execute each script is then tracked in milliseconds. I've calibrated each script to take roughly same amount of time on Node.

### Results
Here are the results I got using Linux Mint 5.8.4 on an AMD Ryzen 5600H. Node and Bun are roughly the same speed. In certain benchmarks Bun outperforms Node slightly. In some benchmarks Static Hermes is over twice as fast as Hermes, but in other benchmarks there is less of a difference. Unsurprisingly, QuickJS which is a small embeddable engine with few optimizations performs the worst.
|         |    path-trace|    mandelbrot| prime-factors| gaussian-blur|
| --------- | ---------  | --------- | --------- | --------- |
| node    |            19|            21|            21|            21|
| node (jitless)|           382|           586|           228|           774|
| bun     |            20|            20|            20|            15|
| hermes  |           323|           347|           300|           403|
| shermes |           308|           149|           115|           326|
| quickjs |           654|           990|           480|          1025|

### Temporarily Add Engines to Path
```
export PATH="./:$PATH"
```
