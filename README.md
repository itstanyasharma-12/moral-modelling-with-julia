# Moral Dilemma Simulation : Agent-Based Behavioral Modeling in Julia

This project simulates how moral decisions evolve in a social network using **agent-based modeling**, **utility-based decision rules**, and **emotional contagion** (simple version).

## Extensions added (simple)
- **Multi-action moral dilemmas**: actions = Sacrifice (S), Medium (M), No-sacrifice (N).
- **Emotional contagion**: agents slightly adjust their empathy (alpha) toward the average alpha of their neighbors each round.

## Quick run (after installing packages)
```julia
using Pkg
Pkg.add.(["Graphs","DataFrames","Distributions","StatsBase","CSV","Plots"])
include("src/model.jl")
include("src/simulation.jl")
include("src/analysis.jl")
using .MoralSim, .MoralSimSim, .MoralSimAnalysis, Graphs, CSV, DataFrames

g = erdos_renyi(100, 0.03)
agents = create_population(100)
df = simulate!(g, agents; rounds=50, gamma=0.2) # gamma controls emotional contagion strength
CSV.write("results/results.csv", df)

plot_time_series("results/results.csv")
plot_action_share("results/results.csv")
```

Files:
- `src/model.jl` : agent struct, multi-action payoffs, choice probabilities, population creation
- `src/simulation.jl` : simulate! with emotional contagion (alpha update)
- `src/analysis.jl` : plotting time-series and action-share bar
- `notebooks/MoralSim_Colab.ipynb` : placeholder (create your Colab notebook using the scripts)
- `results/` : will contain CSV and PNGs after running

License: MIT
