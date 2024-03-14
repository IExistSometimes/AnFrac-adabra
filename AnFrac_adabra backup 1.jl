### A Pluto.jl notebook ###
# v0.19.29

using Markdown
using InteractiveUtils

# ╔═╡ de8306e5-46b3-4c74-9442-0c327a78587f
using MAGEMin_C

# ╔═╡ 54597683-6ca7-4522-8964-da8bf772367c
using CSV

# ╔═╡ aa3fa333-efd7-4221-a9ad-19accfebb4b8
using Tables

# ╔═╡ 5971b407-cf50-440a-89ae-97b4c32c4c69
using DataFrames

# ╔═╡ b5f92c91-b32d-41a4-b6b5-2031f80ed631
begin
	#Defining things
	db   = "ig"  # database: ig, igneous (Holland et al., 2018); mp, metapelite (White et al 2014b)
	data  = Initialize_MAGEMin(db, verbose=false);
	global iteration_number = 1
	Xoxides = ["SiO2", "Al2O3", "CaO", "MgO", "FeO", "K2O", "Na2O", "TiO2", "O", "Cr2O3", "H2O"]
	global label = "test"
	line_number = 1
	n_comps =397
	n_oxides = length(Xoxides) #please don't try to set a job which has initial compositions defined with different numbers of oxides, it'll damage the output file, it should simply be enough to add zeroes for the other oxides in whatever database you are using instead.
	stored_data_groups = ["Technical", "System", "liq", "Bulk solid", "ol", "ol", "pl4T", "pl4T", "opx", "opx", "cpx", "cpx", "g", "g", "spn", "spn", "bi", "bi", "cd", "cd",  "ep", "ep", "hb", "hb", "ilm", "ilm", "mu", "mu", "fl", "fl", "q", "crst", "trd", "coe", "stv", "ky", "sill", "and", "ru", "sph", "fper"] #This is a list of names of groups of data in the order they will appear in the file
	stored_data_groups_n = [1, 3, 13, 13, 17, 17, 16, 16, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13] #This is a corresponding list which stores the number of fields associated with each individual group
	stored_data_groups_specialness = [0, 0, 0, 0, 4, 4, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] #This is an additional list which holds the number of additional fields (beyond the 13 for standard phases) for each group, ignoring groups which aren't relevant to the phase information writing part of the rearranger 
	println(length(stored_data_groups))
	println(length(stored_data_groups_n))
	println(length(stored_data_groups_specialness))
	iteration_number = 1
end

# ╔═╡ 83a49480-9aac-4737-b21e-632be7346018
function run_testing_block() #testing block
n    = 1000
P    = rand(8.0:40,n);
T    = rand(800.0:2000.0, n);
test = 0  #KLB1
return multi_point_minimization(P,T, data, test=test);
end

# ╔═╡ 6a48ab70-3966-47f8-afd4-34e6cb4962cd
function run_first_step(label)
	
	#This function should find the experiment folder, find its initial compositions and then run the first step
	
	
	cd(joinpath(@__DIR__, "Experiments", label))#find the experiment folder
	initial_comps = CSV.read(string(label, "_initial_comps.csv"), delim=',', DataFrame) #Read in the initial composition file
	PT_conditions = CSV.read(string(label, "_PT.csv"), DataFrame) #read in the PT conditions file
	defined_oxides = intersect(names(initial_comps),Xoxides) #Find which oxides relevant to MAGEMin are defined in the experiment composition files
	X = zeros(nrow(initial_comps), n_oxides)
	
	for i in 1:length(defined_oxides) #for each defined oxide
			target_column = findfirst(item -> item == defined_oxides[i], Xoxides) #find the target column number (where the column is going to be put)
			X[:,target_column] = initial_comps[:,string(defined_oxides[i])] #Find the column in the inital compositions dataframe with its name and put it in the right place
	end
	P = fill(PT_conditions[1, "Pressure"], nrow(initial_comps))
	T = fill(Float64(PT_conditions[1, "Temperature"]), nrow(initial_comps))
	X = [X[i,:] for i in 1:size(X,1)]
	sys_in="mol" #this will eventually become variable based on user input
	output = multi_point_minimization(P, T, data, X=X, Xoxides=Xoxides, sys_in=sys_in)
	
	return output
end

