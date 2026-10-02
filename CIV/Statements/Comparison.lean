-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Main.Comparison
public import CIV.Statements.IsAdmissibleDrift
public import CIV.Statements.IsDistributionalDriftDiffusion
public import CIV.Statements.IsLocallyBoundedOn
public import Mathlib.MeasureTheory.Function.LpSeminorm.Basic
public import Mathlib.Order.Interval.Set.OrdConnected

@[expose] public section

open MeasureTheory Set
open CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- Lemma 3.3 (`lem:aniso:comparison`), first assertion. -/
theorem comparison (m d : ℕ) (hd : 1 ≤ d ∧ d ≤ m) (I : Set ℝ)
    (hI : IsOpen I ∧ I.OrdConnected)
    (B : Vec m × ℝ → Vec m) (divB : Vec m × ℝ → ℝ) (hB : IsAdmissibleDrift m I B divB)
    (q : Vec m × ℝ → ℝ) (hq : IsLocallyBoundedOn m I q)
    (heq : IsDistributionalDriftDiffusion m d I B divB q) :
    ∀ᵐ τ₀ ∂(volume.restrict I), ∀ᵐ τ ∂(volume.restrict I), τ₀ < τ →
      eLpNorm (fun x => q (x, τ)) ⊤ volume ≤ eLpNorm (fun x => q (x, τ₀)) ⊤ volume :=
by exact CIV.Main.comparison m d hd I hI B divB hB q hq heq

end CIV
