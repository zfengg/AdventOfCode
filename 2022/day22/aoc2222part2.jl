# AoC 2022 Day 22: Part 2

getpass(r, c, f) = 1000 * r + 4 * c + f

INPUT = joinpath(@__DIR__, "input1.txt")

"""
read map and path
"""
function readinput(input)
    rl = readlines(input)
    return rl[1:end-2], rl[end]
end

M, P = readinput(INPUT)

"""
get the neighbor at edge of a face from the unfolding `A` 

# Example
```julia
 A = [
	Dict(4 => 2),
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
				if  movs[end-1] == movs[end]
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
	1 => r,
	2 => d,
	3 => l,
	4 => u
"""
function getcube(M)
	# get the edge length
    lenEdge = 4

	# faces by their boundaries
	faces = []
	b2f = Dict() # boundary to face
    for i in 0:2, j in 0:3
        if !isequal(M[i*lenEdge+1][j*lenEdge+1], ' ')
			tmp = [(j+1)*lenEdge+1, (i+1)*lenEdge+1, j*lenEdge+1, i*lenEdge+1]
            push!(faces, tmp)
			push!(b2f, tmp => length(faces))
		end
    end
	
	# the unfolding as a directed graph
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

mutable struct State
	r::Int # row
	c::Int # col
	d::Int # direction
	f::Int # face of the cube
end

"""
	1 => r,
	2 => d,
	3 => l,
	4 => u
"""
function getrcf(M, P)
	cube, faces = getcube(M)
    # init
	s = State(1, findfirst(".", M[1])[1], 1, 1)
    # s = [1, findfirst(".", M[1])[1], 0]

    # start tracing path
    cmdstart = 1
    cmdend = 1
    while cmdstart <= length(P)
        # get command
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

        # move
        numMv = parse(Int, cmd)
        mv = 1
        if s.d == 1
            while mv <= numMv
                next = s.c + 1
				if next > faces[s.f][s.d]
					next = faces[cube[s.f][s.d]]
				end
                M[s[1]][next] == '#' && break
                s[2] = next
                mv += 1
            end
            continue
        end
        if s[end] == 1
            while mv <= numMv
                next = s[1] % length(M) + 1
                while length(M[next]) < s[2] || M[next][s[2]] == ' '
                    next = next % length(M) + 1
                end
                M[next][s[2]] == '#' && break
                s[1] = next
                mv += 1
            end
            continue
        end
        if s[end] == 2
            while mv <= numMv
                next = s[2] - 1
                if iszero(next)
                    next = length(M[s[1]])
                end
                while M[s[1]][next] == ' '
                    next = next - 1
                    if iszero(next)
                        next = length(M[s[1]])
                    end
                end
                M[s[1]][next] == '#' && break
                s[2] = next
                mv += 1
            end
            continue
        end
        if s[end] == 3
            while mv <= numMv
                next = s[1] - 1
                if iszero(next)
                    next = length(M)
                end
                while length(M[next]) < s[2] || M[next][s[2]] == ' '
                    next = next - 1
                    if iszero(next)
                        next = length(M)
                    end
                end
                M[next][s[2]] == '#' && break
                s[1] = next
                mv += 1
            end
            continue
        end
    end
    @info s
    return s
end

output(p) = getpass(getrcf(readinput(joinpath(@__DIR__, p))...)...)

# M, P = readinput(joinpath(@__DIR__, "inputtest.txt"))
# getrcf(M, P)
@info output("inputtest.txt") == 5031
# output("input1.txt")
