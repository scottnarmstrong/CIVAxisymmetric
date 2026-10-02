-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Identities.Axisymmetric

/-!
# The divergence of an axisymmetric field in cylindrical form

On the meridional plane `{x₂ = 0}` away from the axis, the Cartesian divergence of a
smooth axisymmetric field is the cylindrical divergence `∂_r u_r + u_r/r + ∂_z u_z`, the
left-hand side of `eq:aniso:scalar:nse:div`. The only input is the `θ`-derivative
relation `∂₂u₂ = u_r/r` of `spatialPartial_one_one_meridional`; the identity is pointwise
and does not use the equation.
-/

@[expose] public section

open CKN.Foundation.Parabolic CKN

set_option autoImplicit false
noncomputable section

namespace CIV

/-- On the meridional plane, off the axis, the Cartesian divergence of a smooth axisymmetric
field is the cylindrical divergence of `eq:aniso:scalar:nse:div`. -/
theorem sum_spatialPartial_meridional {u : ParabolicPoint → Vec3}
    (h : IsAxisymmetricOn u unitCylinder)
    (hu : ContDiffOn ℝ 1 (fun z : Vec3 × ℝ => u z) unitCylinder) {z : ParabolicPoint}
    (hz : z ∈ unitCylinder) (hplane : z.1 1 = 0) (hr : z.1 0 ≠ 0) :
    ∑ j : Fin 3, spatialPartial (fun w => u w j) j z
      = spatialPartial (fun w => u w 0) 0 z + u z 0 / z.1 0
        + spatialPartial (fun w => u w 2) 2 z := by
  rw [Fin.sum_univ_three, spatialPartial_one_one_meridional h hu hz hplane hr]

end CIV
