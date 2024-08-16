macro collection(expression)
    @capture(expression, @kwdef mutable struct name_ <: AbstractCollection fields__ end) ||
        error("Expected @collection @kwdef mutable struct name <: AbstractCollection fields... end, got $expression")

    name_snakecase = Symbol(NamingConventions.convert(PascalCase, SnakeCase, string(name)))

    getters = Expr[]

    for field in fields
        @capture(field, field_name_::field_type_ = constructor_) ||
            error("Expected field_name::field_type = constructor, got $field")

        if field_name == :id
            continue
        end

        function_name = Symbol(name_snakecase, :_, field_name)

        if field_type == :String
            doc_string = 
"""
    $function_name(collection::$name)

Get the value of the $field_name field from the $name collection.
"""
            push!(getters, quote
                @doc $doc_string function $function_name(collection::$name)
                    return collection.$field_name
                end
            end)

            doc_string = 
"""
    $function_name(collections::AbstractCollections)

Get the value of the $field_name field from the $name collection.
"""            
            push!(getters, quote
                @doc $doc_string function $function_name(collections::AbstractCollections)
                    return collections.$name_snakecase.$field_name
                end
            end)

            doc_string = 
"""
    $function_name(inputs::AbstractInputs)

Get the value of the $field_name field from the $name collection.
"""                   
            push!(getters, quote
                @doc $doc_string function $function_name(inputs::AbstractInputs)
                    return inputs.collections.$name_snakecase.$field_name
                end
            end)            
        else
            doc_string = 
"""
    $function_name(collection::$name, i::Integer)

Get the value of the $field_name field from the $name collection at index i.
"""             
            push!(getters, quote
                @doc $doc_string function $function_name(collection::$name, i::Integer)
                    return collection.$field_name[i]
                end
            end)

            doc_string = 
"""
    $function_name(collections::AbstractCollections, i::Integer)

Get the value of the $field_name field from the $name collection at index i.
"""                
            push!(getters, quote
                @doc $doc_string function $function_name(collections::AbstractCollections, i::Integer)
                    return collections.$name_snakecase.$field_name[i]
                end
            end)

            doc_string = 
"""
    $function_name(inputs::AbstractInputs, i::Integer)

Get the value of the $field_name field from the $name collection at index i.
"""         
            push!(getters, quote           
                @doc $doc_string function $function_name(inputs::AbstractInputs, i::Integer)
                    return inputs.collections.$name_snakecase.$field_name[i]
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