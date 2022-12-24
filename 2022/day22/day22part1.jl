# AoC 2022 Day 22: Part 1

getpass(r, c, f) = 1000 * r + 4 * c + f

"""
read map and path
"""
function readinput(input)
	rl = readlines(input)
	return rl[1:end-2], rl[end]
end

"""
PART 1
"""
function getrcf(M, P)
	# init
	s = [1, findfirst(".", M[1])[1], 0]

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
			s[end] = mod(s[end] + 1, 4) 
			continue
		end
		if cmd == "L"
			s[end] = mod(s[end] - 1, 4)
			continue
		end
		
		# move
		numMv = parse(Int, cmd)
		mv = 1
		if s[end] == 0
			while mv <= numMv
				next = mod(s[2], length(M[s[1]])) + 1
				while M[s[1]][next] == ' '
					next = mod(next, length(M[s[1]])) + 1
				end
				M[s[1]][next] == '#' && break
				s[2] = next
				mv += 1
			end
			continue
		end
		if s[end] == 1
			while mv <= numMv
				next = mod(s[1], length(M)) + 1
				while length(M[next]) < s[2] ||  M[next][s[2]] == ' '
					next = mod(next, length(M)) + 1
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
				while  M[s[1]][next] == ' '
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
				while length(M[next]) < s[2] ||  M[next][s[2]] == ' '
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
	return s
end

output(p) = getpass(getrcf(readinput(joinpath(@__DIR__, p))...)...)

# ---------------------------------------------------------------------------- #
#                                     test                                     #
# ---------------------------------------------------------------------------- #
@info output("inputtest.txt") == 6032
output("input.txt")
