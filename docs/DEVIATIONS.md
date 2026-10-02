# Deviations from the paper

Every departure of the Lean development from the printed argument of
arXiv:2609.20803v1 is recorded here, with the label of the affected statement,
what changed, and why. None of them changes the statement of a main result
(Theorems 1.1 and 1.3, Proposition 1.5, Theorem 2.1, Corollary 2.3). The
supporting statements are stated in the form the proofs consume, which is in a
few respects less than the printed text asserts; these are listed under
[Scope of the supporting statements](#scope-of-the-supporting-statements). The
representation choices behind the Lean statements are in
[DESIGN_NOTES.md](DESIGN_NOTES.md). Some entries record that a proof uses fewer
inputs than the docstring of its statement lists (D7, D10, D13): those
docstrings describe the inputs of the paper's argument.

## Scope of the supporting statements

The proofs of the main results consume the following statements only in the
form given here. None of these points adds a hypothesis to a main result.

- **Serrin's interior estimates** (`CIV.serrinInteriorEstimates`). The constant
  is chosen after the solution, the annuli and the other data, so the statement
  gives a finite bound for each fixed solution. The paper also records that the
  bound depends only on the smaller region, the force bound, the velocity bound
  on the larger annulus and $\|\nabla u\|_{L^2}$; that uniformity is not stated.
  The same holds for the constant of the tested energy inequality of
  `lem:aniso:closure` (`CIV.step_closure_energy_inequality`), which is chosen after
  the functions $G$ and $W$. The closure proof fixes those functions before it
  chooses the constant and chooses the small parameter afterwards, so no step
  needs the uniform form.
- **The comparison lemma** (`CIV.comparison`, `CIV.comparisonAncient`) is stated
  for a drift given by a representative that is bounded and Lipschitz in space
  for almost every time (design note R11). The paper's hypothesis is a Sobolev
  class, which is insensitive to changes on null sets. Passing to the Lipschitz
  representative recovers the paper's form, but no general conversion is proved;
  both applications in Section 4 construct the representative directly (D14).
- **Section 4.** The limit equations are proved with a general admissible drift
  and its weak divergence. The identifications $B=(VX/R,W)$,
  $\mathrm{div}\,B=2V/R$ (finite branch) and $\mathrm{div}\,B=0$
  (receding branch) are not stated (D14). The finite-$n$ lifted equation across
  the axis and the $L^1_{\mathrm{loc}}$ convergence of the swirl source up to the
  axis are not proved; the limit equation is obtained with a cutoff instead
  (D17).
- **The Gustafson–Kang–Tsai criterion** (`CIV.gktCriterion`) is the consequence
  the proof of `lem:aniso:closure` uses: if the fourth power of the
  $L^4_tL^6_x$ norm on $B(r)\times(-r^2,0)$ tends to zero, then $(0,0)$ is a
  regular point. The small-constant form and the other exponent pairs of the
  cited theorem are not stated.
- **Predicates built from derivatives and integrals.** The classical partial
  derivatives are built from Mathlib's `fderiv`, which is defined (as zero) where
  a function is not differentiable, and a Bochner integral of a non-integrable
  function is zero. So `ForceC2Bounded` and `ForceSpatiallyAnalytic` do not on
  their own say that the force is $C^2$ or analytic, and the same caveat applies
  to `AnisotropicBounds`, `LocallyUniformlyAnalyticOn`, `radialQuotient`,
  `meridionalQuantity` and `angularMean`. Every statement that uses them also
  assumes the fields smooth on the open cylinder, directly or through
  `IsClassicalSolutionOn`, and under that assumption each is the classical
  notion. They should be read together with it.

## D1. Partial regularity at the blow-up time

Affects `thm:main`, `thm:aniso:main`, `lem:aniso:annulus`.

The paper obtains $\mathcal H^1(S_0)=0$ for the singular set of the blow-up time
by applying partial regularity (the criterion of Gustafson, Kang and Tsai,
Theorem 1.1(ii)) at points $(x,0)$ of the top boundary of $\mathcal Q$. CKN's
theorems are stated on open space-time sets and the solution is not defined past
$t=0$, so they cannot be applied there directly (design note R3). The statement
$\mathcal H^1(S_0)=0$ is `CIV.timeZeroSingularSetNull`; its proof (D7) uses CKN's
interior theory at points $(x,s)$, $s<0$, with constants uniform in $s$. The
radius of the regular sphere is then chosen by pushing this null set forward
along the Lipschitz Euclidean radius (`CIV/Regularity/RegularSphereFull.lean`),
axis included (design note R12). The rest of the proof of `lem:aniso:annulus`
follows the printed three paragraphs: the Serrin step is D13, and the
circulation bound is `lem:aniso:axis` read at the final time.

The ε-regularity smallness at a point of the blow-up time is carried as a single
scale-invariant integral; see D3.

## D2. Interior analyticity

Affects `thm:main`.

The paper cites Kahane's interior analyticity theorem (`thm:analytic:interior`).
It is stated as `CIV.interiorAnalyticity` and proved; the proof is D12.

## D3. The ε-regularity smallness as one integral

Affects `thm:aniso:main`, `lem:aniso:annulus`.

The smallness hypothesis of ε-regularity at a point of the blow-up time is
carried as the single scale-invariant integral
$\int_{Q_r}(|u|^3+|\pi|^{3/2}+r^{3q-3}|f|^q)\le\varepsilon_0r^2$
(`CIV.bounded_of_small_L3_top`) rather than as separate velocity–pressure and
force conditions. The force term scales like $r^{3q-5}$ and the other two like
$r^{-2}$; the lower Lebesgue integral is not subadditive without measurability,
so separate conditions cannot be recombined into the single sum that CKN's
Theorem A takes.

## D4. The barrier rate of the comparison lemma

Affects `lem:aniso:comparison`.

The barrier rate is $K=\sqrt m\,\Lambda+d$ instead of the paper's
$K=\Lambda+d$. `Vec m` carries the sup norm, for which the Cauchy–Schwarz
inequality gives $|B\cdot\nabla\langle x\rangle|\le\sqrt m\,\|B\|_\infty$. The
lemma uses no upper bound on $K$, so nothing downstream changes
(`CIV/Comparison/Barrier.lean`).

## D5. Rotation invariance of the pressure in the swirl equations

Affects `lem:aniso:closure`, `eq:aniso:circulation:pde`,
`eq:aniso:scalar:nse:swirl`.

The swirl equation, the weighted swirl equation, the circulation equation and
the swirl bound assume that the force is axisymmetric
(`IsAxisymmetricOn f unitCylinder`), as `lem:aniso:closure` does, and derive the
rotation invariance of the pressure inside their proofs
(`CIV.pressure_rotZ_invariant`, design note R8). Under the classical system and
the axisymmetry of $u$ the two hypotheses are equivalent, so the force hypothesis
is the one kept.

## D6. A contraction lemma of CKN re-proved

The uniform interior route of D7 needs CKN's one-step Morrey contraction, which
the CKN formalization keeps private. It is re-proved here from CKN's public
lemmas as `CIV.theta_contraction_of_beta_small`
(`CIV/Regularity/ThetaContraction.lean`). This duplicates a statement of the
dependency; nothing in CKN is modified.

## D7. The singular set at the blow-up time: fewer inputs than the docstring lists

Affects `CIV.timeZeroSingularSetNull` (`lem:aniso:annulus`).

The docstring of `CIV/Statements/TimeZeroSingularSetNull.lean` says that the
statement bundles CKN's partial regularity and the Gustafson–Kang–Tsai criterion
applied at the top boundary. The proof uses neither at the top boundary. From
CKN's Theorem A at interior points $(x,s)$, $s<0$, with constants independent of
$s$, it obtains a uniform interior Morrey decay near the top boundary and the
smallness of the Theorem A quantity on top-boundary cylinders; hence the
scale-invariant Dirichlet integral of $\nabla u$ over backward cylinders based at
a singular point has a positive lower bound, and a spatial Vitali covering with
the finite global Dirichlet integral gives $\mathcal H^1(S_0)=0$. The hypotheses
`hp` and `hf` (smoothness of the pressure and of the force) are not needed by
this proof; the statement keeps them.

## D8. The time representative in the comparison argument

Affects `lem:aniso:comparison`.

The paper's proof chooses a representative of $q$ that is Lipschitz in time
before integrating the mollified equation, anchored at reference times at which
the mollified slice is the mollification of the slice. The formalization does
the same with reference times taken in the Fubini sense; see D11 (iii).

## D9. $u$ in place of the meridional velocity $b$ in the elliptic bounds

Affects `lem:aniso:closure`.

In the proof of `lem:aniso:closure`, the two elliptic inequalities
`eq:aniso:closure:elliptic` are stated for $b=u_re_r+u_ze_z$ (the meridional
velocity, $\mathrm{curl}\,b=\omega_\theta e_\theta$,
$\mathrm{div}\,b=0$), and the mixed term is dominated by
$|\partial_ru_z|\le|\nabla b|$, $|\partial_z\partial_ru_z|\le|\nabla^2b|$. The
formalization states and proves both inequalities with $u$ in place of $b$, with
the same quantities $Y$ and $M$: $\mathrm{curl}\,(\chi u)=\chi\omega+\nabla\chi\times u$
and $\mathrm{div}\,(\chi u)=\nabla\chi\cdot u$, every $\nabla\chi$ term lives
in the annulus where $u$, $\nabla u$, $\nabla^2u$ are bounded by
`lem:aniso:annulus`, and the dominations become $|\partial_ru_z|\le|\nabla u|$,
$|\partial_z\partial_ru_z|\le|\nabla^2u|$. The route through $b$ would need $b$
smooth across the axis (the axis expansions, which are not formalized), while
$u$ is smooth by hypothesis. The axis term $\omega_r^2/r^2$ in $M$ is still used
in the angular term.

## D10. The Gustafson–Kang–Tsai criterion through CKN's Theorem A

Affects `CIV.gktCriterion` (`lem:aniso:closure`).

The docstring of `CIV/Statements/GktCriterion.lean` says that the statement
bundles the criterion of Gustafson, Kang and Tsai (Theorem 1.1(i), $p_*=6$,
$q=4$), its application at the top boundary point $(0,0)$ justified by the
footnote in the proof of `lem:aniso:annulus`, and the reduction of
`foot:aniso:pressure` to a divergence-free force. The proof does not follow
Gustafson, Kang and Tsai. At the endpoint $3/p_*+2/q=1$, Hölder's inequality
turns the $L^4_tL^6_x$ smallness directly into scale-invariant $L^3$ smallness,
$\int_{B_r\times(-r^2,0)}|u|^3\le(4\pi/3)^{1/2}r^2\bigl(\int\|u\|_{L^6}^4\bigr)^{3/4}$.
CKN's integrated Lin pressure estimate is then iterated over finitely many scales
at interior base points $(0,s)$, $s<0$, with constants independent of $s$;
monotone convergence as $s\uparrow0$ reaches the backward cylinder, and CKN's
Theorem A in its top-boundary form concludes. The top-boundary application is
therefore proved, not taken from the footnote. The force correction and the
Dirichlet estimate it needs are not used, because both CKN estimates take a
general force. The hypotheses `hp` and `hf` are not needed by this proof; the
statement keeps them.

## D11. The comparison energy

Affects `lem:aniso:comparison`.

The proof follows the paper's route (mollify, commutator, barrier, positive-part
energy, Grönwall, $\varepsilon\downarrow0$, $\sigma\downarrow0$, exhaustion) and
departs in four technical points.

