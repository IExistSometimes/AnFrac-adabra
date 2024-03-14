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

# ╔═╡ d97ce021-1fe1-496d-b9b7-2f72d7756e65


# ╔═╡ 47980d08-466d-40a6-8c91-9afdf25d994e
begin
	#Defining things non-dynamically
	db   = "ig"  # database: ig, igneous (Holland et al., 2018); mp, metapelite (White et al 2014b)
	data  = Initialize_MAGEMin(db, verbose=false);
	Xoxides = ["SiO2", "Al2O3", "CaO", "MgO", "FeO", "K2O", "Na2O", "TiO2", "Fe2O3", "Cr2O3", "H2O"]
	println("Experiment label: ") #Get a title for the experiment
	global label = "water_content"

	println("Experiment notes/description: ") #Offer oppotunity to write notes or a description of the experiment
	notes = "This is a recreation of all of Neave's experiments at a range of water contents 0.1,0.2 wt% to 1 to see if any of these more closely match his observations as water content might depress the plagioclase liquidus and make results nearer to his, particularly as he didn't seem particularly confident of the water content in his experiments"
	
	cd(joinpath(@__DIR__, "Experiments", label)) #go to experiments folder
	open("notes.txt", "w") do file #write the notes
    write(file, notes)
	end

	experiment_comps = CSV.read(string(label, "_initial_comps.csv"), delim=',', DataFrame)
	global n_comps = nrow(experiment_comps) #given this a different variable name to cope with scope weirdness

	println("Is the initial composition file in wt or mol?") #take initial composition system information
	initial_sys_in = "wt"

	println("Starting at what step? (1 if a fresh run starting from initial comps)")
	starting_step = 1
	
	n_oxides = length(Xoxides) #please don't try to set a job which has initial compositions defined with different numbers of oxides, it'll damage the output file, it should simply be enough to add zeroes for the other oxides in whatever database you are using instead.
	stored_data_groups = ["Technical", "System", "liq", "Bulk solid", "ol", "ol", "pl4T", "pl4T", "opx", "opx", "cpx", "cpx", "g", "g", "spn", "spn", "bi", "bi", "cd", "cd",  "ep", "ep", "hb", "hb", "ilm", "ilm", "mu", "mu", "fl", "fl", "q", "crst", "trd", "coe", "stv", "ky", "sill", "and", "ru", "sph", "fper", "wo", "pswo", "ne"] #This is a list of names of groups of data in the order they will appear in the file
	stored_data_groups_n = [1, 4, 13, 13, 17, 17, 16, 16, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13] #This is a corresponding list which stores the number of fields associated with each individual group
	stored_data_groups_specialness = [0, 0, 0, 0, 4, 4, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] #This is an additional list which holds the number of additional fields (beyond the 13 for standard phases) for each group, ignoring groups which aren't relevant to the phase information writing part of the rearranger 

	inst_header = ["Iteration_number", "Pressure_Kbar", "Temperature_C", "fO2", "Remaining_mass_frac", "Liquid_wt_frac", "Liquid_density", "Liquid_wt_SiO2", "Liquid_wt_Al2O3", "Liquid_wt_CaO", "Liquid_wt_MgO", "Liquid_wt_FeO", "Liquid_wt_K2O", "Liquid_wt_Na2O", "Liquid_wt_TiO2", "Liquid_wt_Fe2O3", "Liquid_wt_Cr2O3", "Liquid_wt_H2O", "BulkSolid_wt_frac", "BulkSolid_density", "BulkSolid_wt_SiO2", "BulkSolid_wt_Al2O3", "BulkSolid_wt_CaO", "BulkSolid_wt_MgO", "BulkSolid_wt_FeO", "BulkSolid_wt_K2O", "BulkSolid_wt_Na2O", "BulkSolid_wt_TiO2", "BulkSolid_wt_Fe2O3", "BulkSolid_wt_Cr2O3", "BulkSolid_wt_H2O", "Olivine1_wt_Monticellite", "Olivine1_wt_Fayalite", "Olivine1_wt_Forsterite", "Olivine1_wt_cfm", "Olivine1_wt_frac", "Olivine1_density", "Olivine1_wt_SiO2", "Olivine1_wt_Al2O3", "Olivine1_wt_CaO", "Olivine1_wt_MgO", "Olivine1_wt_FeO", "Olivine1_wt_K2O", "Olivine1_wt_Na2O", "Olivine1_wt_TiO2", "Olivine1_wt_Fe2O3", "Olivine1_wt_Cr2O3", "Olivine1_wt_H2O", "Olivine2_wt_Monticellite", "Olivine2_wt_Fayalite", "Olivine2_wt_Forsterite", "Olivine2_wt_CFM", "Olivine2_wt_frac", "Olivine2_density", "Olivine2_wt_SiO2", "Olivine2_wt_Al2O3", "Olivine2_wt_CaO", "Olivine2_wt_MgO", "Olivine2_wt_FeO", "Olivine2_wt_K2O", "Olivine2_wt_Na2O", "Olivine2_wt_TiO2", "Olivine2_wt_Fe2O3", "Olivine2_wt_Cr2O3", "Olivine2_wt_H2O", "Plagioclase1_wt_Albite", "Plagioclase1_wt_Anorthite", "Plagioclase1_wt_Sanidine", "Plagioclase1_wt_frac", "Plagioclase1_density", "Plagioclase1_wt_SiO2", "Plagioclase1_wt_Al2O3", "Plagioclase1_wt_CaO", "Plagioclase1_wt_MgO", "Plagioclase1_wt_FeO", "Plagioclase1_wt_K2O", "Plagioclase1_wt_Na2O", "Plagioclase1_wt_TiO2", "Plagioclase1_wt_Fe2O3", "Plagioclase1_wt_Cr2O3", "Plagioclase1_wt_H20", "Plagioclase2_wt_Albite", "Plagioclase2_wt_Anorthite", "Plagioclase2_wt_Sanidine", "Plagioclase2_wt_frac", "Plagioclase2_density", "Plagioclase2_wt_SiO2", "Plagioclase2_wt_Al2O3", "Plagioclase2_wt_CaO", "Plagioclase2_wt_MgO", "Plagioclase2_wt_FeO", "Plagioclase2_wt_K2O", "Plagioclase2_wt_Na2O", "Plagioclase2_wt_TiO2", "Plagioclase2_wt_Fe2O3", "Plagioclase2_wt_Cr2O3", "Plagioclase2_wt_H20", "Orthopyroxene1_wt_frac", "Orthopyroxene1_density", "Orthopyroxene1_wt_SiO2", "Orthopyroxene1_wt_Al2O3", "Orthopyroxene1_wt_CaO", "Orthopyroxene1_wt_MgO", "Orthopyroxene1_wt_FeO", "Orthopyroxene1_wt_K2O", "Orthopyroxene1_wt_Na2O", "Orthopyroxene1_wt_TiO2", "Orthopyroxene1_wt_Fe2O3", "Orthopyroxene1_wt_Cr2O3", "Orthopyroxene1_wt_H2O", "Orthopyroxene2_wt_frac", "Orthopyroxene2_density", "Orthopyroxene2_wt_SiO2", "Orthopyroxene2_wt_Al2O3", "Orthopyroxene2_wt_CaO", "Orthopyroxene2_wt_MgO", "Orthopyroxene2_wt_FeO", "Orthopyroxene2_wt_K2O", "Orthopyroxene2_wt_Na2O", "Orthopyroxene2_wt_TiO2", "Orthopyroxene2_wt_Fe2O3", "Orthopyroxene2_wt_Cr2O3", "Orthopyroxene2_wt_H2O","Clinopyroxene1_wt_frac", "Clinopyroxene1_density", "Clinopyroxene1_wt_SiO2", "Clinopyroxene1_wt_Al2O3", "Clinopyroxene1_wt_CaO", "Clinopyroxene1_wt_MgO", "Clinopyroxene1_wt_FeO", "Clinopyroxene1_wt_K2O", "Clinopyroxene1_wt_Na2O", "Clinopyroxene1_wt_TiO2", "Clinopyroxene1_wt_Fe2O3", "Clinopyroxene1_wt_Cr2O3", "Clinopyroxene1_wt_H2O", "Clinopyroxene2_wt_frac", "Clinopyroxene2_density", "Clinopyroxene2_wt_SiO2", "Clinopyroxene2_wt_Al2O3", "Clinopyroxene2_wt_CaO", "Clinopyroxene2_wt_MgO", "Clinopyroxene2_wt_FeO", "Clinopyroxene2_wt_K2O", "Clinopyroxene2_wt_Na2O", "Clinopyroxene2_wt_TiO2", "Clinopyroxene2_wt_Fe2O3", "Clinopyroxene2_wt_Cr2O3", "Clinopyroxene2_wt_H2O",  "Garnet1_wt_frac", "Garnet1_density", "Garnet1_wt_SiO2", "Garnet1_wt_Al2O3", "Garnet1_wt_CaO", "Garnet1_wt_MgO", "Garnet1_wt_FeO", "Garnet1_wt_K2O", "Garnet1_wt_Na2O", "Garnet1_wt_TiO2", "Garnet1_wt_Fe2O3", "Garnet1_wt_Cr2O3", "Garnet1_wt_H2O", "Garnet2_wt_frac", "Garnet2_density", "Garnet2_wt_SiO2", "Garnet2_wt_Al2O3", "Garnet2_wt_CaO", "Garnet2_wt_MgO", "Garnet2_wt_FeO", "Garnet2_wt_K2O", "Garnet2_wt_Na2O", "Garnet2_wt_TiO2", "Garnet2_wt_Fe2O3", "Garnet2_wt_Cr2O3", "Garnet2_wt_H2O", "Spinel1_wt_frac", "Spinel1_density", "Spinel1_wt_SiO2", "Spinel1_wt_Al2O3", "Spinel1_wt_CaO", "Spinel1_wt_MgO", "Spinel1_wt_FeO", "Spinel1_wt_K2O", "Spinel1_wt_Na2O", "Spinel1_wt_TiO2", "Spinel1_wt_Fe2O3", "Spinel1_wt_Cr2O3", "Spinel1_wt_H2O", "Spinel2_wt_frac", "Spinel2_density", "Spinel2_wt_SiO2", "Spinel2_wt_Al2O3", "Spinel2_wt_CaO", "Spinel2_wt_MgO", "Spinel2_wt_FeO", "Spinel2_wt_K2O", "Spinel2_wt_Na2O", "Spinel2_wt_TiO2", "Spinel2_wt_Fe2O3", "Spinel2_wt_Cr2O3", "Spinel2_wt_H2O", "Biotite1_wt_frac", "Biotite1_density", "Biotite1_wt_SiO2", "Biotite1_wt_Al2O3", "Biotite1_wt_CaO", "Biotite1_wt_MgO", "Biotite1_wt_FeO", "Biotite1_wt_K2O", "Biotite1_wt_Na2O", "Biotite1_wt_TiO2", "Biotite1_wt_Fe2O3", "Biotite1_wt_Cr2O3", "Biotite1_wt_H2O", "Biotite2_wt_frac", "Biotite2_density", "Biotite2_wt_SiO2", "Biotite2_wt_Al2O3", "Biotite2_wt_CaO", "Biotite2_wt_MgO", "Biotite2_wt_FeO", "Biotite2_wt_K2O", "Biotite2_wt_Na2O", "Biotite2_wt_TiO2", "Biotite2_wt_Fe2O3", "Biotite2_wt_Cr2O3", "Biotite2_wt_H2O", "Cordierite1_wt_frac", "Cordierite1_density", "Cordierite1_wt_SiO2", "Cordierite1_wt_Al2O3", "Cordierite1_wt_CaO", "Cordierite1_wt_MgO", "Cordierite1_wt_FeO", "Cordierite1_wt_K2O", "Cordierite1_wt_Na2O", "Cordierite1_wt_TiO2", "Cordierite1_wt_Fe2O3", "Cordierite1_wt_Cr2O3", "Cordierite1_wt_H2O", "Cordierite2_wt_frac", "Cordierite2_density", "Cordierite2_wt_SiO2", "Cordierite2_wt_Al2O3", "Cordierite2_wt_CaO", "Cordierite2_wt_MgO", "Cordierite2_wt_FeO", "Cordierite2_wt_K2O", "Cordierite2_wt_Na2O", "Cordierite2_wt_TiO2", "Cordierite2_wt_Fe2O3", "Cordierite2_wt_Cr2O3", "Cordierite2_wt_H2O", "Epidote1_wt_frac", "Epidote1_density", "Epidote1_wt_SiO2", "Epidote1_wt_Al2O3", "Epidote1_wt_CaO", "Epidote1_wt_MgO", "Epidote1_wt_FeO", "Epidote1_wt_K2O", "Epidote1_wt_Na2O", "Epidote1_wt_TiO2", "Epidote1_wt_Fe2O3", "Epidote1_wt_Cr2O3", "Epidote1_wt_H2O", "Epidote2_wt_frac", "Epidote2_density", "Epidote2_wt_SiO2", "Epidote2_wt_Al2O3", "Epidote2_wt_CaO", "Epidote2_wt_MgO", "Epidote2_wt_FeO", "Epidote2_wt_K2O", "Epidote2_wt_Na2O", "Epidote2_wt_TiO2", "Epidote2_wt_Fe2O3", "Epidote2_wt_Cr2O3", "Epidote2_wt_H2O", "Hornblende1_wt_frac", "Hornblende1_density", "Hornblende1_wt_SiO2", "Hornblende1_wt_Al2O3", "Hornblende1_wt_CaO", "Hornblende1_wt_MgO", "Hornblende1_wt_FeO", "Hornblende1_wt_K2O", "Hornblende1_wt_Na2O", "Hornblende1_wt_TiO2", "Hornblende1_wt_Fe2O3", "Hornblende1_wt_Cr2O3", "Hornblende1_wt_H2O", "Hornblende2_wt_frac", "Hornblende2_density", "Hornblende2_wt_SiO2", "Hornblende2_wt_Al2O3", "Hornblende2_wt_CaO", "Hornblende2_wt_MgO", "Hornblende2_wt_FeO", "Hornblende2_wt_K2O", "Hornblende2_wt_Na2O", "Hornblende2_wt_TiO2", "Hornblende2_wt_Fe2O3", "Hornblende2_wt_Cr2O3", "Hornblende2_wt_H2O", "Ilmenite1_wt_frac", "Ilmenite1_density", "Ilmenite1_wt_SiO2", "Ilmenite1_wt_Al2O3", "Ilmenite1_wt_CaO", "Ilmenite1_wt_MgO", "Ilmenite1_wt_FeO", "Ilmenite1_wt_K2O", "Ilmenite1_wt_Na2O", "Ilmenite1_wt_TiO2", "Ilmenite1_wt_Fe2O3", "Ilmenite1_wt_Cr2O3", "Ilmenite1_wt_H2O",  "Ilmenite2_wt_frac", "Ilmenite2_density", "Ilmenite2_wt_SiO2", "Ilmenite2_wt_Al2O3", "Ilmenite2_wt_CaO", "Ilmenite2_wt_MgO", "Ilmenite2_wt_FeO", "Ilmenite2_wt_K2O", "Ilmenite2_wt_Na2O", "Ilmenite2_wt_TiO2", "Ilmenite2_wt_Fe2O3", "Ilmenite2_wt_Cr2O3", "Ilmenite2_wt_H2O", "Muscovite1_wt_frac", "Muscovite1_density", "Muscovite1_wt_SiO2", "Muscovite1_wt_Al2O3", "Muscovite1_wt_CaO", "Muscovite1_wt_MgO", "Muscovite1_wt_FeO", "Muscovite1_wt_K2O", "Muscovite1_wt_Na2O", "Muscovite1_wt_TiO2", "Muscovite1_wt_Fe2O3", "Muscovite1_wt_Cr2O3", "Muscovite1_wt_H2O",  "Muscovite2_wt_frac", "Muscovite2_density", "Muscovite2_wt_SiO2", "Muscovite2_wt_Al2O3", "Muscovite2_wt_CaO", "Muscovite2_wt_MgO", "Muscovite2_wt_FeO", "Muscovite2_wt_K2O", "Muscovite2_wt_Na2O", "Muscovite2_wt_TiO2", "Muscovite2_wt_Fe2O3", "Muscovite2_wt_Cr2O3", "Muscovite2_wt_H2O", "Fluid1_wt_frac", "Fluid1_density", "Fluid1_wt_SiO2", "Fluid1_wt_Al2O3", "Fluid1_wt_CaO", "Fluid1_wt_MgO", "Fluid1_wt_FeO", "Fluid1_wt_K2O", "Fluid1_wt_Na2O", "Fluid1_wt_TiO2", "Fluid1_wt_Fe2O3", "Fluid1_wt_Cr2O3", "Fluid1_wt_H2O", "Fluid2_wt_frac", "Fluid2_density", "Fluid2_wt_SiO2", "Fluid2_wt_Al2O3", "Fluid2_wt_CaO", "Fluid2_wt_MgO", "Fluid2_wt_FeO", "Fluid2_wt_K2O", "Fluid2_wt_Na2O", "Fluid2_wt_TiO2", "Fluid2_wt_Fe2O3", "Fluid2_wt_Cr2O3", "Fluid2_wt_H2O", "Quartz_wt_frac", "Quartz_density", "Quartz_wt_SiO2", "Quartz_wt_Al2O3", "Quartz_wt_CaO", "Quartz_wt_MgO", "Quartz_wt_FeO", "Quartz_wt_K2O", "Quartz_wt_Na2O", "Quartz_wt_TiO2", "Quartz_wt_Fe2O3", "Quartz_wt_Cr2O3", "Quartz_wt_H2O", "Cristobalite_wt_frac", "Cristobalite_density", "Cristobalite_wt_SiO2", "Cristobalite_wt_Al2O3", "Cristobalite_wt_CaO", "Cristobalite_wt_MgO", "Cristobalite_wt_FeO", "Cristobalite_wt_K2O", "Cristobalite_wt_Na2O", "Cristobalite_wt_TiO2", "Cristobalite_wt_Fe2O3", "Cristobalite_wt_Cr2O3", "Cristobalite_wt_H2O",  "Tridymite_wt_frac", "Tridymite_density", "Tridymite_wt_SiO2", "Tridymite_wt_Al2O3", "Tridymite_wt_CaO", "Tridymite_wt_MgO", "Tridymite_wt_FeO", "Tridymite_wt_K2O", "Tridymite_wt_Na2O", "Tridymite_wt_TiO2", "Tridymite_wt_Fe2O3", "Tridymite_wt_Cr2O3", "Tridymite_wt_H2O", "Coesite_wt_frac", "Coesite_density", "Coesite_wt_SiO2", "Coesite_wt_Al2O3", "Coesite_wt_CaO", "Coesite_wt_MgO", "Coesite_wt_FeO", "Coesite_wt_K2O", "Coesite_wt_Na2O", "Coesite_wt_TiO2", "Coesite_wt_Fe2O3", "Coesite_wt_Cr2O3", "Coesite_wt_H2O", "Stishovite_wt_frac", "Stishovite_density", "Stishovite_wt_SiO2", "Stishovite_wt_Al2O3", "Stishovite_wt_CaO", "Stishovite_wt_MgO", "Stishovite_wt_FeO", "Stishovite_wt_K2O", "Stishovite_wt_Na2O", "Stishovite_wt_TiO2", "Stishovite_wt_Fe2O3", "Stishovite_wt_Cr2O3", "Stishovite_wt_H2O",  "Kyanite_wt_frac", "Kyanite_density", "Kyanite_wt_SiO2", "Kyanite_wt_Al2O3", "Kyanite_wt_CaO", "Kyanite_wt_MgO", "Kyanite_wt_FeO", "Kyanite_wt_K2O", "Kyanite_wt_Na2O", "Kyanite_wt_TiO2", "Kyanite_wt_Fe2O3", "Kyanite_wt_Cr2O3", "Kyanite_wt_H2O", "Sillimanite_wt_frac", "Sillimanite_density", "Sillimanite_wt_SiO2", "Sillimanite_wt_Al2O3", "Sillimanite_wt_CaO", "Sillimanite_wt_MgO", "Sillimanite_wt_FeO", "Sillimanite_wt_K2O", "Sillimanite_wt_Na2O", "Sillimanite_wt_TiO2", "Sillimanite_wt_Fe2O3", "Sillimanite_wt_Cr2O3", "Sillimanite_wt_H2O", "Andalusite_wt_frac", "Andalusite_density", "Andalusite_wt_SiO2", "Andalusite_wt_Al2O3", "Andalusite_wt_CaO", "Andalusite_wt_MgO", "Andalusite_wt_FeO", "Andalusite_wt_K2O", "Andalusite_wt_Na2O", "Andalusite_wt_TiO2", "Andalusite_wt_Fe2O3", "Andalusite_wt_Cr2O3", "Andalusite_wt_H2O", "Rutile_wt_frac", "Rutile_density", "Rutile_wt_SiO2", "Rutile_wt_Al2O3", "Rutile_wt_CaO", "Rutile_wt_MgO", "Rutile_wt_FeO", "Rutile_wt_K2O", "Rutile_wt_Na2O", "Rutile_wt_TiO2", "Rutile_wt_Fe2O3", "Rutile_wt_Cr2O3", "Rutile_wt_H2O", "Sphene_wt_frac", "Sphene_density", "Sphene_wt_SiO2", "Sphene_wt_Al2O3", "Sphene_wt_CaO", "Sphene_wt_MgO", "Sphene_wt_FeO", "Sphene_wt_K2O", "Sphene_wt_Na2O", "Sphene_wt_TiO2", "Sphene_wt_Fe2O3", "Sphene_wt_Cr2O3", "Sphene_wt_H2O", "Ferropericlase_wt_frac", "Ferropericlase_density", "Ferropericlase_wt_SiO2", "Ferropericlase_wt_Al2O3", "Ferropericlase_wt_CaO", "Ferropericlase_wt_MgO", "Ferropericlase_wt_FeO", "Ferropericlase_wt_K2O", "Ferropericlase_wt_Na2O", "Ferropericlase_wt_TiO2", "Ferropericlase_wt_Fe2O3", "Ferropericlase_wt_Cr2O3", "Ferropericlase_wt_H2O", "Wollastonite_wt_frac", "Wollastonite_density", "Wollastonite_wt_SiO2", "Wollastonite_wt_Al2O3", "Wollastonite_wt_CaO", "Wollastonite_wt_MgO", "Wollastonite_wt_FeO", "Wollastonite_wt_K2O", "Wollastonite_wt_Na2O", "Wollastonite_wt_TiO2", "Wollastonite_wt_Fe2O3", "Wollastonite_wt_Cr2O3", "Wollastonite_wt_H2O", "pswo_wt_frac", "pswo_density", "pswo_wt_SiO2", "pswo_wt_Al2O3", "pswo_wt_CaO", "pswo_wt_MgO", "pswo_wt_FeO", "pswo_wt_K2O", "pswo_wt_Na2O", "pswo_wt_TiO2", "pswo_wt_Fe2O3", "pswo_wt_Cr2O3", "pswo_wt_H2O", "Nepheline_wt_frac", "Nepheline_density", "Nepheline_wt_SiO2", "Nepheline_wt_Al2O3", "Nepheline_wt_CaO", "Nepheline_wt_MgO", "Nepheline_wt_FeO", "Nepheline_wt_K2O", "Nepheline_wt_Na2O", "Nepheline_wt_TiO2", "Nepheline_wt_Fe2O3", "Nepheline_wt_Cr2O3", "Nepheline_wt_H2O"]

	cum_header = ["Iteration_number", "Pressure_Kbar", "Temperature_C", "fO2", "Remaining_mass_frac", "Liquid_wt_frac", "Liquid_density", "Liquid_wt_SiO2", "Liquid_wt_Al2O3", "Liquid_wt_CaO", "Liquid_wt_MgO", "Liquid_wt_FeO", "Liquid_wt_K2O", "Liquid_wt_Na2O", "Liquid_wt_TiO2", "Liquid_wt_Fe2O3", "Liquid_wt_Cr2O3", "Liquid_wt_H2O", "BulkSolid_wt_frac", "BulkSolid_density", "BulkSolid_wt_SiO2", "BulkSolid_wt_Al2O3", "BulkSolid_wt_CaO", "BulkSolid_wt_MgO", "BulkSolid_wt_FeO", "BulkSolid_wt_K2O", "BulkSolid_wt_Na2O", "BulkSolid_wt_TiO2", "BulkSolid_wt_Fe2O3", "BulkSolid_wt_Cr2O3", "BulkSolid_wt_H2O", "Olivine1_wt_Monticellite", "Olivine1_wt_Fayalite", "Olivine1_wt_Forsterite", "Olivine1_wt_cfm", "Olivine1_wt_frac", "Olivine1_density", "Olivine1_wt_SiO2", "Olivine1_wt_Al2O3", "Olivine1_wt_CaO", "Olivine1_wt_MgO", "Olivine1_wt_FeO", "Olivine1_wt_K2O", "Olivine1_wt_Na2O", "Olivine1_wt_TiO2", "Olivine1_wt_Fe2O3", "Olivine1_wt_Cr2O3", "Olivine1_wt_H2O", "Olivine2_wt_Monticellite", "Olivine2_wt_Fayalite", "Olivine2_wt_Forsterite", "Olivine2_wt_CFM", "Olivine2_wt_frac", "Olivine2_density", "Olivine2_wt_SiO2", "Olivine2_wt_Al2O3", "Olivine2_wt_CaO", "Olivine2_wt_MgO", "Olivine2_wt_FeO", "Olivine2_wt_K2O", "Olivine2_wt_Na2O", "Olivine2_wt_TiO2", "Olivine2_wt_Fe2O3", "Olivine2_wt_Cr2O3", "Olivine2_wt_H2O", "Plagioclase1_wt_Albite", "Plagioclase1_wt_Anorthite", "Plagioclase1_wt_Sanidine", "Plagioclase1_wt_frac", "Plagioclase1_density", "Plagioclase1_wt_SiO2", "Plagioclase1_wt_Al2O3", "Plagioclase1_wt_CaO", "Plagioclase1_wt_MgO", "Plagioclase1_wt_FeO", "Plagioclase1_wt_K2O", "Plagioclase1_wt_Na2O", "Plagioclase1_wt_TiO2", "Plagioclase1_wt_Fe2O3", "Plagioclase1_wt_Cr2O3", "Plagioclase1_wt_H20", "Plagioclase2_wt_Albite", "Plagioclase2_wt_Anorthite", "Plagioclase2_wt_Sanidine", "Plagioclase2_wt_frac", "Plagioclase2_density", "Plagioclase2_wt_SiO2", "Plagioclase2_wt_Al2O3", "Plagioclase2_wt_CaO", "Plagioclase2_wt_MgO", "Plagioclase2_wt_FeO", "Plagioclase2_wt_K2O", "Plagioclase2_wt_Na2O", "Plagioclase2_wt_TiO2", "Plagioclase2_wt_Fe2O3", "Plagioclase2_wt_Cr2O3", "Plagioclase2_wt_H20", "Orthopyroxene1_wt_frac", "Orthopyroxene1_density", "Orthopyroxene1_wt_SiO2", "Orthopyroxene1_wt_Al2O3", "Orthopyroxene1_wt_CaO", "Orthopyroxene1_wt_MgO", "Orthopyroxene1_wt_FeO", "Orthopyroxene1_wt_K2O", "Orthopyroxene1_wt_Na2O", "Orthopyroxene1_wt_TiO2", "Orthopyroxene1_wt_Fe2O3", "Orthopyroxene1_wt_Cr2O3", "Orthopyroxene1_wt_H2O", "Orthopyroxene2_wt_frac", "Orthopyroxene2_density", "Orthopyroxene2_wt_SiO2", "Orthopyroxene2_wt_Al2O3", "Orthopyroxene2_wt_CaO", "Orthopyroxene2_wt_MgO", "Orthopyroxene2_wt_FeO", "Orthopyroxene2_wt_K2O", "Orthopyroxene2_wt_Na2O", "Orthopyroxene2_wt_TiO2", "Orthopyroxene2_wt_Fe2O3", "Orthopyroxene2_wt_Cr2O3", "Orthopyroxene2_wt_H2O","Clinopyroxene1_wt_frac", "Clinopyroxene1_density", "Clinopyroxene1_wt_SiO2", "Clinopyroxene1_wt_Al2O3", "Clinopyroxene1_wt_CaO", "Clinopyroxene1_wt_MgO", "Clinopyroxene1_wt_FeO", "Clinopyroxene1_wt_K2O", "Clinopyroxene1_wt_Na2O", "Clinopyroxene1_wt_TiO2", "Clinopyroxene1_wt_Fe2O3", "Clinopyroxene1_wt_Cr2O3", "Clinopyroxene1_wt_H2O", "Clinopyroxene2_wt_frac", "Clinopyroxene2_density", "Clinopyroxene2_wt_SiO2", "Clinopyroxene2_wt_Al2O3", "Clinopyroxene2_wt_CaO", "Clinopyroxene2_wt_MgO", "Clinopyroxene2_wt_FeO", "Clinopyroxene2_wt_K2O", "Clinopyroxene2_wt_Na2O", "Clinopyroxene2_wt_TiO2", "Clinopyroxene2_wt_Fe2O3", "Clinopyroxene2_wt_Cr2O3", "Clinopyroxene2_wt_H2O",  "Garnet1_wt_frac", "Garnet1_density", "Garnet1_wt_SiO2", "Garnet1_wt_Al2O3", "Garnet1_wt_CaO", "Garnet1_wt_MgO", "Garnet1_wt_FeO", "Garnet1_wt_K2O", "Garnet1_wt_Na2O", "Garnet1_wt_TiO2", "Garnet1_wt_Fe2O3", "Garnet1_wt_Cr2O3", "Garnet1_wt_H2O", "Garnet2_wt_frac", "Garnet2_density", "Garnet2_wt_SiO2", "Garnet2_wt_Al2O3", "Garnet2_wt_CaO", "Garnet2_wt_MgO", "Garnet2_wt_FeO", "Garnet2_wt_K2O", "Garnet2_wt_Na2O", "Garnet2_wt_TiO2", "Garnet2_wt_Fe2O3", "Garnet2_wt_Cr2O3", "Garnet2_wt_H2O", "Spinel1_wt_frac", "Spinel1_density", "Spinel1_wt_SiO2", "Spinel1_wt_Al2O3", "Spinel1_wt_CaO", "Spinel1_wt_MgO", "Spinel1_wt_FeO", "Spinel1_wt_K2O", "Spinel1_wt_Na2O", "Spinel1_wt_TiO2", "Spinel1_wt_Fe2O3", "Spinel1_wt_Cr2O3", "Spinel1_wt_H2O", "Spinel2_wt_frac", "Spinel2_density", "Spinel2_wt_SiO2", "Spinel2_wt_Al2O3", "Spinel2_wt_CaO", "Spinel2_wt_MgO", "Spinel2_wt_FeO", "Spinel2_wt_K2O", "Spinel2_wt_Na2O", "Spinel2_wt_TiO2", "Spinel2_wt_Fe2O3", "Spinel2_wt_Cr2O3", "Spinel2_wt_H2O", "Biotite1_wt_frac", "Biotite1_density", "Biotite1_wt_SiO2", "Biotite1_wt_Al2O3", "Biotite1_wt_CaO", "Biotite1_wt_MgO", "Biotite1_wt_FeO", "Biotite1_wt_K2O", "Biotite1_wt_Na2O", "Biotite1_wt_TiO2", "Biotite1_wt_Fe2O3", "Biotite1_wt_Cr2O3", "Biotite1_wt_H2O", "Biotite2_wt_frac", "Biotite2_density", "Biotite2_wt_SiO2", "Biotite2_wt_Al2O3", "Biotite2_wt_CaO", "Biotite2_wt_MgO", "Biotite2_wt_FeO", "Biotite2_wt_K2O", "Biotite2_wt_Na2O", "Biotite2_wt_TiO2", "Biotite2_wt_Fe2O3", "Biotite2_wt_Cr2O3", "Biotite2_wt_H2O", "Cordierite1_wt_frac", "Cordierite1_density", "Cordierite1_wt_SiO2", "Cordierite1_wt_Al2O3", "Cordierite1_wt_CaO", "Cordierite1_wt_MgO", "Cordierite1_wt_FeO", "Cordierite1_wt_K2O", "Cordierite1_wt_Na2O", "Cordierite1_wt_TiO2", "Cordierite1_wt_Fe2O3", "Cordierite1_wt_Cr2O3", "Cordierite1_wt_H2O", "Cordierite2_wt_frac", "Cordierite2_density", "Cordierite2_wt_SiO2", "Cordierite2_wt_Al2O3", "Cordierite2_wt_CaO", "Cordierite2_wt_MgO", "Cordierite2_wt_FeO", "Cordierite2_wt_K2O", "Cordierite2_wt_Na2O", "Cordierite2_wt_TiO2", "Cordierite2_wt_Fe2O3", "Cordierite2_wt_Cr2O3", "Cordierite2_wt_H2O", "Epidote1_wt_frac", "Epidote1_density", "Epidote1_wt_SiO2", "Epidote1_wt_Al2O3", "Epidote1_wt_CaO", "Epidote1_wt_MgO", "Epidote1_wt_FeO", "Epidote1_wt_K2O", "Epidote1_wt_Na2O", "Epidote1_wt_TiO2", "Epidote1_wt_Fe2O3", "Epidote1_wt_Cr2O3", "Epidote1_wt_H2O", "Epidote2_wt_frac", "Epidote2_density", "Epidote2_wt_SiO2", "Epidote2_wt_Al2O3", "Epidote2_wt_CaO", "Epidote2_wt_MgO", "Epidote2_wt_FeO", "Epidote2_wt_K2O", "Epidote2_wt_Na2O", "Epidote2_wt_TiO2", "Epidote2_wt_Fe2O3", "Epidote2_wt_Cr2O3", "Epidote2_wt_H2O", "Hornblende1_wt_frac", "Hornblende1_density", "Hornblende1_wt_SiO2", "Hornblende1_wt_Al2O3", "Hornblende1_wt_CaO", "Hornblende1_wt_MgO", "Hornblende1_wt_FeO", "Hornblende1_wt_K2O", "Hornblende1_wt_Na2O", "Hornblende1_wt_TiO2", "Hornblende1_wt_Fe2O3", "Hornblende1_wt_Cr2O3", "Hornblende1_wt_H2O", "Hornblende2_wt_frac", "Hornblende2_density", "Hornblende2_wt_SiO2", "Hornblende2_wt_Al2O3", "Hornblende2_wt_CaO", "Hornblende2_wt_MgO", "Hornblende2_wt_FeO", "Hornblende2_wt_K2O", "Hornblende2_wt_Na2O", "Hornblende2_wt_TiO2", "Hornblende2_wt_Fe2O3", "Hornblende2_wt_Cr2O3", "Hornblende2_wt_H2O", "Ilmenite1_wt_frac", "Ilmenite1_density", "Ilmenite1_wt_SiO2", "Ilmenite1_wt_Al2O3", "Ilmenite1_wt_CaO", "Ilmenite1_wt_MgO", "Ilmenite1_wt_FeO", "Ilmenite1_wt_K2O", "Ilmenite1_wt_Na2O", "Ilmenite1_wt_TiO2", "Ilmenite1_wt_Fe2O3", "Ilmenite1_wt_Cr2O3", "Ilmenite1_wt_H2O",  "Ilmenite2_wt_frac", "Ilmenite2_density", "Ilmenite2_wt_SiO2", "Ilmenite2_wt_Al2O3", "Ilmenite2_wt_CaO", "Ilmenite2_wt_MgO", "Ilmenite2_wt_FeO", "Ilmenite2_wt_K2O", "Ilmenite2_wt_Na2O", "Ilmenite2_wt_TiO2", "Ilmenite2_wt_Fe2O3", "Ilmenite2_wt_Cr2O3", "Ilmenite2_wt_H2O", "Muscovite1_wt_frac", "Muscovite1_density", "Muscovite1_wt_SiO2", "Muscovite1_wt_Al2O3", "Muscovite1_wt_CaO", "Muscovite1_wt_MgO", "Muscovite1_wt_FeO", "Muscovite1_wt_K2O", "Muscovite1_wt_Na2O", "Muscovite1_wt_TiO2", "Muscovite1_wt_Fe2O3", "Muscovite1_wt_Cr2O3", "Muscovite1_wt_H2O",  "Muscovite2_wt_frac", "Muscovite2_density", "Muscovite2_wt_SiO2", "Muscovite2_wt_Al2O3", "Muscovite2_wt_CaO", "Muscovite2_wt_MgO", "Muscovite2_wt_FeO", "Muscovite2_wt_K2O", "Muscovite2_wt_Na2O", "Muscovite2_wt_TiO2", "Muscovite2_wt_Fe2O3", "Muscovite2_wt_Cr2O3", "Muscovite2_wt_H2O", "Fluid1_wt_frac", "Fluid1_density", "Fluid1_wt_SiO2", "Fluid1_wt_Al2O3", "Fluid1_wt_CaO", "Fluid1_wt_MgO", "Fluid1_wt_FeO", "Fluid1_wt_K2O", "Fluid1_wt_Na2O", "Fluid1_wt_TiO2", "Fluid1_wt_Fe2O3", "Fluid1_wt_Cr2O3", "Fluid1_wt_H2O", "Fluid2_wt_frac", "Fluid2_density", "Fluid2_wt_SiO2", "Fluid2_wt_Al2O3", "Fluid2_wt_CaO", "Fluid2_wt_MgO", "Fluid2_wt_FeO", "Fluid2_wt_K2O", "Fluid2_wt_Na2O", "Fluid2_wt_TiO2", "Fluid2_wt_Fe2O3", "Fluid2_wt_Cr2O3", "Fluid2_wt_H2O", "Quartz_wt_frac", "Quartz_density", "Quartz_wt_SiO2", "Quartz_wt_Al2O3", "Quartz_wt_CaO", "Quartz_wt_MgO", "Quartz_wt_FeO", "Quartz_wt_K2O", "Quartz_wt_Na2O", "Quartz_wt_TiO2", "Quartz_wt_Fe2O3", "Quartz_wt_Cr2O3", "Quartz_wt_H2O", "Cristobalite_wt_frac", "Cristobalite_density", "Cristobalite_wt_SiO2", "Cristobalite_wt_Al2O3", "Cristobalite_wt_CaO", "Cristobalite_wt_MgO", "Cristobalite_wt_FeO", "Cristobalite_wt_K2O", "Cristobalite_wt_Na2O", "Cristobalite_wt_TiO2", "Cristobalite_wt_Fe2O3", "Cristobalite_wt_Cr2O3", "Cristobalite_wt_H2O",  "Tridymite_wt_frac", "Tridymite_density", "Tridymite_wt_SiO2", "Tridymite_wt_Al2O3", "Tridymite_wt_CaO", "Tridymite_wt_MgO", "Tridymite_wt_FeO", "Tridymite_wt_K2O", "Tridymite_wt_Na2O", "Tridymite_wt_TiO2", "Tridymite_wt_Fe2O3", "Tridymite_wt_Cr2O3", "Tridymite_wt_H2O", "Coesite_wt_frac", "Coesite_density", "Coesite_wt_SiO2", "Coesite_wt_Al2O3", "Coesite_wt_CaO", "Coesite_wt_MgO", "Coesite_wt_FeO", "Coesite_wt_K2O", "Coesite_wt_Na2O", "Coesite_wt_TiO2", "Coesite_wt_Fe2O3", "Coesite_wt_Cr2O3", "Coesite_wt_H2O", "Stishovite_wt_frac", "Stishovite_density", "Stishovite_wt_SiO2", "Stishovite_wt_Al2O3", "Stishovite_wt_CaO", "Stishovite_wt_MgO", "Stishovite_wt_FeO", "Stishovite_wt_K2O", "Stishovite_wt_Na2O", "Stishovite_wt_TiO2", "Stishovite_wt_Fe2O3", "Stishovite_wt_Cr2O3", "Stishovite_wt_H2O",  "Kyanite_wt_frac", "Kyanite_density", "Kyanite_wt_SiO2", "Kyanite_wt_Al2O3", "Kyanite_wt_CaO", "Kyanite_wt_MgO", "Kyanite_wt_FeO", "Kyanite_wt_K2O", "Kyanite_wt_Na2O", "Kyanite_wt_TiO2", "Kyanite_wt_Fe2O3", "Kyanite_wt_Cr2O3", "Kyanite_wt_H2O", "Sillimanite_wt_frac", "Sillimanite_density", "Sillimanite_wt_SiO2", "Sillimanite_wt_Al2O3", "Sillimanite_wt_CaO", "Sillimanite_wt_MgO", "Sillimanite_wt_FeO", "Sillimanite_wt_K2O", "Sillimanite_wt_Na2O", "Sillimanite_wt_TiO2", "Sillimanite_wt_Fe2O3", "Sillimanite_wt_Cr2O3", "Sillimanite_wt_H2O", "Andalusite_wt_frac", "Andalusite_density", "Andalusite_wt_SiO2", "Andalusite_wt_Al2O3", "Andalusite_wt_CaO", "Andalusite_wt_MgO", "Andalusite_wt_FeO", "Andalusite_wt_K2O", "Andalusite_wt_Na2O", "Andalusite_wt_TiO2", "Andalusite_wt_Fe2O3", "Andalusite_wt_Cr2O3", "Andalusite_wt_H2O", "Rutile_wt_frac", "Rutile_density", "Rutile_wt_SiO2", "Rutile_wt_Al2O3", "Rutile_wt_CaO", "Rutile_wt_MgO", "Rutile_wt_FeO", "Rutile_wt_K2O", "Rutile_wt_Na2O", "Rutile_wt_TiO2", "Rutile_wt_Fe2O3", "Rutile_wt_Cr2O3", "Rutile_wt_H2O", "Sphene_wt_frac", "Sphene_density", "Sphene_wt_SiO2", "Sphene_wt_Al2O3", "Sphene_wt_CaO", "Sphene_wt_MgO", "Sphene_wt_FeO", "Sphene_wt_K2O", "Sphene_wt_Na2O", "Sphene_wt_TiO2", "Sphene_wt_Fe2O3", "Sphene_wt_Cr2O3", "Sphene_wt_H2O", "Ferropericlase_wt_frac", "Ferropericlase_density", "Ferropericlase_wt_SiO2", "Ferropericlase_wt_Al2O3", "Ferropericlase_wt_CaO", "Ferropericlase_wt_MgO", "Ferropericlase_wt_FeO", "Ferropericlase_wt_K2O", "Ferropericlase_wt_Na2O", "Ferropericlase_wt_TiO2", "Ferropericlase_wt_Fe2O3", "Ferropericlase_wt_Cr2O3", "Ferropericlase_wt_H2O", "Wollastonite_wt_frac", "Wollastonite_density", "Wollastonite_wt_SiO2", "Wollastonite_wt_Al2O3", "Wollastonite_wt_CaO", "Wollastonite_wt_MgO", "Wollastonite_wt_FeO", "Wollastonite_wt_K2O", "Wollastonite_wt_Na2O", "Wollastonite_wt_TiO2", "Wollastonite_wt_Fe2O3", "Wollastonite_wt_Cr2O3", "Wollastonite_wt_H2O", "pswo_wt_frac", "pswo_density", "pswo_wt_SiO2", "pswo_wt_Al2O3", "pswo_wt_CaO", "pswo_wt_MgO", "pswo_wt_FeO", "pswo_wt_K2O", "pswo_wt_Na2O", "pswo_wt_TiO2", "pswo_wt_Fe2O3", "pswo_wt_Cr2O3", "pswo_wt_H2O", "Nepheline_wt_frac", "Nepheline_density", "Nepheline_wt_SiO2", "Nepheline_wt_Al2O3", "Nepheline_wt_CaO", "Nepheline_wt_MgO", "Nepheline_wt_FeO", "Nepheline_wt_K2O", "Nepheline_wt_Na2O", "Nepheline_wt_TiO2", "Nepheline_wt_Fe2O3", "Nepheline_wt_Cr2O3", "Nepheline_wt_H2O"]

	# "_wt_frac", "_density", "_wt_SiO2", "_wt_Al2O3", "_wt_CaO", "_wt_MgO", "_wt_FeO", "_wt_K2O", "_wt_Na2O", "_wt_TiO2", "_wt_O", "_wt_Cr2O3", "_wt_H2O",

	#detect various badnesses
	if length(stored_data_groups) != length(stored_data_groups_n)
		println("Badness detected: storing data for ", length(stored_data_groups), " groups, but ", length(stored_data_groups_n), " groups have their number of data points defined")
	end
	if length(stored_data_groups) != length(stored_data_groups_specialness)
		println("Badness detected: storing data for ", length(stored_data_groups), " groups, but ", length(stored_data_groups_n), " groups have their specialness defined")
	end
	if length(stored_data_groups_n) != length(stored_data_groups_specialness)
		println("Badness detected: ", length(stored_data_groups_n), " groups have their number of data points defined but ", length(stored_data_groups_n), " groups have their specialness defined")
	end

	proceed = "n"
	
	
	#=if proceed == "y"

		#Fire in the hole
	
		PT_conditions = CSV.read(string(label, "_PT.csv"), DataFrame) #read in the PT conditions file
		steps_to_complete = nrow(PT_conditions) #find the number of iterations
		println("Starting up experiment ", label, " for ", steps_to_complete, " iterations")

		#rearranger(run_first_step(label, initial_sys_in), 1)
		for i in 1:(steps_to_complete -1)			#rearranger(run_next_step(label, i+1), i+1)
			#println("Starting step ", i)
		end
		#Finalize_MAGEMin(data)
		println("Complete")

	else
		println("Aborting run, restart if desired")
	end=#
	
	
		
