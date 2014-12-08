module Mods

import Base.isequal, Base.==, Base.+, Base.-, Base.*
import Base.inv, Base./, Base.^

export Mod
export isequal, ==, +, -, *
export is_invertible, inv, /, ^

immutable Mod
    val::Integer
    mod::Integer
    function Mod{T <: Integer}(a::T, m::T)
        if m < 2
            error("Modulus must be at least 2")
        end
        a = mod(a,m)
        new(a,m)
    end
end

# Test for equality
isequal(x::Mod, y::Mod) = x.mod==y.mod && x.val==y.val
==(x::Mod,y::Mod) = isequal(x,y)

function modcheck(x::Mod, y::Mod)
    if x.mod != y.mod
        error("Cannot operate on two Mod objects with different moduli")
    end
    true
end

# Easy arithmetic
function +(x::Mod, y::Mod)
    modcheck(x,y)
    return Mod(x.val+y.val, x.mod)
end

function -(x::Mod,y::Mod)
    modcheck(x,y)
    return (x.val-y.val, x.mod)
end

function -(x::Mod)
    return Mod(-x.val, x.mod)
end

function *(x::Mod, y::Mod)
    modcheck(x,y)
    return Mod(x.val*y.val, x.mod)
end

# Division stuff

is_invertible(x::Mod) = return gcd(x.val,x.mod)==1

function inv(x::Mod)
    (g, v, ignore) = gcdx(x.val, x.mod)
    if g != 1
        error(x, " is not invertible")
    end
    return Mod(v, x.mod)
end

function /(x::Mod, y::Mod)
    modcheck(x,y)
    return x * inv(y)
end

function ^(x::Mod, k::Integer)
    if k>0
        return Mod(powermod(x.val, k, x.mod), x.mod)
    end
    if k==0
        T = typeof(x.val)
        return Mod(one(T), x.mod)
    end
    y = inv(x)
    return y^(-k)
end

end # end of module Mods
