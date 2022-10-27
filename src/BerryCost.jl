using StatsPlots
using Distributions

function plottler()
    theme(:dark)

    threshold = 5

    xh = Normal(4.2, 5)
    xg = Normal(7, 4)

    ph = plot(xh, label = "Harmlos", color = "green")
    pg = plot(xg, label = "Gefährlich", color = "red")

    plot(ph, pg)
    title!("Werteverteilung")
    xlabel!("Wert")
    ylabel!("Wahrscheinlichkeit bzw. Dichte")

    println(pdf.(xh, [5]))
end

plottler()