end

# ╔═╡ 3f5dbed7-2d3a-4f2c-84dd-dccf57536dce
dump(db)

# ╔═╡ c9928c89-9bd8-4f39-ba3a-4b2bcd1b1144
#=if proceed == "y"

		#Fire in the hole
		cd(joinpath(@__DIR__, "Experiments", label)) #go to experiments folder
		PT_conditions = CSV.read(string(label, "_PT.csv"), DataFrame) #read in the PT conditions file
		steps_to_complete = nrow(PT_conditions) #find the number of iterations
		println("Starting up experiment ", label, " for ", steps_to_complete, " iterations")

		if starting_step == 1
		rearranger(run_first_step(label, initial_sys_in), 1)
			for i in 2:steps_to_complete
				rearranger(run_next_step(label, i), i)
				println("Starting step ", i)
			end
		else
			for i in starting_step:steps_to_complete
				rearranger(run_next_step(label, i), i)
				println("Starting step ", i)
			end
		end
		accumulator(label, steps_to_complete)
		Finalize_MAGEMin(data)
		println("Complete")

	else
		println("Aborting run, restart if desired")
end=#

# ╔═╡ 4b6783d4-c3d6-44cb-a33a-8cc13262d811
#run_point_set(label)

# ╔═╡ 1a2c3657-a3b9-4c37-b43f-3f56127ef087
begin
	cd(joinpath(@__DIR__, "Experiments", label))#find the experiment folder
		PT_conditions = CSV.read(string(label, "_PT.csv"), DataFrame) #read in the PT conditions file
	mapcols(x -> count(ismissing, x), PT_conditions).Temperature
	
