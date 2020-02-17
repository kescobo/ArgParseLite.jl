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
    positional = !startswith(n, "--")
    m = match(r"^(--)?([\w\-][\w\-]*)$", n)
    isnothing(m) && error("Invalid argument name: $n")
    argname = String(m.captures[2])

    if s isa String
        m = match(r"^-([A-Za-z0-9])$", s)
        isnothing(m) && error("Invalid shortname $s")
        s = String(m.captures[1])
        s = length(s) == 1 ? s[1] : error("$s should be a single character")
    end
    (positional && action != :value) && error("positional arguments can't be flags")
    in(action, (:value, :store_true, :store_false)) || error("Action $action not supported")
    return Argument(argname, s, action, positional)
end

struct Arguments
    posargs::Vector{Argument}
    kwargs::Dict{String,Argument}
    shortkwargs::Dict{Char,Argument}
    Arguments() = new(Argument[], Dict{String,Argument}(), Dict{Char,Argument}())
end

function Base.push!(args::Arguments, arg::Argument)
    if arg.positional
        length(args.kwargs) == 0 || error("can't add positional arguments after keyword arguments")
        push!(args.posargs, arg)
    else
        haskey(args.kwargs, arg.name) && error("duplicate arg name $(arg.name)")
        args.kwargs[arg.name] = arg
        if !isnothing(arg.shortname)
            haskey(args.shortkwargs, arg.shortname) && error("duplicate short name $(arg.shortname)")
            args.shortkwargs[arg.shortname] = arg
        end
    end
end

function parse_args(args::Arguments, args_list::Vector{<:AbstractString}=ARGS)
    outdict = Dict{String, Union{String,Bool}}()
    length(args_list) >= length(args.posargs) || error("Mising positional args")

    for (name,arg) in args.kwargs
        arg.action == :store_true && (outdict[name] = false)
        arg.action == :store_false && (outdict[name] = true)
    end

    for (i, arg) in enumerate(args.posargs)
        val = args_list[i]
        startswith(val, "-") && error("keyword arg $val where positional arg should be")

        outdict[arg.name] = val
    end
    i = length(args.posargs) + 1
    while i <= length(args_list)
        arg = args_list[i]
        if occursin(r"^--[A-Za-z0-9]", arg)
            m = match(r"^--([A-Za-z0-9\-]+)$", arg)
            isnothing(m) && error("invalid kwarg format: $arg")
            name = String(m.captures[1])
            haskey(args.kwargs, name) || error("$name is not a valid argument")
            arg = args.kwargs[name]
        else
            m = match(r"^-([A-Za-z])$", arg)
            isnothing(m) && error("$arg is not a valid positional argument")
            name = String(m.captures[1])[1]
            haskey(args.shortkwargs, name) || error("$name is not a valid argument")
            arg = args.shortkwargs[name]
        end

        if arg.action == :value
            outdict[arg.name] = args_list[i+1]
            i += 2
        elseif arg.action == :store_true
            outdict[arg.name] = true
            i += 1
        elseif arg.action == :store_false
            outdict[arg.name] = false
            i += 1
        end
    end
    return outdict
end

end # module
