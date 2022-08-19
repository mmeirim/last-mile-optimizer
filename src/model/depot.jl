struct Depot
    demand::Vector{Int64} #Depot demand
    capacity::Vector{Int64} #Depot capacity
    num_veh::Vector{Int64} #Number of vehicles on the depots
    v_fixcost::Vector{Int64} #Vehicle fixed cost
    x_cord::Vector{Float64}
    y_coord::Vector{Float64}
end