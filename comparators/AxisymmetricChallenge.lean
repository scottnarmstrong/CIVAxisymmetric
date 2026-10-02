-- Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
-- Released under Apache 2.0 license.

module

public import Mathlib.Analysis.Calculus.ContDiff.Operations
public import Mathlib.Analysis.Calculus.FDeriv.Add
public import Mathlib.Analysis.SpecialFunctions.Pow.Real
public import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
public import Mathlib.MeasureTheory.Function.LpSeminorm.Basic
public import Mathlib.MeasureTheory.Integral.Bochner.Set
public import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
public import Mathlib.MeasureTheory.Measure.Lebesgue.Basic
public import Mathlib.MeasureTheory.Measure.Prod

/-!
# Regularity of asymptotically axisymmetric Navier–Stokes solutions

Theorems 1.1 (`thm:main`) and 1.3 (`thm:aniso:main`), Proposition 1.5
(`prop:aniso:small`), Theorem 2.1 (`thm:analytic:interior`) and Corollary 2.3
(`cor:interior:nonanalytic`) of Constantin–Ignatova–Vicol, arXiv:2609.20803,
with every definition they mention stated from Mathlib alone. The five theorem
proofs are intentional placeholders. Comparator compares this environment with
`AxisymmetricSolution.lean`, which proves the same named declarations from the library.

Space is `Fin 3 → ℝ`; Euclidean lengths are written out as square roots of sums
of squares. Space-time is the ordinary product `(Fin 3 → ℝ) × ℝ` with its
product (Lebesgue) measure. The suitable weak-solution class is the one of the
Caffarelli–Kohn–Nirenberg formalization on which the library builds; its three
identities carry no separate integrability clause, because its local
Lebesgue-space hypotheses on `u`, `Du`, `p` and `f` make every integrand
integrable on the support of a test function.

The classical derivatives are built from `fderiv`, which is zero where a
function is not differentiable, and a Bochner integral of a non-integrable
function is zero. Every theorem below assumes its fields smooth on the open
cylinder, directly or through `IsClassicalSolutionOn`; under that assumption
`multiPartial`, `angularMean` and the predicates built from them are the
classical notions, and they should be read together with it.
-/

@[expose] public section

open MeasureTheory MeasureTheory.Measure Set Filter
open scoped ENNReal NNReal Topology

set_option autoImplicit false

noncomputable section

namespace CIVChallenge

/-! ### Space and space-time -/

/-- The spatial carrier: three real coordinates. -/
abbrev Vec3 := Fin 3 → ℝ

/-- A point `(x, t)` of space-time. -/
def ParabolicPoint := Vec3 × ℝ

instance : MeasurableSpace ParabolicPoint := inferInstanceAs (MeasurableSpace (Vec3 × ℝ))

instance : MeasureSpace ParabolicPoint := inferInstanceAs (MeasureSpace (Vec3 × ℝ))

/-- The Euclidean norm of a spatial vector, from the sum of squares. -/
def vec3EuclideanNorm (v : Vec3) : ℝ := Real.sqrt (∑ i, v i ^ 2)

/-- The open Euclidean ball of radius `r` about `x` in space. -/
def vec3Ball (x : Vec3) (r : ℝ) : Set Vec3 :=
  {y | vec3EuclideanNorm (y - x) < r}

/-- The space-time set `Ω × I`. -/
def spaceTimeSet (Ω : Set Vec3) (I : Set ℝ) : Set ParabolicPoint := Ω ×ˢ I

/-- The unit parabolic cylinder `Q = B(1) × (-1, 0)`; `t = 0` is the blow-up time. -/
def unitCylinder : Set ParabolicPoint := spaceTimeSet (vec3Ball 0 1) (Ioo (-1) 0)

/-! ### Classical derivatives -/

/-- The `i`th coordinate basis vector of `Vec3`. -/
def basisVec (i : Fin 3) : Vec3 := Pi.single i (1 : ℝ)

