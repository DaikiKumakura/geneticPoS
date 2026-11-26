\name{karim_pos}
\alias{karim_pos}
\title{Relate user-supplied MR and colocalization results to the Karim benchmark}
\usage{karim_pos(mr, coloc, mapping = list(), metadata = list(), links = NULL)}
\arguments{
\item{mr}{Data frame or local CSV/TSV with mr_id, target_id, indication_id,
exposure_id, outcome_id, build, locus_id and numeric mr_p. Optional columns:
numeric l2g_share and mesh_similarity, logical measured, and coloc_id.}
\item{coloc}{Data frame or local CSV/TSV with coloc_id, exposure_id,
outcome_id, build, locus_id and numeric h4. Supply signal_id in both
inputs when matching individual signals.}
\item{mapping}{Optional named column mappings for mr and coloc.}
\item{metadata}{Optional list with mr and coloc elements. Each is a named
list of file-wide constants or a data frame keyed by one-based source_row.
Values fill missing fields; conflicting values are rejected. Supply
qtl_type = "eqtl" for known eQTL results to mark them outside the pQTL reference.}
\item{links}{Optional data frame or CSV/TSV with mr_id, coloc_id and basis.
Each link asserts a user-verified correspondence. Conflicting identifiers
prevent reference assignment. The MR outcome study and indication are still required.}
}
\description{Keep user-selected results and check their correspondence to
the published Figure 1a MR+coloc thresholds. The input values are user
verified. The reported rates are historical group proportions.}
\details{Missing mapping values are looked up in the bundled snapshot by
exact gene symbol, MeSH indication ID and outcome ID. Measured status uses
the gene symbol. Conflicting or unrecorded values stay missing. User-supplied
values take precedence.}
\value{A list containing candidates (one row per MR result), benchmark
(the applied contrast), references (the full bundled benchmark table),
and inputs (source tables).}
\examples{
keys <- data.frame(exposure_id = "P1", outcome_id = "D1",
                   build = "GRCh38", locus_id = "L1")
mr <- cbind(keys, mr_id = "M1", target_id = "G1", indication_id = "UC",
            mr_p = 4e-10, l2g_share = 0.67, mesh_similarity = 0.91, measured = TRUE)
coloc <- cbind(keys, coloc_id = "K1", h4 = 0.93)
karim_pos(mr, coloc)
}
