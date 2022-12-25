# tranform between 

testInput = raw"""
1=-0-2
12111
2=0=
21
2=01
111
20012
112
1=-1=
1-12
12
1=
122
"""

Digits = Dict(
    '=' => -2,
    '-' => -1,
    '0' => 0,
    '1' => 1,
    '2' => 2,
)

"""
SNAFU -> Decimal
"""
function s2d(s)
    n = 0
    for i in 0:lastindex(s)-1
        n += Digits[s[end-i]] * 5^i
    end
	return n
end

Symbols = Dict(
    0 => '=',
    1 => '-',
    2 => '0',
    3 => '1',
    4 => '2',
)

"""
Decimal -> SNAFU

Strategy: 
    - Contract the number `n` to the interval [-1/2, 1/2) + 1/2.
    - Then apply the usual base-5 representation.
"""
function d2s(n)
    if n == 0
        return "0"
    end
    s = ""
    p = floor(log(5, 2 * n)) + 1 |> Int
    m = n // (5^p) + 1//2 # m in [1, 0)
    for i = 1:p
        s *= Symbols[floor(5m)]
        m = 5m - floor(5m)
    end
    return s
end

"""
Composite the previous steps to get the solution.
"""
soln1(p = "./inputs/day25.txt") = d2s(sum(s2d.(readlines(p))))

soln1test(s) = d2s(sum(s2d.(split(s, '\n', keepempty = false))))

# testList = split(testInput, '\n', keepempty = false)
# @info d2s.(s2d.(testList)) == testList

@info soln1test(testInput) == "2=-1=0"
soln1()
