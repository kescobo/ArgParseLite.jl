using ArgParseLite


function main()
    my_args = Arguments()

    push!(my_args, Argument("arg1"))
    push!(my_args, Argument("--opt1"))
    push!(my_args, Argument("--opt2", "-o"))
    push!(my_args, Argument("--flag1", action=:store_true))


    println("Parsed args:")
    for (arg,val) in parse_args(my_args)
        println("  $arg  =>  $val")
    end
end

main()
