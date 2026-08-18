<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/hero-dark.svg">
  <img alt="Power BI, as source code — two dashboards that answer a real question, two tools that kill a hundred clicks, and every artefact kept as text you can diff." src="assets/hero-light.svg">
</picture>

<p>
  <img alt="Power BI PBIP" src="https://img.shields.io/badge/Power%20BI-PBIP-F2C811?style=flat-square&logo=powerbi&logoColor=black">
  <img alt="PBIR" src="https://img.shields.io/badge/report-PBIR-7C3AED?style=flat-square">
  <img alt="TMDL" src="https://img.shields.io/badge/model-TMDL-0891B2?style=flat-square">
  <img alt="Python and PowerShell" src="https://img.shields.io/badge/Python%20%C2%B7%20PowerShell-stdlib%20only-3776AB?style=flat-square">
  <img alt="Licence Apache 2.0" src="https://img.shields.io/badge/licence-Apache--2.0-059669?style=flat-square">
</p>

Four Power BI projects, none of them clicked together by hand. **The models, the reports and the data are all text** — so you can diff them, script them, and see exactly how each one was built. Two of them are dashboards that answer a real question; two are tools I wrote because the same edit kept taking a hundred clicks.

Each project lives in its own repo now — this page is the index. Click through for the full README, source, and history of each.

| | | |
|---|---|---|
| 💸 | **[BigQuery + dbt Cost Observability](#-observability)** | Where the warehouse spend went, and which dbt model, test or hook spent it. **Runs offline** against a committed synthetic month — no cloud account. |
| 📼 | **[What's On Netflix](#-netflix)** | What the Netflix catalogue is made of, where it comes from, and when it arrived. **Live report — opens in a browser, no sign-in.** |
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

**[Open the repo →](https://github.com/methunt/pbi-bigquery-dbt-cost-observability)** — architecture, every visual and the question it answers, the three-branch cost attribution, setup parameters, and the gotchas.

The dbt half lives in a separate repo: **[dbt Template for BigQuery Cost Observability →](https://github.com/methunt/dbt-bigquery-cost-observability-template)** — a runnable dbt project that emits the `dbt_artifacts` metadata and job labels this report reads.

---

<a id="-netflix"></a>
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/section-netflix-dark.svg">
  <img alt="Project 2 — What's On Netflix. One Kaggle CSV of everything Netflix listed up to September 2021, turned into a model that answers what the catalogue is made of, where it comes from, and when it arrived." src="assets/section-netflix-light.svg">
</picture>

A public Kaggle snapshot of the Netflix catalogue, turned into a semantic model and a three-view report. Three of its columns hold comma-separated lists rather than values, and getting past that is most of the work — a title filed under `Dramas, International Movies` cannot be grouped by genre until the list becomes rows.

| | | |
|---|---|---|
| 📼 | **8,804 titles, 122 countries, 42 genres** | genre and country split into their own rows, so the catalogue can be sliced by either without double-counting a title |
| 🔎 | **The library stopped growing in 2019** | films peaked at 1,424 added that year, series a year later at 595 — the two halves did not turn at the same time |
| ⚙️ | **One shared query, two grains** | the CSV is cleansed once and read by both a bridge table and a title-grain table; dropping an unused cast explosion cut the bridge **7.8×** with no number on the page changing |

**[Open the repo →](https://github.com/methunt/pbi-netflix-dashboard)** — the dataset and its gaps, every transformation and the question it unlocks, the findings with their numbers, and the three "total titles" that all disagree and are all correct.

---

<a id="-remap"></a>
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/section-remap-dark.svg">
  <img alt="Project 3 — PBIR Field Remap Toolkit. Repoint every field reference in a report from one table or column to another, driven by a CSV. Inventory first, then one command, no flags to get wrong." src="assets/section-remap-light.svg">
</picture>

Rename a column in the semantic model and every visual bound to it breaks, with nothing to tell you how many places are affected. Two Python scripts, no dependencies: one inventories every field reference, the other repoints them from a CSV.

| | | |
|---|---|---|
| 🔎 | **Inventory first** | a read-only pass found **257 bindings across 187 JSON files** in this repo's own report |
| 🔁 | **Rewrites the derived strings too** | `queryRef` and `selector.metadata` are rebuilt from the field pair, so they cannot disagree with it |
| 🔖 | **The deep scan is not optional** | it always runs, because the same 16 rules find **119 changes rather than 54** with it — and **62 of the extra 65 are inside 12 bookmark files** |

**[Open the repo →](https://github.com/methunt/pbir-field-remap-toolkit)** — the CSV contract, every JSON location it rewrites, the output logs, and the ways it can bite you.

---

<a id="-descriptions"></a>
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/section-descriptions-dark.svg">
  <img alt="Project 4 — Semantic Model Descriptions. Load field descriptions into a TMDL model from a CSV, as the /// comments that surface as tooltips in Power BI Desktop." src="assets/section-descriptions-light.svg">
</picture>

Documenting a model in Desktop is a per-field click. One PowerShell script turns a CSV into the `///` comment lines TMDL actually stores — and TMDL has no `description:` property, so this is the only form that parses.

| | | |
|---|---|---|
| 📄 | **240 fields in one command** | 142 columns and 98 measures across 16 tables, in this repo's own model |
| ♻️ | **Safe to re-run** | existing comments are replaced in place, never stacked, so the CSV stays the source of truth |
| 🔒 | **Writes UTF-8 without a BOM** | a BOM in a PBIP file makes Desktop refuse to open the project |

**[Open the repo →](https://github.com/methunt/pbi-semantic-model-mapping)** — the CSV contract, what it writes, and the ways it can report success while having done nothing.

---

## 📚 Reference

Everything below is reference — read it when you need it.

### 📁 Repo index

This repo is the index only — each project moved to its own repo, listed below.

| Repo | Contents |
|---|---|
| [pbi-bigquery-dbt-cost-observability](https://github.com/methunt/pbi-bigquery-dbt-cost-observability) | PBIP project, synthetic data, generators |
| [pbi-netflix-dashboard](https://github.com/methunt/pbi-netflix-dashboard) | PBIP project, Kaggle CSV, page captures |
| [pbir-field-remap-toolkit](https://github.com/methunt/pbir-field-remap-toolkit) | inventory + remap scripts, agent skill |
| [pbi-semantic-model-mapping](https://github.com/methunt/pbi-semantic-model-mapping) | TMDL description loader, agent skill |

This repo (`PowerBi`) keeps only `scripts/` and `assets/` for generating this page's hero/section images.

### 🤖 Agent skills

Both toolkits ship a `SKILL.md` describing their workflow for an assistant that supports skills — required inputs, validation gates, and what to report back. They are instructions for driving the scripts, not a second implementation of them.

### 📄 Licence

[Apache-2.0](LICENSE). The synthetic data is synthetic: no production data, table names or addresses appear anywhere in this repository.
