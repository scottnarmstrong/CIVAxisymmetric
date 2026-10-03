# Regularity of asymptotically axisymmetric Navier–Stokes solutions, formalized in Lean 4

[![Build and verify](https://github.com/scottnarmstrong/CIVAxisymmetric/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/scottnarmstrong/CIVAxisymmetric/actions/workflows/build.yml)
[![Comparators](https://github.com/scottnarmstrong/CIVAxisymmetric/actions/workflows/comparators.yml/badge.svg?branch=main)](https://github.com/scottnarmstrong/CIVAxisymmetric/actions/workflows/comparators.yml)

A machine-checked proof, in Lean 4 and Mathlib, of the main results of

> P. Constantin, M. Ignatova and V. Vicol, *Regularity of asymptotically
> axisymmetric solutions to the 3D Navier–Stokes equations with analytic
> forcing*, [arXiv:2609.20803](https://arxiv.org/abs/2609.20803).

The TeX source of the paper is in [paper/](paper/NSE_Anisotropic_Pointwise.tex).
Every result listed below is proved using only Lean's three standard axioms
`propext`, `Classical.choice` and `Quot.sound`; the library contains no
`sorry`. The suitable weak-solution class, the regularity theory it rests on
and much of the analysis library come from the
[Caffarelli–Kohn–Nirenberg formalization](https://github.com/scottnarmstrong/CaffarelliKohnNirenberg),
which this project uses as a Lake dependency.

## The main theorem

Let $(u,\pi)$ be a suitable weak solution of the forced Navier–Stokes equations
on the unit parabolic cylinder $\mathcal Q = B(1)\times(-1,0)$, smooth on
compact subsets of $\mathcal Q$, whose force is bounded in $C^2$ up to the
blow-up time $t=0$ and is real analytic in space, locally uniformly on cylinders
compactly contained in $\mathcal Q$. Suppose that

1. the angular mean $v=\mathcal P u$ of the velocity obeys the anisotropic
   Type II bounds of the paper: for $0<h<1/2$ and derivatives
   $\partial_r^a\partial_z^b$ of total order at most two,
   $|\partial_r^a\partial_z^b v_r|\le C(-t)^{-1/2-a/2-(1/2-h)b}$ and
   $|\partial_r^a\partial_z^b v_z|+|\partial_r^a\partial_z^b v_\theta|\le C(-t)^{-1/2-h-a/2-(1/2-h)b}$;
2. at every time $t\in(-1,0)$ the velocity is exactly axisymmetric on some ball
   $B(\rho(t))$, with no lower bound on $\rho(t)>0$.

Then $u$ is axisymmetric on all of $\mathcal Q$, and $(0,0)$ is a regular point:
$u$ is bounded on $B(r_*)\times(-\delta_*,0)$ for some $r_*,\delta_*>0$
(Theorem 1.1, `thm:main`). Consequently, for a solution with properties 1 and 2
whose force stays bounded in $C^2$ but which is singular at $(0,0)$, the force
can neither be real analytic in space in this sense nor vanish near the singular
point (Corollary 2.3, `cor:interior:nonanalytic`).

In Lean, [`CIV.mainTheorem`](CIV/Statements/MainTheorem.lean):

```lean
theorem mainTheorem (q : ℝ)
    (u : ParabolicPoint → Vec3) (Du : ParabolicPoint → Fin 3 → Vec3)
    (p : ParabolicPoint → ℝ) (f : ParabolicPoint → Vec3)
    (hsol : CKN.IsSuitableWeakSolution (vec3Ball 0 1) (Ioo (-1) 0) q u Du p f)
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
```

`Vec3` is `Fin 3 → ℝ` and a `ParabolicPoint` is a pair of a point and a time,
as in the CKN formalization. The solution class is CKN's
`IsSuitableWeakSolution` (the definition of a suitable weak solution in the
CKN formalization) on
$B(1)\times(-1,0)$ with a force exponent `q`, together with
`GlobalEnergyClass`, the paper's energy class on all of $\mathcal Q$ up to the
blow-up time (CKN's class only controls boxes compactly inside the domain). The
smoothness hypotheses `hu`, `hp`, `hf` are the paper's "smooth on compact
subsets of $\mathcal Q$". `AnisotropicBounds` reads the bounds on the
meridional plane, `BoundedNearOrigin` is the regularity conclusion
`eq:interior:regular`, and `IsAxisymmetricOn` says that the non-axisymmetric
part $u-\mathcal Pu$ vanishes. All of these are defined in
[CIV/Statements](CIV/Statements); the [design notes](docs/DESIGN_NOTES.md)
explain each choice.

## What is proved

The thirteen results below are stated in [CIV/Statements](CIV/Statements),
one file each, and proved in the rest of the library. The paper labels are
those of the TeX source.

| Paper | Label | Lean declaration | File |
|---|---|---|---|
| Theorem 1.1 | `thm:main` | `CIV.mainTheorem` | [MainTheorem.lean](CIV/Statements/MainTheorem.lean) |
| Theorem 1.3 | `thm:aniso:main` | `CIV.axisymmetricTheorem` | [AxisymmetricTheorem.lean](CIV/Statements/AxisymmetricTheorem.lean) |
| Proposition 1.5 | `prop:aniso:small` | `CIV.meridionalSmallness` | [MeridionalSmallnessProp.lean](CIV/Statements/MeridionalSmallnessProp.lean) |
| Theorem 2.1 (Kahane) | `thm:analytic:interior` | `CIV.interiorAnalyticity` | [InteriorAnalyticity.lean](CIV/Statements/InteriorAnalyticity.lean) |
| Corollary 2.3 | `cor:interior:nonanalytic` | `CIV.forceUnderCore` | [ForceUnderCore.lean](CIV/Statements/ForceUnderCore.lean) |
| Lemma 3.1 | `lem:aniso:axis` | `CIV.axisMaximumPrinciple` | [AxisMaximumPrinciple.lean](CIV/Statements/AxisMaximumPrinciple.lean) |
| Lemma 3.2 | `lem:aniso:annulus` | `CIV.regularAnnulus` | [RegularAnnulus.lean](CIV/Statements/RegularAnnulus.lean) |
| Lemma 3.3, $L^\infty$ norm is nonincreasing | `lem:aniso:comparison` | `CIV.comparison` | [Comparison.lean](CIV/Statements/Comparison.lean) |
| Lemma 3.3, decaying ancient solutions vanish | `lem:aniso:comparison`, `eq:aniso:ancient:decay` | `CIV.comparisonAncient` | [ComparisonAncient.lean](CIV/Statements/ComparisonAncient.lean) |
| Lemma 5.1 | `lem:aniso:closure` | `CIV.closureLemma` | [ClosureLemma.lean](CIV/Statements/ClosureLemma.lean) |
| Serrin's interior estimates, as used in the proof of Lemma 3.2 | `lem:aniso:annulus` | `CIV.serrinInteriorEstimates` | [SerrinInteriorEstimates.lean](CIV/Statements/SerrinInteriorEstimates.lean) |
| The Gustafson–Kang–Tsai criterion at $(0,0)$, as used in the proof of Lemma 5.1 | `lem:aniso:closure` | `CIV.gktCriterion` | [GktCriterion.lean](CIV/Statements/GktCriterion.lean) |
| $\mathcal H^1(S_0)=0$ at the blow-up time, as used in the proof of Lemma 3.2 | `lem:aniso:annulus` | `CIV.timeZeroSingularSetNull` | [TimeZeroSingularSetNull.lean](CIV/Statements/TimeZeroSingularSetNull.lean) |

The last three rows are results the paper cites from the literature (Serrin
1962; Gustafson, Kang and Tsai 2007; Caffarelli–Kohn–Nirenberg partial
regularity at the top boundary). They are stated in the form in which the paper
uses them and proved here, as is Kahane's interior analyticity theorem, so the
main theorem depends on no unproved input. Several of these proofs take a
different route from the cited sources; see [the deviations](docs/DEVIATIONS.md).

Because a formal statement is only as good as the definitions in it, five of
the results are also restated in a standalone
[Challenge](Challenge.lean) that uses Mathlib alone and defines
every notion it mentions, including the suitable weak-solution class. The
separate [Solution](Solution.lean) proves the same statements from
the library, and [Comparator](comparators/README.md) checks the pair: the five
are `thm:main`, `thm:aniso:main`, `prop:aniso:small`, `thm:analytic:interior`
and `cor:interior:nonanalytic`. Reading the Challenge is the quickest way to
inspect the precise mathematical claims.

## What is not formalized

The main results depend on none of the following, which the paper states or
uses in passing and which are not proved here:

- the divergence-free correction of the force in footnote `foot:aniso:pressure`
  (solving $\Delta\pi_f=\mathrm{div}\,f$ on $B(1)$ with zero Dirichlet
  data). It is not needed: CKN's solution class admits a general force, so the
  results are applied to the paper's own force (see
  [design note R1](docs/DESIGN_NOTES.md)).
- the smooth expansions of an axisymmetric field near the axis, $u_r=r\,a(r^2,z,t)$,
  $u_\theta=r\,c(r^2,z,t)$, $u_z=d(r^2,z,t)$ (the paragraph after
  `eq:aniso:circulation:pde`; Whitney's even-function representation). The
  proofs avoid them: the elliptic bounds of Section 5 are applied to $u$
  itself, and the limit equation of Section 4 is obtained with a cutoff at the
  axis (deviations D9 and D17 in [docs/DEVIATIONS.md](docs/DEVIATIONS.md)).
- Remark 2.4 (`rem:interior:approximate`): regularity under a $C^3$ bound on the
  non-axisymmetric part instead of an axisymmetric core and an analytic force.
- Remark 5.2 (`rem:interior:meridional`): Theorem 1.3 without the bounds on
  $u_\theta$.

The remarks `rem:exterior:nonanalytic` and `rem:force:symmetry` are proved as
supporting results (`CIV.exteriorNonanalytic` in `CIV/Reduction/ExteriorNonanalyticUnconditional.lean`,
`CIV/Identities/ForceSymmetry.lean`). The other remarks are not stated as
separate Lean results, and Appendix A
(the properties of the construction to which the paper is applied) is outside
the scope of the formalization.

## How the formalization relates to the paper

The statements follow the paper's hypotheses and conclusions; where a
definition had to be made precise (the meaning of "smooth on compact subsets",
cylindrical coefficients on the axis, the energy class up to the blow-up time,
the regular-point conclusion at the top boundary) the choice is explained in
the [design notes](docs/DESIGN_NOTES.md). The proofs follow the paper's
argument, with eighteen recorded departures, D1 to D18 in
[docs/DEVIATIONS.md](docs/DEVIATIONS.md). The most substantial are:

- Kahane's analyticity theorem (D12) and Serrin's interior estimates (D13) are
  proved by pointwise heat-kernel and Newtonian-potential estimates rather than
  by the Hölder bootstrapping of the original papers;
- the Gustafson–Kang–Tsai criterion at the top boundary point is replaced by an
  argument through CKN's Theorem A and its pressure estimates (D10), and the
  top-boundary partial regularity by a uniform interior argument (D1, D7);
- the comparison lemma uses a smooth convex energy and Fubini reference times
  (D11);
- in Section 4 the limiting drift is extracted through time primitives instead
  of weak-* compactness (D14), the finite-axis compactness goes through the
  azimuthal vorticity (D15), and the finite-axis limit equation is obtained with
  a cutoff at the axis (D17).

None of these changes the statement of a main result. The supporting statements
are stated in the form the proofs consume, which in a few places is less than
the printed text asserts (a non-uniform constant in Serrin's estimates, a
Lipschitz representative of the drift in the comparison lemma, and the
intermediate identities of Section 4); see
[the scope notes](docs/DEVIATIONS.md#scope-of-the-supporting-statements).

## Building and checking it yourself

The project pins Lean 4 and Mathlib at v4.35.0-rc2 and the CKN formalization at a
fixed commit (`lakefile.toml`, `lake-manifest.json`). With `elan` and Python 3
installed:

```sh
elan toolchain install leanprover/lean4:v4.35.0-rc2
lake exe cache get
CIV_IGNORE_PACKAGE_BUILD=1 python3 scripts/build.py CIV
```

`lake exe cache get` downloads the Mathlib build; the CKN dependency has no
binary cache and is compiled from source during the first build.
`CIV_IGNORE_PACKAGE_BUILD=1` lets that first build create the compiled files of
CKN and Mathlib, while the build script still checks that their sources are
unchanged; later builds are `python3 scripts/build.py CIV`. Keep the
committed dependency manifest and avoid `lake update` or `lake clean` when
verifying this version.

The [verification guide](docs/VERIFICATION.md) explains how to print the axioms
of the thirteen results, run the source and axiom checks, and run the
comparator:

```sh
python3 scripts/check_axioms.py --root .
python3 scripts/build.py Comparators
python3 scripts/check_comparators.py
scripts/verify_comparator.sh
```

## Repository layout

- [CIV/Statements](CIV/Statements): the thirteen results and the definitions their statements use.
- [CIV/Setting](CIV/Setting), [CIV/Identities](CIV/Identities): cylindrical coordinates, rotations and the angular mean, and the axisymmetric identities of Section 3.1.
- [CIV/Reduction](CIV/Reduction): the reduction of Theorem 1.1 to Theorem 1.3 (Section 2) and the regular-annulus lemma.
- [CIV/Axis](CIV/Axis), [CIV/Comparison](CIV/Comparison): the maximum principle and the comparison lemma (Section 3).
- [CIV/Zoom](CIV/Zoom): the zoom-in argument of Section 4 and the proof of Proposition 1.5.
- [CIV/Closure](CIV/Closure): the closure lemma of Section 5.
- [CIV/Regularity](CIV/Regularity): regularity at the blow-up time from CKN's interior theory.
- [CIV/Prerequisites](CIV/Prerequisites): the proofs of the Kahane, Serrin and Gustafson–Kang–Tsai inputs.
- [CIV/Analysis](CIV/Analysis): general analysis lemmas.
- [CIV/Main](CIV/Main): short files connecting each of the thirteen statements to its proof.
- [comparators](comparators): the independent restatements described above.
- [paper](paper): the TeX source of arXiv:2609.20803.
- [docs](docs): design notes, deviations, verification guide and sources.
- [scripts](scripts): the build, checking and verification scripts.

## How this was made

The Lean development was written by AI coding agents under the supervision of
the authors. Most of the Lean code was written by Leanstral. Claude Sonnet and
Claude Opus wrote the harder proofs, and Claude Opus designed the proofs of the
Kahane, Serrin, Gustafson–Kang–Tsai and comparison results. Claude coordinated
the agents, and Claude Opus and GPT-6 Astra reviewed the statements and proofs.
The authors decided the mathematics and approved every theorem statement before
its proof was written. Each statement was checked against the paper by a
reviewer that had not written its proof. Lean checks the proofs, and the
comparator files let anyone inspect the statements independently.

## Contributing, authors and license

See [Contributing](CONTRIBUTING.md) for the source rules and checks, and
[CITATION.cff](CITATION.cff) for how to cite this work.

The Lean development is by:

- **Scott Armstrong**, CNRS and Laboratoire Jacques-Louis Lions, Sorbonne
  Université; Courant Institute School of Mathematics, Computing, and Data Science, New York University.
  Supported by the European Research Council under the European Union's
  Horizon Europe programme, grant agreement No. 101200828.
- **Vlad Vicol**, Courant Institute School of Mathematics, Computing, and Data Science, New York University. Partially supported by Collaborative NSF
  grant DMS-2307681 and a Simons Investigator Award.

The paper is by Peter Constantin, Mihaela Ignatova and Vlad Vicol. The Lean
library, software and documentation are copyright © 2026 Scott Armstrong and
Vlad Vicol and distributed under the [Apache License 2.0](LICENSE). The paper
in [paper/](paper) is the work of its three authors and is included as the
source being formalized. Cited third-party works and dependencies retain their
own licenses.
