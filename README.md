# js-engine-bench
Originally a simple to use benchmark for JavaScript engines. This is not a sophisticated benchmark, but should give a decent estimate of how each JS engine will perform on your system. I created this benchmark because I wanted to compare how Static Hermes' ahead of time compilation would compare to Node's JIT compilation.

Since this project's original creation I have added the following non-JavaScript languages to the benchmark: Dart, Zig

Disclaimer: These benchmarks are mostly just tight math loops which may not be representative of your use case.

## Results
See [https://github.com/vExcess/js-engine-bench/blob/main/results.md](https://github.com/vExcess/js-engine-bench/blob/main/results.md)

## Run the Benchmark
Install the supported JS engines and then run the following. Apologies to those that don't have Dart installed. I originally wrote the start script in TypeScript, but rewrote it in Dart because Dart is a lot nicer for this type of task.
```ts
dart run do-benchmarks.dart
```

## Benchmark Scripts
Note: JS versions of benchmarks must be in ES5 because mquickjs doesn't support ES6
- path tracer :: renders a 3d scene of spheres
- mandelbrot :: renders a mandelbrot
- prime factors :: searches for number with the most prime factors
- gaussian blur :: computes a gaussian blur on an image

## Execution
Each benchmark is run on each engine for 3 seconds with a 3 second pause between each run to give the CPU a chance to cool down. The time to execute each script is then tracked in milliseconds. I've calibrated each script to take roughly same amount of time on Node.

## Bench More Things
Adding support for more engines is easy, simply add them to the `runtimes` object in the top of the `do-benchmarks.dart` file. However, I'm only including engines and languages that I'm interested in to this repo.

## Temporarily Add Engines to Path
If you downloaded the engines to the root directory of this repo you can temporarily add them to your path with the following. Make sure to `chmod 755 ` downloaded engine binaries.
```
export PATH="./:$PATH"
```
