"""
    modified from https://www.khanacademy.org/computer-programming/i/5919189559197696
    under MIT License
"""

import math
import array

# END IMPORTS

pixels = array.array('B', [0] * (600 * 600 * 4)) # 'B' for unsigned char (byte)

def benchit():
    for x in range(600):
        for y in range(600):
            a = 4 * x / 600 - 2
            b = 4 * y / 600 - 2
            iter_count = 0  # Renamed to avoid conflict with built-in 'iter'
            max_iter = 200
            ca = a
            cb = b
            while iter_count < max_iter:
                aa = a * a - b * b
                bb = 2 * a * b
                a = aa + ca
                b = bb + cb
                if abs(a + b) > 16:
                    break
                iter_count += 1
            
            bright = iter_count / max_iter
            bright = math.sqrt(bright) * 150
            
            if iter_count == max_iter:
                bright = 255
            
            p = (x + y * 600) << 2  # Equivalent to (x + y * 600) * 4
            
            # Ensure bright is within 0-255 range and convert to integer
            pixel_value = int(max(0, min(255, 255 - bright)))
            
            pixels[p + 0] = pixel_value # Red
            pixels[p + 1] = pixel_value # Green
            pixels[p + 2] = pixel_value # Blue
            pixels[p + 3] = 255         # Alpha (fully opaque) - Dart code only set RGB, but for image display, Alpha is typically 255
