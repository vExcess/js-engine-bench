/*
    modified from https://www.khanacademy.org/computer-programming/i/5919189559197696
    under MIT License
*/

import 'dart:typed_data';
import 'dart:math' as Math;

// END IMPORTS

final pixels = new Uint8List(600 * 600 * 4);

void benchit() {
    for (int x = 0; x < 600; x++) {
        for (int y = 0; y < 600; y++) {
            double a = 4 * x / 600 - 2;
            double b = 4 * y / 600 - 2;
            int iter = 0;
            int maxIter = 200;
            double ca = a;
            double cb = b;
            while (iter < maxIter) {
                double aa = a * a - b * b;
                double bb = 2 * a * b;
                a = aa + ca;
                b = bb + cb;
                if ((a + b).abs() > 16) {
                    break;
                }
                iter++;
            }
            double bright = iter / maxIter;
            bright = Math.sqrt(bright) * 150;
            if (iter == maxIter) {
                bright = 255;
            }
            int p = (x + y * 600) << 2;
            pixels[p + 0] = (255 - bright).toInt();
            pixels[p + 1] = (255 - bright).toInt();
            pixels[p + 2] = (255 - bright).toInt();
        }
    }   
}
