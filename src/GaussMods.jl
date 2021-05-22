import Base: mod, real, imag, reim, conj, promote_rule

export GaussMod, AbstractMod

# mod support for Gaussian integers until officially adopted into Base
mod(z::Complex{<:Integer}, n::Integer) = Complex(mod(real(z), n), mod(imag(z), n))

"""
`GaussMod{m,T}(v)` creates a modular number in mod `m` with value `mod(v,m)`.
`GaussMod{m,T}()` is equivalent to `GaussMod{m}(0)`.
"""
struct GaussMod{N,T} <: AbstractMod
    val::Complex{T}
end

function GaussMod{N}(x::Complex{T}) where {T<:Integer, N}
    @assert N>1 "modulus must be at least 2"
    GaussMod{N,T}(mod(x,N))
end

GaussMod(x::Complex{T}, N::Integer) where {T<:Integer} = GaussMod{N}(x)
GaussMod{N}(x::S, y::T) where {N,S<:Integer,T<:Integer} = GaussMod{N}(x + y*im)
GaussMod(x::Mod{N,T}) where {N,T} = GaussMod{N,T}(x.val)
GaussMod{N,T}(x::Mod{N,T}) where {N,T} = GaussMod{N,T}(x.val)

GaussMod{N}(x::Rational{T}) where {N,T<:Integer} = GaussMod{N,T}(numerator(x)) / GaussMod{N}(denominator(x))
GaussMod{N}(x::Complex{Rational{T}}) where {N,T<:Integer} = GaussMod{N,T}(real(x)) + GaussMod{N}(imag(x))*im
Base.zero(::Type{GaussMod{N,T}}) where {N,T} = GaussMod{N,T}(0+0im)
Base.zero(::Type{GaussMod{N}}) where {N,T} = GaussMod{N,Int}(0+0im)

#Mod{N}(a::S,b::T) where {N,S<:Integer,T<:Integer} = GaussMod{N}(a+b*im)
#Mod{N}(x::Complex) where N = GaussMod{N}(x)

modulus(x::GaussMod{T}) where T = T
value(a::GaussMod) = a.val

real(x::GaussMod{N}) where N = Mod{N}(real(x.val))
real(x::Mod) = x 

imag(x::GaussMod{N}) where N = Mod{N}(imag(x.val))
imag(x::Mod{N}) where N = Mod{N}(0)

reim(x::AbstractMod) = (real(x),imag(x))

conj(x::GaussMod{N}) where N = GaussMod{N}(conj(x.val))

function Mod{N}(x::GaussMod{N}) where N
    if imag(x) == 0
        return Mod{N}(real(x))
    end 
    error("Cannot convert $x to type Mod{$N} (nonzero imaginary part)\nPerhaps use: real(x)")
end

Mod(x::GaussMod{N}) where N = Mod{N}(x)


# ARITHMETIC

function(+)(x::GaussMod{N}, y::GaussMod{N}) where N
    xx = widen(x.val)
    yy = widen(y.val)
    zz = mod(xx+yy,N)
    return Mod{N}(zz)
end

(-)(x::GaussMod{N}) where N = GaussMod{N}(-x.val)
(-)(x::GaussMod{N},y::GaussMod{N}) where N = x + (-y)

function (*)(x::GaussMod{N}, y::GaussMod{N}) where N
    xx = widen(x.val)
    yy = widen(y.val)
    zz = mod(xx*yy,N)
    return Mod{N}(zz)
end



function inv(x::GaussMod{N}) where N 
    try
        a,b = reim(x)
        bot = inv(a*a + b*b)
        aa = a*bot
        bb = -b*bot
        return aa + bb*im
    catch
        error("$x is not invertible")
    end 
end

is_invertible(x::GaussMod) = is_invertible(real(x*x'))

(/)(x::GaussMod{N}, y::GaussMod{N}) where N = x * inv(y)

(//)(x::GaussMod{N}, y::GaussMod{N}) where N = x/y
(//)(x::Number, y::GaussMod{N}) where N = x/y
(//)(x::GaussMod{N}, y::Number) where N = x/y


show(io::IO, z::GaussMod{N}) where N = print(io,"Mod{$N}($(z.val))")



# Random

rand(::Type{GaussMod{N,T}}) where {N,T} = GaussMod{N}(rand(T) + im*rand(T))
rand(::Type{GaussMod{N,T}}, dims::Integer...) where {N,T} = GaussMod{N}.(rand(T,dims...)) + im*GaussMod{N,T}.(rand(T,dims...))


promote_rule(::Type{GaussMod{N,T}}, ::Type{Mod{N,T}}) where {N,T} = GaussMod{N,T}
promote_rule(::Type{Mod{N,T}}, ::Type{GaussMod{N,T}}) where {N,T} = GaussMod{N,T}

promote_rule(::Type{GaussMod{N,T}}, ::Type{T}) where {N, T} = GaussMod{N,T}
promote_rule(::Type{T}, ::Type{GaussMod{N,T}}) where {N, T} = GaussMod{N,T}

promote_rule(::Type{GaussMod{N,T}}, ::Type{Complex{T}}) where {N, T} = GaussMod{N,T}
promote_rule(::Type{Complex{T}}, ::Type{GaussMod{N,T}}) where {N, T} = GaussMod{N,T}

promote_rule(::Type{Mod{N,T}}, ::Type{Complex{T}}) where {N, T} = GaussMod{N,T}
promote_rule(::Type{Complex{T}}, ::Type{Mod{N,T}}) where {N, T} = GaussMod{N,T}


promote_rule(::Type{GaussMod{N,T}}, ::Type{Rational{T}}) where {N, T} = GaussMod{N,T}
promote_rule(::Type{Rational{T}}, ::Type{GaussMod{N,T}}) where {N, T} = GaussMod{N,T}

promote_rule(::Type{Mod{N,T}}, ::Type{T}) where {N, T<:Complex} = GaussMod{N,T}
promote_rule(::Type{T}, ::Type{Mod{N,T}}) where {N, T<:Complex} = GaussMod{N,T}
