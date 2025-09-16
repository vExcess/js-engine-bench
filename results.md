# Results

## Brief
Node and Bun are roughly the same speed, however in certain benchmarks Bun is slightly faster. Static Hermes is over twice as fast as Hermes in some benchmarks, but identical to Hermes in others. For a small engine without JIT, QuickJS is surprisingly fast. Kiesel is by far the slowest JS engine, but has been getting significantly faster over time. Disappointingly, Dart is slower than Node despite knowing much more information at compile time. And as expected Zig is incredibly fast even when running in safe mode.

## September 14, 2025
OS: Linux Mint 22.1  
CPU: AMD Ryzen 8845HS

Note: Updated to Zig 0.15.1 from 0.14.1 which shows a significant regression in `zig fast` performance but shows a moderate performance increase for `zig small`. Also importantly `shermes` works again for me and is now only 7.8x slower than Node compared to the 10x slower the last time I tested it.
|                 | path-trace | mandelbrot | prime-factors | gaussian-blur | Average | Relative to Node |
| --------- | ---------  | --------- | --------- | --------- | --------- | --------- |
| zig fast        |        4.7 |       17.2 |          17.1 |           6.2 |    11.3 |             0.65 |
| zig small       |        6.3 |       17.2 |          17.2 |           6.2 |    11.7 |             0.67 |
| zig safe        |        6.7 |       17.4 |          17.4 |           9.3 |    12.7 |             0.73 |
| bun             |       13.9 |       16.8 |          18.0 |          10.9 |    14.9 |             0.85 |
| node            |       16.4 |       17.6 |          20.2 |          15.7 |    17.5 |             1.00 |
| dart js -O4     |       21.7 |       17.1 |          23.9 |          19.5 |    20.5 |             1.17 |
| dart js -O2     |       22.6 |       17.0 |          26.1 |          19.5 |    21.3 |             1.22 |
| dart js -O3     |       22.7 |       17.1 |          25.7 |          19.5 |    21.3 |             1.22 |
| dart jit        |       16.4 |       20.3 |          57.4 |          21.4 |    28.9 |             1.65 |
| dart run        |       16.5 |       20.3 |          59.9 |          21.9 |    29.7 |             1.70 |
| dart exe        |       27.6 |       20.2 |          71.3 |          18.8 |    34.5 |             1.97 |
| wasm (dart)     |       60.7 |       55.6 |         187.9 |          43.7 |    87.0 |             4.98 |
| shermes         |      144.0 |      103.8 |          63.3 |         239.9 |   137.8 |             7.88 |
| hermes          |      301.3 |      274.5 |         170.9 |         393.3 |   285.0 |            16.31 |
| node (jitless)  |      251.9 |      395.4 |         156.5 |         490.0 |   323.4 |            18.51 |
| quickjs         |      485.7 |      675.4 |         294.0 |         767.8 |   555.7 |            31.80 |
| python          |      509.0 |     1066.3 |         662.4 |        2107.5 |  1086.3 |            62.16 |
| boa             |     3731.0 |     3359.0 |        2322.5 |        4779.0 |  3547.9 |           203.01 |
| kiesel          |     2954.0 |     7959.0 |        2476.5 |        6565.0 |  4988.6 |           285.45 |

## June 1, 2025
OS: Linux Mint 22.1  
CPU: AMD Ryzen 8845HS

|                 | path-trace | mandelbrot | prime-factors | gaussian-blur | Average | Relative to Node |
| --------- | ---------  | --------- | --------- | --------- | --------- | --------- |
| zig fast        |        4.7 |       17.2 |          11.8 |           6.2 |    10.0 |             0.59 |
| zig small       |        6.3 |       17.1 |          17.7 |           6.2 |    11.8 |             0.70 |
| zig safe        |        6.9 |       17.5 |          11.8 |          11.9 |    12.1 |             0.72 |
| bun             |       14.3 |       16.9 |          18.2 |          10.9 |    15.1 |             0.90 |
| node            |       15.8 |       17.5 |          18.0 |          16.0 |    16.8 |             1.00 |
| dart js -O4     |       21.8 |       17.0 |          23.2 |          19.4 |    20.3 |             1.21 |
| dart js -O2     |       22.8 |       17.0 |          22.6 |          19.8 |    20.6 |             1.22 |
| dart js -O3     |       22.8 |       17.0 |          23.7 |          19.5 |    20.7 |             1.23 |
| dart jit        |       16.8 |       20.4 |          57.5 |          21.5 |    29.0 |             1.73 |
| dart run        |       16.5 |       20.4 |          59.9 |          22.0 |    29.7 |             1.77 |
| dart exe        |       27.7 |       20.1 |          71.2 |          19.1 |    34.5 |             2.05 |
| wasm (dart)     |       59.9 |       57.2 |         187.9 |          43.7 |    87.2 |             5.19 |
| hermes          |      298.1 |      244.4 |         161.4 |         434.3 |   284.5 |            16.93 |
| node (jitless)  |      249.8 |      395.5 |         164.5 |         506.0 |   328.9 |            19.57 |
| quickjs         |      463.4 |      744.8 |         329.5 |         812.8 |   587.6 |            34.96 |
| python          |      476.7 |     1053.3 |         640.0 |        2107.0 |  1069.3 |            62.82 |
| boa             |     3816.0 |     3384.0 |        2292.5 |        4758.0 |  3562.6 |           211.95 |
| kiesel          |     3315.0 |     8409.0 |        2624.0 |        6459.0 |  5201.8 |           309.46 |
| shermes         |       -1.0 |       -1.0 |          -1.0 |          -1.0 |   Error |            Error |

