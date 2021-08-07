# Mods

Modular arithmetic for Julia.


## Quick Overview
This module supports modular values and arithmetic. The moduli are integers (at least 2)
and the values are either integers or Gaussian integers.

An element of $\mathbb{Z}_N$ is entered as `Mod{N}(a)` and is of type `Mod{N}`.
An element of $\mathbb{Z}_N[i]$ is entered a `Mod{N}(a+b*im)` and is of type 
`GaussMod{N}`. Both types are fully interoperable with each other and with 
(ordinary) integers and Gaussian integers.

```julia
julia> a = Mod{17}(9); b = Mod{17}(10);

julia> a+b
Mod{17}(2)

julia> 2a
Mod{17}(1)

julia> a = Mod{17}(9-2im)
Mod{17}(9 + 15im)

julia> 2a
Mod{17}(1 + 13im)

julia> a'
Mod{17}(9 + 2im)

julia> typeof(a)
GaussMod{17}

julia> typeof(b)
Mod{17}

julia> supertype(ans)
AbstractMod
```

## Basics 
### `Mod` numbers

Integers modulo `N` (where `N>1`) are values in the set 
`{0,1,2,...,N-1}`. All arithmetic takes place modulo `N`. To create a mod-`N` number 
we use `Mod{N}(a)`. For example:
```julia
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
```julia
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
```julia
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
```julia
julia> a = Mod{17}(2)
Mod{17}(2)

julia> a^16
Mod{17}(1)

julia> a^(-3)
Mod{17}(15)
```
Invertibility can be checked with `is_invertible`.
```julia
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

Modular number with different moduli cannot be combined using the usual operations.
```julia
julia> a = Mod{10}(1)
Mod{10}(1)

julia> b = Mod{9}(1)
Mod{9}(1)

julia> a+b
ERROR: can not promote types Mod{10,Int64} and Mod{9,Int64}
```



### `GaussMod` numbers

We can also work modulo `N` with Gaussian integers (numbers of the form `a+b*im` where `a`
and `b` are integers).
```julia
julia> a = Mod{10}(2-3im)
Mod{10}(2 + 7im)

julia> b = Mod{10}(5+6im)
Mod{10}(5 + 6im)

julia> a+b
Mod{10}(7 + 3im)

julia> a*b
Mod{10}(8 + 7im)
```
In addition to the usual arithmetic operations, the following features apply 
to `GaussMod` values.

#### Real and imaginary parts
* Use the functions `real` and `imag` (or `reim`) to extract the real and imaginary parts:
```julia
julia> a = Mod{10}(2-3im)
Mod{10}(2 + 7im)

julia> real(a)
Mod{10}(2)

julia> imag(a)
Mod{10}(7)

julia> reim(a)
(Mod{10}(2), Mod{10}(7))
```

#### Complex conjugate
Use `a'` (or `conj(a)`) to get the complex conjugate value:
```julia
julia> a = Mod{10}(2-3im)
Mod{10}(2 + 7im)

julia> a'
Mod{10}(2 + 3im)

julia> a*a'
Mod{10}(3 + 0im)

julia> a+a'
Mod{10}(4 + 0im)
```

### Inspection

Given a `Mod` number, the modulus is recovered using the `modulus`
function and the numerical value with `value`:
```julia
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
```julia
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
```julia
julia> zero(Mod{9})
Mod{9}(0)

julia> one(GaussMod{7})
Mod{7}(1 + 0im)

julia> zeros(Mod{9},2,2)
2×2 Array{Mod{9},2}:
 Mod{9}(0)  Mod{9}(0)
 Mod{9}(0)  Mod{9}(0)

julia> ones(GaussMod{5},4)
4-element Array{GaussMod{5},1}:
 Mod{5}(1 + 0im)
 Mod{5}(1 + 0im)
 Mod{5}(1 + 0im)
 Mod{5}(1 + 0im)
```

### Iteration

The `Mod{m}` type can be used as an iterator (in `for` statements and list comprehension):
```julia
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
```julia
julia> for z in GaussMod{3}
       println(z)
       end
