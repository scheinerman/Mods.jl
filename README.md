# Mods

Modular arithmetic for Julia.

## New in Version 2



With this new version the modulus of a `Mod` number must be of type `Int`.
If a `Mod` number is constructed with any other typeof `Integer`, the 
constructor will (try to) convert it to type `Int`.

### Why this change?

There were various issues in the earlier version of `Mods` that are 
resolved by requiring `N` to be of type `Int`.

* Previously `Mod` numbers created with different sorts of integer parameters would 
be different. So if `N = 17` and `M = 0x11`, then `Mod{N}(1)` would not be interoperable with `Mod{M}(1).`

* The internal storage of the value of the `Mod` numbers could be  different. 
For example, `Mod{17}(-1)` would store the
value internally as `-1` whereas `Mod{17}(16)` would store the value as `16`.

* Finally, if the modulus were a large `Int128` number, then arithmetic 
operations could silently fail. 

We believe that the dominant use case for this module will be with moduli between 
`2` and `2^63-1` and so we do not expect this change to affect
users. Further, since `Mod` numbers that required `Int128` moduli were 
likely to give incorrect results, version 1 of this module was buggy.

In addition, some functionality has been moved to the `extras` folder. 
See the `README` there. 


## Quick Overview
This module supports modular values and arithmetic. The moduli are integers (at least 2)
and the values are either integers or Gaussian integers.

An element of $\mathbb{Z}_N$ is entered as `Mod{N}(a)` and is of type `Mod{N}`.
An element of $\mathbb{Z}_N[i]$ is entered a `Mod{N}(a+b*im)` and is of type 
`GaussMod{N}`. Both types are fully interoperable with each other and with 
(ordinary) integers and Gaussian integers.

```
julia> a = Mod{17}(9); b = Mod{17}(10);

julia> a+b
Mod{17}(2)

julia> 2a
Mod{17}(1)

julia> a = Mod{17}(9-2im)
GaussMod{17}(9 + 15im)

julia> 2a
GaussMod{17}(1 + 13im)

julia> a'
GaussMod{17}(9 + 2im)
```

## Basics 
### Mod numbers

Integers modulo `N` (where `N>1`) are values in the set 
`{0,1,2,...,N-1}`. All arithmetic takes place modulo `N`. To create a mod-`N` number 
we use `Mod{N}(a)`. For example:
```
julia> Mod{10}(3)
Mod{10}(3)

julia> Mod{10}(23)
Mod{10}(3)

julia> Mod{10}(-3)
Mod{10}(7)
```
The usual arithmetic operations may be used. Furthermore, oridinary integers can be 
combined with `Mod` values. However, values of different moduli cannot be used
together in an arithmetic expression. 
```
julia> a = Mod{10}(5)
Mod{10}(5)

julia> b = Mod{10}(6)
Mod{10}(6)

julia> a+b
Mod{10}(1)

julia> a-b
Mod{10}(9)

julia> a*b
Mod{10}(0)

julia> 2b
Mod{10}(2)
```
Division is permitted, but if the denominator is not invertible, an error is thrown.
```
julia> a = Mod{10}(5)
Mod{10}(5)

julia> b = Mod{10}(3)
Mod{10}(3)

julia> a/b
Mod{10}(5)

julia> b/a
ERROR: Mod{10}(5) is not invertible
```
Exponentiation by an integer is permitted.
```
julia> a = Mod{17}(2)
Mod{17}(2)

julia> a^16
Mod{17}(1)

julia> a^(-3)
Mod{17}(15)
```
Invertibility can be checked with `is_invertible`.
```
julia> a = Mod{10}(3)
Mod{10}(3)

julia> is_invertible(a)
true

julia> inv(a)
Mod{10}(7)

julia> a = Mod{10}(4)
Mod{10}(4)

julia> is_invertible(a)
false

julia> inv(a)
ERROR: Mod{10}(4) is not invertible
```

