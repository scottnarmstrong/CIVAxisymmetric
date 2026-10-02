-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Statements.MultiPartial
public import Mathlib.Analysis.SpecialFunctions.Pow.Real

@[expose] public section

open Set
open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- Spatial real analyticity of the force, locally uniformly on cylinders compactly contained
in `Q`, `eq:interior:force:analytic`. -/
def ForceSpatiallyAnalytic (f : ParabolicPoint → Vec3) : Prop :=
  ∀ R : ℝ, R < 1 → ∀ t₁ t₂ : ℝ, -1 < t₁ → t₂ < 0 →
    ∃ M a : ℝ, 0 < a ∧ ∀ α : Fin 3 → ℕ, ∀ t ∈ Icc t₁ t₂, ∀ x ∈ vec3Ball 0 R, ∀ i : Fin 3,
      |multiPartial (fun w => f w i) α (x, t)| ≤
        M * a ^ (-((α 0 + α 1 + α 2 : ℕ) : ℝ)) * Nat.factorial (α 0 + α 1 + α 2)

end CIV
