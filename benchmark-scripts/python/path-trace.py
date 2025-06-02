"""
    modified from https://www.khanacademy.org/computer-programming/new-webpage/5620563683229696
    under MIT License
"""

import math
import random as py_random
import array

# END IMPORTS

# In Python, random.Random() is the equivalent of Dart's Math.Random()
PRNG = py_random.Random()

def normalize(v: list[float]) -> list[float]:
    """Normalizes a 3D vector."""
    lv = 1 / math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2])
    return [v[0] * lv, v[1] * lv, v[2] * lv]

def reflect(v: list[float], n: list[float]) -> list[float]:
    """Reflects a vector v across a normal n."""
    dn = v[0] * n[0] + v[1] * n[1] + v[2] * n[2]
    return [
        v[0] - 2 * n[0] * dn,
        v[1] - 2 * n[1] * dn,
        v[2] - 2 * n[2] * dn
    ]

def uniform_vec() -> list[float]:
    """Generates a random uniform vector within a unit sphere."""
    while True:
        v = [random_range(-1, 1), random_range(-1, 1), random_range(-1, 1)]
        if math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]) < 1:
            return normalize(v)

def random_range(min_val: float, max_val: float) -> float:
    """Generates a random float within a specified range (inclusive)."""
    return min_val + (PRNG.random() * (max_val - min_val))

def lerp(value1: float, value2: float, amt: float) -> float:
    """Linear interpolation between two values."""
    return ((value2 - value1) * amt) + value1

sky = [0.7, 0.9, 1.0] # Renamed to avoid conflict with Python's built-in 'sky' if it were used elsewhere.

class TraceResult:
    """
    Represents the result of a ray trace operation.
    h: bool - True if a hit occurred, False otherwise.
    curr_t: float - The distance to the hit point.
    n: list[float] - The normal vector at the hit point.
    mat: list[float] or None - The material properties of the hit object.
    """
    def __init__(self, h: bool, curr_t: float, n: list[float], mat: list[float] | None):
        self.h = h
        self.curr_t = curr_t
        self.n = n
        self.mat = mat

def trace_sphere(o: list[float], d: list[float], s: list[float], mat: list[float]) -> TraceResult:
    """Traces a ray against a sphere."""
    # s is [sphere_x, sphere_y, sphere_z, radius]
    # mat is [r, g, b, emission, specular_factor, specular_probability]
    
    oc = [o[0] - s[0], o[1] - s[1], o[2] - s[2]]
    a = d[0] * d[0] + d[1] * d[1] + d[2] * d[2]
    b = 2 * (d[0] * oc[0] + d[1] * oc[1] + d[2] * oc[2])
    c = (oc[0] * oc[0] + oc[1] * oc[1] + oc[2] * oc[2]) - s[3] * s[3]
    disc = b * b - 4 * a * c
    
    if disc < 0: # No real solutions, no hit
        return TraceResult(h=False, curr_t=float('inf'), n=[0, 0, 0], mat=None)

    # Use the smaller of the two solutions for curr_t (the closest intersection point)
    curr_t = (-b - math.sqrt(disc)) / (2 * a)
    
    h = curr_t >= 0 # Check if the intersection is in front of the ray origin
    
    if h:
        # Calculate normal at hit point
        hit_x = o[0] + d[0] * curr_t
        hit_y = o[1] + d[1] * curr_t
        hit_z = o[2] + d[2] * curr_t
        
        normal_x = (hit_x - s[0]) / s[3]
        normal_y = (hit_y - s[1]) / s[3]
        normal_z = (hit_z - s[2]) / s[3]
        
        return TraceResult(
            h=h,
            curr_t=curr_t,
            n=normalize([normal_x, normal_y, normal_z]), # Ensure normal is normalized
            mat=mat
        )
    else:
        return TraceResult(
            h=h,
            curr_t=float('inf'), # Use infinity for no hit to simplify comparisons
            n=[0, 0, 0],
            mat=None
        )

def trace_scene(o: list[float], d: list[float], s: list[list[float]]) -> TraceResult:
    """Traces a ray against all objects in the scene."""
    init_t = float('inf') # Use float('inf') for initial large value
    curr_mat = sky
    n = [0, 0, 0]
    h = False
    
    # Scene is a list of [sphere_data, material_data] pairs.
    # The loop iterates by 2 to get both parts of the pair.
    for i in range(0, len(s) - 1, 2): 
        hit = trace_sphere(o, d, s[i], s[i + 1])
        if hit.h and hit.curr_t >= 0 and hit.curr_t < init_t:
            h = True
            init_t = hit.curr_t
            n = hit.n
            curr_mat = hit.mat
            
    return TraceResult(
        h=h,
        curr_t=init_t,
        n=n,
        mat=curr_mat
    )

