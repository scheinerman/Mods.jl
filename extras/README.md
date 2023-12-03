# Extras for `Mods`

The `extras` folder contains files with functionality that was 
previously included in the `Mods` module. 


## Chinese Remainder Theorem

```
julia> include("extras/CRT.jl")
CRT (generic function with 3 methods)
```

The Chinese Remainder Theorem gives a solution to the following
problem. Given integers `a, b, m, n` with `gcd(m,n)==1` find an
integer `x` such that `mod(x,m)==mod(a,m)` and
`mod(x,n)==mod(b,n)`. We provide the `CRT` function to solve this
problem as illustrated here with `a=3`, `m=10`, `b=5`, and `n=17`:

```
julia> s = Mod{10}(3); t = Mod{17}(5);

julia> CRT(s,t)
73
```

We find that `mod(73,10)` equals `3` and `mod(73,17)` equals `5` as
required. The answer is reported as `73` because any value of
`x` congruent to 73 modulo 170 is a solution.

The `CRT` function can be applied to any number of arguments so long
as their moduli are pairwise relatively prime.

```
julia> a = Mod{11}(5); b = Mod{15}(8); c = Mod{29}(4);

julia> n = CRT(a,b,c)
1193

julia> n .% (11,15,29)
(5, 8, 4)
```


## Approximate Equality

Approximate equality of `Mod` numbers was removed from an older version of 
this module. That code is preserved in the file `extras/mod_approx.jl`.

Example:
```
julia> a = Mod{17}(6); b = Mod{17}(7);

julia> isapprox(a,b)
false

julia> isapprox(a,b,atol=2)
true
```

Unfortunately, approximation doesn't seem to wrap around the modulus:
```
julia> a = Mod{17}(0); b = Mod{17}(16);

julia> isapprox(a,b,atol=2)
false
```
I have no plan to work on this. 