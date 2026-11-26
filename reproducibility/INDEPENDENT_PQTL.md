# 独立pQTL実データによる Karim 支持群の適用試験

geneticPoS 0.5.0 のインストール済みパッケージで、IL23R × クローン病の1組を検証した。外部の係数から Wald ratio を再計算し、Zheng らの公開 PWCoCo 結果と対応付け、Karim Figure 1a の支持群を参照した。

| 項目 | 検証値 |
|---|---:|
| cis-pQTL / GWAS | rs11581607 / GCST004132 |
| pQTL 効果・標準誤差（A 対 G） | −0.42 / 0.0491 |
| GWAS 効果・標準誤差（A 対 G、原ファイル表記） | 0.7935 / 0.0388 |
| Wald ratio / 標準誤差 | −1.889286 / 0.09238095 |
| MR p値 | 5.881896 × 10⁻⁹³ |
| 条件付き共局在 H4 | 0.993 |
| L2G share | 0.55 |
| MeSH 類似度 / pQTL 測定対象 | 1 / TRUE |
| 対応付け / 判定 | exact_identifiers / supported |
| 支持群の過去上市割合 | 20/36（55.56%） |

MR は同じアレルの公開係数を用い、曝露係数の不確実性を省いた一次近似で Wald ratio の標準誤差を計算した。H4 は論文掲載精度で転記した。曝露側は rs11581607 で揃え、アウトカム側では de Lange らの同じクローン病 GWAS を使用した。MR は単一変異の周辺効果を使用し、共局在は条件付き解析である。以前確認した Zheng 補足表 S7 の MR は別の GWAS を使用するため、この試験の入力から除外した。 [Zheng らの論文と補足資料](https://pmc.ncbi.nlm.nih.gov/articles/PMC7610464/) [de Lange らの原著](https://doi.org/10.1038/ng.3760)

L2G share は Minikel の行 244136。Open Targets が rs11581607 を GCST004132 の座位として記載している。GWAS 原ファイルの対応変異と Minikel 行について、研究、遺伝子、疾患、GWAS p 値（6.33 × 10⁻⁹³）および log OR の絶対値を照合した。この 0.55 を `metadata` で明示し、MeSH 類似度と測定対象はパッケージ内蔵参照から解決した。 [Open Targets の座位記載](https://blog.opentargets.org/open-targets-genetics-new-release-is-out/) [Minikel 公開参照](https://github.com/ericminikel/genetic_support/blob/main/data/assoc.tsv.gz)

照合キーは pQTL アッセイ、GWAS ID、ゲノムビルド、rsID。L2G share を渡さない場合、および coloc 側を別座位に変えた場合は、上市割合が欠損のままであることも確認した。55.56% は Karim の過去の支持群で第1相から上市した割合であり、この候補固有の確率として解釈できない。

## 再実行

リポジトリ直下でパッケージをインストールし、同梱の一座位の抽出値を使って実行します。

```sh
R CMD INSTALL .
Rscript --vanilla reproducibility/check_delange_pqtl.R
```

## 公開資料から抽出し直す

`reproducibility/data/` に Zheng Supplementary Data の `zheng_s3.xlsx`、de Lange 原ファイルを `delange_cd_GCST004132.txt.gz`、Minikel の `assoc.tsv.gz` を `minikel_assoc.tsv.gz` として配置する。Python には openpyxl、R には geneticPoS 0.5.0 が必要。 [Zheng 補足ファイル一覧](https://www.nature.com/articles/s41588-020-0682-6#Sec38) [de Lange GWAS データ](https://ftp.ebi.ac.uk/pub/databases/gwas/summary_statistics/GCST004001-GCST005000/GCST004132/cd_build37_40266_20161107.txt.gz) [Minikel データ](https://raw.githubusercontent.com/ericminikel/genetic_support/main/data/assoc.tsv.gz)

```sh
python reproducibility/check_delange_pqtl.py
Rscript --vanilla reproducibility/check_delange_pqtl.R
```
