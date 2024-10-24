import Base: promote_rule

promo_error = "Cannot promote types with different moduli"

promote_rule(::Type{Mod{M}}, ::Type{Mod{N}}) where {M,N} = error(promo_error)

promote_rule(::Type{GaussMod{M}}, ::Type{GaussMod{N}}) where {M,N} = error(promo_error)

promote_rule(::Type{Mod{M}}, ::Type{GaussMod{N}}) where {M,N} = error(promo_error)

promote_rule(::Type{Mod{N}}, ::Type{Mod{N}}) where {N} = Mod{N}
promote_rule(::Type{GaussMod{N}}, ::Type{Mod{N}}) where {N} = GaussMod{N}
promote_rule(::Type{Mod{N}}, ::Type{GaussMod{N}}) where {N} = GaussMod{N}

promote_rule(::Type{Mod{N}}, ::Type{T}) where {N,T<:Integer} = Mod{N}
promote_rule(::Type{Mod{N}}, ::Type{Complex{T}}) where {N,T<:Integer} = GaussMod{N}

promote_rule(::Type{GaussMod{N}}, ::Type{T}) where {N,T<:Union{Integer,Complex}} =
    GaussMod{N}


promote_rule(::Type{Mod{N}}, ::Type{Rational{T}}) where {N,T<:Integer} = Mod{N}
promote_rule(::Type{GaussMod{N}}, ::Type{Rational{T}}) where {N,T<:Integer} = GaussMod{N}

promote_rule(::Type{Mod{N}}, ::Type{Complex{Rational{T}}}) where {N,T<:Integer} =
    GaussMod{N}
promote_rule(::Type{GaussMod{N}}, ::Type{Complex{Rational{T}}}) where {N,T<:Integer} =
    GaussMod{N}
