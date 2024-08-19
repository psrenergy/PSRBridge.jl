module PSRBridge

using Dates
using MacroTools
using NamingConventions
using Random
using Serialization

import PSRClassesInterface as PSRI

const PSRDatabaseSQLite = PSRI.PSRDatabaseSQLite
const DatabaseSQLite = PSRI.PSRDatabaseSQLite.DatabaseSQLite

export
    AbstractInputs,
    AbstractCollection,
    AbstractCollections,
    AbstractData,
    AdjustedVectorData,
    MapData,
    StaticVectorData,
    TimeSeriesData,
    Cache,
    initialize!,
    update!,
    adjust!,
    finalize!,
    @collection

include("abstract.jl")
include("data/adjusted_vector.jl")
include("data/any.jl")
include("data/map.jl")
include("data/static_vector.jl")
include("data/time_series.jl")
include("collection.jl")
include("collections.jl")
include("inputs.jl")
include("cache.jl")
include("macros.jl")

function __init__()
    return nothing
end

end
