
struct Mod{N} <: AbstractMod
    val::value_type
    function Mod{N}(x::T) where {N,T<:Integer}
        @assert N isa Integer && N > 1 "Modulus must be an integer greater than 1"
        @assert N <= max_mod "modulus is too large"
        new{value_type(N)}(mod(x, N))
    end
end

# Construct from Rational
function Mod{N}(ab::Rational) where {N}
    a = numerator(ab)
    b = denominator(ab)
    return Mod{N}(a) * inv(Mod{N}(b))
end

# copy constructor
Mod{N}(x::Mod{N}) where {N} = Mod{N}(x.val)
Mod(x::Mod{N}) where {N} = Mod{N}(x.val)


# Compute mod of a Gaussian integer
mod(z::Complex{<:Integer}, n::Integer) = Complex(mod(real(z), n), mod(imag(z), n))


struct GaussMod{N} <: AbstractMod
    val::Complex{value_type}
    function GaussMod{N}(x::Complex{T}) where {N,T<:Integer}
        @assert N isa Integer && N > 1 "Modulus must be an integer greater than 1"
        @assert N <= max_mod "modulus is too large"
        new{Int(N)}(mod(x, N))
    end
end

function GaussMod{N}(x::T1, y::T2 = 0) where {N,T1<:Integer,T2<:Integer}
    z = x + im * y
    return GaussMod{N}(z)
end

GaussMod{N}(ab::Rational) where {N} = GaussMod(Mod{N}(ab))
function GaussMod{N}(ab::Complex{Rational{T}}) where {N,T<:Integer}
    a, b = reim(ab)
    x = Mod{N}(a)
    y = Mod{N}(b)
    return x + y * im
end

Mod{N}(z::Complex{T}) where {N,T<:Integer} = GaussMod{N}(z)
Mod{N}(z::Complex{Rational{T}}) where {N,T<:Integer} = GaussMod{N}(z)
Mod(a::GaussMod{N}) where {N} = a
Mod{N}(a::GaussMod{N}) where {N} = a

# copy constructor & casting Mod to GaussMod
GaussMod{N}(x::Mod{N}) where {N} = GaussMod{N}(value(x), 0)
GaussMod{N}(x::GaussMod{N}) where {N} = x
GaussMod(x::Mod{N}) where {N} = GaussMod{N}(value(x), 0)
GaussMod(x::GaussMod{N}) where {N} = x
