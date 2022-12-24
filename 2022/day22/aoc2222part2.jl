# AoC 2022 Day 22: Part 2

"""
	Record the state of the turtle.

The code for direction `d`: 
	1 => r, 
	2 => d, 
	3 => l, 
	4 => u
"""
mutable struct State
    r::Int # row
    c::Int # col
    d::Int # direction
    f::Int # face of the cube
end


"""
generate password from `s::State`
"""
getpass(s::State) = 1000 * s.r + 4 * s.c + s.d - 1


"""
read map and path from input file.
"""
function readinput(input)
    rl = readlines(input)
    return rl[1:end-2], rl[end]
end

"""
get the neighbor at edge of a face from the unfolding `A` 

# Example
```julia
unfolding = [
	Dict(4 => 2), # face => move pairs
	Dict(3 => 1),
	Dict(2 => 3, 4 => 1),
	Dict(1 => 4, 3 => 3, 5 => 2),
	Dict(4 => 4, 6 => 1),
	Dict(5 => 3),
]
```
"""
function getneighbors(unfolding, i)
    A = deepcopy(unfolding)
    neighbors = zeros(Int, 5)
    # DFS
    faces = [i]
    movs = []
    knowns = []
    cur = i
    while !isempty(faces)
        # go deepest
        while !isempty(A[cur])
            nextface, nextmov = pop!(A[cur])
            pop!(A[nextface], cur)
            cur = nextface
            push!(faces, nextface)
            push!(movs, nextmov)
            # update neighbors & knowns
            if length(movs) == 1
                nextknown = movs[end]
            elseif length(movs) == 2
                if movs[end] == movs[1]
                    nextknown = 5
                else
                    nextknown = movs[end]
                end
            elseif length(movs) == 3
                if movs[end-1] == movs[end]
                    nextknown = mod(knowns[1] + 1, 4) + 1
                else
                    if movs[end] == movs[1]
                        nextknown = 5
                    else
                        nextknown = movs[end]
                    end
                end
            elseif length(movs) == 4
                if allequal(movs[1:3])
                    nextknown = movs[end]
                elseif movs[end-1] == movs[end]
                    nextknown = mod(knowns[2] + 1, 4) + 1
                elseif movs[2] == movs[4]
                    nextknown = mod(knowns[1] + 1, 4) + 1
                else
                    nextknown = 5
                end
            else
                nextknown = findfirst(iszero, neighbors)
            end
            neighbors[nextknown] = nextface
            push!(knowns, nextknown)
        end

        # bunch back
        while isempty(A[cur])
            pop!(faces)
            !isempty(movs) && pop!(movs)
            !isempty(knowns) && pop!(knowns)
            isempty(faces) && break
            cur = faces[end]
        end
    end
    return neighbors
end


"""
A small function get the unit length of the edge of a face.
"""
function get_unit_len(M)
    pool = []
    for r in M
        c = 1
        while r[c] == ' '
            c += 1
        end
        push!(pool, length(r) - c + 1)
    end
    for c in 1:maximum(length.(M))
        s = []
        flag = true
        for r in 1:lastindex(M)
            if flag
                if c <= length(M[r]) && !isequal(M[r][c], ' ')
                    push!(s, r)
                    flag = false
                end
            else
                if r == lastindex(M)
                    push!(s, r)
                    break
                end
                if c > length(M[r]) || isequal(M[r][c], ' ')
                    push!(s, r - 1)
                    break
                end
            end
        end
        push!(pool, s[2] - s[1] + 1)
    end
    return gcd(Int.(pool))
end