# ╔═╡ f8f6ff3d-008d-4713-9b6e-5084999a3cee
#output = multi_point_minimization(P, T, data, X=X, Xoxides=Xoxides, sys_in=sys_in)

# ╔═╡ 4ebbc04e-db10-4eac-86c3-1787fa26774d
#=begin
	out = run_next_step("test", 2)
	rearranger(out)
end=#

# ╔═╡ a3baa877-0da2-4a9e-bcb7-445bbb8bf2bf
#=begin
	X1      = [48.43; 15.19; 11.57; 10.13; 6.65; 1.64; 0.59; 1.87; 0.68; 0.0; 3.0];
	X2      = [49.43; 14.19; 11.57; 10.13; 6.65; 1.64; 0.59; 1.87; 0.68; 0.0; 3.0];
	X       = [X1,X2];
	typeof(X)
end
=#

# ╔═╡ 46fe46ed-8c2a-457d-b8a9-56175aac2926
run_first_step("test")

# ╔═╡ de7b506f-c88a-4ebd-a6f8-d05816cbeac8
println(iteration_number)

# ╔═╡ 7f44d751-b4ca-4318-9271-bf08d78c4d9a
#dump(out)

# ╔═╡ 72f7f977-9a49-4bf9-8cc7-9fbb94a20225
#out[1].ph

# ╔═╡ 5a2f3b14-ebeb-4bc0-9581-8154cc2585f9


# ╔═╡ 30fd7ab3-0029-45fa-9628-84a7e6c91521
#sys_in = "wt"

# ╔═╡ b63808b3-2def-4f2c-8863-7e640d91c4d9
#out = run_testing_block()

# ╔═╡ 43e4e469-8775-45c5-a804-3b54df3e1545
Finalize_MAGEMin(data)

# ╔═╡ 72f7679b-47e9-4bb2-9e10-d67bae2a0cd5
function find_starting_value(group, phase_list = ["nope", "not real"], position_in_list=999) #This takes the name of a group of data (in my usage these are mostly minerals) and returns the column of the first field in the output file for that group (typically that phase's phase fraction)
	
	#first check if the group in question is technical, rather than a phase
	
	if position_in_list == 999 #this is true if the function is called without providing a position in the list of phases (i.e if the group is technical)
		field_number = 0 
		for i in 1:(findfirst(item -> item == group, stored_data_groups)-1)
			field_number = field_number + stored_data_groups_n[i]
		end
		field_number +=1
	
		#if it is not technical, check whether there is only one instance of it in the phase list
	
	elseif findfirst(item -> item == group, phase_list) == findlast(item -> item == group, phase_list) #if the first and last instance of the specific group are the same, then only one instance of that phase is present, and everything can procede normally
		field_number = 0 
		for i in 1:(findfirst(item -> item == group, stored_data_groups)-1)
			field_number = field_number + stored_data_groups_n[i]
		end
		field_number +=1

		#If it isn't technical, and also occurs more than once in the phase list
		
	else 
		if findfirst(item -> item == group, phase_list) == position_in_list #if it's the first instance of the two, procede as normal
			field_number = 0 
			for i in 1:(findfirst(item -> item == group, stored_data_groups)-1)
				field_number = field_number + stored_data_groups_n[i]
			end
			field_number +=1
		else #if it's the second, find the last instance of it in the list of stored data groups, rather than the first
			field_number = 0 
			for i in 1:(findlast(item -> item == group, stored_data_groups)-1)
				field_number = field_number + stored_data_groups_n[i]
			end
			field_number +=1
		end
	end

	
	return convert(Int, field_number)
end

# ╔═╡ 80cd3328-f5dc-4487-b5d6-576b12565f84
#=begin
	group = "Not"
specialness = stored_data_groups_specialness[findfirst(item -> item == group, stored_data_groups)] #Identify the number of special values it needs
end=#

# ╔═╡ 1377c2d9-2600-4727-80f6-ca30dfd4b75e
#=for i in 1:length(out)
	println(out[i].ph)
end=#

# ╔═╡ 03560d76-b895-43b9-9632-1fd461a131fd
function inst_file_namer(iteration_number, label)
	file_number = "0" ^ (5-ndigits(iteration_number))
	file_name= string(label, "_inst_", file_number, iteration_number, ".csv")
	return file_name
end

