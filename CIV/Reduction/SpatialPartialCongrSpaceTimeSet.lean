-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import CKN.Statements.SpatialPartial
public import CKN.Statements.SpatialSecondPartial
public import CKN.Statements.TimePartial
public import CKN.Statements.SpaceTimeSet
public import CKN.Foundation.Parabolic.Topology

@[expose] public section

open Set
open CKN.Foundation.Parabolic CKN

set_option autoImplicit false
noncomputable section

namespace CIV

/-- Pointwise agreement of two scalar fields on an open space-time cylinder transports a
spatial partial derivative. These lemmas generalize `CIV.spatialPartial_congr_of_eqOn`
(CIV/Reduction/AveragedClassical.lean) from the unit cylinder to an arbitrary open
cylinder `spaceTimeSet Ω I`, needed to differentiate the momentum equation of a classical
solution on the general cylinder that `thm:analytic:interior` is stated on. -/
theorem spatialPartial_congr_of_eqOn_spaceTimeSet {v u : ParabolicPoint → ℝ} {Ω : Set Vec3}
    {I : Set ℝ} (hΩ : IsOpen Ω) (hI : IsOpen I)
    (h : ∀ w ∈ spaceTimeSet Ω I, v w = u w) {z : ParabolicPoint} (hz : z ∈ spaceTimeSet Ω I)
    (j : Fin 3) :
    spatialPartial v j z = spatialPartial u j z := by
  have _ := hI.mem_nhds hz.2
  show fderiv ℝ (fun y : Vec3 => v (y, z.2)) z.1 (basisVec j)
    = fderiv ℝ (fun y : Vec3 => u (y, z.2)) z.1 (basisVec j)
  have hev : (fun y : Vec3 => v (y, z.2)) =ᶠ[nhds z.1] (fun y : Vec3 => u (y, z.2)) := by
    filter_upwards [hΩ.mem_nhds hz.1] with y hy using h (y, z.2) ⟨hy, hz.2⟩
  rw [hev.fderiv_eq]

/-- Pointwise agreement of two scalar fields on an open space-time cylinder transports the
time partial derivative. -/
theorem timePartial_congr_of_eqOn_spaceTimeSet {v u : ParabolicPoint → ℝ} {Ω : Set Vec3}
    {I : Set ℝ} (hΩ : IsOpen Ω) (hI : IsOpen I)
    (h : ∀ w ∈ spaceTimeSet Ω I, v w = u w) {z : ParabolicPoint} (hz : z ∈ spaceTimeSet Ω I) :
    timePartial v z = timePartial u z := by
  have _ := hΩ.mem_nhds hz.1
  show fderiv ℝ (fun s : ℝ => v (z.1, s)) z.2 1 = fderiv ℝ (fun s : ℝ => u (z.1, s)) z.2 1
  have hev : (fun s : ℝ => v (z.1, s)) =ᶠ[nhds z.2] (fun s : ℝ => u (z.1, s)) := by
    filter_upwards [hI.mem_nhds hz.2] with s hs using h (z.1, s) ⟨hz.1, hs⟩
  rw [hev.fderiv_eq]

/-- Pointwise agreement of two scalar fields on an open space-time cylinder transports a
second spatial partial derivative. -/
theorem spatialSecondPartial_congr_of_eqOn_spaceTimeSet {v u : ParabolicPoint → ℝ} {Ω : Set Vec3}
    {I : Set ℝ} (hΩ : IsOpen Ω) (hI : IsOpen I)
    (h : ∀ w ∈ spaceTimeSet Ω I, v w = u w) {z : ParabolicPoint} (hz : z ∈ spaceTimeSet Ω I)
    (i j : Fin 3) :
    spatialSecondPartial v i j z = spatialSecondPartial u i j z :=
  spatialPartial_congr_of_eqOn_spaceTimeSet hΩ hI
    (fun _w hw => spatialPartial_congr_of_eqOn_spaceTimeSet hΩ hI h hw i) hz j

end CIV
