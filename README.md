# js-engine-bench
A simple to use benchmark for JavaScript engines. This is not a sophisticated benchmark, but should give a decent estimate of how each JS engine will perform on your system. I created this benchmark because I wanted to compare how Static Hermes with its ahead of time compilation would compare to Node.

### Run the Benchmark
Install all the supported JS engines and then run:
```ts
npx tsx ./src/js/index.ts
```
or
```ts
bun run ./src/js/index.ts
```

### Benchmark Scripts
- path tracer :: renders a 3d scene of spheres
- mandelbrot :: renders a mandelbrot
- prime factors :: searches for number with the most prime factors
- gaussian blur :: computes a gaussian blur on an image

### Execution
Each benchmark is run on each engine for 3 seconds with a 3 second pause between each run to give the CPU a chance to cool down. The time to execute each script is then tracked in milliseconds. I've calibrated each script to take roughly same amount of time on Node.

### Note
Adding support for more engines is easy, but the engines benchmarked above are the only ones
that I was interested in.

### Temporarily Add Engines to Path
```
export PATH="./:$PATH"
```

### Results
See the `results.md` file.


### Dart Benchmark
I just ported the JS scripts to Dart so I could benchmark Dart as well. To run the Dart benchmarks use
```ts
dart run src/dart/main.dart
```