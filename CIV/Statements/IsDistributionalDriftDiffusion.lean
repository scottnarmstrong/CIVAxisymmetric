-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Statements.GradPair
public import CIV.Statements.PartialLaplacian
public import CIV.Statements.TestFunctions
public import CIV.Statements.TimeDeriv
public import Mathlib.MeasureTheory.Constructions.Pi
public import Mathlib.MeasureTheory.Integral.Bochner.Basic
public import Mathlib.MeasureTheory.Integral.IntegrableOn
public import Mathlib.MeasureTheory.Measure.Lebesgue.Basic
public import Mathlib.MeasureTheory.Measure.Prod

@[expose] public section

open MeasureTheory
open CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- `∂_τ q + B·∇q = Δ_X q` on `Vec m × I` in the sense of distributions, with
`B·∇q = div(Bq) - (div B) q` (footnote to `eq:aniso:comparison:equation`), the divergence
`div B` of the drift being carried as data (design note N5). -/
def IsDistributionalDriftDiffusion (m d : ℕ) (I : Set ℝ) (B : Vec m × ℝ → Vec m)
    (divB : Vec m × ℝ → ℝ) (q : Vec m × ℝ → ℝ) : Prop :=
  ∀ φ ∈ testFunctions m I,
    IntegrableOn (fun z => q z * (-(timeDeriv m φ z) - gradPair m φ z (B z) - divB z * φ z -
      partialLaplacian m d φ z)) (tsupport φ) volume ∧
    ∫ z, q z * (-(timeDeriv m φ z) - gradPair m φ z (B z) - divB z * φ z -
      partialLaplacian m d φ z) = 0

end CIV
