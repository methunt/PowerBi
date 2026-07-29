<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/hero-dark.svg">
  <img alt="Power BI, as source code — a semantic model and report you can diff, a scripted month of synthetic data, and two tools that bulk-edit PBIR and TMDL files from a CSV. 4,894 BigQuery jobs modelled and $662.98 attributed; 119 field references repointed in one run; 240 TMDL fields documented from one CSV." src="assets/hero-light.svg">
</picture>

<p>
  <img alt="Power BI PBIP" src="https://img.shields.io/badge/Power%20BI-PBIP-F2C811?style=flat-square&logo=powerbi&logoColor=black">
  <img alt="PBIR" src="https://img.shields.io/badge/report-PBIR-7C3AED?style=flat-square">
  <img alt="TMDL" src="https://img.shields.io/badge/model-TMDL-0891B2?style=flat-square">
  <img alt="Python and PowerShell" src="https://img.shields.io/badge/Python%20%C2%B7%20PowerShell-stdlib%20only-3776AB?style=flat-square">
  <img alt="Licence Apache 2.0" src="https://img.shields.io/badge/licence-Apache--2.0-059669?style=flat-square">
</p>

Three Power BI projects that all treat the artefacts as **files rather than clicks**: a semantic model and report kept as diffable text, a synthetic month of warehouse data written by a script, and two tools that bulk-edit PBIR and TMDL from a CSV.

| | | |
|---|---|---|
| 💸 | **[BigQuery + dbt Cost Observability](#-observability)** | Where the warehouse spend went, and which dbt model, test or hook spent it. **Runs offline** against a committed synthetic month — no cloud account. |
| 🔁 | **[PBIR Field Remap Toolkit](#-remap)** | Repoint every field reference in a report from one table or column to another, from a CSV. **Writes in place — commit first.** |
| 📄 | **[Semantic Model Descriptions](#-descriptions)** | Load field descriptions into a TMDL model from a CSV, as the `///` comments Desktop shows as tooltips. |

---

<a id="-observability"></a>
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/section-observability-dark.svg">
  <img alt="Project 1 — BigQuery + dbt Cost Observability. Where the warehouse spend went, and which dbt model, test or hook spent it. Ships a synthetic month, so it refreshes with no cloud account." src="assets/section-observability-light.svg">
</picture>

A Power BI semantic model over BigQuery's own `INFORMATION_SCHEMA` job history, joined to `dbt_artifacts`. It answers the two questions cloud billing cannot: **where did the spend go**, and **which dbt node spent it**.

| | | |
|---|---|---|
| 📊 | **7 report pages** across query usage and dbt execution | interactive tabs, drillthrough to a single statement, and two Explore grids built on field parameters |
| 🧪 | **One synthetic month**, 4,894 jobs, $662.98 attributed | generated from a fixed seed by a stdlib-only script; no production data, and re-running reproduces the CSVs byte for byte |
| 🔌 | **One parameter switches the source** | `p_DataSource` takes the whole model from live BigQuery to the committed CSVs and back |

**[Read the full README →](Bigquery%20%26%20Dbt%20Cost%20Observability/README.md)** — architecture, every visual and the question it answers, the three-branch cost attribution, setup parameters, and the gotchas.

---

<a id="-remap"></a>
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/section-remap-dark.svg">
  <img alt="Project 2 — PBIR Field Remap Toolkit. Repoint every field reference in a report from one table or column to another, driven by a CSV. Inventory first, then one command, no flags to get wrong." src="assets/section-remap-light.svg">
</picture>

Rename a column in the semantic model and every visual bound to it breaks, with nothing to tell you how many places are affected. Two Python scripts, no dependencies: one inventories every field reference, the other repoints them from a CSV.

| | | |
|---|---|---|
| 🔎 | **Inventory first** | a read-only pass found **257 bindings across 187 JSON files** in this repo's own report |
| 🔁 | **Rewrites the derived strings too** | `queryRef` and `selector.metadata` are rebuilt from the field pair, so they cannot disagree with it |
| 🔖 | **The deep scan is not optional** | it always runs, because the same 16 rules find **119 changes rather than 54** with it — and **62 of the extra 65 are inside 12 bookmark files** |

**[Read the full README →](PBIR%20Field%20Remap%20Toolkit/README.md)** — the CSV contract, every JSON location it rewrites, the output logs, and the ways it can bite you.

---

<a id="-descriptions"></a>
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/section-descriptions-dark.svg">
  <img alt="Project 3 — Semantic Model Descriptions. Load field descriptions into a TMDL model from a CSV, as the /// comments that surface as tooltips in Power BI Desktop." src="assets/section-descriptions-light.svg">
</picture>

Documenting a model in Desktop is a per-field click. One PowerShell script turns a CSV into the `///` comment lines TMDL actually stores — and TMDL has no `description:` property, so this is the only form that parses.

| | | |
|---|---|---|
| 📄 | **240 fields in one command** | 142 columns and 98 measures across 16 tables, in this repo's own model |
| ♻️ | **Safe to re-run** | existing comments are replaced in place, never stacked, so the CSV stays the source of truth |
| 🔒 | **Writes UTF-8 without a BOM** | a BOM in a PBIP file makes Desktop refuse to open the project |

**[Read the full README →](Semantic%20Model-Descriptions%20Mapping/README.md)** — the CSV contract, what it writes, and the ways it can report success while having done nothing.

---

## 📚 Reference

Everything below is reference — read it when you need it.

### 📁 Repo layout

```
PowerBi/
├─ Bigquery & Dbt Cost Observability/   PBIP project, synthetic data, generators
├─ PBIR Field Remap Toolkit/            inventory + remap scripts, agent skill
├─ Semantic Model-Descriptions Mapping/ TMDL description loader, agent skill
├─ scripts/                             this page's SVG generator and its specs
└─ assets/                              this page's light/dark SVGs
```

Each project folder is self-contained: its own README, its own assets, no shared code. The `&` in the first folder name is a shell operator, so **quote the path** in any command you run against it.

### 🤖 Agent skills

Both toolkits ship a `SKILL.md` describing their workflow for an assistant that supports skills — required inputs, validation gates, and what to report back. They are instructions for driving the scripts, not a second implementation of them.

### 🎨 Rebuilding this page's graphics

The hero and section banners are generated as light **and** dark variants from a spec, so the two cannot drift apart. The cost figures in the hero are read from the observability project's `summary.json`, which its data generator writes.

```bash
python scripts/build_readme_assets.py --spec scripts/readme-assets.root.json
python scripts/build_readme_assets.py --spec scripts/readme-assets.remap.json
python scripts/build_readme_assets.py --spec scripts/readme-assets.descriptions.json
```

Stdlib only. Each spec names its own `out_dir`, so the second and third write into their project's `assets/` folder.

### 📄 Licence

[Apache-2.0](LICENSE). The synthetic data is synthetic: no production data, table names or addresses appear anywhere in this repository.
