struct Satelite
    capacity::Vector{Int64} #satelites capacity
    num_veh::Vector{Int64} #Number of vehicles on the satelites
    v_fixcost::Vector{Int64} #Vehicle fixed cost
    x_cord::Vector{Float64}
    y_coord::Vector{Float64}
    uhcost::Vector{Float64} #unit handling cost at satellites
    uhtime::Vector{Float64} #unit handling time at satellites
end