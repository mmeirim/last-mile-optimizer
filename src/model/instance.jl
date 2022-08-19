include("customer.jl")
include("depot.jl")
include("pickup_facility.jl")
include("satelite.jl")

struct Instance
    num_dep::Int64 #Number of depots
    num_sat::Int64 #Number of satelites
    num_pic::Int64 #Number of pickup facilities
    num_cus::Int64 #Number of customers
    total_demand::Int64 #Total demand
    v1_cap::Int64 #First level vehicle capacity
    v2_cap::Int64 #Second level vehicle capacity
    f1_size::Int64 #First level fleet size
    f2_size::Int64 #Second level fleet size
    v1_worktime::Int64 #First level vehicle maximum working time
    v2_worktime::Int64 #Second level vehicle maximum working time
    v1_speed::Int64 #First level vehicle speed
    v2_speed::Int64 #Second level vehicle speed
    ud1::Float64 #First level vehicle unit distance traveling cost
    ud2::Float64 #Second level vehicle unit distance traveling cost
    utp::Float64 #Service time coefficient associated with the pickup facility
    ucp::Float64 #Unit cost coefficient associated with customer pickup service
    utc::Float64 #Service time coefficient associated with the customer service
    depots::Depot #depots data
    satelites::Satelite #satelites data
    pickup_facilities::PickupFacility #pickup facilities data
    customers::Customer #customer data
    assignment_matrix::Matrix{Int64}
end