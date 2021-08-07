function Base.iterate(::Type{Mod{m}}) where {m}
    return Mod{m}(0), 0
end

function Base.iterate(::Type{Mod{m}}, s) where {m}
    if s == m - 1
        return nothing
    end
    s += 1
    return Mod{m}(s), s
end

Base.IteratorSize(::Type{Mod{m}}) where {m} = Base.HasLength()

Base.length(::Type{Mod{m}}) where {m} = m
