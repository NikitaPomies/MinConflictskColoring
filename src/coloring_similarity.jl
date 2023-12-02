

function create_similarity_matrix(c1::Graphs.Coloring.colors,c2::Graphs.Coloring.colors,k::Int)

    similarity_matrix = Vector{Int}(undef, k^2)
    n = length(c1)
    for i in 1:n
        similarity_matrix[c1[i],c2[i]] = 0
    end
    for i in 1:n
        similarity_matrix[c1[i],c2[i]] +=1

    end
    return similarity_matrix
end