## Apr 17, 2025
OS: Linux Mint 22.1  
CPU: AMD Ryzen 8845HS

Note: I fixed how the delta time is calculated (it had an off by one error) so now the times are about double what they were before so compare the relative to Node values when comparing against historical data. Also shermes is still broken.
|                 | path-trace | mandelbrot | prime-factors | gaussian-blur | Average | Relative to Node |
| --------- | ---------  | --------- | --------- | --------- | --------- | --------- |
| zig fast        |        4.7 |       17.1 |          11.9 |           6.2 |    10.0 |             0.59 |
| zig small       |        6.2 |       17.1 |          17.7 |           6.2 |    11.8 |             0.70 |
| zig safe        |        6.9 |       17.5 |          11.8 |          12.6 |    12.2 |             0.72 |
| bun             |       14.3 |       16.9 |          18.0 |          12.8 |    15.5 |             0.91 |
| node            |       16.2 |       17.7 |          18.2 |          15.8 |    17.0 |             1.00 |
| dart js -O4     |       21.7 |       16.9 |          23.3 |          19.7 |    20.4 |             1.20 |
| dart js -O2     |       22.9 |       16.9 |          23.1 |          19.3 |    20.6 |             1.21 |
| dart js -O3     |       23.7 |       16.9 |          23.5 |          19.2 |    20.8 |             1.23 |
| dart jit        |       16.3 |       20.4 |          57.0 |          21.5 |    28.8 |             1.70 |
| dart run        |       16.7 |       20.2 |          59.0 |          22.6 |    29.6 |             1.75 |
| dart exe        |       27.9 |       20.4 |          74.0 |          18.8 |    35.3 |             2.08 |
| hermes          |      295.3 |      242.5 |         173.3 |         486.9 |   299.5 |            17.64 |
| node (jitless)  |      253.3 |      411.3 |         179.2 |         482.9 |   331.6 |            19.53 |
| quickjs         |      471.3 |      779.8 |         342.2 |         765.0 |   589.6 |            34.73 |
| boa             |     3780.0 |     3341.0 |        2326.5 |        4826.0 |  3568.4 |           210.18 |
| kiesel          |     3290.0 |     8450.0 |        2559.0 |        6447.0 |  5186.5 |           305.49 |
| shermes         |       -1.0 |       -1.0 |          -1.0 |          -1.0 |   Error |            Error |

## Apr 15, 2025
OS: Linux Mint 22.1  
CPU: AMD Ryzen 8845HS

Note: Something happened with shermes as none of its command line flags work anymore.
|                |    path-trace|    mandelbrot| prime-factors| gaussian-blur|       average|
| --------- | ---------  | --------- | --------- | --------- | --------- |
| bun            |             7|             8|             9|             6|             8|
| node           |             8|             9|             9|             8|             9|
| shermes        |            -1|            -1|            -1|            -1|           NaN|
| hermes         |           140|           127|            86|           209|           141|
| node (jitless) |           126|           197|            81|           246|           163|
| quickjs        |           232|           380|           166|           384|           291|
| boa            |          1815|          1629|          1160|          2322|          1732|
| kiesel         |          1607|          4132|          1303|          3319|          2590|
| dart jit       |           8|          10|          26|          10|            14|
| dart run       |           8|          10|          29|          11|            15|
| dart exe       |          14|          10|          55|           9|            22|

#### Relative to Node
|  |  |
| --------- | --------- |
| bun            |          0.9x slower|
| node           |            1x slower|
| shermes        |           ???|
| hermes         |           16x slower|
| node (jitless) |           18x slower|
| quickjs        |           32x slower|
| boa            |          192x slower|
| kiesel         |          288x slower|
| dart jit       |          1.5x slower|
| dart run       |          1.6x slower|
| dart exe       |          2.4x slower|

## Aug 29, 2024
OS: Linux Mint 21.2  
CPU: AMD Ryzen 5600H

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

#### Relative to Node
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

## Jul 26, 2024
OS: Linux Mint 21.2  
CPU: AMD Ryzen 5600H

Note: Due to a bug in Kiesel the engine aborts and core dumps while running the mandelbrot script.
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

#### Relative to Node
|  |  |
| --------- | --------- |
| bun            |          0.9x slower|
| node           |          1.0x slower|
| shermes        |           11x slower|
| hermes         |           16x slower|
| node (jitless) |           24x slower|
| quickjs        |           36x slower|
| boa            |          381x slower|
| kiesel         |         1728x slower|
