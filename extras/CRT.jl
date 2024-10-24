using Mods

"""
    `CRT([T=BigInt, ]m1, m2,...)`

Chinese Remainder Theorem.

```
julia> CRT(Int, Mod{11}(4), Mod{14}(814))
92

julia> 92%11
4

julia> 92%14
8

julia> CRT(Mod{9223372036854775783}(9223372036854775782), Mod{9223372036854775643}(9223372036854775642))
85070591730234614113402964855534653468
```

!!! note

    `CRT` uses `BigInt` by default to prevent potential integer overflow.
    If you are confident that numbers do not overflow in your application,
    please specify an optional type parameter as the first argument.
"""
function CRT(::Type{T}, remainders, primes) where {T}
    length(remainders) == length(primes) || error("size mismatch")
    isempty(remainders) && return zero(T)
    primes = convert.(T, primes)
    M = prod(primes)
    Ms = M .÷ primes
    ti = Mods._invmod.(Ms, primes)
    mod(sum(convert.(T, remainders) .* ti .* Ms), M)
end

function CRT(::Type{T}, rs::Mod...) where {T}
    CRT(T, value.(rs), modulus.(rs))
end
CRT(rs::Mod...) = CRT(BigInt, rs...)
