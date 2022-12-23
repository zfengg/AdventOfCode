# function getneighbors1(unfolding, i)
# 	A = deepcopy(unfolding)
# 	neighbors = zeros(Int, 5)
# 	# DFS
# 	faces = [i]
# 	movs = []
# 	knowns = []
# 	numKnownNeighbors = 0
# 	lastknown = undef
# 	cur = i
# 	while !isempty(faces)
# 		# go deepest
# 		while !isempty(A[cur])
# 			nextface, nextmov = pop!(A[cur])
# 			pop!(A[nextface], cur)
# 			cur = nextface
# 			push!(faces, nextface)
# 			push!(movs, nextmov)
# 			# update neighbors & knowns
# 			if length(movs) == 1
# 				lastknown = nextmov 
# 			elseif nextmov == movs[1]
# 				if length(movs) == 3 && movs[2] == movs[1]
# 					lastknown = mod(lastknown + 1, 4) + 1
# 				else
# 					if in(5, knowns)
# 						if lastknown == 5
# 							lastknown = knowns[1]
# 						end
# 						if in(mod(lastknown, 4) + 1, knowns)
# 							lastknown = mod(lastknown - 2, 4) + 1
# 						else
# 							lastknown = mod(lastknown, 4) + 1
# 						end
# 					else
# 						lastknown = 5
# 					end
# 				end
# 			else
# 				if numKnownNeighbors == 1
# 					lastknown = nextmov 
# 				else
# 					if lastknown == 5
# 						lastknown = knowns[1]
# 					end
# 					if in(mod(lastknown, 4) + 1, knowns)
# 						lastknown = mod(lastknown - 2, 4) + 1
# 					else
# 						lastknown = mod(lastknown, 4) + 1
# 					end
# 				end
# 			end
# 			if lastknown != 5
# 				numKnownNeighbors += 1
# 			end
# 			push!(knowns, lastknown)
# 			neighbors[lastknown] = nextface 
# 		end
# 		# bunch back
# 		while isempty(A[cur])
# 			pop!(faces)
# 			!isempty(movs) && pop!(movs)
# 			if !isempty(knowns)
# 				if pop!(knowns) != 5
# 					numKnownNeighbors -= 1
# 				end
# 				if !isempty(knowns)
# 					lastknown = knowns[end]
# 				end
# 			end
# 			isempty(faces) && break
# 			cur = faces[end]
# 		end
# 	end
# 	return neighbors
# end

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


A = [
	Dict(4 => 2),
	Dict(3 => 1),
	Dict(2 => 3, 4 => 1),
	Dict(1 => 4, 3 => 3, 5 => 2),
	Dict(4 => 4, 6 => 1),
	Dict(5 => 3),
]

A = [
	Dict(3 => 2),
	Dict(3 => 1, 5 => 2),
	Dict(2 => 3, 1 => 4),
	Dict(5 => 1, 6 => 2),
	Dict(4 => 3, 2 => 4),
	Dict(4 => 4),
]

println(getneighbors(A, 6))
println()
for i in 1:lastindex(A)
	# println(getneighbors1(A, i))
	println(getneighbors(A, i))
	# println()
end