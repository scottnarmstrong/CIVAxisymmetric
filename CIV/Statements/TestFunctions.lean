-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CKN.Foundation.Sobolev.Ambient.Basic
public import Mathlib.Analysis.Calculus.ContDiff.Operations
public import Mathlib.Data.Set.Prod

@[expose] public section

open Set
open CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- Test functions on `Vec m × ℝ` supported in `Vec m × I`. -/
def testFunctions (m : ℕ) (I : Set ℝ) : Set (Vec m × ℝ → ℝ) :=
  {φ | ContDiff ℝ (⊤ : ℕ∞) φ ∧ HasCompactSupport φ ∧ tsupport φ ⊆ univ ×ˢ I}

end CIV