# ╔═╡ a58e22e2-dec7-40da-b598-0f9c4f45e707
function run_next_step(label, step_number)
	#This function should find the experiment folder, find its initial compositions and then run the first step

	cd(joinpath(@__DIR__, "Experiments", label, "Instantaneous"))#find the experiment's instantaneous folder
	input_file = inst_file_namer(step_number-1, label) #find name of the last output file to be taken as input
	comps = CSV.read(input_file, delim=',', DataFrame, header=false) #Read in the initial composition file
	cd(joinpath(@__DIR__, "Experiments", label)) #go back out to the experiment folder
	PT_conditions = CSV.read(string(label, "_PT.csv"), DataFrame) #read in the PT conditions file
	
	X = zeros(nrow(comps), n_oxides) #initialise the composition array
	
	for i in 1:n_comps #for each composition
		if comps[i, find_starting_value("liq")] > 0.001 #if there is any liquid left
			for j in 1:n_oxides
				X[i,j] = comps[i, (find_starting_value("liq") + (stored_data_groups_n[findfirst(item -> item == "liq", stored_data_groups)]) -n_oxides -1 + j)] 
			end
		else
			for j in 1:n_oxides
				X[i,j] = comps[i, (find_starting_value("Bulk solid") + (stored_data_groups_n[findfirst(item -> item == "Bulk solid", stored_data_groups)]) -n_oxides -1 + j)] 
			end

		end
	end
	P = fill(PT_conditions[iteration_number, "Pressure"], nrow(comps))
	T = fill(Float64(PT_conditions[iteration_number, "Temperature"]), nrow(comps))
	X = [X[i,:] for i in 1:size(X,1)]
	sys_in="wt" #all future steps are always wt
	output = multi_point_minimization(P, T, data, X=X, Xoxides=Xoxides, sys_in=sys_in)
	return output
end

# ╔═╡ e4e4548e-b062-41c7-893e-be1041745e42
run_next_step("test", 2)

# ╔═╡ 22e1385e-8918-4229-823f-db732bd4e251
function rearranger(out)

	#=
	This is the rearranger, it takes the out struct and produces single lines of a csv containing the data we wish to store

	Each single line represents the output of the MAGEMin of a single initial bulk composition for a single iteration 
	=#
	global line_length = 0
	for i in 1:length(stored_data_groups)
		line_length += stored_data_groups_n[i] #the number of pieces of data stored on each line
	end
	global working_line = zeros(n_comps, line_length) # initialise the working line, we will be editing this line and then storing it in a csv as a single operation (note that I don't claim this is the best way of doing this and I'm certain a better one exists, but this is understandable to me)

	#spaghetti incoming

	for line_number in 1:n_comps

		position_in_SS = 1 #Initialisations for the working positions of the SS and PP
		position_in_PP = 1 #vectors, used to handle the fact that they may not be presented in order in the phase name field

		#techincal information

	
		working_line[line_number, 1] = iteration_number

		#system information

		field = find_starting_value("System") #Using the function here is I imagine techinically a performance hit, but improves generality by allowing reordering/addition of groups
		working_line[line_number, field] = out[line_number].P_kbar
		working_line[line_number, field+1] = out[line_number].T_C
		working_line[line_number, field+3] = out[line_number].fO2
		
		#bulk solid information

		if out[line_number].ph != ["liq"] && out[line_number].ph != ["liq", "fl"] && out[line_number].ph != ["fl", "liq"] && out[line_number].ph != ["fl"]
			#Check that there exists a stable non-liquid phase, otherwise the bulk solid fields become NaN
		
			field = find_starting_value("Bulk solid")
			working_line[line_number, field] = out[line_number].frac_S_wt
			working_line[line_number, field+1] = out[line_number].rho_S
			for i in 1:n_oxides
				working_line[line_number, field+i+1] = out[line_number].bulk_S_wt[i] #melt composition in oxide wt%, using whatever oxide system was defined
			end

		end
	
		#Phase information
		#Store the normal phase data
		for i in 1:length(out[line_number].ph) 
			group = out[line_number].ph[i] #Identify the phase
			specialness = stored_data_groups_specialness[findfirst(item -> item == group, stored_data_groups)] #Identify the number of special values it needs
			field = find_starting_value(group, out[line_number].ph, i)
			working_line[line_number, field+specialness] = out[line_number].ph_frac_wt[i] #storage common to PP and SS

			#=if out[line_number].ph_type[i] == 0 #detect if the phase being stored is pure
				if specialness != 0
				#No pure phases are currently special
				end
				position_in_PP += 1 #and then increment position in the PP vector
			end=#

			if out[line_number].ph_type[i] == 0 #detect if the phase being stored is pure
				#and then store its relevant data
				working_line[line_number, field+specialness+1] = out[line_number].PP_vec[position_in_PP].rho

				for j in 1:n_oxides 
					working_line[line_number, field+specialness+j+1] = out[line_number].PP_vec[position_in_PP].Comp_wt[j]
				end

				if specialness !=0
					#No pure phases are currently special
				end
				position_in_PP = position_in_PP +1 #and then increment position in the PP vector
			end

			if out[line_number].ph_type[i] == 1 #detect if the phase being stored is a solid solution
				#and then store its relevant data
				working_line[line_number, field+specialness+1] = out[line_number].SS_vec[position_in_SS].rho

				for j in 1:n_oxides 
					working_line[line_number, field+specialness+j+1] = out[line_number].SS_vec[position_in_SS].Comp_wt[j]
				end

				if specialness !=0
					#special cases
					if group == "ol" || group == "pl4T" #SS phases of whom the end member fractions are stored
						for j in 1:length(out[line_number].SS_vec[position_in_SS].emNames)
						working_line[line_number, field+j-1] = out[line_number].SS_vec[position_in_SS].emFrac[j]
						end
					end
				end
			position_in_SS = position_in_SS +1 #and then increment position in the SS vector
			end
		end
	end
	

	
	#=for debugging
	println(working_line)
	println(position_in_SS)
	for i in 1:line_length
		println(working_line[i], "   ", i)
	end
	=#
	file_name = inst_file_namer(iteration_number, label) #generate file name
	mkpath(joinpath(@__DIR__, "Experiments", label, "Instantaneous")) #Make the instantaneous folder if it doesn't exist
	cd(joinpath(@__DIR__, "Experiments", label, "Instantaneous")) #go to instantaneous folder
	CSV.write(file_name, Tables.table(working_line), writeheader=false) #write output
