/*
    modified from https://stackoverflow.com/questions/39899072/how-can-i-find-the-prime-factors-of-an-integer-in-javascript
*/

// END IMPORTS

List<int> getPrimeFactors(integer) {
    List<int> primeArray = [];
    bool isPrime = false;

    // Find divisors starting with 2
    for (int i = 2; i <= integer; i++) {
        if (integer % i != 0) continue;

        // Check if the divisor is a prime number
        for (int j = 2; j <= i / 2; j++) {
            isPrime = i % j != 0;
        }

        if (!isPrime) continue;
        // if the divisor is prime, divide integer with the number and store it in the array
        integer /= i;
        primeArray.add(i);
    }

    return primeArray;
}

int maxFactors = 0;
int maxFactorsNum = 0;

void benchit() {
    maxFactors = 0;
    maxFactorsNum = 0;
    for (int i = 1; i < 9450; i++) {
        final factors = getPrimeFactors(i);
        if (factors.length > maxFactors) {
            maxFactors = factors.length;
            maxFactorsNum = i;
        }
    }
}
