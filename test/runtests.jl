using Test
using Mods

p = 23
@test Mod(2,p) == Mod(25,p)
@test Mod(2,p)+Mod(21,p) == Mod(0,p)
@test Mod(10,p)*Mod(5,p) == Mod(4,p)
@test Mod(10,p)/Mod(5,p) == Mod(2,p)
@test Mod(17,p) * inv(Mod(17,p)) == Mod(1,p)
@test Mod(17^6,p)==Mod(17,p)^6
@test Mod(17,p)^(-2) == inv(Mod(17,p))^2
@test Mod(17,p) == 17

q = 91
a = Mod(17,p)
b = Mod(32,q)

x = CRT(a,b)
@test Mod(x.val,p)==a
@test Mod(x.val,q)==b
@test inv(a)*a == 1
