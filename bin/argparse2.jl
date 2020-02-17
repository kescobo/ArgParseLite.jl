using ArgParse2

function main()
    parser = ArgumentParser()
    add_argument(parser, "arg1", help = "a positional argument")
    add_argument(parser, "--opt1", help = "an option with an argument")
    add_argument(parser, "-o", "--opt2", help = "another option with an argument")
    add_argument(parser, "--flag1", action="store_true", default=false, help = "an option without argument, i.e. a flag")

    println("Parsed args:")
    for (arg,val) in pairs(parse_args(parser))
        println("  $arg  =>  $val")
    end
end

main()