/-- The spatial derivative of `g` in the `i`th coordinate, with time frozen. -/
def spatialPartial (g : ParabolicPoint → ℝ) (i : Fin 3) (z : ParabolicPoint) : ℝ :=
  (fderiv ℝ (fun x : Vec3 => g (x, z.2)) z.1) (basisVec i)

/-- The time derivative of `g`, with the spatial point frozen. -/
def timePartial (g : ParabolicPoint → ℝ) (z : ParabolicPoint) : ℝ :=
  (fderiv ℝ (fun s : ℝ => g (z.1, s)) z.2) 1

/-- The iterated spatial derivative `∂_j ∂_i g`. -/
def spatialSecondPartial (g : ParabolicPoint → ℝ) (i j : Fin 3)
    (z : ParabolicPoint) : ℝ :=
  spatialPartial (fun w => spatialPartial g i w) j z

/-- The multi-index spatial derivative `∂_x^α g = ∂₁^{α₀} ∂₂^{α₁} ∂₃^{α₂} g`. -/
def multiPartial (g : ParabolicPoint → ℝ) (α : Fin 3 → ℕ) : ParabolicPoint → ℝ :=
  (fun k => spatialPartial k 0)^[α 0]
    ((fun k => spatialPartial k 1)^[α 1] ((fun k => spatialPartial k 2)^[α 2] g))

/-- The iterated partial derivative `∂₁^a ∂₃^b g`; on the meridional plane it is
`±∂_r^a ∂_z^b g` for an axisymmetric scalar `g`. -/
def meridionalPartial (g : ParabolicPoint → ℝ) (a b : ℕ) : ParabolicPoint → ℝ :=
  (fun k => spatialPartial k 0)^[a] ((fun k => spatialPartial k 2)^[b] g)

/-! ### Suitable weak solutions -/

/-- Compactly interior spatial and time subdomains of `Ω` and `I`. -/
def localBox (Ω : Set Vec3) (I : Set ℝ) (Ω' : Set Vec3) (J : Set ℝ) : Prop :=
  IsOpen Ω' ∧ IsCompact (closure Ω') ∧ closure Ω' ⊆ Ω ∧
    OrdConnected J ∧ IsCompact (closure J) ∧ closure J ⊆ I

/-- Smooth compactly supported test functions on `Ω × I`, valued in `V`. -/
def spaceTimeTestFunction {V : Type} [NormedAddCommGroup V] [NormedSpace ℝ V]
    (Ω : Set Vec3) (I : Set ℝ) : Set (Vec3 × ℝ → V) :=
  {φ | ContDiff ℝ (⊤ : ℕ∞) φ ∧ HasCompactSupport φ ∧
    tsupport φ ⊆ spaceTimeSet Ω I}

/-- Local scalar `L^p` membership on a space-time set. -/
def localLp (E : Set ParabolicPoint) (p : ℝ) (g : ParabolicPoint → ℝ) : Prop :=
  MeasureTheory.MemLp g (ENNReal.ofReal p) (volume.restrict E)

/-- Componentwise local vector `L^p` membership on a space-time set. -/
def localVecLp (E : Set ParabolicPoint) (p : ℝ)
    (g : ParabolicPoint → Vec3) : Prop :=
  ∀ i : Fin 3, localLp E p (fun z => g z i)

/-- The squared spatial-gradient density `|Du|²` of the gradient datum `Du`. -/
def spatialGradientSq (_u : ParabolicPoint → Vec3)
    (Du : ParabolicPoint → Fin 3 → Vec3) (z : ParabolicPoint) : ℝ :=
  ∑ i, ∑ j, (Du z i j) ^ (2 : ℕ)

/-- `gi` is the `i`th weak derivative of `u` on the spatial set `U`. -/
def HasWeakPartialDerivOn (U : Set Vec3) (i : Fin 3)
    (u gi : Vec3 → ℝ) : Prop :=
  ∀ φ : Vec3 → ℝ,
    ContDiff ℝ (⊤ : ℕ∞) φ →
    HasCompactSupport φ →
    tsupport φ ⊆ U →
    ∫ x in U, u x * (fderiv ℝ φ x) (basisVec i) ∂MeasureTheory.volume =
      -∫ x in U, gi x * φ x ∂MeasureTheory.volume

