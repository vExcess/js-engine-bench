import array
import math

# END IMPORTS

def convolve_rgba(src: array.ArrayType, out: array.ArrayType, line: array.ArrayType, coeff: array.ArrayType, width: int, height: int):
    """
    for gaussian blur
    takes src image and writes the blurred and transposed result into out
    """
    
    # Python equivalent for Dart's Uint32List elements being read as rgba integers.
    # In Python, we'll work with individual R, G, B, A components explicitly or packed integers.
    # The current approach unpacks rgba from a single integer (like Dart's Uint32List element).

    # Initialize variables with None or 0.0 for clarity, though Python handles scope naturally
    prev_src_r, prev_src_g, prev_src_b, prev_src_a = 0, 0, 0, 0
    curr_src_r, curr_src_g, curr_src_b, curr_src_a = 0, 0, 0, 0
    curr_out_r, curr_out_g, curr_out_b, curr_out_a = 0.0, 0.0, 0.0, 0.0
    prev_out_r, prev_out_g, prev_out_b, prev_out_a = 0.0, 0.0, 0.0, 0.0
    prev_prev_out_r, prev_prev_out_g, prev_prev_out_b, prev_prev_out_a = 0.0, 0.0, 0.0, 0.0

    src_index, out_index, line_index = 0, 0, 0
    
    coeff_a0, coeff_a1, coeff_b1, coeff_b2 = 0.0, 0.0, 0.0, 0.0

    for i in range(height):
        src_index = i * width
        out_index = i
        line_index = 0

        # left to right
        rgba = src[src_index] # Assuming src is a list of integers (representing Uint32)

        prev_src_r = rgba & 0xff
        prev_src_g = (rgba >> 8) & 0xff
        prev_src_b = (rgba >> 16) & 0xff
        prev_src_a = (rgba >> 24) & 0xff

        prev_prev_out_r = prev_src_r * coeff[6]
        prev_prev_out_g = prev_src_g * coeff[6]
        prev_prev_out_b = prev_src_b * coeff[6]
        prev_prev_out_a = prev_src_a * coeff[6]

        prev_out_r = prev_prev_out_r
        prev_out_g = prev_prev_out_g
        prev_out_b = prev_prev_out_b
        prev_out_a = prev_prev_out_a

        coeff_a0 = coeff[0]
        coeff_a1 = coeff[1]
        coeff_b1 = coeff[4]
        coeff_b2 = coeff[5]

        for j in range(width):
            rgba = src[src_index]
            curr_src_r = rgba & 0xff
            curr_src_g = (rgba >> 8) & 0xff
            curr_src_b = (rgba >> 16) & 0xff
            curr_src_a = (rgba >> 24) & 0xff

            curr_out_r = curr_src_r * coeff_a0 + prev_src_r * coeff_a1 + prev_out_r * coeff_b1 + prev_prev_out_r * coeff_b2
            curr_out_g = curr_src_g * coeff_a0 + prev_src_g * coeff_a1 + prev_out_g * coeff_b1 + prev_prev_out_g * coeff_b2
            curr_out_b = curr_src_b * coeff_a0 + prev_src_b * coeff_a1 + prev_out_b * coeff_b1 + prev_prev_out_b * coeff_b2
            curr_out_a = curr_src_a * coeff_a0 + prev_src_a * coeff_a1 + prev_out_a * coeff_b1 + prev_prev_out_a * coeff_b2

            prev_prev_out_r = prev_out_r
            prev_prev_out_g = prev_out_g
            prev_prev_out_b = prev_out_b
            prev_prev_out_a = prev_out_a

            prev_out_r = curr_out_r
            prev_out_g = curr_out_g
            prev_out_b = curr_out_b
            prev_out_a = curr_out_a

            prev_src_r = curr_src_r
            prev_src_g = curr_src_g
            prev_src_b = curr_src_b
            prev_src_a = curr_src_a

            line[line_index] = prev_out_r
            line[line_index + 1] = prev_out_g
            line[line_index + 2] = prev_out_b
            line[line_index + 3] = prev_out_a
            line_index += 4
            src_index += 1 # equivalent to src_index++
        
        src_index -= 1 # equivalent to src_index--
        line_index -= 4
        out_index += height * (width - 1)

        # right to left
        rgba = src[src_index]

        prev_src_r = rgba & 0xff
        prev_src_g = (rgba >> 8) & 0xff
        prev_src_b = (rgba >> 16) & 0xff
        prev_src_a = (rgba >> 24) & 0xff

        prev_prev_out_r = prev_src_r * coeff[7]
        prev_prev_out_g = prev_src_g * coeff[7]
        prev_prev_out_b = prev_src_b * coeff[7]
        prev_prev_out_a = prev_src_a * coeff[7]

        prev_out_r = prev_prev_out_r
        prev_out_g = prev_prev_out_g
        prev_out_b = prev_prev_out_b
        prev_out_a = prev_prev_out_a

        curr_src_r = prev_src_r
        curr_src_g = prev_src_g
        curr_src_b = prev_src_b
        curr_src_a = prev_src_a

        coeff_a0 = coeff[2]
        coeff_a1 = coeff[3]

        for j in range(width - 1, -1, -1): # Iterate from width - 1 down to 0
            curr_out_r = curr_src_r * coeff_a0 + prev_src_r * coeff_a1 + prev_out_r * coeff_b1 + prev_prev_out_r * coeff_b2
            curr_out_g = curr_src_g * coeff_a0 + prev_src_g * coeff_a1 + prev_out_g * coeff_b1 + prev_prev_out_g * coeff_b2
            curr_out_b = curr_src_b * coeff_a0 + prev_src_b * coeff_a1 + prev_out_b * coeff_b1 + prev_prev_out_b * coeff_b2
            curr_out_a = curr_src_a * coeff_a0 + prev_src_a * coeff_a1 + prev_out_a * coeff_b1 + prev_prev_out_a * coeff_b2

            prev_prev_out_r = prev_out_r
            prev_prev_out_g = prev_out_g
            prev_prev_out_b = prev_out_b
            prev_prev_out_a = prev_out_a

            prev_out_r = curr_out_r
            prev_out_g = curr_out_g
            prev_out_b = curr_out_b
            prev_out_a = curr_out_a

            prev_src_r = curr_src_r
            prev_src_g = curr_src_g
            prev_src_b = curr_src_b
            prev_src_a = curr_src_a

            rgba = src[src_index]
            curr_src_r = rgba & 0xff
            curr_src_g = (rgba >> 8) & 0xff
            curr_src_b = (rgba >> 16) & 0xff
            curr_src_a = (rgba >> 24) & 0xff

            # Combine individual RGBA components into a single 32-bit integer (similar to Dart's Uint32)
            # Ensure values are clamped to 0-255 before shifting
            # Note: The Dart code uses `toInt()` which implicitly truncates floats.
            # In Python, we explicitly convert to int and clamp.
            r_val = int(max(0, min(255, (line[line_index] + prev_out_r))))
            g_val = int(max(0, min(255, (line[line_index + 1] + prev_out_g))))
            b_val = int(max(0, min(255, (line[line_index + 2] + prev_out_b))))
            a_val = int(max(0, min(255, (line[line_index + 3] + prev_out_a))))

            rgba_out = (r_val << 0) | \
                       (g_val << 8) | \
                       (b_val << 16) | \
                       (a_val << 24)

            out[out_index] = rgba_out

            src_index -= 1
            line_index -= 4
            out_index -= height

