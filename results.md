# Results

## Brief
Node and Bun are roughly the same speed, however in certain benchmarks Bun is slightly faster. Static Hermes is over twice as fast as Hermes in some benchmarks, but identical to Hermes in others. For a small engine without JIT, QuickJS is surprisingly fast. Kiesel is by far the slowest JS engine, but has been getting significantly faster over time. Disappointingly, Dart is slower than Node despite knowing much more information at compile time.

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
