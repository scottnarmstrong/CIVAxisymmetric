-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CIV.Main.InteriorAnalyticity
public import CKN.Statements.SpaceTimeSet
public import CIV.Statements.IsClassicalSolutionOn
public import CIV.Statements.LocallyUniformlyAnalyticOn

@[expose] public section

open MeasureTheory Set
open CKN.Foundation.Parabolic CKN

set_option autoImplicit false

noncomputable section

namespace CIV

/-- Theorem 2.1 (`thm:analytic:interior`, Kahane 1969): interior spatial analyticity. -/
theorem interiorAnalyticity (R t₁ t₂ : ℝ) (hR : 0 < R) (ht : t₁ < t₂)
    (u : ParabolicPoint → Vec3) (p : ParabolicPoint → ℝ) (f : ParabolicPoint → Vec3)
    (hsol : IsClassicalSolutionOn u p f (spaceTimeSet (vec3Ball 0 R) (Ioo t₁ t₂)))
    (hf : LocallyUniformlyAnalyticOn f R t₁ t₂) :
    LocallyUniformlyAnalyticOn u R t₁ t₂ :=
by exact CIV.Main.interiorAnalyticity R t₁ t₂ hR ht u p f hsol hf

end CIV
