using Distances, JuMP, GLPK
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
    
    #Generate Second Level Routes
    second_level_routes = RoutingAlgorithm(best_satelite, assignment_list,instance)
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
    assignment_list = Vector{Int64}()
    assignment_weight = 0
    nearest_customers = sortperm(distances[:,best_satelite])
    for cust in nearest_customers
        if instance.customers.demand[cust] + assignment_weight <= instance.satelites.capacity[best_satelite]
            append!(assignment_list,cust)
        end
    end
    return assignment_list
end

#MTZ formulation
function RoutingAlgorithm(best_satelite, assignment_list, instance::Instance)
    deterministic_routes_dict = Dict{Int64,Matrix}()
    deterministic_u_dict = Dict{Int64,Vector}()
    deterministic_obj_value_dict = Dict{Int64,Float64}()
    
    # 0 represents the satelite/depot
    nodes = vcat(0,assignment_list)
    println(nodes)
    println(nodes[2:end])
    model_deterministic = Model(GLPK.Optimizer)
    # set_optimizer_attribute(model, "LogLevel",0)
    @variables(model_deterministic,
    begin
        x[nodes,nodes], Bin
        u[nodes[2:end]] ≥ 0
    end)

    @constraints(model_deterministic,
    begin
        ct1[j in nodes[2:end]], sum(x[i,j] for i in nodes) == 1 #vehicle leaves node that it enters
        ct2[i in nodes[2:end]], sum(x[i,j] for j in nodes) == 1 #vehicle leaves node that it enters
        ct3, sum(x[i,0] for i in nodes) == instance.f2_size #every vehicle leaves the depot
        ct4, sum(x[0,j] for j in nodes) == instance.f2_size #every vehicle returns to the depot
        ct5[i in nodes[2:end], j in nodes[2:end]; i != j], u[j] - u[i] + (instance.v2_cap)*(1-x[i,j]) ≥ instance.customers.demand[j] #MTZ constraint
        ct6[i in nodes[2:end]], instance.customers.demand[i] ≤ u[i] ≤ (instance.v2_cap) #MTZ constraint
        ct7[i in nodes], x[i,i] == 0 #avoiding cycles
    end)

    println(model_deterministic)

    # @objective(model_deterministic, Min, sum(instance.weights[i,j] * x[i,j] for i in nodes for j in nodes))
    # set_optimizer_attribute(model_deterministic, "TimeLimit", 60)
    # set_optimizer_attribute(model_deterministic, "OutputFlag", 0)
    # optimize!(model_deterministic)


end
GreedySecondLevel(instance)