end

# ╔═╡ 6a4f51fb-9336-48f8-ae69-7df56c52d8d1
pwd(
)

# ╔═╡ f100fb74-13a9-463e-b2d1-4ab944857be9
#=begin
	for i in 1:(steps_to_complete -1)
				rearranger(run_next_step(label, i+1), i+1)
				println("Starting step ", i)
			end
			Finalize_MAGEMin(data)
end=#

# ╔═╡ 07c136c8-0bde-4486-9f05-9e67cde0dc97
#thingy = run_first_step("test", "mol")

# ╔═╡ fb619c18-3603-4cd2-af8f-0834bd437233
#rearranger(thingy, 2)

# ╔═╡ 71c01bb1-83f1-4f98-b51d-bfc50ea802d6
#rearranger(run_testing_block(), 1)

# ╔═╡ 08bc3073-89d7-4f0d-a841-e1cf0cb7593e
#thingy = run_next_step("Haleyjabunga", 2)

# ╔═╡ 19d1027d-ea46-47ac-8553-531807e9e3ad
#=if intersect(thingy[1].ph, stored_data_groups) == ["liq"]
	println("That's the bitch")
end=#

# ╔═╡ 993bb32d-5d7b-40b5-a3c3-3c05626ec9a3
#=if thingy[1].ph == ["liq"]
	println("that's the bitch")
