-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Main.ComparisonAncient
public import CIV.Statements.IsAdmissibleDrift
public import CIV.Statements.IsDistributionalDriftDiffusion
public import CIV.Statements.IsLocallyBoundedOn
public import Mathlib.Analysis.SpecialFunctions.Pow.Real
public import Mathlib.MeasureTheory.Function.LpSeminorm.Basic

@[expose] public section

open MeasureTheory Set
open scoped ENNReal
open CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- Lemma 3.3 (`lem:aniso:comparison`), ancient assertion with the decay
`eq:aniso:ancient:decay`. -/
theorem comparisonAncient (m d : ℕ) (hd : 1 ≤ d ∧ d ≤ m) (T : ℝ)
    (B : Vec m × ℝ → Vec m) (divB : Vec m × ℝ → ℝ) (hB : IsAdmissibleDrift m (Iio T) B divB)
    (q : Vec m × ℝ → ℝ) (hq : IsLocallyBoundedOn m (Iio T) q)
    (heq : IsDistributionalDriftDiffusion m d (Iio T) B divB q)
    (C κ : ℝ) (hκ : 0 < κ)
    (hdecay : ∀ᵐ τ ∂(volume.restrict (Iio (min (-1) T))),
      eLpNorm (fun x => q (x, τ)) ⊤ volume ≤ ENNReal.ofReal (C * |τ| ^ (-κ))) :
    (∀ᵐ z ∂(volume.restrict (univ ×ˢ Iio T)), q z = 0) ∧
      ∀ (V : Set (Vec m × ℝ)) (q' : Vec m × ℝ → ℝ), IsOpen V →
        ContinuousOn q' (V ∩ univ ×ˢ Iic T) →
        (∀ᵐ z ∂(volume.restrict (V ∩ univ ×ˢ Iio T)), q' z = q z) →
        ∀ z ∈ V ∩ univ ×ˢ Iic T, q' z = 0 :=
by exact CIV.Main.comparisonAncient m d hd T B divB hB q hq heq C κ hκ hdecay

end CIV
