
function customize_argmin(M::Matrix{Int}, skip::Vector{Tuple{Int,Int}}, S::Solution)
    min = 100000000
    min_row_idx = -1
    min_col_idx = -1
    num_rows = size(M, 1)
    num_cols = size(M, 2)

    for i in 1:num_rows
        for j in 1:num_cols
            if (i, j) in skip || (j == S.coloring.colors[i])
                continue
            else
                if M[i, j] < min
                    min_row_idx = i
                    min_col_idx = j
                    min = M[i, j]
                end

            end
        end
    end
    return min_row_idx, min_col_idx

end


function LS_best_1opt!(S::Solution)::Bool
    index = customize_argmin(S.T, S.TabuList, S)
    v, new_color = index[1], index[2]
    old_color = S.coloring.colors[v]    
    S.coloring.colors[v] = new_color
    push!(S.TabuList, (v, old_color))
    S.cost += S.T[v,new_color]
    update_color_change_table!(v, old_color, new_color, S)
    return true

end







function TabuSearch(S::Solution)
    global best_found_sol = deepcopy(S)
    global best_found_val = S.cost
    global iteration = 0
    global step_counter = 0
    while (iteration < 10000 && best_found_val!=0)

        println("Iteration $(iteration)")
        improved = LS_best_1opt!(S)
        if improved
            println("Cost after best 1opt of iteration $(iteration) $(coloring_cost(S)) $(S.cost)")
            if S.cost < best_found_val
                best_found_sol = deepcopy(S)
                best_found_val = S.cost
            end
        end
        if length(S.TabuList) > 60
            S.TabuList = S.TabuList[20:end]
        end
        iteration += 1
        step_counter += 1
        println(" ")
    end
    return best_found_sol
end