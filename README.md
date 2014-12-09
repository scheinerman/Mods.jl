# Mods

Easy modular arithmetic for Julia.


After `using Mods`, construct a `Mod` object with `Mod(val,mod)`.
Both `val` and `mod` must `Integer` values.
```julia
julia> using Mods

julia> Mod(4,23)
Mod(4,23)

julia> Mod(-1,23)
Mod(22,23)

julia> Mod(99,12)
Mod(3,12)

julia> x = Mod(4,10)
Mod(4,10)

julia> x.val
4

julia> x.mod
10
```

With just a single argument, `Mod` creates a zero element of the given
modulus.
```julia
julia> Mod(17)
Mod(0,17)
```


## Operations

### The basic four

`Mod` objects can be added, subtracted, mulitplied, and divided with
one another. The two `Mod` operands must have the same modulus.
```julia
julia> x = Mod(8,10); y = Mod(6,10);

julia> x+y
Mod(4,10)

julia> x-y
(2,10)

julia> x*y
Mod(8,10)

julia> Mod(5,10) + Mod(5,11)
ERROR: Cannot operate on two Mod objects with different moduli
```

Division can result in an error if the divisor is not invertible. A
`Mod` object `x` can be checked for invertibility using
`is_invertible(x)`. To find the inverse of `x` (assuming it exists)
use `inv(x)`.
```julia
julia> x = Mod(8,10); y = Mod(6,10);

julia> x/y
ERROR: Mod(6,10) is not invertible

julia> x = Mod(8,10); y = Mod(3,10);

julia> x/y
Mod(6,10)

julia> inv(y)
Mod(7,10)
```

We also support unary minus.
```julia
julia> x = Mod(3,10);

julia> -x
Mod(7,10)
```

#### Mixed Integer/Mod arithmetic

The basic four operations may also be performed between a `Mod` object
and an `Integer`. The calculation proceeds as if the `Integer` has the
same modulus as the `Mod` object.
```julia
julia> x = Mod(3,10);

julia> x+9
Mod(2,10)

julia> 4x
Mod(2,10)

julia> 3-x
Mod(0,10)

julia> x/7
Mod(9,10)
```




### Exponentiation

Use `x^k` to raise a `Mod` object `x` to an `Integer` power `k`. If
`k` is zero, this always returns `Mod(1,m)` where `m` is the modulus
of `x`. Negative exponentiation succeeds if and only if `x` is
invertible. 
```julia
julia> x = Mod(3,100)
Mod(3,100)

julia> x^10
Mod(49,100)

julia> x^-2
Mod(89,100)

julia> x = Mod(5,100)
Mod(5,100)

julia> x^-3
ERROR: Mod(5,100) is not invertible

julia> Mod(0,10)^0
Mod(1,10)
```


## To Do List

* Implement Chinese Remainder Theorem calculations.
