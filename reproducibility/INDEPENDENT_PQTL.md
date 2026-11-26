# An independent real-data test of the Karim support group (pQTL)

With the installed geneticPoS 0.5.0, one pair, IL23R × Crohn's disease, was checked. The Wald ratio was recomputed from external coefficients, matched to the public PWCoCo result of Zheng et al., and the support group of Karim Figure 1a was looked up.

| Item | Value checked |
|---|---:|
| cis-pQTL / GWAS | rs11581607 / GCST004132 |
| pQTL effect and standard error (A vs G) | −0.42 / 0.0491 |
| GWAS effect and standard error (A vs G, as written in the source file) | 0.7935 / 0.0388 |
| Wald ratio / standard error | −1.889286 / 0.09238095 |
| MR p-value | 5.881896 × 10⁻⁹³ |
| Conditional colocalization H4 | 0.993 |
| L2G share | 0.55 |
| MeSH similarity / pQTL measured target | 1 / TRUE |
| Matching / verdict | exact_identifiers / supported |
| Historical launch proportion of the support group | 20/36 (55.56%) |

The MR used the published coefficients for the same allele, and the standard error of the Wald ratio is a first-order approximation that leaves out the uncertainty of the exposure coefficient. H4 is transcribed at the precision printed in the paper. The exposure side is aligned on rs11581607, and the outcome side uses the same Crohn's disease GWAS of de Lange et al. The MR uses the marginal effect of a single variant, and the colocalization is a conditional analysis. The MR of Zheng Supplementary Table S7 that was checked earlier uses a different GWAS, so it was left out of the input of this test. [Zheng et al., paper and supplementary data](https://pmc.ncbi.nlm.nih.gov/articles/PMC7610464/) [de Lange et al., original paper](https://doi.org/10.1038/ng.3760)

The L2G share is from Minikel row 244136. Open Targets lists rs11581607 as a locus of GCST004132. For the variant in the GWAS source file and the Minikel row, the study, the gene, the disease, the GWAS p-value (6.33 × 10⁻⁹³) and the absolute value of the log OR were compared. This 0.55 is given explicitly in `metadata`; the MeSH similarity and the measured target are resolved from the bundled reference. [Open Targets locus listing](https://blog.opentargets.org/open-targets-genetics-new-release-is-out/) [Minikel public reference](https://github.com/ericminikel/genetic_support/blob/main/data/assoc.tsv.gz)

The matching key is pQTL assay, GWAS ID, genome build and rsID. Without the L2G share, and with the coloc side changed to another locus, the launch proportion stayed missing, as it should. The 55.56% is the proportion of the past support group of Karim that went from phase 1 to launch; it cannot be read as a probability specific to this candidate.

## Rerun

Install the package at the repository root and run it with the bundled single-locus extract.

```sh
R CMD INSTALL .
Rscript --vanilla reproducibility/check_delange_pqtl.R
```

## Extract again from the public sources

Place Zheng Supplementary Data as `zheng_s3.xlsx`, the de Lange source file as `delange_cd_GCST004132.txt.gz` and the Minikel `assoc.tsv.gz` as `minikel_assoc.tsv.gz` in `reproducibility/data/`. Python needs openpyxl, and R needs geneticPoS 0.5.0. [Zheng supplementary file list](https://www.nature.com/articles/s41588-020-0682-6#Sec38) [de Lange GWAS data](https://ftp.ebi.ac.uk/pub/databases/gwas/summary_statistics/GCST004001-GCST005000/GCST004132/cd_build37_40266_20161107.txt.gz) [Minikel data](https://raw.githubusercontent.com/ericminikel/genetic_support/main/data/assoc.tsv.gz)

```sh
python reproducibility/check_delange_pqtl.py
Rscript --vanilla reproducibility/check_delange_pqtl.R
```
