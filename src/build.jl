macro collection(expression)
    evaluated = eval(expression)

    name = nameof(evaluated)
    name_snakecase = convert(PascalCase, SnakeCase, string(name))
    fields = fieldnames(evaluated)

    collection_functions = [
        quote
            function $(Symbol(name_snakecase, :_, field))(collection::$name, i::Integer)
                return collection.$field[i]
            end
        end for field in fields
    ]

    inputs_functions = [
        quote
            function $(Symbol(name_snakecase, :_, field))(inputs::AbstractInputs, i::Integer)
                return inputs.$(Symbol(name_snakecase)).$field[i]
            end
        end for field in fields
    ]

    return esc(
        Expr(:block,
            [
                expression,
                collection_functions...,
                inputs_functions...,
            ]...,
        ),
    )
end
