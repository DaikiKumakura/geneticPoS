library(geneticPoS)
stopifnot(identical(getNamespaceExports("geneticPoS"), "karim_pos"))
keys <- data.frame(exposure_id = c("P1", "P2", "P3", "P4"), outcome_id = "D1",
                   build = "GRCh38", locus_id = "L1")
mr <- cbind(keys, mr_id = paste0("M", 1:4), target_id = "G1", indication_id = "UC",
            mr_p = 4e-10, l2g_share = c(.67, NA, .67, .67),
            mesh_similarity = .91, measured = TRUE)
coloc <- cbind(keys[1:3, ], coloc_id = paste0("K", 1:3), h4 = c(.93, .93, .31))
r <- karim_pos(mr, coloc)
stopifnot(identical(r$candidates$status, c("thresholds_met", "missing_inputs",
                                         "thresholds_not_met", "coloc_unmatched")),
          identical(r$candidates$reference_group, c("supported", NA, NA, NA)),
          identical(r$benchmark$historical_launch_rate, c(20/36, 760/7164)))
extra <- rbind(coloc, transform(coloc[1, ], coloc_id = "K4"))
stopifnot(karim_pos(mr, extra)$candidates$status[1] == "coloc_ambiguous")
mr$coloc_id <- c("K4", NA, NA, NA)
stopifnot(karim_pos(mr, extra)$candidates$matched_coloc_id[1] == "K4")

# Known exact keys in the installed reference; user evidence here is illustrative.
m <- transform(mr[1, ], target_id = "PCSK9", indication_id = "D002318",
               outcome_id = "GCST90038595", l2g_share = NA_real_,
               mesh_similarity = NA_real_, measured = NA, coloc_id = NA_character_)
k <- transform(coloc[1, ], outcome_id = "GCST90038595")
r <- karim_pos(m, k)
stopifnot(r$candidates$l2g_share == .82, r$candidates$mesh_similarity == 1,
          r$candidates$measured, r$candidates$status == "thresholds_met",
          r$candidates$l2g_share_source == "karim_mapping", is.na(r$inputs$mr$l2g_share),
          nrow(r$references) == 116L, any(r$references$source_table == "ST11", na.rm = TRUE))
m$l2g_share <- .1
r <- karim_pos(m, k)
stopifnot(r$candidates$l2g_share == .1, r$candidates$l2g_share_source == "user",
          r$candidates$status == "thresholds_not_met")

minimal_mr <- data.frame(gene = "PCSK9", pval = 4e-10)
minimal_coloc <- data.frame(PP.H4.abf = .93)
metadata <- list(mr = list(indication_id = "D002318", exposure_id = "P1",
                            outcome_id = "GCST90038595", build = "GRCh38", locus_id = "L1"),
                 coloc = data.frame(source_row = 1L, exposure_id = "P1",
                                    outcome_id = "GCST90038595", build = "GRCh38", locus_id = "L1"))
stopifnot(karim_pos(minimal_mr, minimal_coloc)$candidates$status == "missing_inputs",
          karim_pos(minimal_mr, minimal_coloc, metadata = metadata)$candidates$status == "thresholds_met")
stopifnot(inherits(try(karim_pos(m, k, metadata = list(mr = list(outcome_id = "other"))),
                        silent = TRUE), "try-error"))

links <- data.frame(mr_id = "MR:1", coloc_id = "coloc:1", basis = "Test protocol")
meta <- list(mr = list(indication_id = "D002318", outcome_id = "GCST90038595"))
linked <- karim_pos(minimal_mr, minimal_coloc, metadata = meta, links = links)$candidates
stopifnot(linked$status == "thresholds_met", linked$match_basis == "user_confirmed",
          linked$historical_launch_rate == 20/36)
meta$coloc <- list(outcome_id = "other")
conflict <- karim_pos(minimal_mr, minimal_coloc, metadata = meta, links = links)$candidates
stopifnot(conflict$status == "link_conflict", is.na(conflict$historical_launch_rate))
