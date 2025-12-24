/*
    modified from https://www.khanacademy.org/computer-programming/i/5919189559197696
    under MIT License
*/

var pixels = new Uint8ClampedArray(600 * 600);
var _abs = Math.abs;
var _sqrt = Math.sqrt;

function benchit() {
    for (var x = 0; x < 600; x++) {
        for (var y = 0; y < 600; y++) {
            var a = 4 * x / 600 - 2;
            var b = 4 * y / 600 - 2;
            var iter = 0;
            var maxIter = 200;
            var ca = a;
            var cb = b;
            while (iter < maxIter) {
                var aa = a * a - b * b;
                var bb = 2 * a * b;
                a = aa + ca;
                b = bb + cb;
                if (_abs(a + b) > 16) {
                    break;
                }
                iter++;
            }
            var bright = iter / maxIter;
            bright = _sqrt(bright) * 150;
            if (iter === maxIter) {
                bright = 255;
            }
            var p = (x + y * 600) << 2;
            pixels[p + 0] = 255 - bright;
            pixels[p + 1] = 255 - bright;
            pixels[p + 2] = 255 - bright;
        }
    }   
}