def path_trace(o: list[float], d: list[float], s: list[list[float]]) -> list[float]:
    """Performs path tracing for a single ray."""
    col = [1.0, 1.0, 1.0] # Initialize color with full white (multiplicative)
    
    for i in range(12): # Max bounce depth
        hit = trace_scene(o, d, s)
        
        if hit.h:
            # Ensure hit.mat is not None before accessing elements
            if hit.mat is None:
                # This case should ideally not happen if trace_scene always sets mat on hit
                # but adding a check for robustness
                col[0] *= sky[0]
                col[1] *= sky[1]
                col[2] *= sky[2]
                break
            
            is_spec = hit.mat[5] > random_range(0, 1) # Specular probability
            
            # Apply material color and emission
            col[0] *= lerp(hit.mat[3] * hit.mat[0], 1, 1 if is_spec else 0)
            col[1] *= lerp(hit.mat[3] * hit.mat[1], 1, 1 if is_spec else 0)
            col[2] *= lerp(hit.mat[3] * hit.mat[2], 1, 1 if is_spec else 0)
            
            # If emission is high (e.g., light source), stop tracing further
            if hit.mat[3] > 1: # Emission value
                break
            
            # Move ray origin to hit point
            o = [
                o[0] + d[0] * hit.curr_t,
                o[1] + d[1] * hit.curr_t,
                o[2] + d[2] * hit.curr_t,
            ]
            
            # Determine new ray direction
            dd = uniform_vec() # Diffuse direction
            dd = normalize([
                dd[0] + hit.n[0],
                dd[1] + hit.n[1],
                dd[2] + hit.n[2],
            ])
            
            rd = normalize(reflect(d, hit.n)) # Reflected direction
            
            # Blend diffuse and reflected based on specular factor
            d = [
                lerp(dd[0], rd[0], hit.mat[4] * (1 if is_spec else 0)),
                lerp(dd[1], rd[1], hit.mat[4] * (1 if is_spec else 0)),
                lerp(dd[2], rd[2], hit.mat[4] * (1 if is_spec else 0)),
            ]
        else:
            # Ray hit the sky (missed all objects)
            if i >= 1: # If it's not the first bounce
                col[0] *= sky[0] * 2
                col[1] *= sky[1] * 2
                col[2] *= sky[2] * 2
            else: # First bounce, direct sky color
                col[0] *= sky[0]
                col[1] *= sky[1]
                col[2] *= sky[2]
            break
            
    return col

its = 1 # Iterations for progressive rendering

# Using array.array for typed lists like Dart's Float32List and Uint8List
# 'f' for float (Float32List equivalent)
# 'B' for unsigned char (Uint8List equivalent)
color_buffer = array.array('f', [0.0] * (400 * 400 * 4)) # Assuming max 400x400 image for buffer

scene = [
    # Red sphere: [x, y, z, radius], [r, g, b, emission, specular_factor, specular_probability]
    [-1.5, 0.5, 5, 0.5],
    [1.0, 0.0, 0.0, 0.5, 1.0, 0.01], # Red, little emission, highly specular, low spec prob
    
    # White light: [x, y, z, radius], [r, g, b, emission, specular_factor, specular_probability]
    [1.0, -1.0, 4.0, 0.35],
    [1.0, 1.0, 1.0, 20.0, 0.0, 0.0], # White, high emission (light source), diffuse
    
    # Green sphere
    [0.0, 0.5, 5.0, 0.5],
    [0.0, 1.0, 0.0, 0.5, 0.0, 0.0], # Green, diffuse
    
    # Blue sphere
    [1.5, 0.5, 5.0, 0.5],
    [0.0, 0.0, 1.0, 0.5, 1.0, 0.3], # Blue, little emission, highly specular, medium spec prob
    
    # Ground: [x, y, z, radius], [r, g, b, emission, specular_factor, specular_probability]
    [0.0, 10001.0, 5.0, 10000.0], # Large sphere acting as ground plane (y=1.0 plane equivalent)
    [1.0, 1.0, 1.0, 0.5, 0.9, 0.1] # White, diffuse, slightly specular
]

WIDTH = 210
HEIGHT = 210
image_data_globals = {
    "width": WIDTH,
    "height": HEIGHT,
    "data": array.array('B', [0] * (WIDTH * HEIGHT * 4)) # Uint8List (for final displayable image)
}
image_display_buffer = image_data_globals["data"] # Renamed to avoid conflict with `id`

def benchit():
    """Renders one iteration of the path tracing scene."""
    global its # Modify the global 'its' variable
    
    for i in range(WIDTH):
        for j in range(HEIGHT):
            # Calculate normalized device coordinates with random sub-pixel sampling
            u = ((i + random_range(-0.5, 0.5)) - (WIDTH / 2)) / WIDTH
            v = ((j + random_range(-0.5, 0.5)) - (HEIGHT / 2)) / HEIGHT
            
            ci = (i + j * WIDTH) << 2 # (i + j * WIDTH) * 4 to get byte index
            
            o = [0.0, 0.0, 0.0] # Ray origin (camera position)
            d = normalize([u, v, 1.0]) # Ray direction (pointing into the scene)
            
            curr_col = path_trace(o, d, scene) # Trace the ray
            
            # Accumulate color for progressive rendering
            # lerp(old_value, new_value, amount) -> old_value * (1 - amount) + new_value * amount
            # Here, amount is 1/its for averaging
            color_buffer[ci] = lerp(color_buffer[ci], curr_col[0], 1 / its)
            color_buffer[ci + 1] = lerp(color_buffer[ci + 1], curr_col[1], 1 / its)
            color_buffer[ci + 2] = lerp(color_buffer[ci + 2], curr_col[2], 1 / its)
            # Alpha channel is not accumulated, remains 1.0 (or 255 after conversion)
            
            # Apply gamma correction and convert to 0-255 byte values for display
            # Dart's Math.pow is equivalent to Python's ** operator
            image_display_buffer[ci] = min(255, int(math.pow(color_buffer[ci], 1 / 2.2) * 255))
            image_display_buffer[ci + 1] = min(255, int(math.pow(color_buffer[ci + 1], 1 / 2.2) * 255))
            image_display_buffer[ci + 2] = min(255, int(math.pow(color_buffer[ci + 2], 1 / 2.2) * 255))
            image_display_buffer[ci + 3] = 255 # Alpha channel (fully opaque)
            
    its += 1 # Increment iteration count
