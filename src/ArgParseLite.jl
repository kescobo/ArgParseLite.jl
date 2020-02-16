module ArgParseLite

export
    Argument,
    Arguments,
    parse_args

struct Argument
    name::String
    shortname::Union{Nothing,Char}
    action::Symbol
    positional::Bool
end

function Argument(n::String, s::Union{Nothing,String}=nothing; action=:value)
    positional = startswith(n, "--")
    let m = match(r"^(--)?([A-Za-z][A-Za-z\-]*)$", n)
        isnothing(m) && error("Invalid argument name: $n")
        argname = String(m.captures[2])
    end
    if s isa String
        let m = match(r"^-([a-z])$", s)
            isnothing(m) && error("Invalid shortname $s")
            s = String(m.match)
            s = length(s) == 1 ? s[1] : error("$s should be a single character")
        end
    end
    (positional && action != :value) && error("positional arguments can't be flags")
    in(action, (:value, :store_true, :store_false)) || error("Action $action not supported")
    return Argument(argname, s, action, positional)
end

struct Arguments
    posargs::Vector{Argument}
    kwargs::Dict{String,Argument}
    Arguments() = new(Argument[], Dict{String,Argument}())
end

function Base.push!(args::Arguments, arg::Argument)
    if arg.positional
        length(args.kwargs) == 0 || error("can't add positional arguments after keyword arguments")
        push!(args.posargs, arg)
    else
        haskey(args.kwargs, arg.name) && error("duplicate arg name $(arg.name)")
        args.kwargs[arg.name] = arg
    end
end

function parse_args(args::Arguments, args_list::Vector{<:AbstractString}=ARGS)
    outdict = Dict{String, String}()
    for (i, arg) in enumerate(args.posargs)
        val = args_list[i]
        startswith(val, "-") && error("keyword arg $val where positional arg should be")

        outdict[name] = val
    end
end

end # module
