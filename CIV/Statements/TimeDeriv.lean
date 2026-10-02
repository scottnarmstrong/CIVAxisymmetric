-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CKN.Foundation.Sobolev.Ambient.Basic
public import Mathlib.Analysis.Calculus.FDeriv.Basic

@[expose] public section

open CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The time derivative of a test function on `Vec m × ℝ`. -/
def timeDeriv (m : ℕ) (φ : Vec m × ℝ → ℝ) (z : Vec m × ℝ) : ℝ :=
  fderiv ℝ (fun τ : ℝ => φ (z.1, τ)) z.2 1

end CIV