1. The energy is $\int G(q_\varepsilon-\Psi_\sigma)$ with
   $G(y)=\int_0^y\mathrm{smoothTransition}$, a smooth convex profile vanishing
   exactly on $(-\infty,0]$, in place of $\int(q_\varepsilon-\Psi_\sigma)_+^2$.
   The weak-divergence clause of `eq:aniso:comparison:drift` is stated for smooth
   test functions, and $G\circ w$ is one, so the transport term needs no
   approximation of a $C^1$ function, and the diffusion term is
   $-\int G''(w)|\nabla_Xw|^2\le0$ by two smooth integrations by parts. The energy
   grows linearly, so the Grönwall bound takes a different form from the paper's
   $L^2$ bound, and the transport term is bounded by $\Lambda\int G(w)$.
2. The commutator term is split as $|R_\varepsilon|\le\delta+R_\varepsilon^2/(4\delta)$
   instead of by the Cauchy–Schwarz inequality, with $\delta\downarrow0$ after
   $\varepsilon\downarrow0$; the $\varepsilon$-limit converts $L^2$ convergence
   of the commutator to $L^1$ with the same split.
3. The representative of the sentence after `eq:aniso:comparison:mollified` is
   $q_\varepsilon(x,\tau_0)+\int_{\tau_0}^\tau H(x,\cdot)$, anchored at a reference
   time $\tau_0$. The reference times are taken in the Fubini sense: the
   primitive identity holds from $\tau_0$ for almost every $x$ and almost every
   later time, simultaneously for $\varepsilon=1/(n+1)$. This replaces "Lebesgue
   point of $\tau\mapsto q(\cdot,\tau)\in L^1_{\mathrm{loc}}$" and plays the same
   role.
