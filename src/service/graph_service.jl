function GenerateGraph(nodes::Vector{Int64},x_values)
    # u_list = [value.(u)[CartesianIndex(i)] for i in 1:(instance.num_cus)]
    # x_matrix = zeros(Int64, instance.num_cus+1, instance.num_cus+1)
    # for i in nodes
    #     for j in nodes
    #         x_matrix[i,j] = x_values[CartesianIndex(i,j)] >= 1 ? 1 : 0
    #     end
    # end
 
    # push!(routes_dict, 2 => x_matrix)
    # push!(u_dict, 2 => u_list)

    G = SimpleDiGraph(instance.num_cus+1)
    nodelabel = collect(Int64,1:nv(G)) 
    for i in nodes
        for j in nodes
            if(x_values[CartesianIndex(i,j)]>=1)
                add_edge!(G, i, j)
                println("x[$i,$j] = $(x_values[CartesianIndex(i,j)])")
                if j != 1
                end
            end
        end
    end
    display(gplot(G,arrowlengthfrac=0.03))

    return G
end