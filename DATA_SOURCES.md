# 参照データの出典と再生成

| ファイル | 内容と変換 |
|----|----|
| `inst/extdata/benchmarks.tsv.gz` | Karim由来の集計Parquetを `pos_id` 順で抽出した116行。候補の参照先は、v2 Figure 1a の MR＋coloc 比較。 |
| `inst/extdata/mapping.tsv.gz` | 臨床マッピングを遺伝子・適応症のMeSH ID・GWAS IDごとに集約。L2G shareとMeSH類似度は、それぞれ一意の値を採用。 |
| `inst/extdata/measured.tsv.gz` | 遺伝子ごとに一意に解決できるpQTL測定対象のフラグ。 |
| `reproducibility/data/delange_il23r_source.csv` | 独立検証で使う公開統計の一座位の抽出値。由来と照合手順は [実データ検証](https://daikikumakura.github.io/geneticPoS/reproducibility/INDEPENDENT_PQTL.md) に記載。 |

Karim, Hukku, Ariano
ほかの公開資料に基づく加工スナップショットです。上流GitHubのプロジェクトは
CC BY 4.0
を明示しています。Zenodoの個別ファイル、および上流の第三者由来データを含む加工表への再配布条件は公開前に確認してください。GPL-3
は本パッケージのコードに適用されます。 [Karim
原著](https://doi.org/10.64898/2026.02.23.26346731) ·
[著者リポジトリ](https://github.com/mohdkarim/mrcoloc) ·
[著者データのZenodo DOI](https://doi.org/10.5281/zenodo.18451758) ·
[Minikel ら](https://doi.org/10.1038/s41586-024-07316-0)

参照を再生成するには、2つの入力Parquetを同じフォルダに置き、DuckDBのPythonパッケージを入れた環境で実行します。

``` sh
python reproducibility/build_karim_refs.py PATH_TO_PARQUETS NEW_OUTPUT_DIRECTORY
```

同梱TSVと再生成結果は展開後の表として比較できます。著者の上流解析を再実行する場合は著者リポジトリを参照してください。上記のZenodo
DOIは著者資料の識別子です。このパッケージの加工表用に新規のZenodo
DOIを発行した場合は、版とファイルのハッシュをこの文書に記録してください。
