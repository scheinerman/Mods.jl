# (+)(a::Mod{N}, b::Mod{N}) where {N} = Mod{N}(widen(a.val) + widen(b.val))
# (+)(a::GaussMod{N}, b::GaussMod{N}) where {N} = Mod{N}(widen(a.val) + widen(b.val))

function (+)(a::Mod{N}, b::Mod{N}) where {N}
    N <= typemax(Int32) ? Mod{N}(a.val + b.val) : Mod{N}(widen(a.val) + widen(b.val))
end
function (+)(a::GaussMod{N}, b::GaussMod{N}) where {N}
    N <= typemax(Int32) ? Mod{N}((a.val) + (b.val)) :
    GaussMod{N}(widen(a.val) + widen(b.val))
end



(-)(a::Mod{N}) where {N} = Mod{N}(N - a.val)
(-)(a::GaussMod{N}) where {N} = GaussMod{N}(N - a.val)

(-)(a::AbstractMod, b::AbstractMod) = a + (-b)

# (*)(a::Mod{N}, b::Mod{N}) where {N} = Mod{N}(widemul(a.val, b.val))
# (*)(a::GaussMod{N}, b::GaussMod{N}) where {N} = GaussMod{N}(widemul(a.val, b.val))


function (*)(a::Mod{N}, b::Mod{N}) where {N}
    N <= typemax(Int32) ? Mod{N}(a.val * b.val) : Mod{N}(widemul(a.val, b.val))
end
function (*)(a::GaussMod{N}, b::GaussMod{N}) where {N}
    N <= typemax(Int32) ? GaussMod{N}(a.val * b.val) : GaussMod{N}(widemul(a.val, b.val))
end

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
