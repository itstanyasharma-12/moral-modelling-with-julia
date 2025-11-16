module MoralSimSim
export simulate!

using Random, DataFrames, Graphs
using ..MoralSim: Agent, create_population, choice_probs, ACTIONS

# simulate! updates reputation and applies emotional contagion to alpha each round
# gamma: emotional contagion strength [0,1] (0=no contagion, 1=full replace by neighbor mean)
function simulate!(g::SimpleGraph, agents::Vector{Agent}; rounds::Int=30, seed::Int=1234, gamma::Float64=0.1)
    Random.seed!(seed)
    n = nv(g)
    history = DataFrame(round=Int[], agent=Int[], action=String[], alpha=Float64[])

    # keep last actions map
    last_actions = Dict{Int,Symbol}()

    for r in 1:rounds
        # compute neighbor reputation (fraction who did :S or :M weighted? here count :S and :M as 'cooperative')
        neighbor_rep = zeros(Float64, n)
        neighbor_alpha = zeros(Float64, n)
        for i in 1:n
            nbrs = neighbors(g, i)
            if isempty(nbrs)
                neighbor_rep[i] = 0.0
                neighbor_alpha[i] = agents[i].alpha
            else
                s_count = 0
                a_sum = 0.0
                for j in nbrs
                    if haskey(last_actions, j)
                        act = last_actions[j]
                        if act == :S || act == :M
                            s_count += 1
                        end
                    end
                    a_sum += agents[j].alpha
                end
                neighbor_rep[i] = length(nbrs) > 0 ? s_count / length(nbrs) : 0.0
                neighbor_alpha[i] = a_sum / length(nbrs)
            end
        end

        # Update agents' reputation and apply emotional contagion to alpha
        for i in 1:n
            a = agents[i]
            new_alpha = (1 - gamma) * a.alpha + gamma * neighbor_alpha[i]
            agents[i] = Agent(a.id, a.w, new_alpha, a.beta, a.lambda, neighbor_rep[i])
        end

        # Sample actions for this round
        for i in 1:n
            probs = choice_probs(agents[i])
            # sample according to probabilities
            rdraw = rand()
            cum = 0.0
            chosen = :N
            for (act, p) in probs
                cum += p
                if rdraw <= cum
                    chosen = act
                    break
                end
            end
            push!(history, (r, i, string(chosen), agents[i].alpha))
            last_actions[i] = chosen
        end
    end

    return history
end

end # module
