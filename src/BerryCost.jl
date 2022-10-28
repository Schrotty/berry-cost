using StatsPlots
using Distributions

function getpositives(dh, dd, t)::Tuple{Float64, Float64}
    fp = 1 - cdf.(dh, t)
    tp = 1 - cdf.(dd, t)
    return (fp, tp)
end

# distributions
dh = Normal(4.2, 5)
dd = Normal(7, 4)

positives = []
for t in -20:20
    push!(positives, getpositives(dh, dd, t))
end

# plots
theme(:dark)

dplt = plot(dh, label = "Harmless", color = "green")
plot!(dplt, dd, label = "Dangerous", color = "red")

title!("Distributions")
xlabel!("Value")
ylabel!("Density")

roc = plot(collect(zip(positives)), legend = false)
xlabel!("false positive")
ylabel!("true positive")

plot(dplt, roc, layout = (2, 1))
plot!(size=(800,600))