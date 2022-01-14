using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using ArgParse
using HTTP: queryparams
using Mux: Mux, @app, page, serve
using Noticer: Model, all_features, evaluate, Report
using Sockets: @ip_str, IPv4

module Templates

sanitize(s::AbstractString) = replace(s, r"[<>]" => "")
sanitize(s) = sanitize(string(s)::AbstractString)

function Results(report)
    """<div>
    <h2>Results</h2>
    $(report)
    </div>
    """
end

function Style()
    """
    <style>
    h1,h2,h3 {
        font-family: 'lucida grande', sans-serif;
    }
    .flex-outer {
        display: flex;
        flex-wrap: wrap;
    }
    .flex-col {
        display: flex;
        flex-direction: column;
    }
    .flex-col label {
        padding-top: 1em;
        padding-bottom: 0.5em;
    }
    .spacer {
        width: 1em;
    }
    .home-link a {
        color: black;
    }

    table {
        border-collapse: collapse;
        box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
    }
    tr {
        border: none;
    }
    th {
        margin: 5px;
        border: 1px solid white;
        padding-left: 0.5em;
        padding-right: 0.5em;
    }
    td {
        margin: 0;
        border: 1px solid white;
        padding-left: 0.5em;
        padding-right: 0.5em;
    }
    th:not(:empty) {
        text-align: center;
    }
    tr:nth-child(2) th:empty {
        border-left: none;
        border-right: 1px dashed #888;
    }
    td {
        border: 2px solid #ccf;
    }
    tbody tr:nth-of-type(even) {
        background-color: #f3f3f3;
    }
    </style>
    """
end

function Index(body)
    """
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <link rel="shortcut icon" href="favicon.ico" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="theme-color" content="#000000" />
        <title>Noticer.jl</title>
        $(Style())
      </head>
      <body style="background-color: whitesmoke;">
        <div style="background-color: white; width: 90%; margin: auto; max-width: 800pt; box-shadow: 2px 2px 8px #aaa; padding: 1em 1em 1em 1em">
                $(body)
        </div>
      </body>
    </html>
    """
end

function WordsInput(words=[])
    """
    <form action="solve" method="GET">
        <div class="flex-outer">
            <div class="flex-col" style="max-width: 90%">
                <label for="clue">Clue</label>
                <textarea id="clue" name="clue" max-width: 100%" rows="10" cols="20">
$(join(sanitize.(words), '\n'))
                </textarea>
            </div>
            <div class="spacer"></div>
            <input type="submit" value="Solve" style="margin-top: 1em"/>
        </div>
    </form>
    """
end

end

const MODEL = Model(all_features())

function split_query(app, req)
    req[:query_params] = queryparams(req[:query])
    app(req)
end

function handle_solve(request)
    @show request
    params = request[:query_params]
    words = filter(!isempty, split(params["clue"], '\n'))
    @show params
    results = evaluate(MODEL, words)

    io = IOBuffer()
    show(io, MIME"text/html"(), Report(results))
    Templates.Index(
        Templates.WordsInput(words) *
        Templates.Results(String(take!(io)))
    )
end

function handle_home(request)
    Templates.Index(
        Templates.WordsInput([])
    )
end

function main()
    settings = ArgParseSettings()
    @add_arg_table settings begin
        "--host"
            default="127.0.0.1"
        "--port"
            default="8000"
    end
    parsed_args = parse_args(ARGS, settings)
    host = parsed_args["host"]
    port = parse(Int, parsed_args["port"])

    @info "Serving at $host:$port"
    @app server = (
        Mux.stack(Mux.todict, Mux.basiccatch, Mux.splitquery, Mux.toresponse),
        page("/solve",
             split_query,
             req -> Base.invokelatest(handle_solve, req)),
        page("/",
             req -> Base.invokelatest(handle_home, req)),
        Mux.notfound())
    serve(server, host, port)
end

wait(main())
