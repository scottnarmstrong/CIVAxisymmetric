-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Comparison.ComparisonLimits

@[expose] public section

open MeasureTheory
open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The squared `L²` mass of the DiPerna–Lions commutator on a ball is nonnegative. -/
theorem commutatorL2Sq_nonneg {m : ℕ} (ε Rb : ℝ) (B : Vec m × ℝ → Vec m) (divB q : Vec m × ℝ → ℝ)
    (s : ℝ) : 0 ≤ commutatorL2Sq m ε Rb B divB q s := by
  unfold commutatorL2Sq
  refine MeasureTheory.setIntegral_nonneg measurableSet_closedBall ?_
  intro x hx
  apply sq_nonneg

end CIV
