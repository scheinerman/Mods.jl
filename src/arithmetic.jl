(+)(a::Mod{N}, b::Mod{N}) where {N} = Mod{N}(widen(value(a) + widen(value(b))))
(+)(a::GaussMod{N}, b::GaussMod{N}) where {N} = Mod{N}(widen(value(a) + widen(value(b))))

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

inv(a::Mod{N}) where {N} = Mod{N}(invmod(value(a), N))
function inv(a::GaussMod{N}) where {N}
    d = real(a * a')
    return inv(d) * a'
end

(/)(a::AbstractMod, b::AbstractMod) = a * inv(b)
(//)(a::AbstractMod, b::AbstractMod) = a * inv(b)
(//)(a::AbstractMod, b) = a / b
(//)(a, b::AbstractMod) = a / b
