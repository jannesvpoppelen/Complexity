using DelimitedFiles, LinearAlgebra,Statistics

function read_moments(moments::Array,Nx::Int64,Ny::Int64,Nz::Int64)
    #= Creates matrices based on moments.simid.out as generated by UppASD. 
    Moments are parsed in terms of unit cells, which are taken as the finest "pixel".
    Averaging the unit cell in the coarse graining stage can be done both before and after selecting blocks,
    so for ease it is done before. =#
    N_Atoms=length(moments[:,1])
    Na=N_Atoms/(Nx*Ny*Nz)
    if ~isinteger(Na)
        error("Dimensions do not match")
    end

    Na=Int(Na)
    Mx=permutedims(reshape(moments[:,4].*moments[:,5],Int(Na),Nz,Ny,Nx),(1,4,3,2))
    My=permutedims(reshape(moments[:,4].*moments[:,6],Int(Na),Nz,Ny,Nx),(1,4,3,2))
    Mz=permutedims(reshape(moments[:,4].*moments[:,7],Int(Na),Nz,Ny,Nx),(1,4,3,2))
    M=Array{Vector{Float64},3}(undef,Nx,Ny,Nz)
        for j=1:Nx #Highly inefficient computations from here
            for k=1:Ny
                for l=1:Nz
                    M[j,k,l]= normalize(collect(map(x->mean(x), (Mx[:,j,k,l], My[:,j,k,l], Mz[:,j,k,l])))); #Averaging function, avg/stagavg
                end
            end
        end
    return M
end

function reading(simid::String,Nx::Int64,Ny::Int64,Nz::Int64)
    #= Outdated moment reading function. =#
    moments=readdlm("moment."*simid*".out")[8:end,:]
    N_Atoms=length(readdlm("restart."*simid*".out")[8:end,1])
    list=Array{Array{Vector{Float64},3}}(undef,div(length(moments[:,1]),N_Atoms)); #0 to nstep
    for i=1:length(list)
        list[i]=read_moments(moments[1+(i-1)*N_Atoms:i*N_Atoms,:],Nx,Ny,Nz);
    end
    list=[x::Array{Vector{Float64}, 3} for x in list]
    return list
end

function read_moments(moments::Array,coords::Array,Nx::Int64,Ny::Int64,Nz::Int64, q::Vector)
    #= Creates matrices based on moments.simid.out as generated by UppASD. 
    Moments are parsed in terms of unit cells, which are taken as the finest "pixel".
    Averaging the unit cell in the coarse graining stage can be done both before and after selecting blocks,
    so for ease it is done before. =#
    N_Atoms=length(moments[:,1])
    Na=N_Atoms/(Nx*Ny*Nz)
    if ~isinteger(Na)
        error("Dimensions do not match")
    end

    Na=Int(Na)
    Mx=permutedims(reshape(moments[:,4].*moments[:,5],Int(Na),Nz,Ny,Nx),(1,4,3,2)) #Moments
    My=permutedims(reshape(moments[:,4].*moments[:,6],Int(Na),Nz,Ny,Nx),(1,4,3,2))
    Mz=permutedims(reshape(moments[:,4].*moments[:,7],Int(Na),Nz,Ny,Nx),(1,4,3,2))

    rx=permutedims(reshape(coords[:,1],Int(Na),Nz,Ny,Nx),(1,4,3,2)) #Positions
    ry=permutedims(reshape(coords[:,2],Int(Na),Nz,Ny,Nx),(1,4,3,2))
    rz=permutedims(reshape(coords[:,3],Int(Na),Nz,Ny,Nx),(1,4,3,2))
    
    M=Array{Vector{Float64},3}(undef,Nx,Ny,Nz)

    for j=1:Nx #Highly inefficient computations from here
        for k=1:Ny
            for l=1:Nz
                avgm=zeros(3)
                for m=1:Na
                    r=[rx[m,j,k,l],ry[m,j,k,l],rz[m,j,k,l]]
                    avgm+=[Mx[m,j,k,l], My[m,j,k,l], Mz[m,j,k,l]].*cos(dot(q,r))  #Staggered average every magnetic unit cell
                end
                M[j,k,l]=normalize(avgm)
            end
        end
    end
    return M
end

