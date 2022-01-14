using Pkg
Pkg.activate(@__DIR__)
using Dash
using Noticer

const words = Set{String}(Noticer.normalize.(open(readlines, joinpath(@__DIR__, "data/113809of.fic"))))
open("/usr/share/dict/words") do f
    for line in readlines(f)
        push!(words, Noticer.normalize(line))
    end
end

const features = all_features()
const model = Model(features, words)

app = dash(external_stylesheets = ["https://codepen.io/chriddyp/pen/bWLwgP.css"])

demo = ["formally", "thinnest", "businesswoman", "communicated", "hallucinogen", "saccharin", "cellophane"]

app.layout = html_div() do
        dcc_textarea(id = "input-div", placeholder=join(demo, '\n')),
        html_div(id = "output-div")
    end
callback!(app, Output("output-div", "children"), 
    Input("input-div", "value")) do input_value
    io = IOBuffer()
    if isnothing(input_value) || isempty(input_value)
        return ""
    end
    show(io, MIME"text/html"(), Report(evaluate(model, split(input_value, '\n'))))
    String(take!(io))
end



run_server(app, "0.0.0.0", 8080)


