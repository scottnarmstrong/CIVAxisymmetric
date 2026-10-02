-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Statements.AnalyticBoundOn

@[expose] public section

open Set
open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- Spatial analyticity of a field, locally uniformly on cylinders compactly contained in
`B(R) × (t₁, t₂)`: `eq:analytic:interior:force` / `eq:analytic:interior:velocity`. -/
def LocallyUniformlyAnalyticOn (g : ParabolicPoint → Vec3) (R t₁ t₂ : ℝ) : Prop :=
  ∀ R' : ℝ, R' < R → ∀ s₁ s₂ : ℝ, t₁ < s₁ → s₂ < t₂ →
    ∃ M a : ℝ, 0 < a ∧ AnalyticBoundOn g R' (Icc s₁ s₂) M a

end CIV