function reading(simid::String,Nx::Int64,Ny::Int64,Nz::Int64,q::Vector{Float64})
    #= Updated moment reading function which takes in the magnetic ordering vector q. =#
    moments=readdlm("moment."*simid*".out")[8:end,:]
    coords=readdlm("coord."*simid*".out")[:,2:4]
    N_Atoms=length(readdlm("restart."*simid*".out")[8:end,1])
    list=Array{Array{Vector{Float64},3}}(undef,div(length(moments[:,1]), N_Atoms));
    for i=1:length(list)
        list[i]=read_moments(moments[1+(i-1)*N_Atoms:i*N_Atoms,:],coords,Nx,Ny,Nz,q);
    end
    list=[x::Array{Vector{Float64}, 3} for x in list]
    return list
end

function avgM(simid::String,Nx::Int64,Ny::Int64,Nz::Int64,q::Vector{Float64})
    M=[0.0,0.0,0.0]
    moments=readdlm("restart."*simid*".out")[8:end,:]
    coords=readdlm("coord."*simid*".out")[:,2:4]
    N_Atoms=length(moments[:,1])
    Na=N_Atoms/(Nx*Ny*Nz)
    if ~isinteger(Na)
        error("Dimensions do not match")
    end
    Na=Int(Na)

    Mx=permutedims(reshape(moments[:,4].*moments[:,5],Int(Na),Nz,Ny,Nx),(1,4,3,2)) #Moments
    My=permutedims(reshape(moments[:,4].*moments[:,6],Int(Na),Nz,Ny,Nx),(1,4,3,2))
    Mz=permutedims(reshape(moments[:,4].*moments[:,7],Int(Na),Nz,Ny,Nx),(1,4,3,2))

    rx=permutedims(reshape(coords[:,1],Int(Na),Nz,Ny,Nx),(1,4,3,2)) #Positions
    ry=permutedims(reshape(coords[:,2],Int(Na),Nz,Ny,Nx),(1,4,3,2))
    rz=permutedims(reshape(coords[:,3],Int(Na),Nz,Ny,Nx),(1,4,3,2))


    for j=1:Nx #Highly inefficient computations from here
        for k=1:Ny
            for l=1:Nz
                avgm=zeros(3)
                for m=1:Na
                    r=[rx[m,j,k,l],ry[m,j,k,l],rz[m,j,k,l]]
                    avgm+=[Mx[m,j,k,l], My[m,j,k,l], Mz[m,j,k,l]].*cos(dot(q,r))  #Staggered average every magnetic unit cell
                end
                M+=avgm
            end
        end
    end
    return M/(N_Atoms)
end

function coarse_grain(A::Array{Vector{Float64},3},Λx::Int64,Λy::Int64,Λz::Int64)
    #= Computes a coarse grained matrix (cgm) at sizes Λx, Λy, Λz, in x,y and z directions, respectively.
    Renormalization is done through the average function. 
    Assumed here is that Λx|Nx, Λy|Ny, Λz|Nz. =#
    Nx,Ny,Nz=size(A,1),size(A,2),size(A,3) #Size of A
    if Nx==1
        Λx=1
    end
    if Ny==1
        Λy=1
    end
    if Nz==1
        Λz=1
    end
    if Nx%Λx!=0 || Ny%Λy!=0 || Nz%Λz!=0
        error("Size of cgm incommensurate")
    end
    M1,M2,M3=div(Nx,Λx),div(Ny,Λy),div(Nz,Λz) #Size of cgm
    B=Array{Vector{Float64},3}(undef,M1,M2,M3)
        for i=1:M1
            for j=1:M2
                for k=1:M3
                    B[i,j,k]=1/(Λx*Λy*Λz)*(sum(A[(i-1)*Λx+1:i*Λx,(j-1)*Λy+1:j*Λy,(k-1)*Λz+1:k*Λz]))
                end
            end
        end
    return B
end

function complexity(A::Array{Vector{Float64},3},N::Int64,Λx::Int64,Λy::Int64,Λz::Int64)
    #= Computes the multiscale structural complexity of A matrix
     with N renormalization steps at a scale Λ, in 3D =#
    M1,M2,M3=size(A,1),size(A,2),size(A,3)
    complexity=0
    c=0
    if M1/(Λx)^N<4 || M2/(Λy)^N<4 || M3/(Λz)^N<4
        #error("Number of renormalization steps is too big")
    end

    for k=1:N
        B=coarse_grain(A,Λx,Λy,Λz)
        c=abs(dot(B,B)/(size(B,1)*size(B,2)*size(B,3))-dot(A,A)/(size(A,1)*size(A,2)*size(A,3)))
        A=B
        complexity+=c
    end
    return complexity
