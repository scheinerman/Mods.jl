module Mods

import Base.isequal, Base.==, Base.+, Base.-, Base.*
import Base.inv, Base./, Base.^
import Base.hash, Base.ctranspose, Base.show

export Mod
export isequal, ==, +, -, *
export is_invertible, inv, /, ^, ctranspose
export hash, CRT

"""
`Mod(v,m)` creates a modular number in mod `m` with value `v%m`.
`Mod(m)` is equivalent to `Mod(0,m)`.
"""
immutable Mod
    val::Integer
    mod::Integer
    function Mod(a::Integer, m::Integer)
        if m < 1
            error("Modulus must be at least 1")
        end

        typeA = typeof(a)
        typeM = typeof(m)

        if typeA == typeM
            return new(mod(a,m),m)
        end

        aa = a + zero(typeA) + zero(typeM)
        mm = m + zero(typeA) + zero(typeM)

        aa = mod(aa,mm)
        new(aa,mm)
    end
end

Mod(m::Integer) = Mod(0,m)

function hash(x::Mod, h::UInt64= UInt64(0))
    v = BigInt(x.val)
    m = BigInt(x.mod)
    return hash(v,hash(m,h))
end

# Test for equality
isequal(x::Mod, y::Mod) = x.mod==y.mod && x.val==y.val
==(x::Mod,y::Mod) = isequal(x,y)

function modcheck(x::Mod, y::Mod)
    if x.mod != y.mod
        error("Cannot operate on two Mod objects with different moduli")
    end
    true
end

# Easy arithmetic
function +(x::Mod, y::Mod)
    modcheck(x,y)
    return Mod(x.val+y.val, x.mod)
end

function -(x::Mod,y::Mod)
    modcheck(x,y)
    return Mod(x.val-y.val, x.mod)
end

function -(x::Mod)
    return Mod(-x.val, x.mod)
end

function *(x::Mod, y::Mod)
    modcheck(x,y)
    return Mod(x.val*y.val, x.mod)
end

# Division stuff
"""
`is_invertible(x::Mod)` determines if `x` is invertible.
"""
is_invertible(x::Mod) = return gcd(x.val,x.mod)==1

"""
`inv(x::Mod)` gives the multiplicative inverse of `x`.
This may be abbreviated by `x'`.
"""
function inv(x::Mod)
    (g, v, ignore) = gcdx(x.val, x.mod)
    if g != 1
        error(x, " is not invertible")
    end
    return Mod(v, x.mod)
end

# Typing shortcut for inv(x)
ctranspose(x::Mod) = inv(x)


function /(x::Mod, y::Mod)
    modcheck(x,y)
    return x * inv(y)
end

function ^(x::Mod, k::Integer)
    if k>0
        return Mod(powermod(x.val, k, x.mod), x.mod)
    end
    if k==0
        T = typeof(x.val)
        return Mod(one(T), x.mod)
    end
    y = inv(x)
    return y^(-k)
end

# Operations with Integers

+(x::Mod, k::Integer) = Mod(x.val+k, x.mod)
+(k::Integer, x::Mod) = Mod(x.val+k, x.mod)

-(x::Mod, k::Integer) = Mod(x.val-k, x.mod)
-(k::Integer, x::Mod) = Mod(k-x.val, x.mod)

*(x::Mod, k::Integer) = Mod(k*x.val, x.mod)
*(k::Integer, x::Mod) = Mod(k*x.val, x.mod)

/(x::Mod, k::Integer) = x / Mod(k, x.mod)
/(k::Integer, x::Mod) = Mod(k, x.mod) / x

# Comparison with Integers

isequal(x::Mod, k::Integer) = mod(k,x.mod) == x.val
isequal(k::Integer, x::Mod) = isequal(x,k)
==(x::Mod, k::Integer) = isequal(x,k)
==(k::Integer, x::Mod) = isequal(x,k)

# Chinese remainder theorem functions

# private helper function
function CRT_work(x::Mod, y::Mod)
    n = x.mod
    m = y.mod
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
        return Mod(1)
    end

    result::Mod = mtuple[1]

    for k=2:n
        result = CRT_work(result,mtuple[k])
    end

    return result
end


show(io::IO, m::Mod) = print(io,"Mod(",m.val,",",m.mod,")")

end # end of module Mods
