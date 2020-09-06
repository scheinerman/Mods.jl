import Base: mod, real, imag, reim, conj, promote_rule

export GaussMod, AbstractMod

# mod support for Gaussian integers until officially adopted into Base
mod(z::Complex{<:Integer}, n::Integer) = Complex(mod(real(z), n), mod(imag(z), n))

"""
`GaussMod{m}(v)` (and also `GaussMod(v,m)`) creates a modular number in mod `m` with value `v%m`.
`GaussMod{m}()` is equivalent to `GaussMod(0,m)`.
"""
struct GaussMod{N} <: AbstractMod
    val::Complex{Int}
    function GaussMod(x::Complex{T},N::Int) where T<:Integer
        @assert N>1 "modulus must be at least 2"
        new{N::Int}(mod(x,N))
    end
end

GaussMod{N}(x::Complex{T}=0+0im) where {N,T<:Integer} = GaussMod(x,N)
GaussMod{N}(x::T) where {N,T<:Integer}  = GaussMod{N}(Complex{Int}(x))
GaussMod(x::Mod{N}) where N = GaussMod{N}(x.val)
GaussMod{N}(x::Mod{N}) where N = GaussMod{N}(x.val)

GaussMod{N}(x::Rational{T}) where {N,T<:Integer} = GaussMod{N}(numerator(x)) / GaussMod{N}(denominator(x))
GaussMod{N}(x::Complex{Rational{T}}) where {N,T<:Integer} = GaussMod{N}(real(x)) + GaussMod{N}(imag(x))*im


modulus(x::GaussMod{T}) where T = T

real(x::GaussMod{N}) where N = Mod{N}(real(x.val))
real(x::Mod) = x 

imag(x::GaussMod{N}) where N = Mod{N}(imag(x.val))
imag(x::Mod{N}) where N = Mod{N}(0)

reim(x::AbstractMod) = (real(x),imag(x))

conj(x::GaussMod{N}) where N = GaussMod{N}(conj(x.val))

Mod{N}(x::Complex) where N = GaussMod{N}(x)

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

rand(::Type{GaussMod{N}}) where N = GaussMod{N}(rand(Int) + im*rand(Int))
rand(::Type{GaussMod{N}},dims::Integer...) where N = GaussMod{N}.(rand(Int,dims...)) + im*GaussMod{N}.(rand(Int,dims...))




promote_rule(::Type{GaussMod{N}}, ::Type{Mod{N}}) where N = GaussMod{N}
promote_rule(::Type{Mod{N}}, ::Type{GaussMod{N}}) where N = GaussMod{N}

promote_rule(::Type{GaussMod{N}}, ::Type{T}) where {N, T<:Integer} = GaussMod{N}
promote_rule(::Type{T}, ::Type{GaussMod{N}}) where {N, T<:Integer} = GaussMod{N}

promote_rule(::Type{GaussMod{N}}, ::Type{Complex{T}}) where {N, T<:Integer} = GaussMod{N}
promote_rule(::Complex{Type{T}}, ::Type{GaussMod{N}}) where {N, T<:Integer} = GaussMod{N}

promote_rule(::Type{Mod{N}}, ::Type{Complex{T}}) where {N, T<:Integer} = GaussMod{N}
promote_rule(::Complex{Type{T}}, ::Type{Mod{N}}) where {N, T<:Integer} = GaussMod{N}


promote_rule(::Type{GaussMod{N}}, ::Type{T}) where {N, T<:Rational} = GaussMod{N}
promote_rule(::Type{T}, ::Type{GaussMod{N}}) where {N, T<:Rational} = GaussMod{N}

promote_rule(::Type{GaussMod{N}}, ::Type{T}) where {N, T<:Complex} = GaussMod{N}
promote_rule(::Type{T}, ::Type{GaussMod{N}}) where {N, T<:Complex} = GaussMod{N}


promote_rule(::Type{Mod{N}}, ::Type{T}) where {N, T<:Complex} = GaussMod{N}
promote_rule(::Type{T}, ::Type{Mod{N}}) where {N, T<:Complex} = GaussMod{N}
