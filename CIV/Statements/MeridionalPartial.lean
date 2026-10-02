-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CKN.Statements.SpatialPartial

@[expose] public section

open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The iterated classical partial derivative `∂₁^a ∂₃^b g`. On the meridional plane it is
`±∂_r^a ∂_z^b g` for an axisymmetric scalar `g` (design note R4). -/
def meridionalPartial (g : ParabolicPoint → ℝ) (a b : ℕ) : ParabolicPoint → ℝ :=
  (fun k => spatialPartial k 0)^[a] ((fun k => spatialPartial k 2)^[b] g)

end CIV
