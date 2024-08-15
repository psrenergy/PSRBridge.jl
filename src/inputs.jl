function initialize!(inputs::AbstractInputs; kwargs...)
    initialize!(inputs.collections, inputs.db; kwargs...)
    return nothing
end

function update!(inputs::AbstractInputs; kwargs...)
    update!(inputs.collections, inputs.db; kwargs...)
    return nothing
end

function finalize!(inputs::AbstractInputs)
    finalize!(inputs.collections)
    return nothing
end
