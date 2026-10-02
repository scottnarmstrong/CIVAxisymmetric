-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import Mathlib.Analysis.Calculus.Deriv.Basic

@[expose] public section

set_option autoImplicit false

noncomputable section

namespace CIV

/-- `∂_z` of a function of `((r, z), t)`. -/
def dz (φ : (ℝ × ℝ) × ℝ → ℝ) (p : (ℝ × ℝ) × ℝ) : ℝ :=
  deriv (fun z => φ ((p.1.1, z), p.2)) p.1.2

end CIV
