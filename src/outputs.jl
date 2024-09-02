function initialize!(outputs::AbstractOutputs, path::AbstractString; kwargs...)
    field_names = fieldnames(typeof(outputs))

    for field_name in field_names
        output = getfield(outputs, field_name)
        initialize!(output, path; kwargs...)
    end

    return nothing
end

function write!(outputs::AbstractOutputs; kwargs...)
    field_names = fieldnames(typeof(outputs))

    for field_name in field_names
        output = getfield(outputs, field_name)
        write!(output; kwargs...)
    end

    return nothing
end

function finalize!(outputs::AbstractOutputs)
    field_names = fieldnames(typeof(outputs))

    for field_name in field_names
        output = getfield(outputs, field_name)
        finalize!(output)
    end

    return nothing
end