4. The hypothesis $1\le d\le m$ is not used by the proof; the statement keeps it.

## D12. Interior analyticity by pointwise heat-kernel Cauchy estimates

Affects `thm:analytic:interior` (Kahane 1969, Theorem 1.2 and p. 387, with a
nonconservative force).

The proof of `CIV.interiorAnalyticity` does not follow Kahane's scheme, which
gains one derivative per step in Hölder seminorms through Serrin's
representation formulas and two singular-integral estimates. Instead it bounds
the weighted derivatives $(\tau d)^k|\partial^\alpha g|$ of the three velocity
components and of the pressure by the majorant $b_0=M$,
$b_{k+1}=MK^k(k+1)!/(k+2)$ on nested regions of depth $\tau$. Each order is
gained by a pointwise interior gradient bound on a backward window of radius
$\theta\tau d/(k+1)$: the heat bound for $\partial^\alpha u_i$ (residual: the
differentiated momentum equation), and its frozen-time Laplace form for
$\partial^\alpha p$ (Laplacian:
$\partial^\alpha(\mathrm{div}\,f-\sum_{ij}\partial_iu_j\partial_ju_i)$, the
pressure Poisson identity, proved pointwise from the equations). The constants
$\theta=1/(400C(1+M))$ and $K=\max(12800C^2(1+M),1/a_f,1)$ do not depend on the
order. The only analytic input is the Serrin heat-potential bound
`CIV.serrin_heat_pointwise_bound`, proved in Lean; no Newtonian potential,
harmonic part or singular integral enters. The hypotheses `hR : 0 < R` and
`ht : t₁ < t₂` are not used by the proof; the statement keeps them. Inside the
heat chain, `CIV.HB2_cutoff_decomposition` assumes $\rho\le1$; its only consumer,
the heat bound, assumes the same and passes it through.

