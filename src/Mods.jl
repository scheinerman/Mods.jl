module Mods

import Base: (==), (+), (-), (*), (inv), (/), (//), (^)
import Base: hash, iszero, isone, mod, abs, conj, real, imag


export GaussMod, Mod, AbstractMod
export modulus, value, is_invertible

QZ = Union{<:Rational,<:Integer}
CZ = Union{Complex,<:Integer}
CZQ = Union{Complex{<:Integer},Integer,Complex{<:Rational},Rational}


abstract type AbstractMod <: Number end


const value_type = Int                # storage type for the value in a Mod

const max_mod = typemax(value_type)   # maximum modulus allowed
const max_mul = isqrt(max_mod)        # maximum before widening may be necessary for multiplication
const max_add = max_mod ÷ 2           # maximum before widening may be necessary for addition


include("constructors.jl")
include("basic_functions.jl")
include("promotion.jl")
include("arithmetic.jl")
include("iterate.jl")
include("random.jl")


end # module Mods
