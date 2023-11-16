using Graphs

mutable struct Solution
    graph::SimpleGraph{Int}
    coloring::Graphs.Coloring
    T::Matrix{Int}
    TabuMatrix::Matrix{Int}
    cost::Int
    function Solution(graph::SimpleGraph{Int}, coloring::Graphs.Coloring)
        T = compute_color_change_table(graph,coloring.colors)
        TabuMatrix = zeros(Int, nv(graph),length(unique(coloring.colors)))
        cost = coloring_cost(graph,coloring)
        new(graph, coloring, T,TabuMatrix,cost)
    end
end




function parse_instance_file(filename::AbstractString)
    # Initialize an empty graph
    g = SimpleGraph()

    open(filename) do file
        for line in eachline(file)
            if startswith(line, "p")
                println(line)
                # Extract the number of nodes from the line
                _, _,num_nodes, _ = split(line)
                num_nodes = parse(Int, num_nodes)

                # Add nodes to the graph
                add_vertices!(g, num_nodes)
            elseif startswith(line, "e")
                # Extract the edge information
                _, a, b = split(line)
                a, b = parse(Int, a), parse(Int, b)

                # Add an edge between nodes 'a' and 'b'
                add_edge!(g, a, b)
            end
        end
    end

    return g
end

function is_coloring_valid(S::Solution,k::Int)
    if S.coloring.num_colors != k
        return false
    elseif length(unique(S.coloring.colors)) != S.coloring.num_colors
        return false
    else
        return true
    end
end


function coloring_cost(graph::SimpleGraph,coloring::Graphs.Coloring)
    num_conflicts = 0
    for edge in edges(graph)
        src, dst = edge.src,edge.dst
        if coloring.colors[src] == coloring.colors[dst]
            num_conflicts+=1
        end
    end
    return num_conflicts
end

function coloring_cost(S::Solution)
   return coloring_cost(S.graph,S.coloring)
end

function get_conclicted_vertices(S::Solution)::Vector{Int}

    conf_vertices :: Vector{Int} = []
    for edge in edges(S.graph)
        src, dst = edge.src,edge.dst
        if S.coloring.colors[src] == S.coloring.colors[dst]
            if ! (src in conf_vertices)
                 push!(conf_vertices,src)
            end
            if ! (dst in conf_vertices) 
                push!(conf_vertices,dst)
            end
        end
    end
    return conf_vertices
end

function reindex_vector(vector)
    unique_values = unique(vector)
    value_to_index = Dict(unique_values[i] => i for i in 1:length(unique_values))
    reindexed_vector = [value_to_index[vector[i]] for i in 1:length(vector)]
    return reindexed_vector
end




function compute_color_change_table(graph::SimpleGraph,colors::Vector{Int})::Matrix{Int}
    n = nv(graph)
    k = length(unique(colors))
    cost_matrix = zeros(Int, n, k)
    for i in 1:n
        for color in 1:k
            cost = 0
            for neighbor in all_neighbors(graph,i)
                cost += ((colors[neighbor] == color) - (colors[neighbor] == colors[i]))
            end
            cost_matrix[i,color] = cost
            
        end
    end
    return cost_matrix

end



function update_color_change_table!(v::Int,color_before::Int,
    color_after::Int,S::Solution)
    k = size(S.T,2)
    
    for neighbor in all_neighbors(S.graph,v)
        neighbor_color = S.coloring.colors[neighbor]

        if neighbor_color != color_before
            S.T[neighbor,color_before] -= 1
        end

        if neighbor_color != color_after
            S.T[neighbor,color_after] += 1
        end
        
            
        if color_before == neighbor_color
            for color in 1:k
                if color != neighbor_color
                    S.T[neighbor,color] += 1
                end
                S.T[v,color] += 1
            end
        end

        if color_after == neighbor_color
            for color in 1:k
                if color != neighbor_color
                    S.T[neighbor,color] -= 1
                end
                S.T[v,color] -= 1
            end
        end
        
       
    end
end
