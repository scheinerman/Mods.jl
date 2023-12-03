module Mods


__init__() =
    @warn "This version of Mods is still under development. Don't upgrade to version 2.0.x yet. I'm working on it."



import Base: (==), (+), (-), (*), (inv), (/), (//), (^), hash, show, iszero, isone, mod


export Mod, modulus, value, AbstractMod
export is_invertible

QZ = Union{Rational,Integer}
CZ = Union{Complex,Integer}
CZQ = Union{Complex{Integer},Integer,Complex{Rational},Rational}


abstract type AbstractMod <: Number end

# Private constructor DO NOT USE
struct Mod{N,T} <: AbstractMod
    val::T
end

# type casting
Mod{N,T}(x::Mod{N,T2}) where {T,N,T2} = Mod{N,T}(T(x.val))
Mod{N,T}(x::Mod{N,T}) where {T,N} = x

# Public constructor
"""
    Mod{N}(a)
Create a new modular number with modulus `N` and value `a`.
"""
function Mod{N}(x::Integer) where {N}
    @assert N isa Integer && N > 1 "modulus must be an integer and at least 2"
    @assert N <= typemax(Int) "modulus is too large"
    v = Int(mod(x, N))
    Mod{Int(N),Int}(v)
end

function Mod{N}(x::Rational) where N
    a = numerator(x)
    b = denominator(x)
    return Mod{N}(a) / Mod{N}(b)
end


"""
`modulus(a::Mod)` returns the modulus of this `Mod` number.
```
julia> a = Mod{13}(11);

julia> modulus(a)
13
```
"""
modulus(a::Mod{N}) where {N} = N

"""
`value(a::Mod)` returns the value of this `Mod` number.
```
julia> a = Mod{13}(11);

julia> value(a)
11
```
"""
value(a::Mod{N}) where {N} = a.val

Base.abs(a::Mod{N} where {N}) = abs(value(a))
Base.conj(x::Mod{N}) where {N} = Mod{N}(conj(x.val))


function hash(x::Mod, h::UInt64 = UInt64(0))
    v = value(x)
    m = modulus(x)
    return hash(v, hash(m, h))
end



# Test for equality
iszero(x::AbstractMod) = iszero(x.val)
isone(x::AbstractMod) = isone(x.val)
(==)(x::AbstractMod, y::AbstractMod) = modulus(x) == modulus(y) && value(x) == value(y)
(==)(x::AbstractMod, y::T) where {T<:CZQ} = x == Mod{modulus(x)}(y)
(==)(x::T, y::AbstractMod) where {T<:CZQ} = Mod{modulus(x)}(x) == y





show(io::IO, z::Mod{N}) where {N} = print(io, "Mod{$N}($(value(z)))")
show(io::IO, ::MIME"text/plain", z::Mod{N}) where {N} = show(io, z)

include("GaussMods.jl")
include("mod_arithmetic.jl")
include("gauss_mod_arithmetic.jl")
include("iterate.jl")

end # module Mods
