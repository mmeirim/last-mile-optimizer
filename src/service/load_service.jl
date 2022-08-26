include("../model/instance.jl")

function LoadInstance(filename::String)::Instance

    f = open(filename)
    s = read(f, String)
    values = split(s)

    num_dep = parse(Int64,values[21])
    num_sat = parse(Int64,values[22])
    num_pic = parse(Int64,values[23])
    num_cus = parse(Int64,values[24])
    total_demand = parse(Int64,values[25])
    v1_cap = parse(Int64,values[26])
    v2_cap = parse(Int64,values[27])
    f1_size = parse(Int64,values[28])
    f2_size = parse(Int64,values[29])
    v1_worktime = parse(Int64,values[30])
    v2_worktime = parse(Int64,values[31])
    v1_speed  = parse(Int64,values[32])
    v2_speed  = parse(Int64,values[33])
    ud1 = parse(Float64,values[34])
    ud2 = parse(Float64,values[35])
    utp = parse(Float64,values[36])
    ucp = parse(Float64,values[37])
    utc = parse(Float64,values[38])

    counter = 47
    depot_demand = parse.(Int64,values[counter:7:counter + 7*num_dep-1])
    depot_cap = parse.(Int64,values[counter+1:7:counter+1 + 7*num_dep-1])
    depot_nveh = parse.(Int64,values[counter+2:7:counter+2 + 7*num_dep-1])
    depot_vfc = parse.(Int64,values[counter+3:7:counter+3 + 7*num_dep-1])
    depot_cords = zeros(Float64,2,num_dep)
    it = counter+4
    for i in 1:2
        depot_cords[i, :] = parse.(Float64,values[it:7:it + 7*num_dep-1])
        it += 1
    end

    depots_struct = Depot(depot_demand,depot_cap,depot_nveh,depot_vfc,depot_cords)

    counter += 7*num_dep + 8

    satelites_cap = parse.(Int64,values[counter:8:counter + 8*num_sat-1])
    satelites_nveh = parse.(Int64,values[counter+1:8:counter+1 + 8*num_sat-1])
    satelites_vfc = parse.(Int64,values[counter+2:8:counter+2 + 8*num_sat-1])
    satelites_cords = zeros(Float64,2,num_sat)
    it = counter+3
    for i in 1:2
        satelites_cords[i, :] = parse.(Float64,values[it:8:it + 8*num_sat-1])
        it += 1
    end
    satelites_uhcost = parse.(Float64,values[counter+5:8:counter+5 + 8*num_sat-1])
    satelites_uhtime = parse.(Float64,values[counter+6:8:counter+6 + 8*num_sat-1])

    satelites_struct = Satelite(satelites_cap,satelites_nveh,satelites_vfc,satelites_cords,satelites_uhcost,satelites_uhtime)

    counter += 8*num_sat + 3

    pickup_cords = zeros(Float64,2,num_pic)
    it = counter
    for i in 1:2
        pickup_cords[i, :] = parse.(Float64,values[it:3:it + 3*num_pic-1])
        it += 1
    end

    pickup_struct = PickupFacility(pickup_cords)

    counter += 3*num_pic + 4

    customer_demand = parse.(Int64,values[counter:4:counter + 4*num_cus-1])
    customer_cords = zeros(Float64,2,num_cus)
    it = counter+1
    for i in 1:2
        customer_cords[i, :] = parse.(Float64,values[it:4:it + 4*num_cus-1])
        it +=1
    end
    customers_struct = Customer(customer_demand,customer_cords)

    counter += 4*num_cus-1
    
    m_assignment = zeros(Int64, num_dep, num_cus)
    for i = 1:num_dep
        m_assignment[i,:] = parse.(Int64, values[counter:counter+num_cus-1])
        counter += num_cus-1
    end

    return Instance(num_dep, num_sat, num_pic, num_cus, total_demand, v1_cap, v2_cap,f1_size, f2_size,
                    v1_worktime, v2_worktime, v1_speed, v2_speed, ud1, ud2, utp, ucp, utc,depots_struct,
                    satelites_struct, pickup_struct,customers_struct,m_assignment)
end
