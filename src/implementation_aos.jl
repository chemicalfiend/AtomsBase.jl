#
# Implementation of AtomsBase interface in an array-of-structs style
#

using StaticArrays

export FlexibleSystem

# TODO Switch order of type arguments?
struct FlexibleSystem{D,S,L<:Unitful.Length,AT} <: AbstractSystem{D,S}
    box::SVector{D,<:SVector{D,L}}
    boundary_conditions::SVector{D,<:BoundaryCondition}
    particles::Vector{AT}
    FlexibleSystem(box, boundary_conditions, particles) = new{
        length(boundary_conditions),
        eltype(elements),
        eltype(eltype(box)),
        eltype(particles),
    }(
        box,
        boundary_conditions,
        particles,
    )
end
# convenience constructor where we don't have to preconstruct all the static stuff...
function FlexibleSystem(
    box::Vector{<:AbstractVector{L}},
    boundary_conditions::Vector{BC},
    particles::Vector{AT},
) where {BC<:BoundaryCondition,L<:Unitful.Length,AT}
    D = length(box)
    if !all(length.(box) .== D)
        throw(ArgumentError("box must have D vectors of length D"))
    end
    FlexibleSystem(
        SVector{D,SVector{D,L}}(box),
        SVector{D,BoundaryCondition}(boundary_conditions),
        particles,
    )
end

bounding_box(sys::FlexibleSystem) = sys.box
boundary_conditions(sys::FlexibleSystem) = sys.boundary_conditions

function Base.show(io::IO, sys::FlexibleSystem)
    print(io, "FlexibleSystem with ", length(sys), " particles")
end

Base.size(sys::FlexibleSystem) = size(sys.particles)
Base.length(sys::FlexibleSystem) = length(sys.particles)
Base.getindex(sys::FlexibleSystem, i::Int) = getindex(sys.particles, i)