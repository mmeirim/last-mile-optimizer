using Distances, JuMP, HiGHS, Graphs, GraphPlot, Compose
include("service/load_service.jl")
include("service/graph_service.jl")

instance = LoadInstance("/home/matheus.meirim/projetos/last-mile-optimizer/data/I2-4-10-50.txt")

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
    routes_dict = Dict{Int64,Matrix}()
    u_dict = Dict{Int64,Vector}()
    obj_value_dict = Dict{Int64,Float64}()
    
    # 1 represents the satelite/depot and customers have their id added in 1 unit
    nodes = vcat(1,assignment_list.+1)
    model_deterministic = Model(HiGHS.Optimizer)
    # set_optimizer_attribute(model, "LogLevel",0)
    set_optimizer_attribute(model_deterministic, "time_limit", 60.0)

    @variables(model_deterministic,
    begin
        x[nodes,nodes], Bin
        u[nodes[2:end]] ≥ 0
    end)

    @constraints(model_deterministic,
    begin
        ct1[j in nodes[2:end]], sum(x[i,j] for i in nodes) == 1 #vehicle leaves node that it enters
        ct2[i in nodes[2:end]], sum(x[i,j] for j in nodes) == 1 #vehicle leaves node that it enters
        ct3, sum(x[i,1] for i in nodes) == instance.satelites.num_veh[best_satelite] #every vehicle returns to the depot
        ct4, sum(x[1,j] for j in nodes) == instance.satelites.num_veh[best_satelite] #every vehicle leaves the depot
        ct5[i in nodes[2:end], j in nodes[2:end]; i != j], u[j] - u[i] + (instance.v2_cap)*(1-x[i,j]) ≥ instance.customers.demand[j-1] #MTZ constraint
        ct6[i in nodes[2:end]], instance.customers.demand[i-1] ≤ u[i] ≤ (instance.v2_cap) #MTZ constraint
        ct7[i in nodes], x[i,i] == 0 #avoiding cycles
        # ct8[] #respecting vehicle working time
    end)

    vehicle_cost = instance.satelites.v_fixcost[best_satelite]*sum(x[1,j] for j in nodes)
    arcs_cost = sum(instance.ud2 *x[i,j] * euclidean(instance.customers.cords[i-1],instance.customers.cords[j-1]) for i in nodes[2:end] for j in nodes[2:end]) +  sum(instance.ud2 *x[1,j] * euclidean(instance.satelites.cords[best_satelite],instance.customers.cords[j-1]) for j in nodes[2:end]) +  sum(instance.ud2 *x[i,1] * euclidean(instance.satelites.cords[best_satelite],instance.customers.cords[i-1]) for i in nodes[2:end])
    assignment_cost = 0 
    handling_cost = sum(instance.satelites.uhcost[best_satelite] * x[i,j] * instance.customers.demand[i-1] for i in nodes[2:end] for j in nodes)

    @objective(model_deterministic, Min, vehicle_cost+arcs_cost+assignment_cost+handling_cost)

    optimize!(model_deterministic)
    
    obj_value = objective_value(model_deterministic)
    println("Objective value: $(obj_value)")
    println("Termination status: $(termination_status(model_deterministic))")
    
    x_values = value.(x)
    G = GenerateGraph(nodes,x_values)
    
end