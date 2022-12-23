#! julia

# AoC 2022 Day 22: Part 1

getpass(r, c, f) = 1000 * r + 4 * c + f

INPUT = "input1.txt"

"""
read map and path
"""
function readinput(input)
	rl = readlines(input)
	return rl[1:end-2], rl[end]
end

M, P = readinput(INPUT)

"""
the PART 1
"""
function getrcf(M, P)
	# init
	s = [1, findfirst(".", M[1])[1], 0]
	@info s

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
		if cmdstart > length(P)
			break
		end

		@info cmd

		# rotation
		if cmd == "R"
			s[end] = (s[end] + 1) % 4
			continue
		end
		if cmd == "L"
			s[end] = (s[end] - 1) % 4
			continue
		end

		# move
		numMv = parse(Int, cmd)
		mv = 1
		if s[end] == 0
			@info M[s[1]]
			while mv <= numMv
				next = s[2] % length(M[s[1]]) + 1
				@info next
				while M[s[1]][next] == " "
					@info M[s[1]][next]
					next += 1
				end
				M[s[1]][next] == "#" && break
				s[2] = next
				@info s
				mv += 1
			end
		end
		if s[end] == 1
			while mv <= numMv
				next = s[1] % length(M) + 1
				while length(M[next]) < s[2] ||  M[next][s[2]] == " "
					next += 1
				end
				M[next][s[2]] == "#" && break
				s[1] = next
				mv += 1
			end
		end
		if s[end] == 2
			while mv <= numMv
				next = undef
				if s[2] == 1
					next = length(M[s[1]])
				else
					next = s[2] - 1
				end
				# next = s[2] % length(M[s[1]])
				if M[s[1]][next] == " "
					next = length(M[s[1]])
				end
				M[s[1]][next] == "#" && break
				s[2] = next
				mv += 1
			end
		end
		if s[end] == 3
			while mv <= numMv
				next = undef
				if s[1] == 1
					next = length(M)
				else
					next = s[1] - 1
				end
				while length(M[next]) < s[2] ||  M[next][s[2]] == " "
					next -= 1
				end
				M[next][s[2]] == "#" && break
				s[1] = next
				mv += 1
			end
		end
		@info s
	end
	return s
end

M, P = readinput("inputtest.txt")
getrcf(M, P)

