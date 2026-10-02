-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CKN.Foundation.Parabolic.Basic

@[expose] public section

open CKN.Foundation.Parabolic

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The point `(x₁, 0, x₃)` of the meridional plane `{x₂ = 0}`. -/
def meridional (x₁ x₃ : ℝ) : Vec3 := ![x₁, 0, x₃]

end CIV
