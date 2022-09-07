using Distances
include("service/load_service.jl")

instance = LoadInstance("../data/I2-4-10-50.txt")

function GreedySecondLevel(instance::Instance)
    #Compute the number of unassigned customers whose closest satelite is k
    unassigned_customers = collect(Int64,1:instance.num_cus)
    distances = DistanceCustomerSatelite(instance)
    best_satelite = ChooseBestSatelite(distances,instance.num_sat, unassigned_customers) 
    
    #Assign customers to best satelite and remove from unassigned
    assignment_list = AssignCustomersToSatelite(best_satelite,instance,unassigned_customers, distances)
    filter!(x->!(x in assignment_list),unassigned_customers)
    println(unassigned_customers)
end

function DistanceCustomerSatelite(instance::Instance)::Matrix{Float64}
    return ceil.(pairwise(Euclidean(),instance.customers.cords,instance.satelites.cords);digits=5)
end

function ChooseBestSatelite(distances::Matrix{Float64}, num_sat::Int64, unassigned_customers::Vector{Int64})::Int64
    satelites_proximity = zeros(Int64,num_sat) 
    for i in unassigned_customers
        nearest_satelite = argmin(distances[i,:])
        satelites_proximity[nearest_satelite] += 1
    end
    return argmax(satelites_proximity)
end

function AssignCustomersToSatelite(best_satelite::Int64,instance::Instance,unassigned_customers::Vector{Int64},distances::Matrix{Float64})::Vector{Int64}
    assignment_list = Int64[]
    assignment_weight = 0
    nearest_customers = sortperm(distances[:,best_satelite])
    for cust in nearest_customers
        if instance.customers.demand[cust] + assignment_weight <= instance.satelites.capacity[best_satelite]
            append!(assignment_list,cust)
        end
    end
    return assignment_list
end
GreedySecondLevel(instance)