-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import Mathlib.Analysis.Calculus.Deriv.Basic

@[expose] public section

set_option autoImplicit false

noncomputable section

namespace CIV

/-- `∂_r` of a function of `((r, z), t)`. -/
def dr (φ : (ℝ × ℝ) × ℝ → ℝ) (p : (ℝ × ℝ) × ℝ) : ℝ :=
  deriv (fun r => φ ((r, p.1.2), p.2)) p.1.1

end CIV
