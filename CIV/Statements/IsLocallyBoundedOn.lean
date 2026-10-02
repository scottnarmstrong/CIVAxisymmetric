-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CKN.Foundation.Sobolev.Ambient.Basic
public import Mathlib.Data.Set.Prod
public import Mathlib.MeasureTheory.Constructions.Pi
public import Mathlib.MeasureTheory.Function.StronglyMeasurable.AEStronglyMeasurable
public import Mathlib.MeasureTheory.Measure.Lebesgue.Basic
public import Mathlib.MeasureTheory.Measure.Prod

@[expose] public section

open MeasureTheory Set
open CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- `q ∈ L^∞_loc(I; L^∞(ℝ^m))`. -/
def IsLocallyBoundedOn (m : ℕ) (I : Set ℝ) (q : Vec m × ℝ → ℝ) : Prop :=
  AEStronglyMeasurable q (volume.restrict (univ ×ˢ I)) ∧
    ∀ J : Set ℝ, IsCompact J → J ⊆ I → ∃ M : ℝ, ∀ᵐ z ∂(volume.restrict (univ ×ˢ J)), |q z| ≤ M

end CIV