end=#

# ╔═╡ af4f8907-e1ff-4d9f-816f-1efa29609a3a
#rearranger(thingy, 2)

# ╔═╡ 83a49480-9aac-4737-b21e-632be7346018
function run_testing_block() #testing block
n    = 1000
P    = rand(8.0:40,n);
T    = rand(800.0:2000.0, n);
test = 0  #KLB1
return multi_point_minimization(P,T, data, test=test);
end

# ╔═╡ 6a48ab70-3966-47f8-afd4-34e6cb4962cd
function run_first_step(label, initial_sys_in)
	
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
	P = fill(Float64(PT_conditions[1, "Pressure"]), nrow(initial_comps))
	T = fill(Float64(PT_conditions[1, "Temperature"]), nrow(initial_comps))
	X = [X[i,:] for i in 1:size(X,1)] 
	output = multi_point_minimization(P, T, data, X=X, Xoxides=Xoxides, sys_in=initial_sys_in)
	
	
	return output
end

# ╔═╡ 72f7679b-47e9-4bb2-9e10-d67bae2a0cd5
function find_starting_value(group, phase_list = ["nope", "not real"], position_in_list=999; debug_line_number =1) #This takes the name of a group of data (in my usage these are mostly minerals) and returns the column of the first field in the output file for that group (typically that phase's phase fraction)
	
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
		if group == "liq"
			println("Badness detected: multiple liquids, this is modelled as these being remixed", group, " ", debug_line_number)
		end
		if length(findall(item -> item == group, phase_list)) > 2
			println("Badness detected: More than 2 of the same phase, some information will be lost: ", group, " ", debug_line_number)
		end
	end

	
	return convert(Int, field_number)
