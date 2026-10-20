"""
    allmods(Mod{m})
    allmods(GaussMod{m})

An iterator over all elements of `Mod{m}` (the residues `0, 1, …, m-1`) or of
`GaussMod{m}` (`a + b*im` for `a, b` in `0:m-1`, `b` varying fastest).

```
julia> collect(allmods(Mod{4}))
4-element Vector{Mod{4}}:
 Mod{4}(0)
 Mod{4}(1)
 Mod{4}(2)
 Mod{4}(3)
```
"""
allmods(::Type{T}) where {T<:AbstractMod} = AllMods{T}()

struct AllMods{T<:AbstractMod} end

Base.eltype(::Type{AllMods{T}}) where {T} = T
Base.IteratorSize(::Type{<:AllMods}) = Base.HasLength()
Base.length(::AllMods{Mod{m}}) where {m} = m
Base.length(::AllMods{GaussMod{m}}) where {m} = m * m

function Base.iterate(::AllMods{Mod{m}}, s = 0) where {m}
    s < m || return nothing
    return Mod{m}(s), s + 1
end

function Base.iterate(::AllMods{GaussMod{m}}, s = 0) where {m}
    s < m * m || return nothing
    a, b = divrem(s, m)
    return GaussMod{m}(a + b * im), s + 1
end
