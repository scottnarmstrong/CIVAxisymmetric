# Sources

## The formalized paper

- **Constantin, Peter; Ignatova, Mihaela; Vicol, Vlad.** “Regularity of
  asymptotically axisymmetric solutions to the 3D Navier–Stokes equations with
  analytic forcing.” [arXiv:2609.20803](https://arxiv.org/abs/2609.20803)
  (version 1). The TeX source is
  [paper/NSE_Anisotropic_Pointwise.tex](../paper/NSE_Anisotropic_Pointwise.tex);
  the Lean sources cite it by its LaTeX labels. Its bibliography is the full
  list of references; the entries below are those whose results enter the
  formalized statements or proofs.

## Formal dependency

- **Armstrong, Scott; Vicol, Vlad.** *CaffarelliKohnNirenberg: a Lean 4
  formalization of the Caffarelli–Kohn–Nirenberg partial regularity theorem for
  the Navier–Stokes equations.*
  [github.com/scottnarmstrong/CaffarelliKohnNirenberg](https://github.com/scottnarmstrong/CaffarelliKohnNirenberg),
  pinned by commit in `lakefile.toml`. It supplies the carriers `Vec3` and
  `ParabolicPoint`, the suitable weak-solution class `IsSuitableWeakSolution`,
  Theorem A (ε-regularity), the pressure estimates and the Sobolev, mollifier
  and potential library.

## Results cited by the paper and proved here

These are stated in the forms in which the paper uses them and proved in Lean;
the proofs do not follow the original arguments (see
[DEVIATIONS.md](DEVIATIONS.md)).

- **Kahane, C.** “On the spatial analyticity of solutions of the Navier–Stokes
  equations.” *Arch. Rational Mech. Anal.* **33**(5), 386–405 (1969).
  [DOI: 10.1007/BF00247697](https://doi.org/10.1007/BF00247697). Theorem 1.2 and
  p. 387: the paper's Theorem 2.1, `CIV.interiorAnalyticity` (D12).
- **Serrin, J.** “On the interior regularity of weak solutions of the
  Navier–Stokes equations.” *Arch. Ration. Mech. Anal.* **9**, 187–195 (1962).
  [DOI: 10.1007/BF00253344](https://doi.org/10.1007/BF00253344). Section 4 with
  `m = 1`: `CIV.serrinInteriorEstimates` (D13).
- **Gustafson, S.; Kang, K.; Tsai, T.-P.** “Interior regularity criteria for
  suitable weak solutions of the Navier–Stokes equations.” *Comm. Math. Phys.*
  **273**(1), 161–176 (2007).
  [DOI: 10.1007/s00220-007-0214-6](https://doi.org/10.1007/s00220-007-0214-6).
  Theorem 1.1(i) with `p_* = 6`, `q = 4`: `CIV.gktCriterion` (D10); Theorem
  1.1(ii), used by the paper for the singular set at the blow-up time, is
  replaced by the argument behind `CIV.timeZeroSingularSetNull` (D1, D7).

## Other inputs of the proofs

- **Caffarelli, L.; Kohn, R.; Nirenberg, L.** “Partial regularity of suitable
  weak solutions of the Navier–Stokes equations.” *Comm. Pure Appl. Math.*
  **35**(6), 771–831 (1982).
  [DOI: 10.1002/cpa.3160350604](https://doi.org/10.1002/cpa.3160350604). Used
  through its Lean formalization.
- **Lin, F.-H.** “A new proof of the Caffarelli–Kohn–Nirenberg theorem.”
  *Comm. Pure Appl. Math.* **51**(3), 241–257 (1998).
  [DOI: 10.1002/(SICI)1097-0312(199803)51:3<241::AID-CPA2>3.0.CO;2-A](https://doi.org/10.1002/%28SICI%291097-0312%28199803%2951%3A3%3C241%3A%3AAID-CPA2%3E3.0.CO%3B2-A).
  Its pressure estimate, as formalized in the CKN library, is used in the proof
  of `CIV.gktCriterion` (D10).
- **DiPerna, R. J.; Lions, P.-L.** “Ordinary differential equations, transport
  theory and Sobolev spaces.” *Invent. Math.* **98**(3), 511–547 (1989).
  [DOI: 10.1007/BF01393835](https://doi.org/10.1007/BF01393835). The commutator
  estimate of the comparison lemma (Lemma II.1), proved in
  [CIV/Comparison](../CIV/Comparison).
- **Koch, G.; Nadirashvili, N.; Seregin, G. A.; Šverák, V.** “Liouville
  theorems for the Navier–Stokes equations and applications.” *Acta Math.*
  **203**(1), 83–105 (2009).
  [DOI: 10.1007/s11511-009-0039-6](https://doi.org/10.1007/s11511-009-0039-6).
  The reading of `∂_r² + 3r⁻¹∂_r` as the Laplacian of `ℝ⁴`, used for the
  potential-vorticity equation in Section 4.
