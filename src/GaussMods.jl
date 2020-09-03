import Base: mod, real, imag, reim, conj, promote_rule

export GaussMod

function mod(z::Complex{T}, m::Integer) where T<:Integer 
    a,b = reim(z)
    return mod(a,m) + mod(b,m)*im 
end 


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

modulus(x::GaussMod{T}) where T = T

real(x::GaussMod{N}) where N = Mod{N}(real(x.val))
real(x::Mod) = x 

imag(x::GaussMod{N}) where N = Mod{N}(imag(x.val))
imag(x::Mod{N}) where N = Mod{N}(0)

reim(x::AbstractMod) = (real(x),imag(x))

conj(x::GaussMod{N}) where N = GaussMod{N}(conj(x.val))

Mod{N}(x::Complex) where N = GaussMod{N}(x)



# ARITHMETIC

(+)(x::GaussMod{N}, y::GaussMod{N}) where N = GaussMod{N}(x.val+y.val)
(-)(x::GaussMod{N}) where N = GaussMod{N}(-x.val)
(-)(x::GaussMod{N},y::GaussMod{N}) where N = GaussMod{N}(x.val - y.val)
(*)(x::GaussMod{N},y::GaussMod{N}) where N = GaussMod{N}(x.val * y.val)

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
(/)(x::GaussMod{N}, y::GaussMod{N}) where N = x * inv(y)



show(io::IO, z::GaussMod{N}) where N = print(io,"Mod{$N}($(z.val))")






promote_rule(::Type{GaussMod{N}}, ::Type{Mod{N}}) where N = GaussMod{N}
promote_rule(::Type{Mod{N}}, ::Type{GaussMod{N}}) where N = GaussMod{N}

promote_rule(::Type{GaussMod{N}}, ::Type{T}) where {N, T<:Integer} = GaussMod{N}
promote_rule(::Type{T}, ::Type{GaussMod{N}}) where {N, T<:Integer} = GaussMod{N}

promote_rule(::Type{GaussMod{N}}, ::Type{Complex{T}}) where {N, T<:Integer} = GaussMod{N}
promote_rule(::Complex{Type{T}}, ::Type{GaussMod{N}}) where {N, T<:Integer} = GaussMod{N}

promote_rule(::Type{Mod{N}}, ::Type{Complex{T}}) where {N, T<:Integer} = GaussMod{N}
promote_rule(::Complex{Type{T}}, ::Type{Mod{N}}) where {N, T<:Integer} = GaussMod{N}





# promote_rule(::GaussMod{N}, ::Mod{N}) where N = GaussMod{N}
# promote_rule(::Mod{N}, ::GaussMod{N}) where N = GaussMod{N}
