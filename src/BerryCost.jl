using StatsPlots
using Distributions

function getpositives(xh, xd, t)
    fp = ccdf.(xh, t) # false positive - situation is not dangerous
    tp = ccdf.(xd, t) # true positive - situation is dangerous
    return (fp = fp, tp = tp, t = t)
end

function getcosts(xh, xd, t)
    fp, tp, thr = getpositives(xh, xd, t)
    ch = cdf.(xh, t) * 2.0
    cd = cdf.(xd, t) * 2.3
    return (fp = fp, tp = tp, t = t,
            ch = ch, cd = cd,
            diff = ch - cd)
end

# distributions
xh = Normal(4.2, 5)
xd = Normal(7, 4)
mix = MixtureModel(Normal[xh, xd])

# extrema
min = -20
max = 20

# get random x values from mixture
agents = [rand(mix, x) for x in 1:100]

# calculate threshold
costs = [getcosts(xh, xd, x) for x in min:.001:max]
t = [x for x in costs if x.diff == maximum([p.diff for p in costs])][1]
positives = [getpositives(xh, xd, t) for t in min:1:max]

# P(fp) + (P(tp) - P(fp) / 2) - calculate quorum
q = t.fp + ((t.tp - t.fp) / 2)

tpg = []
fpg = []

for x::Vector{Float64} in agents
    #local tp = reduce(+, [pdf.(mix, p) for p::Float64 in x if p > t.t]; init = 0.0)
    #local fp = reduce(+, [pdf.(mix, p) for p::Float64 in x if p < t.t]; init = 0.0)

    local tp = [p for p::Float64 in x if p > t.t]
    local n = length(x)

    if length(tp) > n * q
        push!(tpg, (p = 1, n = n))
    else
        push!(fpg, (p = 0, n = n))
    end
end

# plots
theme(:dark)

dplt = plot(xh, label = "Harmless", color = "green")
plot!(dplt, xd, label = "Dangerous", color = "red")

title!("Distributions")
xlabel!("Value")
ylabel!("Density")
vline!([t.t], label = "Threshold", color = "blue", line = (1, :dash), annotation = (t.t, 0.01, t.t))

mixplt = scatter([(p.n, p.p) for p in tpg], seriestype = :scatter, label = "True positive", legend = true)
#ylims!(0.0, .1)
#xlims!(0, 100)
#hline!([q], label = "Quorum", color = "blue", line = (1, :dash))
plot!(mixplt, [(p.n, p.p) for p in fpg], seriestype = :scatter, label = "False positive")

mplot = scatter()

roc = plot([(p.fp, p.tp) for p in positives], legend = false)
title!("ROC")
xlabel!("false positive")
ylabel!("true positive")

plot(dplt, mixplt, roc, layout = (3, 1))
plot!(size=(800,600))