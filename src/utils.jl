using Graphs

struct Solution
    graph::SimpleGraph{Int}
    coloring::Graphs.Coloring
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

function coloring_cost(S::Solution)
    num_conflicts = 0
    for edge in edges(S.graph)
        src, dst = edge.src,edge.dst
        if S.coloring.colors[src] == S.coloring.colors[dst]
            num_conflicts+=1
        end
    end
    return num_conflicts
end