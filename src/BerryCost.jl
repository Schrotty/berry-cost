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

function quorum(tp, fp)
    # P(fp) + (P(tp) - P(fp) / 2)
    return fp + ((tp - fp) / 2)
end

function calculateaverage(input::Vector{Vector{Float64}}, t::Float64)
    tp = []
    fp = []
    for x::Vector{Float64} in input
        p = sum(pdf.(mix, x); init = 0) / length(x)

        m = mean(x)
        if m > t
            push!(tp, (p = p, n = length(x)))
        else
            push!(fp, (p = p, n = length(x)))
        end
    end

    return (tp = tp, fp = fp)
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
positives = [getpositives(xh, xd, t) for t in min:1:max]
t = [x for x in costs if x.diff == maximum([p.diff for p in costs])][1]

# calculate quorum
q = quorum(t.tp, t.fp)

tpg = []
fpg = []

for x::Vector{Float64} in agents

    # calculate TPR and FPR
    local n = length(x)
    fpb = Binomial(n, t.fp)
    tpb = Binomial(n, t.tp)

    push!(tpg, tpb)
    push!(fpg, fpb)
end

# calculate values for average
avg = calculateaverage(agents, t.t)

# plots
theme(:dark)

# distribution plot
dplt = plot(xh, label = "Harmless", color = "green")
plot!(dplt, xd, label = "Dangerous", color = "red")

title!("Distributions")
xlabel!("Value")
ylabel!("Density")
vline!([t.t], label = "Threshold", color = "blue", line = (1, :dash), annotation = (t.t, 0.01, t.t))

# quorums plot
bb = Binomial(100, .5)
show(ccdf(bb, 0))

mixplt = plot([ccdf(x, q) for x in tpg], seriestype = :scatter, label = "True positive", legend = true)
#ylims!(0.0, .1)
#xlims!(0, 100)
#hline!([q], label = "Quorum", color = "blue", line = (1, :dash))
plot!(mixplt, [ccdf(x, q) for x in fpg], seriestype = :scatter, label = "False positive")

# plot for average desicsion making
mplot = scatter([(p.n, p.p) for p in avg.tp], label = "True postive")
plot!(mplot, [(p.n, p.p) for p in avg.fp], seriestype = :scatter, label = "False positive")

# roc plot
roc = plot([(p.fp, p.tp) for p in positives], legend = false)
title!("ROC")
xlabel!("false positive")
ylabel!("true positive")

# combined plots
plot(dplt, mixplt, mplot, roc, layout = (4, 1))
plot!(size=(1280,1280))