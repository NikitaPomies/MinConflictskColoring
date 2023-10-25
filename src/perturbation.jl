
function decrease_k_with_random(S::Solution)::Solution
    color_to_remove::Int = rand(unique(S.coloring.colors))
    colors = deepcopy(S.coloring.colors)
    for i in 1:nv(S.graph)
        if colors[i] == color_to_remove
            col = color_to_remove
            while col == color_to_remove
                col = rand(unique(S.coloring.colors))
            end
            colors[i] = col
        end
    end
    colors = reindex_vector(colors)
    coloring = Graphs.Coloring(length(unique(colors)),colors)
    return Solution(S.graph,coloring)
end

