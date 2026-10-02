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

/-- The spatial gradient of a test function paired with a vector. -/
def gradPair (m : ℕ) (φ : Vec m × ℝ → ℝ) (z : Vec m × ℝ) (v : Vec m) : ℝ :=
  fderiv ℝ (fun x : Vec m => φ (x, z.2)) z.1 v

end CIV
