-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CKN.Statements.SpatialPartial

@[expose] public section

open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The multi-index spatial derivative `∂_x^α g`. -/
def multiPartial (g : ParabolicPoint → ℝ) (α : Fin 3 → ℕ) : ParabolicPoint → ℝ :=
  (fun k => spatialPartial k 0)^[α 0]
    ((fun k => spatialPartial k 1)^[α 1] ((fun k => spatialPartial k 2)^[α 2] g))

end CIV
