# /*
#     modified from https://stackoverflow.com/questions/39899072/how-can-i-find-the-prime-factors-of-an-integer-in-javascript
# */

# END IMPORTS

def get_prime_factors(integer: int) -> list[int]:
    prime_array = []

    # Find divisors starting with 2
    mut_integer = float(integer)
    i = 2
    while i <= mut_integer:
        if mut_integer % i != 0:
            i += 1
            continue

        # Check if the divisor is a prime number
        is_prime = True
        for j in range(2, int(i / 2) + 1):
            if i % j == 0:
                is_prime = False
                break

        if not is_prime:
            i += 1
            continue

        # if the divisor is prime, divide integer with the number and store it in the array
        mut_integer /= i
        prime_array.append(i)
    return prime_array

max_factors = 0
max_factors_num = 0

def benchit():
    global max_factors, max_factors_num
    max_factors = 0
    max_factors_num = 0
    for i in range(1, 9450):
        factors = get_prime_factors(i)
        if len(factors) > max_factors:
            max_factors = len(factors)
            max_factors_num = i