end

# ╔═╡ cb55d0ea-11fe-42e5-bead-9ea3381ce0f9
find_starting_value("pl4T")

# ╔═╡ a6cab4f0-8a2e-473d-bd82-69f693cecc90
find_starting_value("pl4T")

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
	comps = CSV.read(input_file, delim=',', DataFrame) #Read in the initial composition file
	cd(joinpath(@__DIR__, "Experiments", label)) #go back out to the experiment folder
	PT_conditions = CSV.read(string(label, "_PT.csv"), DataFrame) #read in the PT conditions file
	n_comps = nrow(comps) #make a variable of the number of compositions per run
	
	X = zeros(n_comps, n_oxides) #initialise the composition array
	
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
	P = fill(Float64(PT_conditions[step_number, "Pressure"]), nrow(comps))
	T = fill(Float64(PT_conditions[step_number, "Temperature"]), nrow(comps))
	X = [X[i,:] for i in 1:size(X,1)]
	sys_in="wt" #all future steps are always wt
	output = multi_point_minimization(P, T, data, X=X, Xoxides=Xoxides, sys_in=sys_in)
	return output
end

# ╔═╡ 22e1385e-8918-4229-823f-db732bd4e251
function rearranger(out, step_number, n_lines)

	#=
	This is the rearranger, it takes the out struct and produces single lines of a csv containing the data we wish to store

	Each single line represents the output of the MAGEMin of a single initial bulk composition for a single iteration 
	=#

	if step_number != 1
	cd(joinpath(@__DIR__, "Experiments", label, "Instantaneous"))#find the experiment's instantaneous folder
	input_file = inst_file_namer(step_number-1, label) #find name of the last output file to be taken as input
	last_out = CSV.read(input_file, delim=',', DataFrame) #Read in the last step's output file
	end

	line_length = 0
	for i in 1:length(stored_data_groups)
		line_length += stored_data_groups_n[i] #the number of pieces of data stored on each line
	end
	working_line = zeros(n_lines, line_length) # initialise the working line, we will be editing this line and then storing it in a csv as a single operation (note that I don't claim this is the best way of doing this and I'm certain a better one exists, but this is understandable to me)
	

	#spaghetti incoming

	for line_number in 1:n_lines

		position_in_SS = 1 #Initialisations for the working positions of the SS and PP
		position_in_PP = 1 #vectors, used to handle the fact that they may not be presented in order in the phase name field

		#techincal information

	
		working_line[line_number, 1] = step_number

		#system information

		field = find_starting_value("System") #Using the function here is I imagine techinically a performance hit, but improves generality by allowing reordering/addition of groups
		working_line[line_number, field] = out[line_number].P_kbar
		working_line[line_number, field+1] = out[line_number].T_C
		working_line[line_number, field+2] = out[line_number].fO2
		
		if step_number == 1 #if this is the first step
			working_line[line_number, field + 3] = 1 #it's just 1
		else #otherwise
			liq_wt_frac_pos  = find_starting_value("liq") #Find where the liquid wt fraction is stored
			working_line[line_number, field + 3] = last_out[line_number, field + 3] * last_out[line_number, liq_wt_frac_pos] #calculate the weight fraction of liquid which remained after the last step (the fraction of initial mass)
		end

		
	

		#bulk solid information

		if out[line_number].ph != ["liq"] && out[line_number].ph != ["liq", "fl"] && out[line_number].ph != ["fl", "liq"] && out[line_number].ph != ["fl"]
			#Check that there exists a stable non-liquid phase, otherwise the bulk solid fields become NaN
		
			field = find_starting_value("Bulk solid")
			if "liq" in out[line_number].ph || "fl" in out[line_number].ph
				working_line[line_number, field] = out[line_number].frac_S_wt
			else
				working_line[line_number, field] = 1
				println("Solid rounder working as intended")
			end
			
			working_line[line_number, field+1] = out[line_number].rho_S
			for i in 1:n_oxides
				working_line[line_number, field+i+1] = out[line_number].bulk_S_wt[i] #melt composition in oxide wt%, using whatever oxide system was defined
			end
			
		#=
		elseif "fl" in out[line_number].ph == false 
			#ie: when there are no solid phases and no fluid
			field = find_starting_value("liq")
			working_line[line_number, field] = 1 #then there is only melt, without this you end up with fractions close to one which bleed mass from the system over a number of steps

		elseif "liq" in out[line_number].ph == false
			#ie: when there are no solid phases and no liquid
			field = find_starting_value("fl")
			working_line[line_number,field] = 1 #then there is only fluid, though I hope this never needs to be evaluated
		=#
		end
		#Phase information
		
		#Store the normal phase data
		for i in 1:length(out[line_number].ph) 
			group = out[line_number].ph[i] #Identify the phase
			specialness = stored_data_groups_specialness[findfirst(item -> item == group, stored_data_groups)] #Identify the number of special values it needs
			field = find_starting_value(group, out[line_number].ph, i, debug_line_number=line_number)
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
				println("I am storing data about ", group)

				for j in 1:n_oxides 
					working_line[line_number, field+specialness+j+1] = out[line_number].PP_vec[position_in_PP].Comp_wt[j]
				end

				if specialness !=0
					#No pure phases are currently special
				end
				position_in_PP = position_in_PP +1 #and then increment position in the PP vector
			end

			if out[line_number].ph_type[i] == 1 #detect if the phase being stored is a solid solution
				if group != "liq" #and check it isn't a liquid, which is covered by the earlier melt information section
				#and then store its relevant data
				working_line[line_number, field+specialness+1] = out[line_number].SS_vec[position_in_SS].rho
				println("I am storing data about ", group)
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
				end
			position_in_SS = position_in_SS +1 #and then increment position in the SS vector
			end
		end
		#println(step_number, " ", line_number)
		#bulk solid information

		if out[line_number].ph != ["liq"] && out[line_number].ph != ["liq", "fl"] && out[line_number].ph != ["fl", "liq"] && out[line_number].ph != ["fl"]
			#Check that there exists a stable non-liquid phase, otherwise the bulk solid fields become NaN
		
			field = find_starting_value("Bulk solid")
			if "liq" in out[line_number].ph || "fl" in out[line_number].ph
				working_line[line_number, field] = out[line_number].frac_S_wt
			else
				working_line[line_number, field] = 1
			end
			
			working_line[line_number, field+1] = out[line_number].rho_S
			for i in 1:n_oxides
				working_line[line_number, field+i+1] = out[line_number].bulk_S_wt[i] #melt composition in oxide wt%, using whatever oxide system was defined
			end
		end
			#Melt information
		
		
		field = find_starting_value("liq")
		if intersect(out[line_number].ph, stored_data_groups) == ["liq"]
			working_line[line_number, field] = 1
			println("Liquid rounder firing")
		else
			working_line[line_number, field] = out[line_number].frac_M_wt
			println("Overprinting")
		end
		working_line[line_number, field+1] = out[line_number].rho_M
		for i in 1:n_oxides
			working_line[line_number, field+i+1] = out[line_number].bulk_M_wt[i] #melt composition in oxide wt%, using whatever oxide system was defined
		end
	end
	
	
	#=for debugging
	println(working_line)
	println(position_in_SS)
	for i in 1:line_length
		println(working_line[i], "   ", i)
	end
	=#
	file_name = inst_file_namer(step_number, label) #generate file name
	mkpath(joinpath(@__DIR__, "Experiments", label, "Instantaneous")) #Make the instantaneous folder if it doesn't exist
	cd(joinpath(@__DIR__, "Experiments", label, "Instantaneous")) #go to instantaneous folder
	CSV.write(file_name, Tables.table(working_line), header = inst_header) #write output
