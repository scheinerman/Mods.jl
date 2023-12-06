module Mods

import Base: (==), (+), (-), (*), (inv), (/), (//), (^)
import Base: hash, iszero, isone, mod, abs, conj, real, imag


export GaussMod, Mod, AbstractMod
export modulus, value, is_invertible

QZ = Union{<:Rational,<:Integer}
CZ = Union{Complex,<:Integer}
CZQ = Union{Complex{<:Integer},Integer,Complex{<:Rational},Rational}


abstract type AbstractMod <: Number end

include("constructors.jl")
include("basic_functions.jl")
include("promotion.jl")
include("arithmetic.jl")
include("iterate.jl")
include("random.jl")


end # module Mods
