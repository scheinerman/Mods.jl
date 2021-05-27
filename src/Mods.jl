module Mods

import Base: isequal, (==), (+), (-), (*), (inv), (/), (//), (^), hash, show
import Base: zero, one, rand, conj

export Mod, modulus, value, AbstractMod, modnumber
export isequal, ==, +, -, *, is_invertible, inv, /, ^
export hash, CRT

abstract type AbstractMod <: Number end

"""
`Mod{m}(v)` creates a modular number in mod `m` with value `mod(v,m)`.
"""
struct Mod{N,T<:Integer} <: AbstractMod
    val::T
end

# safe constructors (slower)
function Mod{N}(x::T) where {T<:Integer,N}
    @assert N isa Integer && N>1 "modulus must be at least 2"
    Mod{N,T}(x)
end

# type casting
Mod{N,T}(x::Mod{N,T2}) where {T<:Integer,N,T2<:Integer} = Mod{N,T}(T(x.val))
Mod{N,T}(x::Mod{N,T}) where {T<:Integer,N} = x

modnumber(x::Integer, N::Integer) = Mod{N}(x)

show(io::IO, z::Mod{N}) where N = print(io,"Mod{$N}($(value(z)))")
show(io::IO, ::MIME"text/plain", z::Mod{N}) where N = show(io, z)

"""
`modulus(a::Mod)` returns the modulus of this `Mod` number.
```
julia> a = Mod{13}(11);

julia> modulus(a)
13
```
"""
modulus(a::Mod{N}) where N = N

"""
`value(a::Mod)` returns the value of this `Mod` number.
```
julia> a = Mod{13}(11);

julia> value(a)
11
```
"""
value(a::Mod{N}) where N = mod(a.val, N)

zero(::Mod{N,T}) where {N,T} = Mod{N,T}(zero(T))
zero(::Type{Mod{N,T}}) where {N,T} = Mod{N,T}(zero(T))

one(::Mod{N,T}) where {N,T} = Mod{N,T}(one(T))
one(::Type{Mod{N,T}}) where {N,T} = Mod{N,T}(one(T))

conj(x::Mod) = x   # so matrix transpose will work

function hash(x::AbstractMod, h::UInt64= UInt64(0))
    v = value(x)
    m = modulus(x)
    return hash(v,hash(m,h))
end

# Test for equality
isequal(x::Mod{N,T1}, y::Mod{M,T2}) where {M,N,T1,T2} = false
isequal(x::Mod{N,T1}, y::Mod{N,T2}) where {N,T1,T2} = value(x)==value(y)

==(x::Mod,y::Mod) = isequal(x,y)


# Easy arithmetic
@inline function +(x::Mod{N,T}, y::Mod{N,T}) where {N,T}
    s, flag = Base.add_with_overflow(x.val,y.val)
    if !flag
        return Mod{N,T}(s)
    end
    t = widen(x.val) + widen(y.val)    # add with added precision
    return Mod{N,T}(unsafe_mod(t,N))
end


function -(x::Mod{M,T}) where {M,T}
    return Mod{M,T}(-x.val)  # Note: might break for UInt
end

-(x::Mod,y::Mod) = x + (-y)

unsafe_mod(x, y) = x - (x ÷ y) * y  # does not check `y` being positive

@inline function *(x::Mod{N,T}, y::Mod{N,T}) where {N,T}
    p, flag = Base.mul_with_overflow(x.val,y.val)
    if !flag
        return Mod{N,T}(p)
    else
        q = widemul(x.val, y.val)         # multipy with added precision
        return Mod{N,T}(unsafe_mod(q,N)) # return with proper type
    end
end

# Division stuff
"""
`is_invertible(x::Mod)` determines if `x` is invertible.
"""
function is_invertible(x::Mod{M})::Bool where M
    return gcd(x.val,M) == 1
end


"""
`inv(x::Mod)` gives the multiplicative inverse of `x`.
This may be abbreviated by `x'`.
"""
@inline function inv(x::Mod{M,T}) where {M,T}
    (g, v, ignore) = gcdx(x.val, M)
    if g != 1
        error("$x is not invertible")
    end
    return Mod{M,T}(v)
end

function /(x::Mod{N,T}, y::Mod{N,T}) where {N,T}
    return x * inv(y)
end

(//)(x::Mod,y::Mod) = x/y

#Base.convert(::Type{Mod{M,T}}, x::Integer) where {M,T} = Mod{M,T}(x)
Base.promote_rule(::Type{Mod{M,T1}}, ::Type{T2}) where {M,T1<:Integer,T2<:Integer} = Mod{M,promote_type(T1, T2)}
Base.promote_rule(::Type{T2}, ::Type{Mod{M,T1}}) where {M,T1<:Integer,T2<:Integer} = Mod{M,promote_type(T1, T2)}
#Base.convert(::Type{Mod{M,T}}, x::Rational) where {M,T} = Mod{M}(x)
Base.promote_rule(::Type{Mod{M,T1}}, ::Type{Rational{T2}}) where {M,T1<:Integer,T2<:Integer} = Mod{M,promote_type(T1, T2)}
Base.promote_rule(::Type{Rational{T2}}, ::Type{Mod{M,T1}}) where {M,T1<:Integer,T2<:Integer} = Mod{M,promote_type(T1, T2)}

# Operations with rational numbers  
Mod{N}(k::Rational) where N = Mod{N}(numerator(k))/Mod{N}(denominator(k))
Mod{N,T}(k::Rational{T2}) where {N,T<:Integer,T2<:Integer} = Mod{N,T}(numerator(k))/Mod{N,T}(denominator(k))

# Comparison with Integers

isequal(x::Mod{M}, k::Integer) where M = mod(k,M) == value(x)
isequal(k::Integer, x::Mod) = isequal(x,k)
(==)(x::Mod, k::Integer) = isequal(x,k)
(==)(k::Integer, x::Mod) = isequal(x,k)

# Comparisons with Rationals
function isequal(x::Mod{N}, k::Rational) where N
    return x == Mod{N}(k)
end
isequal(k::Rational,x::Mod) = isequal(x,k)
(==)(x::Mod, k::Rational) = isequal(x,k)
(==)(k::Rational, x::Mod) = isequal(x,k)




# Random

rand(::Type{Mod{N}}) where N = Mod{N}(rand(Int))
rand(::Type{Mod{N}},dims::Integer...) where N = Mod{N}.(rand(Int,dims...))



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

include("GaussMods.jl")


end # end of module Mods
