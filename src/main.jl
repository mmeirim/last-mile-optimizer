using Distances
include("service/load_service.jl")

instance = LoadInstance("../data/I2-4-10-50.txt")

println(instance.depots.cords)

function GreedySecondLevel(instance::Instance)
    #Compute the number of unassigned customers whose closest satelite is k
    assigned_customers = [] 
    distances = DistanceCustomerSatelite(instance)
end

function DistanceCustomerSatelite(instance::Instance)::Matrix{Float64}
    return pairwise(Euclidean(),instance.customers.cords,instance.satelites.cords)
end