Modular numbers with different moduli cannot be combined using the usual operations.
```
julia> a = Mod{10}(1)
Mod{10}(1)

julia> b = Mod{9}(1)
Mod{9}(1)

julia> a+b
ERROR: can not promote types Mod{10,Int64} and Mod{9,Int64}
```



### GaussMod numbers

We can also work modulo `N` with Gaussian integers (numbers of the form `a+b*im` where `a`
and `b` are integers).
```
julia> a = Mod{10}(2-3im)
GaussMod{10}(2 + 7im)

julia> b = Mod{10}(5+6im)
GaussMod{10}(5 + 6im)

julia> a+b
GaussMod{10}(7 + 3im)

julia> a*b
GaussMod{10}(8 + 7im)
```
In addition to the usual arithmetic operations, the following features apply 
to `GaussMod` values.

#### Real and imaginary parts
* Use the functions `real` and `imag` (or `reim`) to extract the real and imaginary parts:
```
julia> a = Mod{10}(2-3im)
GaussMod{10}(2 + 7im)

julia> real(a)
Mod{10}(2)

julia> imag(a)
Mod{10}(7)

julia> reim(a)
(Mod{10}(2), Mod{10}(7))
```

#### Complex conjugate
Use `a'` (or `conj(a)`) to get the complex conjugate value:
```
julia> a = Mod{10}(2-3im)
GaussMod{10}(2 + 7im)

julia> a'
GaussMod{10}(2 + 3im)

julia> a*a'
GaussMod{10}(3 + 0im)

julia> a+a'
GaussMod{10}(4 + 0im)
```

### Inspection

Given a `Mod` number, the modulus is recovered using the `modulus`
function and the numerical value with `value`:
```
julia> a = Mod{23}(100)
Mod{23}(8)

julia> modulus(a)
23

julia> value(a)
8
```


### Overflow safety

Integer operations on 64-bit numbers can give results requiring more than
64 bits. Fortunately, when working with modular numbers the results of
the operations are bounded by the modulus.
```
julia> N = 10^18                # this is a 60-bit number
1000000000000000000

julia> a = 10^15
1000000000000000

julia> a*a                      # We see that a*a overflows
5076944270305263616

julia> Mod{N}(a*a)              # this gives an incorrect answer
Mod{1000000000000000000}(76944270305263616)

julia> Mod{N}(a) * Mod{N}(a)    # but this is correct!
Mod{1000000000000000000}(0)
```

## Extras

### Zeros and ones

The standard Julia functions `zero`, `zeros`, `one`, and `ones` may be used
with `Mod` types:
```
julia> zero(Mod{9})
Mod{9}(0)

julia> one(GaussMod{7})
GaussMod{7}(1 + 0im)

julia> zeros(Mod{9},2,2)
2×2 Matrix{Mod{9}}:
 Mod{9}(0)  Mod{9}(0)
 Mod{9}(0)  Mod{9}(0)

julia> ones(GaussMod{5},4)
4-element Vector{GaussMod{5}}:
 GaussMod{5}(1 + 0im)
 GaussMod{5}(1 + 0im)
 GaussMod{5}(1 + 0im)
 GaussMod{5}(1 + 0im)

```

### Iteration

The `Mod{m}` type can be used as an iterator (in `for` statements and list comprehension):
```
julia> for a in Mod{5}
       println(a)
       end
Mod{5}(0)
Mod{5}(1)
Mod{5}(2)
Mod{5}(3)
Mod{5}(4)

julia> collect(Mod{6})
6-element Vector{Mod{6, T} where T}:
 Mod{6}(0)
 Mod{6}(1)
 Mod{6}(2)
 Mod{6}(3)
 Mod{6}(4)
 Mod{6}(5)

julia> [k*k for k ∈ Mod{7}]
7-element Vector{Mod{7, Int64}}:
 Mod{7}(0)
 Mod{7}(1)
 Mod{7}(4)
 Mod{7}(2)
 Mod{7}(2)
 Mod{7}(4)
 Mod{7}(1)

julia> prod(k for k in Mod{5} if k!=0) == -1  # Wilson's theorem
true
```

