import Base: rand
rand(::Type{Mod{N}}, dims::Integer...) where {N} = Mod{N}.(rand(Int, dims...))
function rand(::Type{GaussMod{N}}, dims::Integer...) where {N}
    return GaussMod{N}.(rand(Complex{Int}, dims...))
end
