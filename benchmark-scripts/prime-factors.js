/*
    modified from https://stackoverflow.com/questions/39899072/how-can-i-find-the-prime-factors-of-an-integer-in-javascript
*/

function getPrimeFactors(integer) {
    const primeArray = [];
    let isPrime;

    // Find divisors starting with 2
    for (let i = 2; i <= integer; i++) {
        if (integer % i !== 0) continue;

        // Check if the divisor is a prime number
        for (let j = 2; j <= i / 2; j++) {
            isPrime = i % j !== 0;
        }

        if (!isPrime) continue;
        // if the divisor is prime, divide integer with the number and store it in the array
        integer /= i
        primeArray.push(i);
    }

    return primeArray;
}

let maxFactors = 0;
let maxFactorsNum = 0;

function benchit() {
    maxFactors = 0;
    maxFactorsNum = 0;
    for (let i = 1; i < 9450; i++) {
        const factors = getPrimeFactors(i);
        if (factors.length > maxFactors) {
            maxFactors = factors.length;
            maxFactorsNum = i;
        }
    }
}
