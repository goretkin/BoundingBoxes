using BoundingBoxes
using Test

b_ref = BoundingBox([1.0, 1.0], [2.0, 2.0])
b_inside = BoundingBox([1.2, 1.2], [1.8, 1.8])
b_overlap1 = BoundingBox([1.8, 1.8], [2.2, 2.2])
b_overlap2 = BoundingBox([0.8, 0.8], [1.2, 1.2])
b_overlap3 = BoundingBox([1.8, 0.8], [2.2, 1.2])
b_overlap4 = BoundingBox([0.8, 1.8], [1.2, 2.2])
b_outside_all1 = BoundingBox([3.0, 3.0], [4.0, 4.0])
b_outside_all2 = BoundingBox([-4.0, -4.0], [-3.0, -3.0])
b_outside_all3 = BoundingBox([3.0, -4.0], [4.0, -3.0])
b_outside_all4 = BoundingBox([-4.0, 3.0], [-3.0, 4.0])
b_outside_partial1 = BoundingBox([1.1, 3.0], [2.1, 4.0])
b_outside_partial2 = BoundingBox([3.0, 1.1], [4.0, 2.1])
b_outside_partial3 = BoundingBox([1.2, 3.0], [1.8, 4.0])
b_outside_partial4 = BoundingBox([3.0, 1.2], [4.0, 1.8])
b_outside_inf = BoundingBox([3.0, 3.0], [Inf, Inf])
b_overlap_inf = BoundingBox([1.8, 1.8], [Inf, Inf])
b_overlap_inf2 = BoundingBox([-Inf, -Inf], [Inf, Inf])
b_empty = BoundingBox([NaN, NaN], [NaN, NaN])

b_true = [b_inside, b_overlap1, b_overlap2, b_overlap3, b_overlap4, b_overlap_inf, b_overlap_inf2]
b_false = [b_outside_all1, b_outside_all2, b_outside_all3, b_outside_all4, b_outside_partial1,
  b_outside_partial2, b_outside_partial3, b_outside_partial4, b_outside_inf, b_empty]

function overlap_sym(a, b, answer)
  @test overlaps(a, b)==answer
  @test overlaps(b, a)==answer
end

for b in b_true
  overlap_sym(b_ref, b, true)
end

for b in b_false
  overlap_sym(b_ref, b, false)
end

for b in vcat(b_true, b_false)
  overlap_sym(b_empty, b, false)
end
