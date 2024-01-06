value(a::AbstractMod) = a.val
modulus(a::Mod{N}) where N = N 
modulus(a::GaussMod{N}) where N = N

abs(a::AbstractMod) = abs(value(a))
conj(x::Mod{N}) where {N} = x
conj(x::GaussMod{N}) where N = GaussMod{N}(value(x)')

# real & imaginary parts
real(x::GaussMod{N}) where N = Mod{N}(real(value(x)))
imag(x::GaussMod{N}) where N = Mod{N}(imag(value(x)))


function hash(x::AbstractMod, h::UInt64 = UInt64(0))
    v = value(x)
    m = modulus(x)
    return hash(v, hash(m, h))
end



# Test for equality
iszero(x::AbstractMod) = iszero(value(x))
isone(x::AbstractMod) = isone(value(x))
(==)(x::AbstractMod, y::AbstractMod) = modulus(x) == modulus(y) && value(x) == value(y)
(==)(x::AbstractMod, y::T) where {T<:CZQ} = x == Mod{modulus(x)}(y)
(==)(x::T, y::AbstractMod) where {T<:CZQ} = Mod{modulus(x)}(x) == y