One can also use `GaussMod` as an iterator:
```
julia> for z in GaussMod{3}
       println(z)
       end
GaussMod{3}(0 + 0im)
GaussMod{3}(0 + 1im)
GaussMod{3}(0 + 2im)
GaussMod{3}(1 + 0im)
GaussMod{3}(1 + 1im)
GaussMod{3}(1 + 2im)
GaussMod{3}(2 + 0im)
GaussMod{3}(2 + 1im)
GaussMod{3}(2 + 2im)
```


### Random values

The `rand` function can be used to produce random `Mod` values:
```
julia> rand(Mod{17})
Mod{17}(13)

julia> rand(GaussMod{17})
GaussMod{17}(3 + 6im)
```

With extra arguments, `rand` produces random vectors or matrices populated with 
modular numbers:
```
julia> rand(GaussMod{10},4)
4-element Vector{GaussMod{10, Complex{Int64}}}:
 GaussMod{10}(2 + 6im)
 GaussMod{10}(2 + 6im)
 GaussMod{10}(7 + 4im)
 GaussMod{10}(7 + 3im)

julia> rand(Mod{10},2,5)
2×5 Matrix{Mod{10, Int64}}:
 Mod{10}(9)  Mod{10}(8)  Mod{10}(1)  Mod{10}(3)  Mod{10}(1)
 Mod{10}(2)  Mod{10}(0)  Mod{10}(9)  Mod{10}(0)  Mod{10}(2)
```







### Rationals and Mods

The result of `Mod{N}(a//b)` is exactly
`Mod{N}(numerator(a)) / Mod{n}(denominator(b))`. This may equal
`Mod{N}(a)/Mod{N}(b)` if `a` and `b` are relatively prime to each other
and to `N`.

When a `Mod` and a `Rational` are operated with each other, the
`Rational` is first converted to a `Mod`, and then the operation
proceeds.

Bad things happen if the denominator and the modulus are not
relatively prime.

## Other Packages Using Mods

The `Mod` and `GaussMod` types work well with my
[SimplePolynomials](https://github.com/scheinerman/SimplePolynomials.jl) and [LinearAlgebraX](https://github.com/scheinerman/LinearAlgebraX.jl) modules.


```
julia> using LinearAlgebraX

julia> A = rand(GaussMod{13},3,3)
3×3 Matrix{GaussMod{13, Complex{Int64}}}:
 GaussMod{13}(12 + 2im)   GaussMod{13}(3 + 5im)  GaussMod{13}(6 + 11im)
  GaussMod{13}(0 + 4im)   GaussMod{13}(2 + 1im)  GaussMod{13}(12 + 2im)
  GaussMod{13}(6 + 0im)  GaussMod{13}(3 + 11im)   GaussMod{13}(4 + 8im)

julia> detx(A)
GaussMod{13}(11 + 5im)

julia> invx(A)
3×3 Matrix{GaussMod{13, Complex{Int64}}}:
 GaussMod{13}(12 + 11im)  GaussMod{13}(3 + 6im)  GaussMod{13}(12 + 11im)
   GaussMod{13}(2 + 7im)  GaussMod{13}(1 + 3im)    GaussMod{13}(9 + 2im)
   GaussMod{13}(4 + 7im)  GaussMod{13}(8 + 9im)    GaussMod{13}(9 + 1im)

julia> ans * A
3×3 Matrix{GaussMod{13, Complex{Int64}}}:
 GaussMod{13}(1 + 0im)  GaussMod{13}(0 + 0im)  GaussMod{13}(0 + 0im)
 GaussMod{13}(0 + 0im)  GaussMod{13}(1 + 0im)  GaussMod{13}(0 + 0im)
 GaussMod{13}(0 + 0im)  GaussMod{13}(0 + 0im)  GaussMod{13}(1 + 0im)

julia> char_poly(A)
GaussMod{13}(2 + 8im) + GaussMod{13}(11 + 2im)*x + GaussMod{13}(8 + 2im)*x^2 + GaussMod{13}(1 + 0im)*x^3
```



