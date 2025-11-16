module MoralSimAnalysis
export plot_time_series, plot_action_share

using CSV, DataFrames, Plots, Statistics

# plot time series of share choosing each action (S/M/N)
function plot_time_series(path::String; outpath::String="results/moral_choices_timeseries.png")
    df = CSV.read(path, DataFrame)
    rounds = sort(unique(df.round))
    acts = unique(df.action)
    # compute proportion per round per action
    prop = DataFrame(round=Int[], action=String[], prop=Float64[])
    for r in rounds
        sub = filter(row -> row.round == r, df)
        total = nrow(sub)
        for a in acts
            cnt = count(==(a), sub.action)
            push!(prop, (r, a, cnt / total))
        end
    end
    # pivot for plotting
    pivot = unstack(prop, :action, :prop)
    plt = plot(title="Action share over time", xlabel="Round", ylabel="Proportion")
    for col in names(pivot)[2:end]
        plot!(pivot.round, pivot[!, col], label=col)
    end
    savefig(plt, outpath)
    println("Saved time series to ", outpath)
end

# bar plot of final action shares
function plot_action_share(path::String; outpath::String="results/action_share_final.png")
    df = CSV.read(path, DataFrame)
    lastr = maximum(df.round)
    final = filter(row -> row.round == lastr, df)
    counts = combine(groupby(final, :action), :action => length => :count)
    counts.prop = counts.count ./ sum(counts.count)
    plt = bar(string.(counts.action), counts.prop, xlabel="Action", ylabel="Proportion", title="Final action shares")
    savefig(plt, outpath)
    println("Saved final action share to ", outpath)
end

end # module
