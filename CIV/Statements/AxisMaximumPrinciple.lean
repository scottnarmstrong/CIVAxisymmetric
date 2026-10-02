-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Axis.MaximumPrinciple
public import CIV.Statements.AxisClosedDomain
public import CIV.Statements.AxisDomain
public import CIV.Statements.AxisParabolicBoundary
public import CIV.Statements.Dr
public import CIV.Statements.DtPast
public import CIV.Statements.Dz
public import Mathlib.Analysis.Calculus.ContDiff.Basic

@[expose] public section

open Set

set_option autoImplicit false

noncomputable section

namespace CIV

/-- Lemma 3.1 (`lem:aniso:axis`): maximum principle for functions vanishing on the axis. -/
theorem axisMaximumPrinciple (R t₁ s k M : ℝ) (hR : 0 < R) (hts : t₁ < s) (hM : 0 ≤ M)
    (φ br bz γ F : (ℝ × ℝ) × ℝ → ℝ)
    (hcont : ContinuousOn φ (axisClosedDomain R t₁ s))
    (haxis : ∀ z t : ℝ, |z| ≤ R → t₁ ≤ t → t ≤ s → φ ((0, z), t) = 0)
    (hreg : ∀ p ∈ axisDomain R t₁ s,
      ContDiffAt ℝ 2 (fun y : ℝ × ℝ => φ (y, p.2)) p.1 ∧
        DifferentiableWithinAt ℝ (fun t => φ (p.1, t)) (Iic p.2) p.2)
    (hγ : ∀ p ∈ axisDomain R t₁ s, 0 ≤ γ p)
    (hF : ∀ p ∈ axisDomain R t₁ s, |F p| ≤ M)
    (hpde : ∀ p ∈ axisDomain R t₁ s,
      dtPast φ p + br p * dr φ p + bz p * dz φ p + γ p * φ p =
        dr (dr φ) p + k / p.1.1 * dr φ p + dz (dz φ) p + F p) :
    ∀ m : ℝ, (∀ p ∈ axisParabolicBoundary R t₁ s, |φ p| ≤ m) →
      ∀ p ∈ axisClosedDomain R t₁ s, |φ p| ≤ m + M * (p.2 - t₁) :=
by exact CIV.axisMaximumPrinciple_of_profile R t₁ s k M hR hts hM φ br bz γ F hcont haxis hreg hγ hF hpde

end CIV