/-- `Du` is a coordinate weak gradient of `u` on the spatial set `U`. -/
def HasWeakGradientOn
    (U : Set Vec3) (u : Vec3 → ℝ) (Du : Vec3 → Vec3) : Prop :=
  ∀ i : Fin 3, HasWeakPartialDerivOn U i u (fun x => Du x i)

/-- The suitable weak-solution class: a divergence-free distributional solution
of the forced Navier–Stokes system with an explicit gradient datum `Du`
(`Du z i j = ∂_j u_i`), finite local energies, and the local energy inequality
against nonnegative test functions. The clauses are, in order: the regularity
class, the incompressibility identity, the weak momentum identity and the local
energy inequality. -/
def IsSuitableWeakSolution (Ω : Set Vec3) (I : Set ℝ) (q : ℝ)
    (u : ParabolicPoint → Vec3) (Du : ParabolicPoint → Fin 3 → Vec3)
    (p : ParabolicPoint → ℝ) (f : ParabolicPoint → Vec3) : Prop :=
  IsOpen Ω ∧ IsOpen I ∧ OrdConnected I ∧ 5 / 2 < q ∧
    (∀ Ω' J, localBox Ω I Ω' J → localVecLp (spaceTimeSet Ω' J) q f) ∧
    (∀ Ω' J, localBox Ω I Ω' J →
      AEStronglyMeasurable u (volume.restrict (spaceTimeSet Ω' J)) ∧
      AEStronglyMeasurable Du (volume.restrict (spaceTimeSet Ω' J)) ∧
      AEStronglyMeasurable p (volume.restrict (spaceTimeSet Ω' J)) ∧
      AEStronglyMeasurable f (volume.restrict (spaceTimeSet Ω' J)) ∧
      essSup (fun s => ∫⁻ x in Ω', ‖u (x, s)‖ₑ ^ (2 : ℝ))
          (volume.restrict J) < ⊤ ∧
      (∫⁻ z in spaceTimeSet Ω' J,
          ‖u z‖ₑ ^ (2 : ℝ) + ‖Du z‖ₑ ^ (2 : ℝ)) < ⊤ ∧
      MemLp p (ENNReal.ofReal (3 / 2 : ℝ))
          (volume.restrict (spaceTimeSet Ω' J)) ∧
      MemLp f (ENNReal.ofReal q)
          (volume.restrict (spaceTimeSet Ω' J)) ∧
      ∀ i : Fin 3, ∀ᵐ s ∂volume.restrict J,
        HasWeakGradientOn Ω' (fun x => u (x, s) i) (fun x => Du (x, s) i)) ∧
    (∀ ψ : Vec3 × ℝ → ℝ, ψ ∈ spaceTimeTestFunction (V := ℝ) Ω I →
      ∫ z in spaceTimeSet Ω I,
        ∑ i, u z i * spatialPartial ψ i z = 0) ∧
    (∀ φ : Vec3 × ℝ → Vec3, φ ∈ spaceTimeTestFunction (V := Vec3) Ω I →
      ∫ z in spaceTimeSet Ω I,
        (-(∑ i, u z i * timePartial (fun w => φ w i) z))
          - ∑ i, ∑ j, u z i * u z j * spatialPartial (fun w => φ w i) j z
          + ∑ i, ∑ j, (Du z i j) * spatialPartial (fun w => φ w i) j z
          - p z * ∑ i, spatialPartial (fun w => φ w i) i z
          - ∑ i, f z i * φ z i = 0) ∧
    (∀ ψ : Vec3 × ℝ → ℝ, ψ ∈ spaceTimeTestFunction (V := ℝ) Ω I →
      (∀ z, 0 ≤ ψ z) →
      2 * ∫ z in spaceTimeSet Ω I, spatialGradientSq u Du z * ψ z ≤
        ∫ z in spaceTimeSet Ω I,
          (vec3EuclideanNorm (u z)) ^ 2 *
              (timePartial ψ z + ∑ i, spatialSecondPartial ψ i i z)
            + ((vec3EuclideanNorm (u z)) ^ 2 + 2 * p z) *
                ∑ i, u z i * spatialPartial ψ i z
            + 2 * (∑ i, f z i * u z i) * ψ z)

/-! ### Classical solutions and the energy class -/

/-- A classical solution of the forced Navier–Stokes equations `eq:nse:forced` on
a space-time set: smooth fields satisfying the momentum and divergence equations
pointwise. -/
def IsClassicalSolutionOn (u : ParabolicPoint → Vec3) (p : ParabolicPoint → ℝ)
    (f : ParabolicPoint → Vec3) (S : Set ParabolicPoint) : Prop :=
  ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => u z) S ∧
    ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => p z) S ∧
    ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => f z) S ∧
    (∀ z ∈ S, ∀ i : Fin 3,
      timePartial (fun w => u w i) z + ∑ j, u z j * spatialPartial (fun w => u w i) j z -
          ∑ j, spatialSecondPartial (fun w => u w i) j j z + spatialPartial p i z = f z i) ∧
    ∀ z ∈ S, ∑ j, spatialPartial (fun w => u w j) j z = 0

/-- The energy class `eq:interior:energy:class` on all of `Q`, up to the blow-up
time: `u ∈ L^∞_t L²_x(Q) ∩ L²_t H¹_x(Q)` and `π ∈ L^{3/2}_{x,t}(Q)`. -/
def GlobalEnergyClass (u : ParabolicPoint → Vec3) (Du : ParabolicPoint → Fin 3 → Vec3)
    (p : ParabolicPoint → ℝ) : Prop :=
  essSup (fun s => ∫⁻ x in vec3Ball 0 1, ‖u (x, s)‖ₑ ^ (2 : ℝ)) (volume.restrict (Ioo (-1) 0)) < ⊤ ∧
    (∫⁻ z in unitCylinder, ‖u z‖ₑ ^ (2 : ℝ) + ‖Du z‖ₑ ^ (2 : ℝ)) < ⊤ ∧
    MemLp p (ENNReal.ofReal (3 / 2 : ℝ)) (volume.restrict unitCylinder)

/-- `(0,0)` is a regular point in the sense of `eq:interior:regular`: the velocity is
bounded on a backward cylinder `B(r) × (-δ, 0)`. -/
def BoundedNearOrigin (u : ParabolicPoint → Vec3) : Prop :=
  ∃ r δ M : ℝ, 0 < r ∧ 0 < δ ∧
    ∀ x ∈ vec3Ball 0 r, ∀ t ∈ Ioo (-δ) 0, vec3EuclideanNorm (u (x, t)) ≤ M

/-! ### The force -/

/-- The force is bounded in `C²` up to the blow-up time, `eq:interior:force:c-two`. -/
def ForceC2Bounded (f : ParabolicPoint → Vec3) : Prop :=
  ∃ M : ℝ, ∀ z ∈ unitCylinder, ∀ i : Fin 3, ∀ α : Fin 3 → ℕ, α 0 + α 1 + α 2 ≤ 2 →
    |multiPartial (fun w => f w i) α z| ≤ M

/-- Spatial real analyticity of the force, locally uniformly on cylinders compactly
contained in `Q`, `eq:interior:force:analytic`. -/
def ForceSpatiallyAnalytic (f : ParabolicPoint → Vec3) : Prop :=
  ∀ R : ℝ, R < 1 → ∀ t₁ t₂ : ℝ, -1 < t₁ → t₂ < 0 →
    ∃ M a : ℝ, 0 < a ∧ ∀ α : Fin 3 → ℕ, ∀ t ∈ Icc t₁ t₂, ∀ x ∈ vec3Ball 0 R, ∀ i : Fin 3,
      |multiPartial (fun w => f w i) α (x, t)| ≤
        M * a ^ (-((α 0 + α 1 + α 2 : ℕ) : ℝ)) * Nat.factorial (α 0 + α 1 + α 2)

/-- The analyticity bound `eq:analytic:interior:force` for a field `g` on `B(R') × J`
with constants `M`, `a`. -/
def AnalyticBoundOn (g : ParabolicPoint → Vec3) (R' : ℝ) (J : Set ℝ) (M a : ℝ) : Prop :=
  ∀ α : Fin 3 → ℕ, ∀ t ∈ J, ∀ x ∈ vec3Ball 0 R', ∀ i : Fin 3,
    |multiPartial (fun w => g w i) α (x, t)| ≤
      M * a ^ (-((α 0 + α 1 + α 2 : ℕ) : ℝ)) * Nat.factorial (α 0 + α 1 + α 2)

/-- Spatial analyticity of a field, locally uniformly on cylinders compactly contained
in `B(R) × (t₁, t₂)`: `eq:analytic:interior:force` / `eq:analytic:interior:velocity`. -/
def LocallyUniformlyAnalyticOn (g : ParabolicPoint → Vec3) (R t₁ t₂ : ℝ) : Prop :=
  ∀ R' : ℝ, R' < R → ∀ s₁ s₂ : ℝ, t₁ < s₁ → s₂ < t₂ →
    ∃ M a : ℝ, 0 < a ∧ AnalyticBoundOn g R' (Icc s₁ s₂) M a

/-! ### Rotations and axisymmetry -/

/-- The rotation `Q_φ` through the angle `φ` about the `z`-axis. -/
def rotZ (φ : ℝ) (x : Vec3) : Vec3 :=
  ![Real.cos φ * x 0 - Real.sin φ * x 1, Real.sin φ * x 0 + Real.cos φ * x 1, x 2]

/-- The rotated field `(ℛ_φ u)(x, t) = Q_φ u(Q_φ⁻¹ x, t)` of `eq:interior:average`. -/
def rotField (φ : ℝ) (u : ParabolicPoint → Vec3) (z : ParabolicPoint) : Vec3 :=
  rotZ φ (u (rotZ (-φ) z.1, z.2))

/-- The angular mean `𝒫u = (2π)⁻¹ ∫₀^{2π} ℛ_φ u dφ` of `eq:interior:average`, the
axisymmetric part of a field. -/
def angularMean (u : ParabolicPoint → Vec3) (z : ParabolicPoint) : Vec3 :=
  (2 * Real.pi)⁻¹ • ∫ φ in (0 : ℝ)..(2 * Real.pi), rotField φ u z

/-- A field is axisymmetric on a set when its non-axisymmetric part `w = u - 𝒫u`
vanishes there (Section `sec:aniso:notation`). -/
def IsAxisymmetricOn (u : ParabolicPoint → Vec3) (S : Set ParabolicPoint) : Prop :=
  ∀ z ∈ S, angularMean u z = u z

/-! ### Meridional quantities -/

/-- The point `(x₁, 0, x₃)` of the meridional plane `{x₂ = 0}`. -/
def meridional (x₁ x₃ : ℝ) : Vec3 := ![x₁, 0, x₃]

/-- The anisotropic Type II bounds `eq:aniso:bounds` (for the angular mean,
`eq:interior:mean:bounds`) with exponent `h` and constant `C`, for all derivatives
of total order at most two, read on the meridional plane `{x₂ = 0}`, where
`|v₀| = |v_r|`, `|v₁| = |v_θ|` and `|v₂| = |v_z|`. -/
def AnisotropicBounds (C h : ℝ) (v : ParabolicPoint → Vec3) : Prop :=
  ∀ a b : ℕ, a + b ≤ 2 → ∀ x₁ x₃ t : ℝ, (meridional x₁ x₃, t) ∈ unitCylinder →
    |meridionalPartial (fun z => v z 0) a b (meridional x₁ x₃, t)| ≤
        C * (-t) ^ (-(1 / 2 : ℝ) - a / 2 - (1 / 2 - h) * b) ∧
      |meridionalPartial (fun z => v z 2) a b (meridional x₁ x₃, t)| +
        |meridionalPartial (fun z => v z 1) a b (meridional x₁ x₃, t)| ≤
        C * (-t) ^ (-(1 / 2 : ℝ) - h - a / 2 - (1 / 2 - h) * b)

/-- The quotient `u_r / r` read on the meridional plane: `u₁ / x₁` off the axis and
`∂₁ u₁` on it (the continuous extension across the axis). -/
def radialQuotient (u : ParabolicPoint → Vec3) (z : ParabolicPoint) : ℝ :=
  if z.1 0 = 0 then spatialPartial (fun w => u w 0) 0 z else u z 0 / z.1 0

/-- The integrand of `G_ρ` in `eq:aniso:G`: `|∂_r u_r| + |u_r/r| + |∂_z u_z| + |∂_z u_r|`
on the meridional plane. -/
def meridionalQuantity (u : ParabolicPoint → Vec3) (z : ParabolicPoint) : ℝ :=
  |spatialPartial (fun w => u w 0) 0 z| + |radialQuotient u z| +
    |spatialPartial (fun w => u w 2) 2 z| + |spatialPartial (fun w => u w 0) 2 z|

/-- `lim_{t↑0} (-t) G_ρ(t) = 0`, `eq:aniso:small`, unfolded. -/
def MeridionalSmallness (ρ : ℝ) (u : ParabolicPoint → Vec3) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ t₀ ∈ Ioo (-1 : ℝ) 0, ∀ t ∈ Ioo t₀ 0, ∀ x₁ x₃ : ℝ,
    meridional x₁ x₃ ∈ vec3Ball 0 ρ → (-t) * meridionalQuantity u (meridional x₁ x₃, t) ≤ ε

/-! ### Theorem 1.1 -/

/-- Theorem 1.1 (`thm:main`): regularity under anisotropic Type II bounds and analytic forcing. -/
theorem mainTheorem (q : ℝ)
    (u : ParabolicPoint → Vec3) (Du : ParabolicPoint → Fin 3 → Vec3)
    (p : ParabolicPoint → ℝ) (f : ParabolicPoint → Vec3)
    (hsol : IsSuitableWeakSolution (vec3Ball 0 1) (Ioo (-1) 0) q u Du p f)
    (henergy : GlobalEnergyClass u Du p)
    (hu : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => u z) unitCylinder)
    (hp : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => p z) unitCylinder)
    (hf : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => f z) unitCylinder)
    (h : ℝ) (hh : 0 < h ∧ h < 1 / 2)
    (hMf : ForceC2Bounded f) (hfa : ForceSpatiallyAnalytic f)
    (C : ℝ) (hC : 0 < C) (hbounds : AnisotropicBounds C h (angularMean u))
    (hcore : ∀ t ∈ Ioo (-1 : ℝ) 0, ∃ ρ ∈ Ioo (0 : ℝ) 1,
      IsAxisymmetricOn u (spaceTimeSet (vec3Ball 0 ρ) {t})) :
    IsAxisymmetricOn u unitCylinder ∧ BoundedNearOrigin u :=
  by sorry

/-! ### Theorem 1.3 -/

/-- Theorem 1.3 (`thm:aniso:main`): regularity of axisymmetric solutions under anisotropic bounds. -/
theorem axisymmetricTheorem (q : ℝ)
    (u : ParabolicPoint → Vec3) (Du : ParabolicPoint → Fin 3 → Vec3)
    (p : ParabolicPoint → ℝ) (f : ParabolicPoint → Vec3)
    (hsol : IsSuitableWeakSolution (vec3Ball 0 1) (Ioo (-1) 0) q u Du p f)
    (henergy : GlobalEnergyClass u Du p)
    (hu : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => u z) unitCylinder)
    (hp : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => p z) unitCylinder)
    (hf : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => f z) unitCylinder)
    (haxi : IsAxisymmetricOn u unitCylinder)
    (h : ℝ) (hh : 0 < h ∧ h < 1 / 2)
    (hMf : ForceC2Bounded f)
    (C : ℝ) (hC : 0 < C) (hbounds : AnisotropicBounds C h u) :
    BoundedNearOrigin u :=
  by sorry

/-! ### Proposition 1.5 -/

/-- Proposition 1.5 (`prop:aniso:small`). -/
theorem meridionalSmallness (q : ℝ)
    (u : ParabolicPoint → Vec3) (Du : ParabolicPoint → Fin 3 → Vec3)
    (p : ParabolicPoint → ℝ) (f : ParabolicPoint → Vec3)
    (hsol : IsSuitableWeakSolution (vec3Ball 0 1) (Ioo (-1) 0) q u Du p f)
    (henergy : GlobalEnergyClass u Du p)
    (hu : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => u z) unitCylinder)
    (hp : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => p z) unitCylinder)
    (hf : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => f z) unitCylinder)
    (haxi : IsAxisymmetricOn u unitCylinder)
    (h : ℝ) (hh : 0 < h ∧ h < 1 / 2) (hMf : ForceC2Bounded f)
    (C : ℝ) (hC : 0 < C) (hbounds : AnisotropicBounds C h u) :
    ∀ ρ ∈ Ioo (0 : ℝ) 1, MeridionalSmallness ρ u :=
  by sorry

/-! ### Theorem 2.1 -/

/-- Theorem 2.1 (`thm:analytic:interior`, Kahane 1969): interior spatial analyticity. -/
theorem interiorAnalyticity (R t₁ t₂ : ℝ) (hR : 0 < R) (ht : t₁ < t₂)
    (u : ParabolicPoint → Vec3) (p : ParabolicPoint → ℝ) (f : ParabolicPoint → Vec3)
    (hsol : IsClassicalSolutionOn u p f (spaceTimeSet (vec3Ball 0 R) (Ioo t₁ t₂)))
    (hf : LocallyUniformlyAnalyticOn f R t₁ t₂) :
    LocallyUniformlyAnalyticOn u R t₁ t₂ :=
  by sorry

/-! ### Corollary 2.3 -/

/-- Corollary 2.3 (`cor:interior:nonanalytic`): the force under an axisymmetric core. -/
theorem forceUnderCore (q : ℝ)
    (u : ParabolicPoint → Vec3) (Du : ParabolicPoint → Fin 3 → Vec3)
    (p : ParabolicPoint → ℝ) (f : ParabolicPoint → Vec3)
    (hsol : IsSuitableWeakSolution (vec3Ball 0 1) (Ioo (-1) 0) q u Du p f)
    (henergy : GlobalEnergyClass u Du p)
    (hu : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => u z) unitCylinder)
    (hp : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => p z) unitCylinder)
    (hf : ContDiffOn ℝ (⊤ : ℕ∞) (fun z : Vec3 × ℝ => f z) unitCylinder)
    (h : ℝ) (hh : 0 < h ∧ h < 1 / 2)
    (hMf : ForceC2Bounded f)
    (C : ℝ) (hC : 0 < C) (hbounds : AnisotropicBounds C h (angularMean u))
    (hcore : ∀ t ∈ Ioo (-1 : ℝ) 0, ∃ ρ ∈ Ioo (0 : ℝ) 1,
      IsAxisymmetricOn u (spaceTimeSet (vec3Ball 0 ρ) {t}))
    (hsing : ¬ BoundedNearOrigin u) :
    ¬ ForceSpatiallyAnalytic f ∧ (∃ z ∈ unitCylinder, f z ≠ 0) ∧
      ∀ R' δ' : ℝ, 0 < R' → R' ≤ 1 → 0 < δ' → δ' ≤ 1 →
        ∃ z ∈ spaceTimeSet (vec3Ball 0 R') (Ioo (-δ') 0), f z ≠ 0 :=
  by sorry

end CIVChallenge
