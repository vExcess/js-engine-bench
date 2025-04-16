/*
    modified from https://www.khanacademy.org/computer-programming/new-webpage/5620563683229696
    under MIT License
*/

function normalize(v) {
    var lv = 1 / Math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    return [v[0] * lv, v[1] * lv, v[2] * lv];
}

function reflect(v, n) {
    var dn = v[0] * n[0] + v[1] * n[1] + v[2] * n[2];
    return [
        v[0] - 2 * n[0] * dn,
        v[1] - 2 * n[1] * dn,
        v[2] - 2 * n[2] * dn
    ];
}

function uniformVec() {
    var v = [random(-1, 1), random(-1, 1), random(-1, 1)];
    while (true) {
        if (Math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]) < 1) {
            return normalize(v);
        }
        v = [random(-1, 1), random(-1, 1), random(-1, 1)];
    }
}

//From Levi
function random(min, max){
    return min + (Math.random()*(max - min));
}

function lerp(value1, value2, amt){
    return ((value2 - value1)*amt) + value1;
}//}

var sky = [0.7, 0.9, 1];

function traceSphere(o, d, s, mat) {
    var oc = [o[0] - s[0], o[1] - s[1], o[2] - s[2]];
    var a = d[0] * d[0] + d[1] * d[1] + d[2] * d[2];
    var b = 2 * (d[0] * oc[0] + d[1] * oc[1] + d[2] * oc[2]);
    var c = (oc[0] * oc[0] + oc[1] * oc[1] + oc[2] * oc[2]) - s[3] * s[3];
    var disc = b * b - 4 * a * c;
    var currT = (-b - Math.sqrt(disc)) / (2 * a);
    
    var h = disc > 0 && currT >= 0;
    
    if (h) {
        return [
            h,
            currT,
            [
                (o[0] + d[0] * currT - s[0]) / s[3],
                (o[1] + d[1] * currT - s[1]) / s[3],
                (o[2] + d[2] * currT - s[2]) / s[3]
            ],
            mat
        ];
    } else {
        return [h, 100000, [0, 0, 0], null];
    }
}

function traceScene(o, d, s) {
    var initT = 10000000;
    var currMat = sky;
    var n = [0, 0, 0];
    var h = false;
    
    for (var i = 0; i < s.length - 1; i += 2) {
        var hit = traceSphere(o, d, s[i], s[i + 1]);
        if (hit[0] && hit[1] >= 0 && hit[1] < initT) {
            h = true;
            initT = hit[1];
            n = hit[2];
            currMat = hit[3];
        }
    }
    return [h, initT, n, currMat];
}

function pathTrace(o, d, s) {
    var col = [1, 1, 1];
    
    for (var i = 0; i < 12; ++i) {
        var hit = traceScene(o, d, s);
        if (hit[0]) {
            var isSpec = hit[3][5] > random(0, 1);
            
            col[0] *= lerp(hit[3][3] * hit[3][0], 1, isSpec);
            col[1] *= lerp(hit[3][3] * hit[3][1], 1, isSpec);
            col[2] *= lerp(hit[3][3] * hit[3][2], 1, isSpec);
            
            if (hit[3][3] > 1) break;
            
            o = [
                    o[0] + d[0] * hit[1],
                    o[1] + d[1] * hit[1],
                    o[2] + d[2] * hit[1],
                ]
            
            var dd = uniformVec();
            
            dd = normalize([
                    dd[0] + hit[2][0],
                    dd[1] + hit[2][1],
                    dd[2] + hit[2][2],
                ]);
            
            var rd = normalize(reflect(d, hit[2]));
            
            d = [
                    lerp(dd[0], rd[0], hit[3][4] * isSpec),
                    lerp(dd[1], rd[1], hit[3][4] * isSpec),
                    lerp(dd[2], rd[2], hit[3][4] * isSpec),
                ];
        } else {
            if (i >= 1) {
                col[0] *= sky[0] * 2;
                col[1] *= sky[1] * 2;
                col[2] *= sky[2] * 2;
            } else {
                col[0] *= sky[0];
                col[1] *= sky[1];
                col[2] *= sky[2];
            }
            break;
        }
    }
    
    return col;
}

var its = 1;

var colorBuffer = new Float32Array(400*400*4).fill(0);

var scene = [
    // Red sphere
    [-1.5, 0.5, 5, 0.5],
    [1, 0, 0, 0.5, 1, 0.01],
    
    // White light
    [1, -1, 4, 0.35],
    [1, 1, 1, 20, 0, 0],
    
    // Green sphere
    [0, 0.5, 5, 0.5],
    [0, 1, 0, 0.5, 0, 0],
    
    // Blue sphere
    [1.5, 0.5, 5, 0.5],
    [0, 0, 1, 0.5, 1, 0.3],
    
    // Ground
    [0, 10001, 5, 10000],
    [1, 1, 1, 0.5, 0.9, 0.1]
];
const WIDTH = 210;
const HEIGHT = 210;
var idg = {
    width: WIDTH,
    height: HEIGHT,
    data: new Uint8ClampedArray(WIDTH * HEIGHT * 4)
};
var id = idg.data;

function benchit(){
    var col = [0, 0, 0];
    for(var i = 0; i < WIDTH; i++){
        for(var j = 0; j < HEIGHT; j++){
            var u = ((i + random(-0.5, 0.5)) - (WIDTH / 2))/WIDTH, v = ((j + random(-0.5, 0.5)) - (HEIGHT / 2))/HEIGHT;
            var ci = (i + j*WIDTH) << 2;
            
            var o = [0, 0, 0];
            var d = normalize([u, v, 1]);
            var col = pathTrace(o, d, scene);
            
            colorBuffer[ci] = lerp(colorBuffer[ci], col[0], 1 / its);
            colorBuffer[ci + 1] = lerp(colorBuffer[ci + 1], col[1], 1 / its);
            colorBuffer[ci + 2] = lerp(colorBuffer[ci + 2], col[2], 1 / its);
            
            id[ci] = Math.pow(colorBuffer[ci], 1/2.2)*255;
            id[ci + 1] = Math.pow(colorBuffer[ci + 1], 1/2.2)*255;
            id[ci + 2] = Math.pow(colorBuffer[ci + 2], 1/2.2)*255;
            id[ci + 3] = 255;
        }
    }
    its++;
}
