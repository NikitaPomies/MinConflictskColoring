include("dsat.jl")
include("perturbation.jl")

function initial_sol(G::SimpleGraph,k::Int)::Solution
    first_sol = Solution(G,dsat(G))

    while first_sol.coloring.num_colors > k
        first_sol = decrease_k_with_random(first_sol)
    end
    return first_sol
end

