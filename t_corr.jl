include("complexity.jl")
using DelimitedFiles, Base, CairoMakie
script_dir = @__DIR__

Tglass=[0, 5, 10, 25, 50, 75, 100, 150, 200, 250, 273, 300, 1400]
TFe=[0, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200,1400]
glass_moments = Vector{Vector{Array{Vector{Float64}, 3}}}(undef, length(Tglass))
glass_complexities=zeros(length(Tglass))
fe_moments = Vector{Vector{Array{Vector{Float64}, 3}}}(undef, length(TFe))
fe_complexities=zeros(length(TFe))


cd(joinpath(script_dir, "..", "..", "Complexity of SD", "Resultaten", "t_corr"))

for (i,T) in enumerate(Tglass) ##Reading glass moments
    println(i)
    cd("T"*string(T))
    glass_moments[i]=reading("glass",32,32,32,"avg")
    cd("..")
end


#T complexity
for (i,T) in enumerate(Tglass)
    c=t_complexity(glass_moments[i],3,6,2,2,2,2) #compute t_complexity for each temperature
    glass_complexities[i]=sum(sum(c,dims=2),dims=1)[1] #Sum all elements of Cκk
end

writedlm("glass.txt", [Tglass glass_complexities]) #Write away data

##Average complexity
avg_comp=zeros(length(Tglass))
comp=zeros(length(glass_moments[1]))

for (i,T) in enumerate(Tglass)
    for (j, val) in enumerate(comp)
        comp[j]=complexity((glass_moments[i])[j],3,2,2,2)
    end
    a=mean(comp)
    avg_comp[i]=a
end 

writedlm("avg_glass.txt", [Tglass avg_comp]) #Write away data



cd(joinpath(script_dir, "..", "..", "Complexity of SD", "Resultaten", "t_corr_fe"))

for (i,T) in enumerate(TFe) ##Reading glass moments
    println(i)
    cd("T"*string(T))
    fe_moments[i]=reading("bccFe",32,32,32)
    cd("..")
end

#T complexity
for (i,T) in enumerate(TFe)
    c=t_complexity(fe_moments[i],3,6,2,2,2,2) #compute t_complexity for each temperature
    fe_complexities[i]=sum(sum(c,dims=2),dims=1)[1] #Sum all elements of Cκk
end

writedlm("bccfe.txt", [TFe fe_complexities]) #Write away data


#Average complexity
avg_comp_fe=zeros(length(TFe))
comp_fe=zeros(length(fe_moments[1]))

for (i,T) in enumerate(TFe)
    for (j, val) in enumerate(comp_fe)
        comp_fe[j]=complexity((fe_moments[i])[j],3,2,2,2)
    end
    a=mean(comp_fe)
    avg_comp_fe[i]=a
end 

writedlm("avg_fe.txt", [TFe avg_comp_fe]) #Write away data