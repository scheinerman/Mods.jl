using Mods, BenchmarkTools, LinearAlgebra, LinearAlgebraX

# m = typemax(Int32) - 18   # this is a big prime but < 2^31 - 1
# d = 500

function speed_test(m, d)

    A = rand(Mod{m}, d, d)

    @info "modulus = $m, matrix size = $d"

    @info "Determinant"
    @btime det(A)

    @info "Rank"
    @btime rankx(A)

    @info "Inverse"
    @btime inv(A)

    @info "Multiplication"
    @btime A * A * A

    AA = value.(A)
    @show A^3 == AA^3   # this should be false if big enough
    nothing
end

## RESULT WITH NO CHANGE IN CODE
# [ Info: modulus = 2147483629, matrix size = 500
# [ Info: Determinant
#   1.260 s (4 allocations: 1.91 MiB)
# [ Info: Rank
#   1.685 s (256007 allocations: 1001.13 MiB)
# [ Info: Inverse
#   6.202 s (8 allocations: 5.73 MiB)
# [ Info: Multiplication
#   5.557 s (12 allocations: 3.87 MiB)

## RESULTS WITH REMOVING widemul and widen
# [ Info: modulus = 2147483629, matrix size = 500
# [ Info: Determinant
#   156.085 ms (4 allocations: 1.91 MiB)
# [ Info: Rank
#   329.689 ms (256007 allocations: 1001.13 MiB)
# [ Info: Inverse
#   1.444 s (8 allocations: 5.73 MiB)
# [ Info: Multiplication
#   1.215 s (12 allocations: 3.87 MiB)

## RESULTS WITH NEW CONTINGENT CODE 
# [ Info: modulus = 2147483629, matrix size = 500  <-- mod is < 2^31
# [ Info: Determinant
#   11.625 μs (3 allocations: 3.48 KiB)
# [ Info: Rank
#   30.292 μs (594 allocations: 103.02 KiB)
# [ Info: Inverse
#   128.041 μs (5 allocations: 10.19 KiB)
# [ Info: Multiplication
#   61.791 μs (8 allocations: 47.53 KiB)

# [ Info: modulus = 8589934609, matrix size = 500  <-- mod is > 2^32
# [ Info: Determinant
#   71.791 μs (3 allocations: 3.48 KiB)
# [ Info: Rank
#   125.250 μs (594 allocations: 103.02 KiB)
# [ Info: Inverse
#   409.250 μs (5 allocations: 10.19 KiB)
# [ Info: Multiplication
#   359.625 μs (8 allocations: 47.53 KiB)
# A ^ 3 == AA ^ 3 = false