def benchit():
    # In Python, we'll use 'array.array' for typed lists, similar to Dart's typed data lists.
    # 'B' for unsigned char (byte)
    # 'I' for unsigned int (typically 4 bytes, matching Uint32List behavior)
    # 'f' for float (matching Float32List behavior)

    image_data = {
        "width": 800,
        "height": 800,
        "data": array.array('B', [0] * (800 * 800 * 4)) # Uint8List
    }
    w = image_data["width"]
    h = image_data["height"]
    radius = 0.5
    p = image_data["data"]

    # Unify input data type: Convert Uint8List (bytes) to Uint32List (integers)
    # This involves packing 4 bytes into 1 integer.
    src_bytes = bytes(p) # Convert array.array('B') to bytes
    src32 = array.array('I', [
        int.from_bytes(src_bytes[i:i+4], byteorder='little') # Assuming little-endian for RGBA
        for i in range(0, len(src_bytes), 4)
    ])

    out = array.array('I', [0] * len(src32))
    tmp_line = array.array('f', [0.0] * (max(w, h) * 4))

    # gaussCoef
    sigma = radius
    if sigma < 0.5:
        sigma = 0.5
    
    a = math.exp(0.726 * 0.726) / sigma
    g1 = math.exp(-a)
    g2 = math.exp(-2 * a)
    k = (1 - g1) * (1 - g1) / (1 + 2 * a * g1 - g2)
    
    a0 = k
    a1 = k * (a - 1) * g1
    a2 = k * (a + 1) * g1
    a3 = -k * g2
    b1 = 2 * g1
    b2 = -g2
    left_corner = (a0 + a1) / (1 - b1 - b2)
    right_corner = (a2 + a3) / (1 - b1 - b2)
    
    coeff = array.array('f', [a0, a1, a2, a3, b1, b2, left_corner, right_corner])

    convolve_rgba(src32, out, tmp_line, coeff, w, h)
    convolve_rgba(out, src32, tmp_line, coeff, h, w)
