/*
    modified from https://www.khanacademy.org/computer-programming/i/5919189559197696
    under MIT License
*/

let pixels = new Uint8ClampedArray(600 * 600);
let _abs = Math.abs;
let _sqrt = Math.sqrt;

function benchit() {
    for (let x = 0; x < 600; x++) {
        for (let y = 0; y < 600; y++) {
            let a = 4 * x / 600 - 2;
            let b = 4 * y / 600 - 2;
            let iter = 0;
            let maxIter = 200;
            let ca = a;
            let cb = b;
            while (iter < maxIter) {
                let aa = a * a - b * b;
                let bb = 2 * a * b;
                a = aa + ca;
                b = bb + cb;
                if (_abs(a + b) > 16) {
                    break;
                }
                iter++;
            }
            let bright = iter / maxIter;
            bright = _sqrt(bright) * 150;
            if (iter === maxIter) {
                bright = 255;
            }
            let p = (x + y * 600) << 2;
            pixels[p + 0] = 255 - bright;
            pixels[p + 1] = 255 - bright;
            pixels[p + 2] = 255 - bright;
        }
    }   
}
