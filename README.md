Mods
====

Easy modular arithmetic for Julia. After `using Mods`, construct a
`Mod` object with `Mod(val,mod)`.  Both `val` and `mod` must be the
same subtype of `Integer`.

We have implemented the basic four operations `+ - * /` (including
unary minus) and equality checking. Note that operating on two `Mod`
objects with different moduli results in an error.

Division can result in an error if the divisor is not invertible. A
`Mod` object `x` can be checked for invertibility using
`is_invertible(x)`. To find the inverse of `x` (assuming it exists)
use `inv(x)`.


To do
-----

* Implement exponentiation to an integer power.
* Implement arithmetic with integers, e.g., `Mod(3,10)+1` should give
  `Mod(4,10)`. 
* Implement Chinese Remainder Theorem calculations.
