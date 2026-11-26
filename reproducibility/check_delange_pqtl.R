library(geneticPoS)

x <- read.csv("reproducibility/data/delange_il23r_source.csv")
b <- x$beta_y / x$beta_x
se <- x$se_y / abs(x$beta_x)
# Use the native TwoSampleMR result column names and coloc summary names.
mr <- data.frame(id.exposure = x$assay, id.outcome = "GCST004132",
                 method = "Wald ratio", nsnp = 1L, b = b, se = se,
                 pval = 2 * pnorm(-abs(b / se)))
coloc <- data.frame(PP.H4.abf = .993) # Zheng et al., conditional PWCoCo, Fig. 4.
keys <- list(exposure_id = x$assay, outcome_id = "GCST004132", build = "GRCh37",
             locus_id = x$variant, qtl_type = "pqtl")
metadata <- list(mr = c(keys, list(target_id = "IL23R", indication_id = "D003424")),
                 coloc = keys)
without_locus <- karim_pos(mr, coloc, metadata = metadata)$candidates
stopifnot(without_locus$match_basis == "exact_identifiers",
          without_locus$missing_fields == "l2g_share",
          is.na(without_locus$historical_launch_rate))
metadata$mr$l2g_share <- x$l2g_share
wrong_locus <- metadata
wrong_locus$coloc$locus_id <- "rs7528804"
unmatched <- karim_pos(mr, coloc, metadata = wrong_locus)$candidates
stopifnot(unmatched$status == "coloc_unmatched", is.na(unmatched$historical_launch_rate))
result <- karim_pos(mr, coloc, metadata = metadata)
r <- result$candidates
stopifnot(r$match_basis == "exact_identifiers", r$status == "thresholds_met",
          r$reference_group == "supported", r$measured, r$mesh_similarity == 1,
          r$l2g_share == .55, r$historical_launch_rate == 20 / 36)
print(r[c("target_id", "indication_id", "outcome_id", "locus_id", "b", "se",
          "mr_p", "h4", "l2g_share", "mesh_similarity", "measured",
          "match_basis", "reference_group", "historical_launch_rate")], row.names = FALSE)
print(result$benchmark[c("group", "phase1_n", "launched_n", "historical_launch_rate")],
      row.names = FALSE)
