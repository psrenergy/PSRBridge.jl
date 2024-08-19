macro collection(expression)
    @capture(expression, @kwdef mutable struct name_ <: AbstractCollection fields__ end) ||
        error("Expected @collection @kwdef mutable struct name <: AbstractCollection fields... end, got $expression")

    name_snakecase = Symbol(NamingConventions.convert(PascalCase, SnakeCase, string(name)))

    getters = Expr[]

    for field in fields
        @capture(field, field_name_::field_type_ = constructor_) ||
            error("Expected field_name::field_type = constructor, got $field")

        if String(field_name)[1] == '_'
            continue
        end

        function_name = Symbol(name_snakecase, :_, field_name)

        if field_type == :String
            description = "Get the value of the $field_name field from the $name collection."

            doc_string = 
"""
    $function_name($name_snakecase::$name)

$description
"""
            push!(getters, quote
                @doc $doc_string function $function_name($name_snakecase::$name)
                    return $name_snakecase.$field_name
                end
            end)

            doc_string = 
"""
    $function_name(collections::AbstractCollections)

$description
"""            
            push!(getters, quote
                @doc $doc_string function $function_name(collections::AbstractCollections)
                    return $function_name(collections.$name_snakecase)
                end
            end)

            doc_string = 
"""
    $function_name(inputs::AbstractInputs)

$description
"""                   
            push!(getters, quote
                @doc $doc_string function $function_name(inputs::AbstractInputs)
                    return $function_name(inputs.collections.$name_snakecase)
                end
            end)
        else
            description = "Get the value of the $field_name field from the $name collection at index i."

            doc_string = 
"""
    $function_name($name_snakecase::$name, i::Integer)

$description
"""             
            push!(getters, quote
                @doc $doc_string function $function_name($name_snakecase::$name, i::Integer)
                    return $name_snakecase.$field_name[i]
                end
            end)

            doc_string = 
"""
    $function_name(collections::AbstractCollections, i::Integer)

$description
"""                
            push!(getters, quote
                @doc $doc_string function $function_name(collections::AbstractCollections, i::Integer)
                    return $function_name(collections.$name_snakecase, i)
                end
            end)

            doc_string = 
"""
    $function_name(inputs::AbstractInputs, i::Integer)

$description
"""         
            push!(getters, quote
                @doc $doc_string function $function_name(inputs::AbstractInputs, i::Integer)
                    return $function_name(inputs.collections.$name_snakecase, i)
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