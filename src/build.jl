macro collection(expression)
    @capture(expression, @kwdef mutable struct name_ <: AbstractCollection fields__ end) ||
        error("Expected @kwdef mutable struct T <: AbstractCollection fields... end, got $expression")

    name_snakecase = convert(PascalCase, SnakeCase, string(name))

    getters = Expr[]

    for field in fields
        @capture(field, field_name_::field_type_ = constructor_) ||
            error("Expected field_name::field_type = constructor, got $field")

        if field_name == :id
            continue
        end

        push!(getters, quote
            function $(Symbol(name_snakecase, :_, field_name))(collection::$name, i::Integer)
                return collection.$field_name[i]
            end
        end)

        push!(getters, quote
            function $(Symbol(name_snakecase, :_, field_name))(inputs::AbstractInputs, i::Integer)
                return inputs.$(Symbol(name_snakecase)).$field_name[i]
            end
        end)
    end

    return esc(
        Expr(:block,
            [
                expression,
                getters...,
            ]...,
        ),
    )
end