## D13. Serrin's interior estimates by heat and Newton potentials of the vorticity

Affects `CIV.serrinInteriorEstimates` (`lem:aniso:annulus`; Serrin 1962, Section 4
with $m=1$, uniform up to $t=0$).

The proof does not follow Serrin's scheme (Hölder and $L^p$ bootstrapping of his
representation formulas, which needs singular-integral and Schauder-type
estimates). The suitable weak solution, smooth on $\mathcal Q$, is first shown to
be classical there (`CIV.isClassicalSolutionOn_of_suitable`: the weak divergence
and momentum identities, the weak gradient identified with the classical one by
pairing on time slices, and the fundamental lemma). The vorticity equation is
written in divergence form,
$\partial_t\omega_i-\Delta\omega_i=\partial_m(\omega_mu_i-u_m\omega_i+F_{im})$
with $\partial_mF_{im}=(\mathrm{curl}\,f)_i$, and differentiated once and
twice. A pointwise cut-off heat representation on backward windows
$\overline B(x,\rho)\times[s-\rho^2,s]$ bounds $\omega$, $\nabla\omega$,
$\nabla^2\omega$ at $(x,s)$ by $C(\rho\Lambda+M/\rho)$, where $\Lambda$ bounds the
same level on the window. The velocity gradient and Hessian are recovered on each
time slice from the Newtonian representation
$\partial_lv=-\partial_lN*\Delta v$, applied to $\chi u_i$ and to
$\chi\,\partial_ju_i$ after replacing $u(\cdot,s)$ by a globally smooth field
equal to it near the ball. The circular terms carry a factor $\rho$ and are
absorbed with the distance weight $d(x)=\min(|x|-a,\ b-|x|)$; the only
non-uniform quantity, a compactness bound on a truncated slab, is removed
exactly, so the constants are uniform up to $t=0$ and use only the past. Six
nested annuli carry the levels
$\omega\to\nabla\omega\to\nabla u\to\nabla^2\omega\to\nabla^2u$. The pressure
never enters an estimate. The hypothesis `henergy` is not used by the proof, and
the constants depend neither on $\|\nabla u\|_{L^2(\mathcal Q)}$ nor on the
pressure; the docstring's statement that these come from `henergy` lists more
inputs than the proof uses. The kernel, cutoff, elliptic and local-step lemmas
assume $\rho\le1$, which the absorption discharges.

