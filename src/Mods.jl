module Mods


import Base: isequal, (==), (+), (-), (*), (inv), (/), (^), hash, show

export Mod, modulus, value
export isequal, ==, +, -, *, is_invertible, inv, /, ^
export hash, CRT

"""
`Mod{m}(v)` (and also `Mod(v,m)`) creates a modular number in mod `m` with value `v%m`.
`Mod{m}()` is equivalent to `Mod(0,m)`.
"""
struct Mod{N}
    val::Int
    function Mod(x::Int,N::Int)
        @assert N>1 ""
        new{N::Int}(mod(x,N))
    end
end

Mod{N}(x::Int=0) where N = Mod(x,N)


modulus(a::Mod{N}) where N = N
value(a::Mod{N}) where N = a.val


function hash(x::Mod, h::UInt64= UInt64(0))
    v = BigInt(value(x))
    m = BigInt(modulus(x))
    return hash(v,hash(m,h))
end

# Test for equality
isequal(x::Mod, y::Mod) = value(x)==value(y) && modulus(x)==modulus(y)

==(x::Mod,y::Mod) = isequal(x,y)


"""
`modcheck(x::Mod,y::Mod)` checks if `x` and `y` have the same modulus.
If so, return than modulus. If not, throw an error.
"""
function modcheck(x::Mod, y::Mod)::Int
    mx = modulus(x)
    my = modulus(y)
    if mx != my
        error("Cannot operate on two Mod objects with different moduli")
    end
    return mx
end

# Easy arithmetic
function +(x::Mod, y::Mod)::Mod
    m = modcheck(x,y)
    s,flag = Base.add_with_overflow(x.val,y.val)
    if !flag
        return Mod(x.val+y.val, m)
    end
    s = widen(x.val) + widen(y.val)    # add with added precision
    s = Int(mod(s,m))                  # reduce by modulus
    return Mod(s,m)
end


function -(x::Mod{M}) where M
    return Mod(-x.val, M)
end

-(x::Mod,y::Mod) = x + (-y)


function *(x::Mod, y::Mod)
    m = modcheck(x,y)
    p,flag = Base.mul_with_overflow(x.val,y.val)
    if !flag
        return Mod(x.val*y.val, m)
    end
    p = widemul(x.val, y.val)         # multipy with added precision
    p = Int(mod(p,m))                  # reduce by the modulus
    return Mod(p,m) # return with proper type
end

# Division stuff
"""
`is_invertible(x::Mod)` determines if `x` is invertible.
"""
function is_invertible(x::Mod{M})::Bool where M
    return gcd(value(x),M) == 1
end


"""
`inv(x::Mod)` gives the multiplicative inverse of `x`.
This may be abbreviated by `x'`.
"""
function inv(x::Mod{M}) where M
    (g, v, ignore) = gcdx(x.val, M)
    if g != 1
        @error "$x is not invertible"
    end
    return Mod(v, M)
end

# Typing shortcut for inv(x)
# adjoint(x::Mod)

function /(x::Mod, y::Mod)
    modcheck(x,y)
    return x * inv(y)
end

function ^(x::Mod{M}, k::Integer) where M
    if k>0
        return Mod(powermod(x.val, k, M), M)
    end
    if k==0
        return Mod(1,M)
    end
    y = inv(x)
    return y^(-k)
end

# Operations with Integers

+(x::Mod{M}, k::Integer) where M = Mod(k,M)+x
+(k::Integer, x::Mod) = x+k

-(x::Mod, k::Integer) = x + (-k)
-(k::Integer, x::Mod) = (-x) + k

*(x::Mod{M}, k::Integer) where M = Mod(k,M) * x
*(k::Integer, x::Mod) = x*k

/(x::Mod{M}, k::Integer) where M = x / Mod(k, M)
/(k::Integer, x::Mod{M}) where M = Mod(k, M) / x

# Comparison with Integers

isequal(x::Mod{M}, k::Integer) where M = mod(k,M) == x.val
isequal(k::Integer, x::Mod) = isequal(x,k)
==(x::Mod, k::Integer) = isequal(x,k)
==(k::Integer, x::Mod) = isequal(x,k)

# Chinese remainder theorem functions

# private helper function
function CRT_work(x::Mod{n}, y::Mod{m}) where {n,m}
    # n = x.mod
    # m = y.mod
    if gcd(n,m) != 1
        error("Moduli must be pairwise relatively prime")
    end

    a = x.val
    b = y.val

    k = inv(Mod(n,m)) * (b-a)

    z = a + k.val*n

    return Mod(z, n*m)
end

# public interface
"""
`CRT(m1,m2,...)`: Chinese Remainder Theorem
```
julia> CRT( Mod(4,11), Mod(8,14) )
Mods.Mod(92,154)

julia> 92%11
4

julia> 92%14
8
```
"""
function CRT(mtuple::Mod...)
    n = length(mtuple)
    if n == 0
        return 1
    end

    result::Mod = mtuple[1]

    for k=2:n
        result = CRT_work(result,mtuple[k])
    end

    return result
end


# show(io::IO, m::Mod{N}) where N = print(io,"Mod(",m.val,",",m.mod,")")

end # end of module Mods
