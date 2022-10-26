module BerryCost
    using StatsPlots
    using Distributions

    greet() = print("Hello World!")
    function plottler()
        p = plot(Normal(3, 5), lw = 3)
        plot!(p, Normal(1, 6), lw = 4)

        display(p)
    end
end # module BerryCost

using .BerryCost
theme(:dark)
BerryCost.plottler()