-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CKN.Statements.SpatialPartial
public import CKN.Statements.SpatialSecondPartial
public import CKN.Statements.TimePartial
public import Mathlib.Analysis.Calculus.ContDiff.Basic

@[expose] public section

open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- A classical solution of the forced Navier–Stokes equations `eq:nse:forced` on an open
space-time set: smooth fields satisfying the momentum and divergence equations pointwise. -/
def IsClassicalSolutionOn (u : ParabolicPoint → Vec3) (p : ParabolicPoint → ℝ)
    (f : ParabolicPoint → Vec3) (S : Set ParabolicPoint) : Prop :=
  ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => u z) S ∧
    ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => p z) S ∧
    ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => f z) S ∧
    (∀ z ∈ S, ∀ i : Fin 3,
      timePartial (fun w => u w i) z + ∑ j, u z j * spatialPartial (fun w => u w i) j z -
          ∑ j, spatialSecondPartial (fun w => u w i) j j z + spatialPartial p i z = f z i) ∧
    ∀ z ∈ S, ∑ j, spatialPartial (fun w => u w j) j z = 0

end CIV
