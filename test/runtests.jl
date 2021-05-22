using Test
using Mods

@testset "Constructors" begin 
    @test Mod{17}() == 0
    @test Mod{17}(1) == GaussMod{17}(1,0)
    @test GaussMod{17}(1,2) == 1 + 2im
    a = Mod{17}(3)
    @test typeof(a) == Mod{17,Int}
    a = GaussMod{17}(3,2)
    @test typeof(a) == GaussMod{17,Int}
    a = zero(GaussMod{17})
    @test typeof(a) == GaussMod{17,Int}
end 


@testset "Mod arithmetic" begin
    p = 23
    a = Mod{p}(2)
    b = Mod{p}(25)
    @test a == b
    @test a == 2
    @test a == -21

    b = Mod{p}(20)
    @test a + b == 22
    @test a - b == -18
    @test a + a == 2a
    @test 0 - a == -a

    @test a * b == Mod{p}(17)
    @test (a / b) * b == a
    @test (b // a) * (2 // 1) == b
    @test a * (2 // 3) == (2a) * inv(Mod{p}(3))

    @test is_invertible(a)
    @test !is_invertible(Mod{10}(4))

    @test a^(p - 1) == 1
    @test a^(-1) == inv(a)
end

@testset "GaussMod arithmetic" begin
    p = 23
    a = GaussMod{p}(3 - im)
    b = GaussMod{p}(5 + 5im)

    @test a + b == 8 + 4im
    @test a + Mod{p}(11) == Mod{p}(14, 22)
    @test -a == 20 + im
    @test a - b == Mod{p}(3 - im - 5 - 5im)

    @test a * b == Mod{p}((3 - im) * (5 + 5im))
    @test a / b == Mod{p}((3 - im) // (5 + 5im))

    @test a^(p * p - 1) == 1
    @test is_invertible(a)
    @test a * inv(a) == 1

    @test a / (1 + im) == a / GaussMod{p}(1 + im)
    @test imag(a * a') == 0






end

@testset "Large Modulus" begin

    p = 9223372036854775783   # This is a large prime
    x = Mod{p}(-2)
    @test x * x == 4
    @test x + x == -4
    @test x / x == 1
    @test x / 3 == x / Mod{p}(3)
    @test (x / 3) * (3 // x) == 1
    @test x // x == value(x) / x
    @test x^4 == 16
    @test x^(p - 1) == 1   # Fermat Little Theorem test
    @test 2x == x + x
    @test x - x == 0
    y = inv(x)
    @test x * y == 1
    @test x + p == x
    @test x * p == 0
    @test p - x == x - 2x

    p = 9223372036854775783   # This is a large prime
    x = Mod{p}(-2 + 0im)
    @test x * x == 4
    @test x + x == -4
    @test x / x == 1
    @test x / 3 == x / Mod{p}(3)
    @test (x / 3) * (3 // x) == 1
    @test x // x == value(x) / x
    @test x^4 == 16
    @test x^(p - 1) == 1   # Fermat Little Theorem test
    @test 2x == x + x
    @test x - x == 0
    y = inv(x)
    @test x * y == 1
    @test x + p == x
    @test x * p == 0
    @test p - x == x - 2x

    @test 0 <= value(rand(Mod{p})) < p

end



@testset "CRT" begin
    p = 23
    q = 91
    a = Mod{p}(17)
    b = Mod{q}(32)

    x = CRT(a, b)
    @test a == mod(value(x), p)
    @test b == mod(value(x), q)

    c = Mod{101}(86)
    x = CRT(a,b,c)

    @test a == mod(value(x), p)
    @test b == mod(value(x), q)
    @test c == mod(value(x), 101)

end


@testset "Matrices" begin
    M = zeros(Mod{11}, 3, 3)
    @test sum(M) == 0

    M = ones(Mod{11}, 5, 5)
    @test sum(M) == 3

    M = rand(GaussMod{11}, 5, 6)
    @test size(M) == (5, 6)

    A = rand(Mod{17}, 5, 5)
    X = values.(A)
    @test sum(X) == sum(Mod{17}.(A))
end

@testset "Hashing/Iterating" begin
    x = Mod{17}(11)
    y = x + 0im
    @test x == y
    @test hash(x) == hash(y)
    @test typeof(x) !== typeof(y)

    A = Set([x,y])
    @test length(A) == 1

    v = [Mod{10}(t) for t = 1:15]
    w = [Mod{10}(t + 0im) for t = 1:15]
    S = Set(v)
    T = Set(w)
    @test length(S) == 10
    @test S == T
    @test union(S, T) == intersect(S, T)
end