end

# ╔═╡ 1fb5e7c6-99ec-420c-8b65-3227c40a4699
function run_PT_grid(label)

	#Most of this is the same as run_first_step
	
	cd(joinpath(@__DIR__, "Experiments", label))#find the experiment folder
	initial_comps = CSV.read(string(label, "_initial_comps.csv"), delim=',', DataFrame) #Read in the initial composition file
	PT_conditions = CSV.read(string(label, "_PT.csv"), DataFrame) #read in the PT conditions file
	defined_oxides = intersect(names(initial_comps),Xoxides) #Find which oxides relevant to MAGEMin are defined in the experiment composition files
	X_list = zeros(nrow(initial_comps), n_oxides)
	
	for i in 1:length(defined_oxides) #for each defined oxide
			target_column = findfirst(item -> item == defined_oxides[i], Xoxides) #find the target column number (where the column is going to be put)
			X_list[:,target_column] = initial_comps[:,string(defined_oxides[i])] #Find the column in the inital compositions dataframe with its name and put it in the right place
	end

	n_P = length(PT_conditions.Pressure)-count(ismissing, PT_conditions.Pressure)
	n_T = length(PT_conditions.Temperature)-count(ismissing, PT_conditions.Temperature)
	n_X = nrow(initial_comps)
	writing_count = 0
	P = zeros(n_P*n_T*n_X)
	T = zeros(n_P*n_T*n_X)
	X = zeros(n_P*n_T*n_X, n_oxides)

	for i in 1:n_T
		for j in 1:n_P
			for k in 1:n_X
				writing_count = writing_count +1
				P[writing_count] = Float64(PT_conditions.Pressure[j])
				T[writing_count] = Float64(PT_conditions.Temperature[i])
				X[writing_count, :] = X_list[k, :]
				
			end
		end
	end
	X = [X[i,:] for i in 1:size(X,1)] #Magic turn array into vector of vectors line

	output = multi_point_minimization(P, T, data, X=X, Xoxides=Xoxides, sys_in=initial_sys_in)
	#println(output[1].ph)
	#println(output[1].ph_frac_wt)
	rearranger(output, 1, n_P*n_T*n_X)
