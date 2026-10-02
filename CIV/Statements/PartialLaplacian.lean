-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CKN.Foundation.Sobolev.Ambient.Basis
public import Mathlib.Analysis.Calculus.FDeriv.Basic

@[expose] public section

open CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The Laplacian in the first `d` coordinates of a test function on `Vec m × ℝ`. -/
def partialLaplacian (m d : ℕ) (φ : Vec m × ℝ → ℝ) (z : Vec m × ℝ) : ℝ :=
  ∑ i : Fin m, if (i : ℕ) < d then
    fderiv ℝ (fun x : Vec m => fderiv ℝ (fun y : Vec m => φ (y, z.2)) x (basisVec i)) z.1
      (basisVec i)
  else 0

end CIV
