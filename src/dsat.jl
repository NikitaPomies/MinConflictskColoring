using Graphs

function dsat(g::SimpleGraph)::Graph.Coloring
    colors = zeros(Int, nv(g))
    saturation_degrees = zeros(Int,nv(g))

    seq = convert(Vector{Int}, sortperm(degree(g); rev=true))

    selected_vertex = seq[1]
    colors[selected_vertex] = 1


    while 0 in colors
        saturation_degrees[selected_vertex] = -1
        
        for node in all_neighbors(g,selected_vertex)
            if saturation_degrees[node] != -1
                saturation_degrees[node] +=1
            end
        end

        check_vertices_degree = [node for node in 1:nv(g) if saturation_degrees[node]==maximum(saturation_degrees)]
        if length(check_vertices_degree) > 1
            selected_vertex = argmax(x->degree(g,x),check_vertices_degree)
        else
            selected_vertex = check_vertices_degree[1]
        end

        available_colors = Set(1:nv(g))
        neighbors = all_neighbors(g, selected_vertex)
        for neighbor in neighbors
            if colors[neighbor] != 0 && colors[neighbor] in available_colors
                pop!(available_colors, colors[neighbor])
            end
        end
        colors[selected_vertex] = minimum(available_colors)
    end
    return Graphs.Coloring(length(colors),colors)
end