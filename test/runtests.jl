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

@test Mod{p}(22) == Mod(22,p)

q = 91
a = Mod(17,p)
b = Mod(32,q)

x = CRT(a,b)
@test Mod(x.val,p)==a
@test Mod(x.val,q)==b
@test inv(a)*a == 1

p = 9223372036854775783   # This is a big prime
x = Mod(-2,p)
@test x*x == 4
@test x+x == -4
@test x/x == 1
@test x/3 == x/Mod{p}(3)
@test (x/3) * (3//x) == 1
@test x//x == value(x)/x
@test x^4 == 16
@test x^(p-1) == 1   # Fermat Little Theorem test
@test 2x == x+x
@test x-x == 0
y = inv(x)
@test x*y == 1
@test x+p == x
@test x*p == 0
@test p-x == x-2x
@test 0 <= value(rand(Mod{p})) < p


M = zeros(Mod{11},3,3)
@test sum(M) == 0

M = ones(Mod{11},5,5)
@test sum(M) == 3
