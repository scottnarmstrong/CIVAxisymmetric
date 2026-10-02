# Design notes

The choices that shape the Lean statements, with the reason for each. Labels
refer to [paper/NSE_Anisotropic_Pointwise.tex](../paper/NSE_Anisotropic_Pointwise.tex)
(arXiv:2609.20803v1). The notes are numbered R1 to R14; the Lean docstrings cite
them by number.

## R1. Carriers and the solution class come from CKN

Velocity fields are `u : ParabolicPoint → Vec3` with `Vec3 = Fin 3 → ℝ` and
`ParabolicPoint = Vec3 × ℝ`, and "suitable weak solution on $\mathcal Q$" is
`CKN.IsSuitableWeakSolution (vec3Ball 0 1) (Set.Ioo (-1) 0) q u Du p f`, CKN's
`IsSuitableWeakSolution` (`def:sws` of the CKN manuscript), for a force exponent
`q` carried as a parameter. The paper's force is bounded in $C^2$
(`eq:interior:force:c-two`), so it lies in every $L^q_{\mathrm{loc}}$; keeping `q`
as a binder makes the statements no weaker than the paper's. The paper's footnote
about a divergence-free force (`foot:aniso:pressure`) is not needed: CKN's class
admits a general force, and every result here is applied to the paper's own
force.

## R2. "Smooth on compact subsets of $\mathcal Q$"

