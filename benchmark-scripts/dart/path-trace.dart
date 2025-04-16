/*
    modified from https://www.khanacademy.org/computer-programming/new-webpage/5620563683229696
    under MIT License
*/

import "dart:math" as Math;
import 'dart:typed_data';

// END IMPORTS

final PRNG = new Math.Random();

List<double> normalize(List<double> v) {
    double lv = 1 / Math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    return [v[0] * lv, v[1] * lv, v[2] * lv];
}

List<double> reflect(List<double> v, List<double> n) {
    double dn = v[0] * n[0] + v[1] * n[1] + v[2] * n[2];
    return [
        v[0] - 2 * n[0] * dn,
        v[1] - 2 * n[1] * dn,
        v[2] - 2 * n[2] * dn
    ];
}

List<double> uniformVec() {
    List<double> v = [random(-1, 1), random(-1, 1), random(-1, 1)];
    while (true) {
        if (Math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]) < 1) {
            return normalize(v);
        }
        v = [random(-1, 1), random(-1, 1), random(-1, 1)];
    }
}

//From Levi
double random(double min, double max){
    return min + (PRNG.nextDouble()*(max - min));
}

double lerp(double value1, double value2, double amt){
    return ((value2 - value1)*amt) + value1;
}//}

List<double> sky = [0.7, 0.9, 1];

class TraceResult {
    bool h;
    double currT;
    List<double> n;
    List<double>? mat;
    TraceResult({
        required this.h,
        required this.currT,
        required this.n,
        required this.mat,
    });
}

TraceResult traceSphere(List<double> o, List<double> d, List<double> s, List<double> mat) {
    List<double> oc = [o[0] - s[0], o[1] - s[1], o[2] - s[2]];
    double a = d[0] * d[0] + d[1] * d[1] + d[2] * d[2];
    double b = 2 * (d[0] * oc[0] + d[1] * oc[1] + d[2] * oc[2]);
    double c = (oc[0] * oc[0] + oc[1] * oc[1] + oc[2] * oc[2]) - s[3] * s[3];
    double disc = b * b - 4 * a * c;
    double currT = (-b - Math.sqrt(disc)) / (2 * a);
    
    bool h = disc > 0 && currT >= 0;
    
    if (h) {
        return TraceResult(
            h: h,
            currT: currT,
            n: [
                (o[0] + d[0] * currT - s[0]) / s[3],
                (o[1] + d[1] * currT - s[1]) / s[3],
                (o[2] + d[2] * currT - s[2]) / s[3]
            ],
            mat: mat
        );
    } else {
        return TraceResult(
            h: h,
            currT: 100000,
            n: [0, 0, 0],
            mat: null
        );
    }
}

TraceResult traceScene(List<double> o, List<double> d, List<List<double>> s) {
    double initT = 10000000;
    List<double>? currMat = sky;
    List<double> n = [0, 0, 0];
    bool h = false;
    
    for (int i = 0; i < s.length - 1; i += 2) {
        TraceResult hit = traceSphere(o, d, s[i], s[i + 1]);
        if (hit.h && hit.currT >= 0 && hit.currT < initT) {
            h = true;
            initT = hit.currT;
            n = hit.n;
            currMat = hit.mat;
        }
    }
    return TraceResult(
        h: h,
        currT: initT,
        n: n,
        mat: currMat
    );
}

List<double> pathTrace(List<double> o, List<double> d, List<List<double>> s) {
    List<double> col = [1, 1, 1];
    
    for (int i = 0; i < 12; ++i) {
        TraceResult hit = traceScene(o, d, s);
        if (hit.h) {
            bool isSpec = hit.mat![5] > random(0, 1);
            
            col[0] *= lerp(hit.mat![3] * hit.mat![0], 1, isSpec ? 1 : 0);
            col[1] *= lerp(hit.mat![3] * hit.mat![1], 1, isSpec ? 1 : 0);
            col[2] *= lerp(hit.mat![3] * hit.mat![2], 1, isSpec ? 1 : 0);
            
            if (hit.mat![3] > 1) break;
            
            o = [
                o[0] + d[0] * hit.currT,
                o[1] + d[1] * hit.currT,
                o[2] + d[2] * hit.currT,
            ];
            
            List<double> dd = uniformVec();
            
            dd = normalize([
                dd[0] + hit.n[0],
                dd[1] + hit.n[1],
                dd[2] + hit.n[2],
            ]);
            
            List<double> rd = normalize(reflect(d, hit.n));
            
            d = [
                lerp(dd[0], rd[0], hit.mat![4] * (isSpec ? 1 : 0)),
                lerp(dd[1], rd[1], hit.mat![4] * (isSpec ? 1 : 0)),
                lerp(dd[2], rd[2], hit.mat![4] * (isSpec ? 1 : 0)),
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

double its = 1;

Float32List colorBuffer = new Float32List(400*400*4);

List<List<double>> scene = [
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
Map<String, dynamic> idg = {
    "width": WIDTH,
    "height": HEIGHT,
    "data": new Uint8List(WIDTH * HEIGHT * 4)
};
Uint8List id = idg["data"];

void benchit(){
    List<double> col = [0, 0, 0];
    for(int i = 0; i < WIDTH; i++){
        for(int j = 0; j < HEIGHT; j++){
            double u = ((i + random(-0.5, 0.5)) - (WIDTH / 2))/WIDTH, v = ((j + random(-0.5, 0.5)) - (HEIGHT / 2))/HEIGHT;
            int ci = (i + j*WIDTH) << 2;
            
            List<double> o = [0, 0, 0];
            List<double> d = normalize([u, v, 1]);
            List<double> col = pathTrace(o, d, scene);
            
            colorBuffer[ci] = lerp(colorBuffer[ci], col[0], 1 / its);
            colorBuffer[ci + 1] = lerp(colorBuffer[ci + 1], col[1], 1 / its);
            colorBuffer[ci + 2] = lerp(colorBuffer[ci + 2], col[2], 1 / its);
            
            id[ci] = (Math.pow(colorBuffer[ci], 1/2.2)*255).toInt();
            id[ci + 1] = (Math.pow(colorBuffer[ci + 1], 1/2.2)*255).toInt();
            id[ci + 2] = (Math.pow(colorBuffer[ci + 2], 1/2.2)*255).toInt();
            id[ci + 3] = 255;
        }
    }
    its++;
}
