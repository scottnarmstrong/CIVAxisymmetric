-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import Mathlib.Basic.Real.Basic

@[expose] public section

set_option autoImplicit false

noncomputable section

namespace CIV

/-- The half-disc `{r > 0, r² + z² < R²}` with the times `(t₁, s]`: the set `D` of
`lem:aniso:axis`. -/
def axisDomain (R t₁ s : ℝ) : Set ((ℝ × ℝ) × ℝ) :=
  {p | 0 < p.1.1 ∧ p.1.1 ^ 2 + p.1.2 ^ 2 < R ^ 2 ∧ t₁ < p.2 ∧ p.2 ≤ s}

end CIV
