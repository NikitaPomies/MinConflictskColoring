
function LS_best_1opt!(S::Solution)::Bool
    index = argmin(S.T)
    v,new_color = index[1],index[2]
    obj_diff = S.T[v,new_color]
    if obj_diff < 0
        old_color = S.coloring.colors[v]
        S.coloring.colors[v] = new_color
        update_color_change_table!(v,old_color,new_color,S)
        return true
    else
        return false
    end  
end