"""
Get the cube from the map `M`.
"""
function getcube(M)
    # get the edge length
    lenEdge = get_unit_len(M)

    # faces by their boundaries
    faces = []
    b2f = Dict() # boundary to face
    r = 1
    while r <= lastindex(M)
        c = 1
        while c <= lastindex(M[r])
            if !isequal(M[r][c], ' ')
                tmp = [c + lenEdge - 1, r + lenEdge - 1, c, r]
                push!(faces, tmp)
                push!(b2f, tmp => length(faces))
            end
            c += lenEdge
        end
        r += lenEdge
    end

    # generate unfolding as a directed graph
    unfolding = []
    for f in 1:lastindex(faces)
        neighbors = Dict()
        tmp = faces[f] + lenEdge .* [1, 0, 1, 0]
        if haskey(b2f, tmp)
            push!(neighbors, b2f[tmp] => 1)
        end
        tmp = faces[f] + lenEdge .* [0, 1, 0, 1]
        if haskey(b2f, tmp)
            push!(neighbors, b2f[tmp] => 2)
        end
        tmp = faces[f] - lenEdge .* [1, 0, 1, 0]
        if haskey(b2f, tmp)
            push!(neighbors, b2f[tmp] => 3)
        end
        tmp = faces[f] - lenEdge .* [0, 1, 0, 1]
        if haskey(b2f, tmp)
            push!(neighbors, b2f[tmp] => 4)
        end
        push!(unfolding, neighbors)
    end

    # generate the cube by edge equivalences
    cube = []
    for f in 1:lastindex(unfolding)
        push!(cube, getneighbors(unfolding, f))
    end
    return cube, faces
end


"""
Move the init state along the path `P` in the cubic map `M`.
"""
function getstate(M, P)
    # get cubes, faces
    cube, faces = getcube(M)
    # init state
    s = State(1, findfirst(".", M[1])[1], 1, 1)

    """
    Move `n` steps in the state `s`.
    """
    function mvstate(n)
        mv = 0
        while mv < n
            # check if at the boundary
            isbdry = false
            if isodd(s.d)
                isbdry = s.c == faces[s.f][s.d]
            else
                isbdry = s.r == faces[s.f][s.d]
            end

            # get tmp next position (r, c)
            if isbdry
                nextF = cube[s.f][s.d] # next face
                nextE = findfirst(isequal(s.f), cube[nextF]) # next edge
                preE = mod(s.d, 4) + 1 # the prev edge
                nextPreE = findfirst(isequal(cube[s.f][preE]), cube[nextF])
                if isodd(s.d)
                    diff = abs(faces[s.f][preE] - s.r)
                else
                    diff = abs(faces[s.f][preE] - s.c)
                end
                if nextPreE > 2
                    a = faces[nextF][nextPreE] + diff
                else
                    a = faces[nextF][nextPreE] - diff
                end
                b = faces[nextF][nextE]
                if isodd(nextE)
                    c = b
                    r = a
                else
                    r = b
                    c = a
                end
            else
                if isodd(s.d)
                    r = s.r
                    c = s.c + (2 - s.d)
                else
                    c = s.c
                    r = s.r + (3 - s.d)
                end
            end

            # check if meet the wall
            if M[r][c] == '#'
                break
            end

            # update state
            s.r = r
            s.c = c
            if isbdry
                s.f = nextF
                s.d = mod(nextE + 1, 4) + 1
            end
            mv += 1
        end
    end

    # start tracing path
    cmdstart = 1
    cmdend = 1
    while cmdstart <= length(P)
        # get the command
        if isnumeric(P[cmdstart])
            while cmdend <= length(P) && isnumeric(P[cmdend])
                cmdend += 1
            end
            cmd = P[cmdstart:cmdend-1]
        else
            cmd = P[cmdstart:cmdend]
            cmdend += 1
        end
        cmdstart = cmdend

        # rotation
        if cmd == "R"
            s.d = mod(s.d, 4) + 1
            continue
        end
        if cmd == "L"
            s.d = mod(s.d - 2, 4) + 1
            continue
        end

        # make a move
        mvstate(parse(Int, cmd))
    end
    return s
end

"""
composite all the previous functions
"""
output(p) = getpass(getstate(readinput(joinpath(@__DIR__, p))...))

# ---------------------------------------------------------------------------- #
#                                     test                                     #
# ---------------------------------------------------------------------------- #
@info output("inputtest.txt") == 5031
output("input.txt")
