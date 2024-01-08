(+)(a::Mod{N}, b::Mod{N}) where {N} = Mod{N}(widen(value(a)) + widen(value(b)))
(+)(a::GaussMod{N}, b::GaussMod{N}) where {N} = Mod{N}(widen(value(a)) + widen(value(b)))

(-)(a::Mod{N}) where {N} = Mod{N}(-value(a))
(-)(a::GaussMod{N}) where {N} = GaussMod{N}(-value(a))

(-)(a::AbstractMod, b::AbstractMod) = a + (-b)

(*)(a::Mod{N}, b::Mod{N}) where {N} = Mod{N}(widen(value(a)) * widen(value(b)))
(*)(a::GaussMod{N}, b::GaussMod{N}) where {N} =
    GaussMod{N}(widen(value(a)) * widen(value(b)))

"""
    is_invertible(a::AbstractMod)::Bool

Return `true` is `a` has a multiplicative inverse.
"""
function is_invertible(a::Mod{N})::Bool where {N}
    gcd(value(a), N) == 1
end
is_invertible(a::GaussMod)::Bool = is_invertible(real(a * a'))

function _invmod(x::S, m::T) where {S<:Integer,T<:Integer}
    (g, v, _) = gcdx(x, m)
    if g != 1
        error("Mod{$m}($x) is not invertible")
    end
    return v
end

inv(a::Mod{N}) where {N} = Mod{N}(_invmod(value(a), N))
function inv(a::GaussMod{N}) where {N}
    d = real(a * a')
    try
        result = inv(d) * a'
        return result
    catch
        error("$a is not invertible")
    end
end

(/)(a::AbstractMod, b::AbstractMod) = a * inv(b)
(//)(a::AbstractMod, b::AbstractMod) = a * inv(b)
(//)(a::AbstractMod, b) = a / b
(//)(a, b::AbstractMod) = a / b