Stated as `ContDiffOn ℝ ⊤` of the fields on the open set `spaceTimeSet Ω I`,
viewed inside the product normed space `Vec3 × ℝ` (`ParabolicPoint` carries the
parabolic metric and is not a normed space, so differentiability is always
taken in the product). Since $\mathcal Q$ is open, smoothness on every compact
subset is the same as smoothness on $\mathcal Q$. The fields of the CKN class are
functions, not almost-everywhere classes, so this is a hypothesis on the given
representative, as in the paper. The force is included: the solution class ties
`f` to `(u, Du, p)` only almost everywhere, so the smoothness hypothesis on `f`
selects the smooth representative that the paper calls $f$ ("hence $f$ is smooth
there as well"), which is what makes the pointwise $C^2$ and analyticity bounds
on $f$ meaningful. It is not a strengthening of the premises: the smooth residual
of the equation is such a representative.

## R3. The regular-point conclusion is the paper's, at the blow-up time

The conclusion of `thm:main` and `thm:aniso:main` is `eq:interior:regular`:
there are $r_*,\delta_*>0$ with $u$ bounded on $B(r_*)\times(-\delta_*,0)$
(`BoundedNearOrigin`). It is not CKN's `IsRegularPoint`, because that predicate
(and CKN's Theorems A, B and C) lives on the open set $\Omega\times I$, and
$(0,0)$ has $t=0\notin I$: the solution is not defined past the blow-up time, so
no interior notion applies there. The paper meets the same point in the footnote
to the proof of `lem:aniso:annulus`, where the criterion of Gustafson, Kang and
Tsai is applied at top-boundary points because its proof only uses backward
cylinders.

Consequently CKN's theorems are used only at interior points $(x,t)$, $t<0$, and
the top-boundary statements are derived from them by limiting arguments that
need quantitative, scale-invariant conclusions: Theorem A gives a Hölder bound
with universal constants on the half cylinder, so after rescaling
(`CKN.isSuitableWeakSolution_rescale`) $|u|\le C/r$ on $Q_{r/2}(x,t)$ for every
interior $(x,t)$ at which the smallness holds at scale $r$, and the union over
$t\uparrow0$ of these cylinders covers $B(r/2)\times(-r^2/4,0)$ with a bound
independent of $t$. How this is used for the singular set at the blow-up time and
for the Gustafson–Kang–Tsai criterion is described in deviations D1, D7 and D10
of [DEVIATIONS.md](DEVIATIONS.md). This changes proofs, not statements.

## R4. Cylindrical coefficients are read on the meridional plane

For a field $u$ and a point $x=(x_1,0,x_3)$ of the plane $\{x_2=0\}$, the
cylindrical coefficients of an axisymmetric field are $u_r=u_1$, $u_\theta=u_2$,
$u_z=u_3$ when $x_1>0$, and $u_r=-u_1$, $u_\theta=-u_2$ when $x_1<0$; the
derivatives $\partial_r$, $\partial_z$ are $\pm\partial_1$, $\partial_3$. The
anisotropic bounds `eq:aniso:bounds` and `eq:interior:mean:bounds`, which involve
only absolute values, are therefore stated (`AnisotropicBounds`) as bounds on
$|\partial_1^a\partial_3^b u_i(x,t)|$ for all $x=(x_1,0,x_3)\in B(1)$, with CKN's
classical `spatialPartial` iterated (`meridionalPartial`). On the axis $x_1=0$
this is the continuous extension of the cylindrical derivative from $r>0$, which
is what the paper's bound means there (its scalar coefficients are smooth
functions of $(r,z)$ extended to the axis by continuity). No coordinate type is
introduced: $u_r/r$ and similar quotients are defined on the ambient space and
shown smooth across the axis where needed. One predicate serves both theorems;
for `thm:main` the paper's second display is a sum of two $L^\infty(B(1))$ norms,
while the predicate bounds the pointwise sum, which is the same condition up to
replacing the constant by twice itself.

## R5. Rotations and the angular mean are literal source formulas

`rotZ φ : Vec3 → Vec3` is the rotation matrix about the $z$-axis;
`(rotField φ u)(x,t) = rotZ φ (u (rotZ (-φ) x, t))` is `eq:interior:average`,
and `angularMean u` is the Bochner integral over $\varphi\in(0,2\pi)$ divided by
$2\pi$. "Axisymmetric" is the paper's $w=0$, that is `angularMean u = u` on the
given set (`IsAxisymmetricOn`); the equivalent `∀ φ, rotField φ u = u` for
continuous fields is a lemma.

## R6. The energy class on the whole cylinder is a separate hypothesis

CKN's `IsSuitableWeakSolution` imposes the energy, gradient and pressure
integrability only on boxes compactly contained in $\Omega\times I$, whereas the
paper's class (`eq:interior:energy:class`) has
$u\in L^\infty_tL^2_x(\mathcal Q)\cap L^2_tH^1_x(\mathcal Q)$ and
$\pi\in L^{3/2}(\mathcal Q)$ on all of $\mathcal Q$, up to the blow-up time, and
the proofs use this at $t=0$ (the covering step of `lem:aniso:annulus`, the
averaged pressure in the reduction). The statements therefore carry the predicate
`GlobalEnergyClass u Du p` next to the CKN class.

## R7. $u_r/r$ across the axis

`radialQuotient u (x,t)` is $u_1/x_1$ off the axis and $\partial_1u_1$ on it. For
a field that is smooth on $\mathcal Q$ and axisymmetric, $u_1(0,0,x_3,t)=0$
(footnote to the standing assumptions before `thm:aniso:main`), so $\partial_1u_1$
at an axis point is the limit of $u_1/x_1$: the axis branch is the paper's
"extended continuously across the axis" (paragraph after `eq:aniso:G`), not a
default value. For $x_1<0$ the quotient equals $u_r/r$ because numerator and
denominator change sign together. `MeridionalSmallness` reads `eq:aniso:G` on the
meridional plane (R4); by rotation invariance of the four scalars this is the
$L^\infty(B(\rho))$ norm of the paper, and the supremum equals the essential
supremum because the quantity is continuous for $t<0$.

## R8. Axisymmetry of the pressure is never a hypothesis; of the force, where the paper says so

The standing assumption opening Section `sec:aniso:identities` takes $\pi$ and
$f$ axisymmetric without loss of generality. `lem:aniso:closure` states
axisymmetry of $f$ explicitly and `lem:aniso:annulus` inherits it; those
statements carry it, while `prop:aniso:small` ("under the hypotheses of
`thm:aniso:main`") does not. Axisymmetry of $\pi$ is redundant: for smooth
axisymmetric $u$ and axisymmetric $f$, the $\theta$-component of the momentum
equation gives $\partial_\theta^2\pi=0$ off the axis, hence
$\partial_\theta\pi=0$ by periodicity (`CIV.pressure_rotZ_invariant`). Proofs
that need an axisymmetric force replace $(\pi,f)$ by their angular means, which
keeps $u$ a suitable weak solution (deviation D18).

## R9. `lem:aniso:axis` is stated in the meridional variables $((r,z),t)$

The paper's $\varphi(r,z,t)$ on $\overline{B(R)}\times[t_1,s]$ is rendered on the
closed half-disc $\{r\ge0,\ r^2+z^2\le R^2\}$: continuity of an axisymmetric
function on the closed ball is continuity of its profile on the closed half-disc
($x\mapsto(|x'|,x_3)$ is a quotient map on the compact ball), and $C^2$ in $x$ at
$r>0$ is `ContDiffAt ℝ 2` of the profile. Time regularity is the one-sided
derivative from the past within `Iic t` at every point of the domain, which is
what the proof uses at the maximum point and what "$C^1$ in $t$" can only mean at
$t=s$; this is weaker than the paper's hypothesis, so the lemma is stronger.
Consumers (`lem:aniso:annulus` for $\Gamma$, `lem:aniso:closure` for
$(-t)^\eta u_\theta$) instantiate the profile from smoothness and axisymmetry. The
conclusion $\max_\Sigma|\varphi|+M(t-t_1)$ is rendered as
`∀ m, (|φ| ≤ m on Σ) → |φ| ≤ m + M(t − t₁)`, which is equivalent because
$\Sigma$ is compact and nonempty and $\varphi$ is continuous there.

## R10. `thm:analytic:interior` is stated for classical solutions

The paper's "$(u,\pi)$ a solution of `eq:nse:forced` on $B(R)\times(t_1,t_2)$,
smooth on compact subsets" is `IsClassicalSolutionOn`: smooth fields with the
momentum and divergence equations pointwise on the open cylinder. No energy class
or boundary data is imposed (Kahane's theorem is local); a smooth suitable weak
solution satisfies the predicate. Smoothness of $f$ is a conjunct for the reason
in R2. The analyticity bounds are pointwise on the open ball and componentwise,
which for smooth fields is the paper's $L^\infty(B(R'))$ bound up to a
dimensional constant absorbed by the existential $M$.

## R11. `lem:aniso:comparison`: drift, divergence and the weak form

$B(\cdot,\tau)\in W^{1,\infty}$ is taken to mean that the given function
$B(\cdot,\tau)$ is bounded and Lipschitz for almost every $\tau$ in each compact
$J\subseteq I$, with one constant $\Lambda_J$ (sup norm on `Vec m`, equivalent to
the paper's constants up to dimension). The divergence is carried as data `divB`,
measurable, bounded by $\Lambda_J$ and equal to the weak divergence of
$B(\cdot,\tau)$ for almost every $\tau$: the pointwise derivative of a merely
measurable drift has no available joint measurability, and a Bochner integral of
a non-integrable integrand is $0$, so the weak form also carries an
`IntegrableOn` conjunct, as in the CKN convention. Consumers that obtain the drift
as a limit pass a jointly measurable representative that is Lipschitz in $x$ for
almost every $\tau$, together with its divergence. $L^\infty_{\mathrm{loc}}(I;L^\infty(\mathbb R^m))$
is $L^\infty(\mathbb R^m\times J)$ for each compact $J\subseteq I$, with
almost-everywhere strong measurability on $\mathbb R^m\times I$. The
continuous-representative clause is stated for an open $V$ and continuity on
$V\cap(\mathbb R^m\times(-\infty,T])$, the form used at both applications in
Section `sec:aniso:zoom`.

## R12. The regular annulus and the singular set at the blow-up time

`lem:aniso:annulus` first needs a radius $R\in(R_1,R_0)$ whose sphere carries no
singular point of the blow-up time. The paper takes $\mathcal H^1(S_0)=0$ from
partial regularity applied at points $(x,0)$ of the top boundary. Here this is
the statement `CIV.timeZeroSingularSetNull`: the set `singularSlice u` of points
of $B(1)$ near which $u$ is unbounded on every backward cylinder ending at $t=0$
has one-dimensional Hausdorff measure zero. Its docstring describes the inputs
the paper uses (CKN partial regularity and the Gustafson–Kang–Tsai criterion at
the top boundary); the proof needs less (deviations D1 and D7).

The radius is then chosen as in the paper: the Euclidean radius is Lipschitz, so
the image of a set of vanishing $\mathcal H^1$ measure is Lebesgue null and
almost every $R$ has $\partial B(R)\cap S_0=\emptyset$; since $S_0$ is closed and
$\partial B(R)$ compact, there are $\delta>0$ with
$S_0\cap\{R-\delta\le|x|\le R+\delta\}=\emptyset$, and compactness gives one
$t_0$ and one bound for $u$ on the annulus $\times(t_0,0)$. The derivative bounds
of `lem:aniso:annulus` come from Serrin's interior estimates (R13).

## R13. Inputs the paper cites from the literature

Three inputs of the proofs of `lem:aniso:annulus` and `lem:aniso:closure` are
classical theorems the paper cites: Serrin's interior estimates (a bounded
solution with a $C^2$ force has bounded $\nabla u$, $\nabla^2u$ on interior
sub-cylinders, uniformly up to the final time because the representation
formulas are one-sided in time), the Gustafson–Kang–Tsai criterion
($\|u\|_{L^4_tL^6_x(Q_r)}\to0$ implies boundedness near the point), and the
top-boundary partial regularity of R12. None is in CKN or Mathlib. Each is stated
as its own result in [CIV/Statements](../CIV/Statements), in the minimal form the
proofs consume, and proved: `CIV.serrinInteriorEstimates`, `CIV.gktCriterion`,
`CIV.timeZeroSingularSetNull`. What each statement bundles beyond the cited
theorem is described in its docstring: for Serrin the paper's argument for
uniformity up to $t=0$; for Gustafson–Kang–Tsai the top-boundary application
and the reduction of `foot:aniso:pressure`, since the statement takes a general
bounded force. Kahane's interior analyticity theorem, `thm:analytic:interior`,
is treated the same way (`CIV.interiorAnalyticity`). The proofs are described in
deviations D10, D12 and D13.

## R14. The two norms on `Vec3`

`Vec3 = Fin 3 → ℝ` carries the sup norm as `‖·‖`, while every CKN scale-invariant
quantity and `vec3Ball` are built on the Euclidean `vec3EuclideanNorm`. The two
differ by a factor $\sqrt3$ ($\|v\|\le|v|\le\sqrt3\|v\|$), and `μH[1]` is computed
in the sup metric. Any statement that mixes the two conventions carries the
constant explicitly ($3$ under a square, $\sqrt3$ otherwise); a statement that
does not is false, not merely imprecise.
