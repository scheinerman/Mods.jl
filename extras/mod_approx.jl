using Mods


import Base: isapprox, rtoldefault

# Apporximate equality
rtoldefault(::Type{Mod{N,T}}) where {N,T} = rtoldefault(T)
isapprox(x::Mod, y::Mod; kwargs...) = false
isapprox(x::Mod{N}, y::Mod{N}; kwargs...) where {N} =
    isapprox(value(x), value(y); kwargs...) || isapprox(value(y), value(x); kwargs...)
