/*
    modified from https://stackoverflow.com/questions/39899072/how-can-i-find-the-prime-factors-of-an-integer-in-javascript
*/

function getPrimeFactors(integer) {
    var primeArray = [];
    var isPrime;

    // Find divisors starting with 2
    for (var i = 2; i <= integer; i++) {
        if (integer % i !== 0) continue;

        // Check if the divisor is a prime number
        for (var j = 2; j <= i / 2; j++) {
            isPrime = i % j !== 0;
        }

        if (!isPrime) continue;
        // if the divisor is prime, divide integer with the number and store it in the array
        integer /= i
        primeArray.push(i);
    }

    return primeArray;
}

var maxFactors = 0;
var maxFactorsNum = 0;

function benchit() {
    maxFactors = 0;
    maxFactorsNum = 0;
    for (var i = 1; i < 9450; i++) {
        var factors = getPrimeFactors(i);
        if (factors.length > maxFactors) {
            maxFactors = factors.length;
            maxFactorsNum = i;
        }
    }
}
