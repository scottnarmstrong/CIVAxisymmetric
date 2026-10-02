-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Statements.MultiPartial
public import Mathlib.Analysis.SpecialFunctions.Pow.Real

@[expose] public section

open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The analyticity bound `eq:analytic:interior:force` for a field `g` on `B(R') × J`
with constants `M`, `a`. -/
def AnalyticBoundOn (g : ParabolicPoint → Vec3) (R' : ℝ) (J : Set ℝ) (M a : ℝ) : Prop :=
  ∀ α : Fin 3 → ℕ, ∀ t ∈ J, ∀ x ∈ vec3Ball 0 R', ∀ i : Fin 3,
    |multiPartial (fun w => g w i) α (x, t)| ≤
      M * a ^ (-((α 0 + α 1 + α 2 : ℕ) : ℝ)) * Nat.factorial (α 0 + α 1 + α 2)

end CIV