end

function t_coarse_grain(A::Vector{Array{Vector{Float64}, 3}}, Λt::Int64)
    L1 = length(A) # nsteps
    L2 = div(L1, Λt) # length of the new array
    N1, N2, N3 = size(A[1], 1), size(A[1], 2), size(A[1], 3)
    B = Vector{Array{Vector{Float64}, 3}}(undef, L2) # initialize the time coarse-grained array
    for t = 1:L2 # time coarse-graining
        avg_arr = Array{Vector{Float64}, 3}(undef, N1, N2, N3)
        arrs = A[(t-1) * Λt + 1 : t * Λt]
        for i = 1:N1
            for j = 1:N2
                for k = 1:N3
                    sum_vec = zeros(Float64, length(arrs[1][i, j, k])) # initialize the sum vector
                    for arr in arrs
                        sum_vec += arr[i, j, k] # accumulate the vectors
                    end

                    avg_vec = 1/(Λt)*sum_vec # calculate the average vector
                    avg_arr[i, j, k] = avg_vec # normalize the average vector
                    
                end
            end
        end
        B[t] = avg_arr
    end
    return B
end


function t_complexity(A::Vector{Array{Vector{Float64},3}},N::Int64,Nt::Int64,Λx::Int64,Λy::Int64,Λz::Int64,Λt::Int64)
    A1=A
    Arr=A
    Cκk=zeros(Nt,N)
    O1,O2=zeros(Nt+1),zeros(Nt+1)
    if length(A)/(Λt)^Nt<2 
        error("Number of temporal renormalization steps is too big")
    end

    ##t_comp at largest spatial scale k=0
    temp=zeros(length(A1))
    for (i,value) in enumerate(A1)
        temp[i]=dot(A1[i],A1[i])/(size(A1[i],1)*size(A1[i],2)*size(A1[i],3)) #spatial overlap
    end
    O1[1]=dot(temp,temp)/length(temp) #temporospatial overlap O_{(0,0);(0,0)}

    for t=1:Nt #time coarse graining
        A2=copy(t_coarse_grain(A1,Λt))
        temp=zeros(length(A2))
        for (i,value) in enumerate(A2)
            temp[i]=dot(A2[i],A2[i])/(size(A2[i],1)*size(A2[i],2)*size(A2[i],3)) #spatial overlap
        end
        O1[(t+1)]=dot(temp,temp)/length(temp) #temporospatial overlap O_{(κ,0);(κ,0)}
        A1=A2 #A2->A1
    end

    #loop over in between space scales k=1 to N-1
    for k = 1:N
        B1=similar(Arr)
        for i in eachindex(Arr) #spatial coarse grain
            B1[i]=copy(coarse_grain(Arr[i],Λx,Λy,Λz))
        end
        Arr=copy(B1)


        temp=zeros(length(B1))
        for (i,value) in enumerate(B1) 
            temp[i]=dot(B1[i],B1[i])/(size(B1[i],1)*size(B1[i],2)*size(B1[i],3)) #spatial overlap
        end
        O2[1]=dot(temp,temp)/length(temp) #temporospatial overlap O_{(0,k);(0,k)}
    
        for t=1:Nt #time coarse graining
            B2=t_coarse_grain(B1,Λt)
            temp=zeros(length(B2))
            for (i,value) in enumerate(B2)
                temp[i]=dot(B2[i],B2[i])/(size(B2[i],1)*size(B2[i],2)*size(B2[i],3)) #spatial overlap
            end
            O2[(t+1)]=dot(temp,temp)/length(temp) #temporospatial overlap O_{(κ,k);(κ,k)}
            B1=copy(B2)
        end

        for i=1:Nt #compute complexity at spatial scale k
            Cκk[i,k]=abs(O1[i]-O1[i+1]-O2[k]+O2[k+1])
        end

        O1=O2 #O2->O1
    end
    return Cκk
end