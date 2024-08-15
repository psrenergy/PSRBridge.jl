macro collection(expression)
    @capture(expression, @kwdef mutable struct name_ <: AbstractCollection fields__ end) ||
        error("Expected @collection @kwdef mutable struct name <: AbstractCollection fields... end, got $expression")

    name_snakecase = NamingConventions.convert(PascalCase, SnakeCase, string(name))

    getters = Expr[]

    for field in fields
        @capture(field, field_name_::field_type_ = constructor_) ||
            error("Expected field_name::field_type = constructor, got $field")

        if field_name == :id
            continue
        end

        if field_type == :String
            push!(getters, quote
                function $(Symbol(name_snakecase, :_, field_name))(collection::$name)
                    return collection.$field_name
                end
            end)

            push!(getters, quote
                function $(Symbol(name_snakecase, :_, field_name))(collections::AbstractCollections)
                    return collections.$(Symbol(name_snakecase)).$field_name
                end
            end)

            push!(getters, quote
                function $(Symbol(name_snakecase, :_, field_name))(inputs::AbstractInputs)
                    return inputs.collections.$(Symbol(name_snakecase)).$field_name
                end
            end)            
        else
            push!(getters, quote
                function $(Symbol(name_snakecase, :_, field_name))(collection::$name, i::Integer)
                    return collection.$field_name[i]
                end
            end)

            push!(getters, quote
                function $(Symbol(name_snakecase, :_, field_name))(collections::AbstractCollections, i::Integer)
                    return collections.$(Symbol(name_snakecase)).$field_name[i]
                end
            end)

            push!(getters, quote
                function $(Symbol(name_snakecase, :_, field_name))(inputs::AbstractInputs, i::Integer)
                    return inputs.collections.$(Symbol(name_snakecase)).$field_name[i]
                end
            end)
        end
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