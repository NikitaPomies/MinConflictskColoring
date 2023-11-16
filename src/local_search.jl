

function customize_argmin(M::Matrix{Int}, tabu_matrix::Matrix{Int64},S::Solution,current_iteration::Int)
    min_val_with_tabu = Inf
    min_val_without_tabu = Inf
    indices_with_tabu = []
    indices_without_tabu = []
    
    for i in 1:size(M, 1)
        for j in 1:size(M, 2)
            if j == S.coloring.colors[i]
                continue
            end

            if tabu_matrix[i,j] <= current_iteration
                if M[i, j] < min_val_without_tabu
                    min_val_without_tabu = M[i, j]
                    indices_without_tabu = [(i, j)]
                elseif M[i, j] == min_val_without_tabu
                    push!(indices_without_tabu, (i, j))
                end
            end
            
            if M[i, j] < min_val_with_tabu
                min_val_with_tabu = M[i, j]
                indices_with_tabu = [(i, j)]
            elseif M[i, j] == min_val_with_tabu
                push!(indices_with_tabu, (i, j))
            end
        end
    end
    
    random_index_with_tabu = rand(1:length(indices_with_tabu))
    random_index_without_tabu = rand(1:length(indices_without_tabu))
    
    return ((indices_with_tabu[random_index_with_tabu],min_val_with_tabu),
    (indices_without_tabu[random_index_without_tabu],min_val_without_tabu))
end


function LS_best_1opt!(S::Solution,best_found_val::Int,current_iteration::Int,plateau_counter::Int)::Bool
    
    index_with_tabu,index_no_tabu = customize_argmin(S.T, S.TabuMatrix, S,current_iteration)

    v_tabu, new_color_tabu,obj_diff_tabu = index_with_tabu[1][1], index_with_tabu[1][2],index_with_tabu[2]
    v_no_tabu, new_color_no_tabu,obj_diff_no_tabu = index_no_tabu[1][1], index_no_tabu[1][2],index_no_tabu[2]

    # Aspiration criteria
    if (S.cost + obj_diff_tabu < best_found_val)
        print("ASPIRATION !!!")
        v, new_color,obj_diff =v_tabu,new_color_tabu,obj_diff_tabu
    else
        v, new_color,obj_diff =v_no_tabu,new_color_no_tabu,obj_diff_no_tabu
        
    end
    old_color = S.coloring.colors[v]    
    S.coloring.colors[v] = new_color
    S.TabuMatrix[v, old_color] = current_iteration + 10 +  round(Int,S.cost) + div(plateau_counter,1000)
    S.cost += S.T[v,new_color]
    update_color_change_table!(v, old_color, new_color, S)
    return true

end







function TabuSearch(S::Solution)
    global best_found_sol = deepcopy(S)
    global best_found_val = S.cost
    global iteration = 0
    global plateau_counter = 0
    global previous_cost = S.cost
    
    while (iteration < 200000 && best_found_val!=0)

        println("Iteration $(iteration)")
        improved = LS_best_1opt!(S,best_found_val,iteration,plateau_counter)
        if S.cost == previous_cost
            plateau_counter += 1
            println(plateau_counter)
        else
            previous_cost = S.cost
            plateau_counter = 0
        end

        if improved
            println("Cost after best 1opt of iteration $(iteration) $(S.cost)")
            if S.cost < best_found_val
                best_found_sol = deepcopy(S)
                best_found_val = S.cost
            end
        end
     
        iteration += 1
        println(" ")
    end
    return best_found_sol
end