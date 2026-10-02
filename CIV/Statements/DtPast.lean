-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import Mathlib.Analysis.Calculus.Deriv.Basic

@[expose] public section

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The one-sided (from the past) time derivative of a function of `((r, z), t)`. -/
def dtPast (φ : (ℝ × ℝ) × ℝ → ℝ) (p : (ℝ × ℝ) × ℝ) : ℝ :=
  derivWithin (fun t => φ (p.1, t)) (Set.Iic p.2) p.2

end CIV