end

# ╔═╡ e6b01bb7-e53f-40ad-834e-aa29f329a2ab
function run_point_set(label)
		
	#This function should find the experiment folder, find the set of PTX points and run them
	
	
	cd(joinpath(@__DIR__, "Experiments", label))#find the experiment folder
	initial_comps = CSV.read(string(label, "_initial_comps.csv"), delim=',', DataFrame) #Read in the initial composition file
	PT_conditions = CSV.read(string(label, "_PT.csv"), DataFrame) #read in the PT conditions file
	defined_oxides = intersect(names(initial_comps),Xoxides) #Find which oxides relevant to MAGEMin are defined in the experiment composition files
	X = zeros(nrow(initial_comps), n_oxides)
	
	for i in 1:length(defined_oxides) #for each defined oxide
			target_column = findfirst(item -> item == defined_oxides[i], Xoxides) #find the target column number (where the column is going to be put)
			X[:,target_column] = initial_comps[:,string(defined_oxides[i])] #Find the column in the inital compositions dataframe with its name and put it in the right place
	end
	P_in = PT_conditions[:,"Pressure"]
	P = convert(Vector{Float64}, P_in)
	T_in = PT_conditions[:,"Temperature"]
	T = convert(Vector{Float64}, T_in)
	X = [X[i,:] for i in 1:size(X,1)] 
	output = multi_point_minimization(P, T, data, X=X, Xoxides=Xoxides, sys_in=initial_sys_in)
	rearranger(output, 1, nrow(initial_comps))
end
	

# ╔═╡ 2f5dd6a2-d191-4cca-966b-8a7b32aa110c
function cum_file_namer(iteration_number, label)
	file_number = "0" ^ (5-ndigits(iteration_number))
	file_name= string(label, "_cum_", file_number, iteration_number, ".csv")
	return file_name
end

# ╔═╡ 88408698-731e-47fc-9fbe-010460681b7e
function accumulator(label, steps_to_complete)
	
	#=
	This is the accumulator, its role is to form files representing the composition of the phases in the solid cumulate for each step of the simulation
	=#

	mkpath(joinpath(@__DIR__, "Experiments", label, "Cumulative")) #Make the cumulate folder if it doesn't exist


	line_length = 0
	for i in 1:length(stored_data_groups)
		line_length += stored_data_groups_n[i] #the number of pieces of data stored on each line
	end
	working_line = zeros(n_comps, line_length) # initialise the working line, we will be editing this line and then storing it in a csv as a single operation (note that I don't claim this is the best way of doing this and I'm certain a better one exists, but this is understandable to me)
	
	
	for step_number in 1:steps_to_complete #for each step of the simulation
		if step_number == 1
			#go to the inst folder and take its first item
			cd(joinpath(@__DIR__, "Experiments", label, "Instantaneous"))
			input_file = inst_file_namer(1, label)
			file_to_write = CSV.read(input_file, delim=',', DataFrame)
			file_name = cum_file_namer(step_number, label)
			cd(joinpath(@__DIR__, "Experiments", label, "Cumulative"))
			CSV.write(file_name, file_to_write, header = cum_header)
		else
			#go to the inst folder and take its next item
			cd(joinpath(@__DIR__, "Experiments", label, "Instantaneous"))
			input_file = inst_file_namer(step_number, label)
			file_to_add = CSV.read(input_file, delim=',', DataFrame)

			#go to cum folder and take its last item
			cd(joinpath(@__DIR__, "Experiments", label, "Cumulative"))
			input_file = cum_file_namer(step_number-1, label)
			last_file = CSV.read(input_file, delim=',', DataFrame)

			for line_number in 1:n_comps #for each line
				for group in stored_data_groups
					#find reference values
					field = find_starting_value(group)
					specialness = stored_data_groups_specialness[findfirst(item -> item == group, stored_data_groups)] 
					data_point_number = stored_data_groups_n[findfirst(item -> item == group, stored_data_groups)] 
					rem_frac = file_to_add[line_number, find_starting_value("System") + 3] #find the fraction of initial liquid the file to add represents
					fresh_solid_frac = file_to_add[line_number, find_starting_value("Bulk solid")] #find the fraction of the remaining liquid at the start of the step which is now solid


					#for technical, system and liquid information we just paste in the inst information, it might be faster to do this with just pasting whole columns, 
					if group == "Technical"
						working_line[line_number, field] = file_to_add[line_number, field]
						
					elseif group == "System"
						working_line[line_number, field] = file_to_add[line_number, field] #write pressure
						working_line[line_number, field+1] = file_to_add[line_number, field+1] #write temperature
						working_line[line_number, field+2] = file_to_add[line_number, field+2] #write oxygen fugacity
						
						working_line[line_number, field+3] = 1- rem_frac #write the cumulative represented solid fraction
						
					elseif group == "liq"
						for i in 1:data_point_number
							working_line[line_number, field+i-1] = file_to_add[line_number, field+i-1]
						end
						
					elseif group =="Bulk solid"
						old_bulk_weight = 1 - rem_frac #essentially old phase frac = 1
						fresh_bulk_weight = rem_frac * fresh_solid_frac #

						working_line[line_number, field] = fresh_bulk_weight + old_bulk_weight
						for i in 1:(data_point_number-1)
							working_line[line_number, field+i] = (old_bulk_weight * last_file[line_number, field+i]) + (fresh_bulk_weight*file_to_add[line_number, field+i])
						end
						
					else
						fresh_phase_frac = file_to_add[line_number, field+specialness]
						old_phase_frac = last_file[line_number, field+specialness]

						fresh_phase_weight = fresh_phase_frac*rem_frac
						#the weighting is the fraction of initial liquid represented by this step * the fraction of that liquid which became solid in this step * the fraction of that solid which is this phase
						old_phase_weight = old_phase_frac*(1-rem_frac)
						#this weighting already has the "fraction of liquid which became solid" factor accounted for, as it is by definition entirely solid material

						working_line[line_number, field] = fresh_phase_weight + old_phase_weight
						for i in 1:(data_point_number-1)
							working_line[line_number, field+i] = ((old_phase_weight*last_file[line_number, field+i] + (fresh_phase_weight*file_to_add[line_number, field+i]))/(old_phase_weight+fresh_phase_weight))
						end
						
					end
				end
			
			end
		
		end
		file_name = cum_file_namer(step_number, label) #generate file name
			cd(joinpath(@__DIR__, "Experiments", label, "Cumulative")) #go to cumulative folder
		CSV.write(file_name, Tables.table(working_line), header = cum_header) #write output
	end
	#badness detection
	goodness_points = 0 #a score for each initial composition which describes how good it is, here it's going to be how closely the initial liquid composition matches the final bulk solid composition

	#read in first inst file and final cumulative file
	
	cd(joinpath(@__DIR__, "Experiments", label, "Instantaneous"))
	comps_to_check_against_name = inst_file_namer(1, label)
	comps_to_check_against = CSV.read(comps_to_check_against_name, delim=',', DataFrame, header=false)
	cd(joinpath(@__DIR__, "Experiments", label, "Cumulative"))
	comps_to_check_name = cum_file_namer(steps_to_complete, label)
	comps_to_check = CSV.read(comps_to_check_name, delim=',', DataFrame, header=false)
	
	for i in 1:n_comps
		
		goodness_points = 0 #a score for each initial composition which describes how good it is, here it's going to be how closely the initial liquid composition matches the final bulk solid composition
		
		if isapprox(comps_to_check_against[i, find_starting_value("liq")], 1 ; atol = 0.001) == false
			println("Composition ",i," was not entirely liquid at the starting conditions, this is not necessarily bad, but means the badness detector will not work on it")
		elseif isapprox(comps_to_check[i, find_starting_value("Bulk solid")], 1 ; atol = 0.001) == false
			println("Composition ",i," was not entirely solid at the ending conditions, this is not necessarily bad, but means the badness detector will not work on it")
		end
		for j in 1:n_oxides
			if isapprox(comps_to_check[i, find_starting_value("Bulk solid")+2+j], comps_to_check_against[i, find_starting_value("liq")+2+j]; atol = 0.005) == true
				goodness_points += 1 #check if the oxide wt%s are within 0.5% of the original value
			end	
		end
		if goodness_points < 11
			println("Badness detected ",i," scored ",goodness_points, " goodness points, and may have suffered mass loss" )
		end
	end
