# Sources and regeneration of the reference data

| File | Content and transformation |
|---|---|
| `inst/extdata/benchmarks.tsv.gz` | 116 rows extracted, in `pos_id` order, from the Karim summary Parquet. The candidate reference is the MR + coloc comparison of v2 Figure 1a. |
| `inst/extdata/mapping.tsv.gz` | The clinical mapping, aggregated by gene, indication MeSH ID and GWAS ID. The L2G share and the MeSH similarity are each taken as the unique value. |
| `inst/extdata/measured.tsv.gz` | Flags of pQTL-measured targets that resolve uniquely per gene. |
| `reproducibility/data/delange_il23r_source.csv` | The extract of one locus from public summary statistics, used in the independent check. Its origin and the matching steps are in the [real-data check](reproducibility/INDEPENDENT_PQTL.md). |

This is a processed snapshot based on the public materials of Karim, Hukku, Ariano and others. The upstream GitHub project states CC BY 4.0. Check the redistribution terms of the individual Zenodo files, and of processed tables that contain third-party upstream data, before publication. GPL-3 applies to the code of this package. [Karim et al.](https://doi.org/10.64898/2026.02.23.26346731) · [Authors' repository](https://github.com/mohdkarim/mrcoloc) · [Zenodo DOI of the authors' data](https://doi.org/10.5281/zenodo.18451758) · [Minikel et al.](https://doi.org/10.1038/s41586-024-07316-0)

To regenerate the references, put the two input Parquet files in one folder and run this in an environment with the DuckDB Python package.

```sh
python reproducibility/build_karim_refs.py PATH_TO_PARQUETS NEW_OUTPUT_DIRECTORY
```

The bundled TSV files and the regenerated output can be compared as expanded tables. To rerun the authors' upstream analysis, see the authors' repository. The Zenodo DOI above identifies the authors' materials. If a new Zenodo DOI is issued for the processed tables of this package, record its version and the file hashes in this document.
