module BoundingBoxes

export BoundingBox, overlaps

import GeometryTypes
import GeometryTypes: overlaps
import GeometryTypes.vertices
import GeometryTypes.intersects
import GeometryTypes.contains
import GeometryTypes.widths
import GeometryTypes.isinside

using GeometryTypes: Point, Vec, HyperSphere, HyperRectangle

import Base.convert
using StaticArrays: SVector
import NaNMath

"Axis-aligned bounding box. Constructor doesn't check all(minimum .<= maximum)"
struct BoundingBox{N,T} <: GeometryTypes.AbstractGeometry{N, T}
  minimum::SVector{N,T}
  maximum::SVector{N,T}
end

convert(::Type{HyperRectangle}, bb::BoundingBox) = HyperRectangle(Vec(minlimit(bb)), Vec(widths(bb)))
function Base.convert(::Type{HyperRectangle{N, T}}, bb::BoundingBox) where {N, T}
  HyperRectangle(Vec{N, T}(minlimit(bb)), Vec{N, T}(widths(bb)))
end

# splatting definition. TODO really should apply for anything whose size is not inferrable
BoundingBox(mi::Vector, ma::Vector) = BoundingBox(promote(SVector(mi...), SVector(ma...))...)
BoundingBox(mi, ma) = BoundingBox(promote(convert(SVector, mi), convert(SVector, ma))...)

minlimit(b::BoundingBox) = b.minimum
maxlimit(b::BoundingBox) = b.maximum
dimlimits(b::BoundingBox{N}) where {N} = tuple(((b.minimum[i], b.maximum[i]) for i = 1:N)...)

function contains(bb::BoundingBox{N, T}, p::Point{N, T}) where {N, T}
  return all(maxlimit(bb) .>= p .>= minlimit(bb))
end

"""symmetric overlap relation"""
function overlaps(b1::BoundingBox{N}, b2::BoundingBox{N}) where {N}
  # can't exit early with broadcasting, but branching might be more expensive

  #= # this is equivalent by DeMorgan's, except that for NaN behavior
  disjoint_dimensions = all(maximum(b1) .< minimum(b2)) .| all(maximum(b2) .< minimum(b1))
  return !(any(disjoint_dimensions))
  =#
  overlap_dimensions = (maxlimit(b1) .≥ minlimit(b2)) .& (maxlimit(b2) .≥ minlimit(b1))
  return all(overlap_dimensions)
end

"make bounding box from array of points"
function BoundingBox(points::AbstractVector) #{PT}) where {T, PT<:AbstractArray{T,1}}
  # errors if length(points) == 0
  #all(length.(points) .== length(points[1]))  # Hope it is elided for static arrays. Doesn't work on iterators
  #mi, ma = extrema(points) # need to reduce over min., max.
  if length(points) == 0
    N = length(eltype(points))
    T = eltype(eltype(points))
    nan = nan(T)
    BoundingBox(fill(nan, N), fill(nan, N))
  end
  mi = reduce((x,y)->min.(x,y), points) # TODO sad for performance
  ma = reduce((x,y)->max.(x,y), points)

  # works on empty collections
  #mi = reduce((x,y)->NaNMath.min.(x,y), nanvector, points) # TODO sad for performance
  #ma = reduce((x,y)->NaNMath.max.(x,y), nanvector, points)

  return BoundingBox(mi, ma)
end

import Base.union
function union(b1::BoundingBox{N,T1}, b2::BoundingBox{N,T2}) where {N, T1, T2}
  # NaN represents empty.
  BoundingBox( NaNMath.min.(minlimit(b1), minlimit(b2)), NaNMath.max.(maxlimit(b1), maxlimit(b2)) )
end

BoundingBox(point::Point) = BoundingBox(point, point)
BoundingBox(s::HyperSphere) = BoundingBox(s.center .- s.r, s.center .+ s.r)
# TODO use a lazy (geometric)-union type from another package
#BoundingBox(u::Union{UnionOfConvex, UnionOfGeometry}) = reduce(union, map(BoundingBox, u.pieces))

"""is ball inside box"""
@inline function contains(box::BoundingBox{N, T}, ball::HyperSphere{N, T}) where {N, T}
  r = ball.r
  c = ball.center
  for i = 1:N
    if !(
        box.maximum[i] > c[i] + r   &&
        box.minimum[i] < c[i] - r
        )
      return false
    end
  end
  return true
end


@inline function center(box::BoundingBox)
  widths(box) / 2 + box.minimum
end

@inline function widths(box::BoundingBox)
  box.maximum - box.minimum
end


@inline vertices(box::BoundingBox) = vertices(HyperRectangle(minlimit(box)..., widths(box)...))


end # module
