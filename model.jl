module MoralSim
export Agent, create_population, choice_probs, ACTIONS

using Random, Distributions

# Actions: :S (high sacrifice), :M (medium), :N (no sacrifice)
const ACTIONS = [:S, :M, :N]

struct Agent
    id::Int
    w::Float64       # utilitarian weight
    alpha::Float64   # empathy / harm aversion (dynamic via contagion)
    beta::Float64    # social sensitivity (reputation weight)
    lambda::Float64  # inverse temperature
    reputation::Float64
end

# Multi-action outcome payoffs (example normalized)
outcome_payoff(action::Symbol) = action == :S ? 4.0 : action == :M ? 2.0 : 0.0

# Emotion penalty - higher for more direct harm
emotion_penalty(action::Symbol) = action == :S ? 1.5 : action == :M ? 0.7 : 0.0

# compute choice probabilities via softmax over actions
function choice_probs(agent::Agent)
    utilities = Float64[]
    for a in ACTIONS
        U = agent.w * outcome_payoff(a) - agent.alpha * emotion_penalty(a) + agent.beta * agent.reputation
        push!(utilities, U)
    end
    exps = exp.(agent.lambda .* utilities)
    probs = exps ./ sum(exps)
    return Dict(ACTIONS[i] => probs[i] for i in 1:length(ACTIONS))
end

# create heterogeneous population
function create_population(n::Int; rng=1234)
    Random.seed!(rng)
    agents = Agent[]
    for i in 1:n
        w = rand(Uniform(0.5, 1.5))
        alpha = rand(Uniform(0.0, 1.5)) # empathy baseline
        beta = rand(Uniform(0.0, 1.0))
        lambda = rand(Uniform(0.5, 3.0))
        push!(agents, Agent(i, w, alpha, beta, lambda, 0.0))
    end
    return agents
end

end # module
