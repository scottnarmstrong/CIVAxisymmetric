-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Statements.IsAdmissibleDrift

@[expose] public section

open MeasureTheory Set
open CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- Extract the weak divergence identity from an `IsAdmissibleDrift` hypothesis.
For almost every `τ ∈ J` the slice `B(·, τ)` has `divB(·, τ)` as its weak divergence:
`∫ divB(·,τ) ψ = -∫ ∑ᵢ B(·,τ)ᵢ (∂ᵢψ)`. -/
theorem isAdmissibleDrift_weak_divergence {m : ℕ} {I : Set ℝ} {B : Vec m × ℝ → Vec m}
    {divB : Vec m × ℝ → ℝ} (hB : IsAdmissibleDrift m I B divB) {J : Set ℝ} (hJ : IsCompact J)
    (hJI : J ⊆ I) :
    ∀ᵐ τ ∂(volume.restrict J), ∀ ψ : Vec m → ℝ, ContDiff ℝ (⊤ : ℕ∞) ψ → HasCompactSupport ψ →
      ∫ x, divB (x, τ) * ψ x = -∫ x, ∑ i, B (x, τ) i * fderiv ℝ ψ x (basisVec i) := by
  obtain ⟨_, _, hrest⟩ := hB
  obtain ⟨_, hΛ⟩ := hrest J hJ hJI
  filter_upwards [hΛ] with τ hτ
  exact hτ.2.2.2

end CIV