end

# ╔═╡ 28604eef-2bbd-4102-8301-cf509b5d154e
#CSV.write(inst_file_namer(iteration_number, label), Tables.table(working_line), writeheader=false)

# ╔═╡ a3275e00-21a6-480e-8fb6-3086aeee5cc8
#= Idealised but hopefully eventually working actual executable

Ask for experiment label
Ask for experiment notes
Run initialiser (first step)
While in 1:number of steps (length of the PT conditions file)
	Run one step of fractionaliser
	Run rearranger
Run accumulator

=#

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
MAGEMin_C = "e5d170eb-415a-4524-987b-12f1bce1ddab"
Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[compat]
CSV = "~0.10.11"
DataFrames = "~1.6.1"
MAGEMin_C = "~1.3.5"
Tables = "~1.11.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "eabd028095272889dada75db5454497bde8b909f"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "44dbf560808d49041989b8a96cae4cffbeb7966a"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.11"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "02aa26a4cf76381be7f66e020a3eddeb27b0a092"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.2"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "04c738083f29f86e62c8afc341f0967d8717bdb8"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.6.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "9f00e42f8d99fdde64d40c8ea5d14269a2e2c1aa"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.21"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MAGEMin_C]]
deps = ["CEnum", "Libdl", "MAGEMin_jll", "ProgressMeter", "Test"]
git-tree-sha1 = "e70844c111bac0a4b49f6238a37ba92d0a6a14a8"
uuid = "e5d170eb-415a-4524-987b-12f1bce1ddab"
version = "1.3.5"

