module Mods

export Mod

immutable Mod{T <: Integer}
    val::T
    mod::T
end

end # end of module Mods