## D14. The limiting drift of Section 4 by time primitives

Affects `prop:aniso:small` (`eq:aniso:zoom:finite:limit`,
`eq:aniso:zoom:receding:limit`).

Steps 2 and 3 of the proof extract the limiting drift by time primitives instead
of weak-* compactness (`CIV.exists_subseq_admissibleDrift`):

- $a_n(x,\tau)=\int_{T-1}^{\min(\tau,T)}b_n(x,s)\,ds$ is equi-Lipschitz in
  $(x,\tau)$ because of the Lipschitz and sup bounds of `eq:drift:Bn:def`;
- a locally uniform limit $a$ is extracted by a box-diagonal Arzelà–Ascoli
  argument;
- $B=\partial_\tau a$ is a Borel representative given by limsup difference
  quotients; for almost every $\tau$ it exists for every $x$ and is
  $\Lambda$-Lipschitz in $x$ (a countable dense set and the mixed bound
  $|\Delta_x\Delta_\tau a|\le\Lambda|x-y||\tau-\tau'|$).

The weak divergence and the weak convergence of $b_n$ and
$\mathrm{div}\,b_n$ against every integrable, compactly supported test
function follow from the primitives. This yields the per-slice Lipschitz
representative that `eq:aniso:comparison:drift` (`IsAdmissibleDrift`) requires,
which a weak-* limit does not provide. The limit drift is characterized only as
the weak limit of $B_n$: the identification $B=(VX/R,W)$,
$\mathrm{div}\,B=2V/R$ (finite branch) and the divergence-freeness
$\partial_RV+\partial_ZW=0$ (receding branch) are not stated, because the
equation carries $\mathrm{div}\,B$ as data (design note R11) and no step
needs them. Weak-* compactness is not used.

## D15. Finite-axis compactness through the azimuthal vorticity divided by $R$

Affects `prop:aniso:small` (`eq:aniso:zoom:finite:compactness`).

The compactness is proved for $\Theta_n^{(0)}=\lambda_n^2\delta_n\omega_\theta$
about the moving axis point $(0,z_n)$: the receding pairing argument is run at
$A=0$ on compacts $\{R\ge\varepsilon\}$, and the result is divided by $R$
($\Omega_n=\Theta_n^{(0)}/R$). This replaces the printed bound of
$\partial_\tau\Omega_n$ in $W^{-2,p}$ together with the Ehrling inequality. The
conclusion is the same.

## D16. The circulation bound from the averaged classical system

Affects `prop:aniso:small` (`eq:aniso:zoom:circulation`).

The circulation bound is obtained from the annulus bound of the original
suitable solution (`lem:aniso:annulus`, which needs no symmetry of $f$) and the
circulation maximum principle applied to the angle-averaged classical system
$(u,\bar\pi,\mathcal Pf)$ (`CIV.exists_zoom_standing_data`). This makes explicit
the averaging of Section `sec:aniso:identities`, since `prop:aniso:small` does
not assume an axisymmetric force.

## D17. The axis in the finite-axis limit equation, by a cutoff

Affects `prop:aniso:small` (`eq:aniso:zoom:lifted`, `eq:aniso:zoom:finite:limit`).

The printed Step 2 establishes the lifted equation `eq:aniso:zoom:lifted` in the
sense of distributions across the null axis $X=0$ at each $n$, and then removes
the swirl source by $F_n\to0$ in $L^1_{\mathrm{loc}}$ up to the axis. The
formalization does neither. The residual of the limit operator against a test
function $\varphi$ is split as $\varphi\chi_\varepsilon+\varphi(1-\chi_\varepsilon)$,
with $\chi_\varepsilon$ a cutoff at distance $\varepsilon$ from the axis:

- near the axis the part is $O(\varepsilon^2)$ uniformly in $n$: $\tilde\Omega_n$,
  $B_n$ and $\mathrm{div}\,B_n$ are bounded, the second derivatives of
  $\varphi\chi_\varepsilon$ are $O(\varepsilon^{-2})$, and the support has volume
  $O(\varepsilon^4)$ in $\mathbb R^4$;
- off the axis the lifted equation holds classically, and integration by parts
  leaves $\delta_n^2\int\tilde\Omega_n\partial_{ZZ}\psi-\int F_n\partial_Z\psi+\int G_n\psi$;
  each term tends to zero, with $F_n\le C_\Gamma^2\delta_n^2/\varepsilon^4$ on
  $\{R\ge\varepsilon\}$ (`CIV.tendsto_finResidual`).

The vanishing of the swirl source up to the axis is therefore not used, and no
finite-$n$ equation across the axis is proved.

## D18. Suitability of the averaged pair by a smooth pressure gauge

Affects `thm:main`.

The proof of `thm:main` says that $(u,\bar\pi)$ is suitable with force
$\mathcal Pf$ because it is smooth and classical. This is proved without a
classical-to-weak passage: the original and the averaged triples are both
classical on $\mathcal Q$ with the same velocity, so
$\nabla\bar\pi-\nabla\pi=\mathcal Pf-f$ there, and a suitable weak solution stays
suitable under such a smooth change of $(\pi,f)$
(`CIV.isSuitableWeakSolution_of_pressureGauge`: one integration by parts per
direction in the momentum identity, and $\mathrm{div}\,u=0$ in the local
energy inequality). This proves the printed sentence rather than departing from
it.

The corollary's scaling takes $R=\min(R',\delta')$ (so $R\le R'$ and
$R^2\le\delta'$) and the core radius $\min(\rho(R^2t)/R,1/2)$, which is the
printed $\min\{\rho(t),R'/2\}$ after rescaling. No other departure occurs in
`thm:aniso:main`, `thm:main` or `cor:interior:nonanalytic`.