[[deps.MAGEMin_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "MPICH_jll", "MPIPreferences", "MPItrampoline_jll", "MicrosoftMPI_jll", "NLopt_jll", "OpenBLAS32_jll", "OpenMPI_jll", "TOML"]
git-tree-sha1 = "88717a671b2396beda559b4d24d52db3b2e0af61"
uuid = "763ebaa8-b0d2-5f6b-90ef-4fc23b5db1c4"
version = "1.3.5+0"

[[deps.MPICH_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "MPIPreferences", "TOML"]
git-tree-sha1 = "8a5b4d2220377d1ece13f49438d71ad20cf1ba83"
uuid = "7cb0a576-ebde-5e09-9194-50597f1243b4"
version = "4.1.2+0"

[[deps.MPIPreferences]]
deps = ["Libdl", "Preferences"]
git-tree-sha1 = "781916a2ebf2841467cda03b6f1af43e23839d85"
uuid = "3da0fdf6-3ccc-4f1b-acd9-58baa6c99267"
version = "0.1.9"

[[deps.MPItrampoline_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "MPIPreferences", "TOML"]
git-tree-sha1 = "6979eccb6a9edbbb62681e158443e79ecc0d056a"
uuid = "f1f71cc9-e9ae-5b93-9b94-4fe0e1ad3748"
version = "5.3.1+0"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.MicrosoftMPI_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "a7023883872e52bc29bcaac74f19adf39347d2d5"
uuid = "9237b28f-5490-5468-be7b-bb81f5f5e6cf"
version = "10.1.4+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NLopt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9b1f15a08f9d00cdb2761dcfa6f453f5d0d6f973"
uuid = "079eb43e-fd8e-5478-9966-2cf3e3edb778"
version = "2.7.1+0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS32_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "2fb9ee2dc14d555a6df2a714b86b7125178344c2"
uuid = "656ef2d0-ae68-5445-9ca0-591084a874a2"
version = "0.3.21+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenMPI_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "MPIPreferences", "TOML"]
git-tree-sha1 = "e25c1778a98e34219a00455d6e4384e017ea9762"
uuid = "fe0851c0-eecd-5654-98d4-656369965a5c"
version = "4.1.6+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "ee094908d720185ddbdc58dbe0c1cbe35453ec7a"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.7"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "00099623ffee15972c16111bcf84c58a0051257c"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.9.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "04bdff0b09c65ff3e06a05e3eb7b120223da3d39"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "a1f34829d5ac0ef499f6d84428bd6b4c71f02ead"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═de8306e5-46b3-4c74-9442-0c327a78587f
# ╠═54597683-6ca7-4522-8964-da8bf772367c
# ╠═aa3fa333-efd7-4221-a9ad-19accfebb4b8
# ╠═5971b407-cf50-440a-89ae-97b4c32c4c69
# ╠═b5f92c91-b32d-41a4-b6b5-2031f80ed631
# ╠═83a49480-9aac-4737-b21e-632be7346018
# ╠═6a48ab70-3966-47f8-afd4-34e6cb4962cd
# ╠═a58e22e2-dec7-40da-b598-0f9c4f45e707
# ╠═f8ca3cce-b16a-4737-8e8f-043b723d3dda
# ╠═f8f6ff3d-008d-4713-9b6e-5084999a3cee
# ╠═4ebbc04e-db10-4eac-86c3-1787fa26774d
# ╠═a3baa877-0da2-4a9e-bcb7-445bbb8bf2bf
# ╠═46fe46ed-8c2a-457d-b8a9-56175aac2926
# ╠═97942588-d035-48c3-9d09-1c01df60221c
# ╠═de7b506f-c88a-4ebd-a6f8-d05816cbeac8
# ╠═e4e4548e-b062-41c7-893e-be1041745e42
# ╠═35c2f67b-4193-48de-b686-4abd4aa0744d
# ╠═7f44d751-b4ca-4318-9271-bf08d78c4d9a
# ╠═72f7f977-9a49-4bf9-8cc7-9fbb94a20225
# ╠═5a2f3b14-ebeb-4bc0-9581-8154cc2585f9
# ╠═30fd7ab3-0029-45fa-9628-84a7e6c91521
# ╠═b63808b3-2def-4f2c-8863-7e640d91c4d9
# ╠═43e4e469-8775-45c5-a804-3b54df3e1545
# ╠═72f7679b-47e9-4bb2-9e10-d67bae2a0cd5
# ╠═80cd3328-f5dc-4487-b5d6-576b12565f84
# ╠═1377c2d9-2600-4727-80f6-ca30dfd4b75e
# ╠═22e1385e-8918-4229-823f-db732bd4e251
# ╠═03560d76-b895-43b9-9632-1fd461a131fd
# ╠═28604eef-2bbd-4102-8301-cf509b5d154e
# ╠═a3275e00-21a6-480e-8fb6-3086aeee5cc8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
