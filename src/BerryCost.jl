using QuadGK
using StatsPlots
using Distributions

function getpositives(xh, xd, t)
    fp = ccdf.(xh, t) # false positive - situation is not dangerous
    tp = ccdf.(xd, t) # true positive - situation is dangerous
    return (fp = fp, tp = tp, t = t)
end

function getprices(xh, xd, t)
    return (ih = cdf.(xh, t)*2.0, id = cdf.(xd, t)*2.3, t = t)
end

# distributions
xh = Normal(4.2, 5)
xd = Normal(7, 4)

# extrema
min = -20
max = 20

prices = [getprices(xh, xd, x) for x in min:.01:max]

# replace?
t = [(diff = x.ih - x.id, t = x.t) for x in prices if x.ih - x.id == maximum([p.ih - p.id for p in prices])][1]

positives = [getpositives(xh, xd, t) for t in min:1:max]

# plots
theme(:dark)

dplt = plot(xh, label = "Harmless", color = "green")
plot!(dplt, xd, label = "Dangerous", color = "red")

title!("Distributions")
xlabel!("Value")
ylabel!("Density")
vline!([t.t], label = "Threshold", color = "blue", line = (1, :dash), annotation = (t.t, 0.01, t.t))

roc = plot([(p.fp, p.tp) for p in positives], legend = false)
title!("ROC")
xlabel!("false positive")
ylabel!("true positive")

plot(dplt, roc, layout = (2, 1))
plot!(size=(800,600))