end

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

# ╔═╡ b5f92c91-b32d-41a4-b6b5-2031f80ed631
#= begin 
	#Defining things dynamically
	db   = "ig"  # database: ig, igneous (Holland et al., 2018); mp, metapelite (White et al 2014b)
	data  = Initialize_MAGEMin(db, verbose=false);
	Xoxides = ["SiO2", "Al2O3", "CaO", "MgO", "FeO", "K2O", "Na2O", "TiO2", "O", "Cr2O3", "H2O"]
	println("Experiment label: ") #Get a title for the experiment
	global label = string(readline())

	println("Experiment notes/description: ") #Offer oppotunity to write notes or a description of the experiment
	notes = readline()
	
	cd(joinpath(@__DIR__, "Experiments", label)) #go to experiments folder
	open("notes.txt", "w") do file #write the notes
    write(file, notes)
	end

	println("Is the initial composition file in wt or mol?")
	initial_sys_in = readline()
	
	n_oxides = length(Xoxides) #please don't try to set a job which has initial compositions defined with different numbers of oxides, it'll damage the output file, it should simply be enough to add zeroes for the other oxides in whatever database you are using instead.
	stored_data_groups = ["Technical", "System", "liq", "Bulk solid", "ol", "ol", "pl4T", "pl4T", "opx", "opx", "cpx", "cpx", "g", "g", "spn", "spn", "bi", "bi", "cd", "cd",  "ep", "ep", "hb", "hb", "ilm", "ilm", "mu", "mu", "fl", "fl", "q", "crst", "trd", "coe", "stv", "ky", "sill", "and", "ru", "sph", "fper", "wo", "pswo", "ne"] #This is a list of names of groups of data in the order they will appear in the file
	stored_data_groups_n = [1, 3, 13, 13, 17, 17, 16, 16, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13] #This is a corresponding list which stores the number of fields associated with each individual group
	stored_data_groups_specialness = [0, 0, 0, 0, 4, 4, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] #This is an additional list which holds the number of additional fields (beyond the 13 for standard phases) for each group, ignoring groups which aren't relevant to the phase information writing part of the rearranger 

	#detect various badnesses
	if length(stored_data_groups) != length(stored_data_groups_n)
		println("Badness detected: storing data for ", length(stored_data_groups), " groups, but ", length(stored_data_groups_n), " groups have their number of data points defined")
	end
	if length(stored_data_groups) != length(stored_data_groups_specialness)
		println("Badness detected: storing data for ", length(stored_data_groups), " groups, but ", length(stored_data_groups_n), " groups have their specialness defined")
	end
	if length(stored_data_groups_n) != length(stored_data_groups_specialness)
		println("Badness detected: ", length(stored_data_groups_n), " groups have their number of data points defined but ", length(stored_data_groups_n), " groups have their specialness defined")
	end

	println("Proceed? y/n")
	proceed = readline()

	if proceed == "y"

		#Fire in the hole
	
		PT_conditions = CSV.read(string(label, "_PT.csv"), DataFrame) #read in the PT conditions file
		steps_to_complete = nrow(PT_conditions) #find the number of iterations
		println("Starting up experiment ", label, " for ", steps_to_complete, " iterations")

		#rearranger(run_first_step(label, initial_sys_in), 1)
		for i in 1:(steps_to_complete -1)
			#rearranger(run_next_step(label, i+1), i+1)
			println("Starting step ", i)
		end
		#Finalize_MAGEMin(data)
		println("Complete")

	else
		println("Aborting run, restart if desired")
	end

	
	
		
end =#

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
git-tree-sha1 = "cd67fc487743b2f0fd4380d4cbd3a24660d0eec8"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.3"

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
git-tree-sha1 = "7c9196c8c83802d7b8ca7a6551a0236edd3bf731"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.0"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

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
# ╠═d97ce021-1fe1-496d-b9b7-2f72d7756e65
# ╠═de8306e5-46b3-4c74-9442-0c327a78587f
# ╠═54597683-6ca7-4522-8964-da8bf772367c
# ╠═aa3fa333-efd7-4221-a9ad-19accfebb4b8
# ╠═5971b407-cf50-440a-89ae-97b4c32c4c69
# ╠═47980d08-466d-40a6-8c91-9afdf25d994e
# ╠═3f5dbed7-2d3a-4f2c-84dd-dccf57536dce
# ╠═cb55d0ea-11fe-42e5-bead-9ea3381ce0f9
# ╠═c9928c89-9bd8-4f39-ba3a-4b2bcd1b1144
# ╠═1fb5e7c6-99ec-420c-8b65-3227c40a4699
# ╠═e6b01bb7-e53f-40ad-834e-aa29f329a2ab
# ╠═4b6783d4-c3d6-44cb-a33a-8cc13262d811
# ╠═1a2c3657-a3b9-4c37-b43f-3f56127ef087
# ╠═a6cab4f0-8a2e-473d-bd82-69f693cecc90
# ╠═6a4f51fb-9336-48f8-ae69-7df56c52d8d1
# ╠═f100fb74-13a9-463e-b2d1-4ab944857be9
# ╠═07c136c8-0bde-4486-9f05-9e67cde0dc97
# ╠═fb619c18-3603-4cd2-af8f-0834bd437233
# ╠═71c01bb1-83f1-4f98-b51d-bfc50ea802d6
# ╠═08bc3073-89d7-4f0d-a841-e1cf0cb7593e
# ╠═19d1027d-ea46-47ac-8553-531807e9e3ad
# ╠═993bb32d-5d7b-40b5-a3c3-3c05626ec9a3
# ╠═af4f8907-e1ff-4d9f-816f-1efa29609a3a
# ╠═83a49480-9aac-4737-b21e-632be7346018
# ╠═6a48ab70-3966-47f8-afd4-34e6cb4962cd
# ╠═a58e22e2-dec7-40da-b598-0f9c4f45e707
# ╠═72f7679b-47e9-4bb2-9e10-d67bae2a0cd5
# ╠═22e1385e-8918-4229-823f-db732bd4e251
# ╠═88408698-731e-47fc-9fbe-010460681b7e
# ╠═03560d76-b895-43b9-9632-1fd461a131fd
# ╠═2f5dd6a2-d191-4cca-966b-8a7b32aa110c
# ╠═a3275e00-21a6-480e-8fb6-3086aeee5cc8
# ╠═b5f92c91-b32d-41a4-b6b5-2031f80ed631
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