Mod{3}(0 + 0im)
Mod{3}(0 + 1im)
Mod{3}(0 + 2im)
Mod{3}(1 + 0im)
Mod{3}(1 + 1im)
Mod{3}(1 + 2im)
Mod{3}(2 + 0im)
Mod{3}(2 + 1im)
Mod{3}(2 + 2im)
```


### Random values

The `rand` function can be used to produce random `Mod` values:
```julia
julia> rand(Mod{17})
Mod{17}(13)

julia> rand(GaussMod{17})
Mod{17}(3 + 6im)
```

With extra arguments, `rand` produces random vectors or matrices populated with 
modular numbers:
```julia
julia> rand(GaussMod{10},4)
4-element Array{GaussMod{10},1}:
 Mod{10}(6 + 0im)
 Mod{10}(3 + 2im)
 Mod{10}(9 + 9im)
 Mod{10}(2 + 5im)

julia> rand(Mod{10},2,5)
2×5 Array{Mod{10},2}:
 Mod{10}(3)  Mod{10}(1)  Mod{10}(1)  Mod{10}(3)  Mod{10}(0)
 Mod{10}(1)  Mod{10}(1)  Mod{10}(8)  Mod{10}(4)  Mod{10}(0)
 ```


### Chinese remainder theorem

The Chinese Remainder Theorem gives a solution to the following
problem. Given integers `a, b, m, n` with `gcd(m,n)==1` find an
integer `x` such that `mod(x,m)==mod(a,m)` and
`mod(x,n)==mod(b,n)`. We provide the `CRT` function to solve this
problem as illustrated here with `a=3`, `m=10`, `b=5`, and `n=17`:

```julia
julia> s = Mod{10}(3); t = Mod{17}(5);

julia> CRT(s,t)
73
```

We find that `mod(73,10)` equals `3` and `mod(73,17)` equals `5` as
required. The answer is reported as `73` because any value of
`x` congruent to 73 modulo 170 is a solution.

The `CRT` function can be applied to any number of arguments so long
as their moduli are pairwise relatively prime.






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

## Other Packages Using `Mod`s

The `Mod` and `GaussMod` types work well with my
[SimplePolynomials](https://github.com/scheinerman/SimplePolynomials.jl) and [LinearAlgebraX](https://github.com/scheinerman/LinearAlgebraX.jl) modules.


```julia
julia> using LinearAlgebraX

julia> A = rand(GaussMod{13},3,3)
3×3 Array{GaussMod{13},2}:
 Mod{13}(11 + 0im)   Mod{13}(0 + 10im)  Mod{13}(1 + 9im)
  Mod{13}(8 + 4im)  Mod{13}(11 + 10im)  Mod{13}(1 + 8im)
 Mod{13}(11 + 6im)   Mod{13}(10 + 6im)  Mod{13}(7 + 3im)

julia> detx(A)
Mod{13}(2 + 11im)

julia> invx(A)
3×3 Array{GaussMod{13},2}:
  Mod{13}(4 + 6im)   Mod{13}(3 + 3im)    Mod{13}(5 + 1im)
  Mod{13}(5 + 0im)  Mod{13}(9 + 12im)   Mod{13}(3 + 10im)
 Mod{13}(11 + 6im)   Mod{13}(5 + 1im)  Mod{13}(10 + 12im)

julia> ans * A
3×3 Array{GaussMod{13},2}:
 Mod{13}(1 + 0im)  Mod{13}(0 + 0im)  Mod{13}(0 + 0im)
 Mod{13}(0 + 0im)  Mod{13}(1 + 0im)  Mod{13}(0 + 0im)
 Mod{13}(0 + 0im)  Mod{13}(0 + 0im)  Mod{13}(1 + 0im)

julia> char_poly(A)
Mod{13}(11 + 2im) + Mod{13}(2 + 1im)*x + Mod{13}(10 + 0im)*x^2 + Mod{13}(1 + 0im)*x^3
```
