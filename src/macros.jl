function build_doc_string(f::AbstractString, description::AbstractString)
    return """
    $f

$description
"""
end

function getters_string(;name::Symbol, name_snakecase::Symbol, function_name::Symbol, field_name::Symbol)
    getters = Expr[]

    description = "Get the value of the $field_name field from the $name collection."

    doc_string = build_doc_string("$function_name($name_snakecase::$name)", description)
    push!(getters, quote
        @doc $doc_string function $function_name($name_snakecase::$name)
            return $name_snakecase.$field_name
        end
    end)

    doc_string = build_doc_string("$function_name(collections::AbstractCollections)", description)
    push!(getters, quote
        @doc $doc_string function $function_name(collections::AbstractCollections)
            return $function_name(collections.$name_snakecase)
        end
    end)

    doc_string = build_doc_string("$function_name(inputs::AbstractInputs)", description)
    push!(getters, quote
        @doc $doc_string function $function_name(inputs::AbstractInputs)
            return $function_name(inputs.collections.$name_snakecase)
        end
    end)

    return getters
end

function getters_callable(;name::Symbol, name_snakecase::Symbol, function_name::Symbol, field_name::Symbol)
    getters = Expr[]

    description = "Get the value of the $field_name field from the $name collection."

    doc_string = build_doc_string("$function_name($name_snakecase::$name)", description)
    push!(getters, quote
        @doc $doc_string function $function_name($name_snakecase::$name)
            return $name_snakecase.$field_name()
        end
    end)

    doc_string = build_doc_string("$function_name(collections::AbstractCollections)", description)
    push!(getters, quote
        @doc $doc_string function $function_name(collections::AbstractCollections)
            return $function_name(collections.$name_snakecase)
        end
    end)

    doc_string = build_doc_string("$function_name(inputs::AbstractInputs)", description)
    push!(getters, quote
        @doc $doc_string function $function_name(inputs::AbstractInputs)
            return $function_name(inputs.collections.$name_snakecase)
        end
    end)

    return getters
end

function getters_vector(;name::Symbol, name_snakecase::Symbol, function_name::Symbol, field_name::Symbol)
    getters = Expr[]

    description = "Get the value of the $field_name field from the $name collection at index i."

    doc_string = build_doc_string("$function_name($name_snakecase::$name, i::Integer)", description)
    push!(getters, quote
        @doc $doc_string function $function_name($name_snakecase::$name, i::Integer)
            return $name_snakecase.$field_name[i]
        end
    end)

    doc_string = build_doc_string("$function_name(collections::AbstractCollections, i::Integer)", description)
    push!(getters, quote
        @doc $doc_string function $function_name(collections::AbstractCollections, i::Integer)
            return $function_name(collections.$name_snakecase, i)
        end
    end)

    doc_string = build_doc_string("$function_name(inputs::AbstractInputs, i::Integer)", description)
    push!(getters, quote
        @doc $doc_string function $function_name(inputs::AbstractInputs, i::Integer)
            return $function_name(inputs.collections.$name_snakecase, i)
        end
    end)

    return getters
end

function getters_collection(; name_snakecase::Symbol)
    getters = Expr[]

    length_function_name = Symbol(name_snakecase, "_length")

    push!(getters, quote
        function $length_function_name(collections::AbstractCollections)
            return length(collections.$name_snakecase)
        end
    end)

    push!(getters, quote
        function $length_function_name(inputs::AbstractInputs)
            return length(inputs.collections.$name_snakecase)
        end
    end)

    indices_function_name = Symbol(name_snakecase, "_indices")

    push!(getters, quote
        function $indices_function_name(inputs::AbstractInputs)
            return collect(1:$length_function_name(inputs))
        end
    end)

    return getters
end

macro collection(expression)
    @capture(expression, @kwdef mutable struct name_ <: AbstractCollection fields__ end) ||
        error("Expected @collection @kwdef mutable struct name <: AbstractCollection fields... end, got $expression")

    name_snakecase = Symbol(NamingConventions.convert(PascalCase, SnakeCase, string(name)))

    getters = Expr[]

    push!(getters, 
        getters_collection(name_snakecase = name_snakecase)...
    )

    for field in fields
        @capture(field, field_name_::field_type_ = constructor_) ||
            error("Expected field_name::field_type = constructor, got $field")

        if String(field_name)[1] == '_'
            continue
        end

        function_name = Symbol(name_snakecase, :_, field_name)

        if field_type == :String
            push!(getters, 
                getters_string(name = name, name_snakecase = name_snakecase, function_name = function_name, field_name = field_name)...
            )
        elseif field_type == :TimeSeriesFileData
            push!(getters, 
                getters_callable(name = name, name_snakecase = name_snakecase, function_name = function_name, field_name = field_name)...
            )
        else
            push!(getters, 
                getters_vector(name = name, name_snakecase = name_snakecase, function_name = function_name, field_name = field_name)...
            )
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