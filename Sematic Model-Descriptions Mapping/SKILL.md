---
description: Add field descriptions from CSV to Power BI semantic model (PBIR TMDL format)
---

# Add Power BI Field Descriptions from CSV

This skill helps add or update field descriptions in a Power BI semantic model saved in TMDL format (Power BI Project files). Descriptions are added as TMDL documentation comments (`///`) that appear as tooltips when users hover over fields in Power BI Desktop.

## What This Skill Does

1. Reads field descriptions from a CSV file
2. Matches them to columns and measures in the Power BI semantic model
3. Adds TMDL documentation comments (`///`) above each field declaration
4. Handles multi-line descriptions by creating multiple `///` comment lines
5. Replaces existing descriptions if they already exist

## Requirements

- Power BI semantic model must be saved in **TMDL format** (not TMSL/model.bim)
  - In Power BI Desktop: File > Options > Preview Features > "Store semantic model using TMDL format"
  - The model should have a `definition\tables` folder, not a `model.bim` file
- CSV file with description mappings

## Questions to Ask Users

Before running the script, gather this information:

1. **Where is your Power BI semantic model?**
   - Ask for the full path to the `.SemanticModel` folder
   - Example: `D:\Projects\MyReport\MyReport.SemanticModel`
   - Validate: Check that `definition\tables` folder exists inside it

2. **Where is your CSV file with descriptions?**
   - Ask for the full path to the CSV file
   - Example: `C:\Users\YourName\Downloads\descriptions.csv`
   - Validate: File exists and has required columns

3. **What should happen to existing descriptions?**
   - The script always overwrites existing descriptions
   - Inform user: "Any existing field descriptions will be replaced with the new ones from the CSV"

## CSV File Format

The CSV must have exactly these 4 columns (case-sensitive):

| Column Name | Description | Example |
|------------|-------------|---------|
| `Table Name` | TMDL table name (matches the `.tmdl` filename) | `dim_Customer` |
| `Field Name` | Column or measure name (exactly as in TMDL) | `CustomerKey` |
| `Field Type` | One of: `Column`, `Calculated Column`, `Field Parameter`, or `Measure` | `Column` |
| `Description` | The description text (can include line breaks) | `Unique identifier for customer` |

**Important notes:**
- `Field Type` values: All non-Measure types (`Column`, `Calculated Column`, `Field Parameter`) map to TMDL `column` declarations
- `Measure` maps to TMDL `measure` declarations
- Multi-line descriptions are automatically split into multiple `///` comment lines
- Table and field names are case-sensitive and must match exactly

### Sample CSV

See `sample-descriptions.csv` in this folder for a template.

## Usage

### Option 1: Run Manually

```powershell
.\Add-PBIRDescriptions.ps1 `
    -SemanticModelPath "D:\Path\To\Your\Model.SemanticModel" `
    -CsvPath "C:\Path\To\descriptions.csv"
```

### Option 2: Via Copilot Skill

When this skill is invoked, the agent will:
1. Ask for the semantic model path
2. Ask for the CSV file path
3. Validate both paths exist
4. Run the script
5. Report summary statistics (inserted, replaced, not found)

## Output

The script reports:
- **Descriptions inserted**: New descriptions added
- **Descriptions replaced**: Existing descriptions updated
- **Fields not found**: CSV rows that couldn't be matched to any field in the model

Example output:
```
[SAVED] dim_Customer.tmdl (15 field(s) processed)
[SAVED] fact_Sales.tmdl (42 field(s) processed)
...
=== Summary ===
  Descriptions inserted : 120
  Descriptions replaced : 15
  Fields not found      : 2
```

## How It Works (Technical Details)

### TMDL Documentation Comments

Power BI's TMDL format supports documentation comments using triple-slash (`///`) syntax, similar to C# XML documentation:

```tmdl
/// Customer's unique identifier used for relationships
column CustomerKey
    dataType: int64
    sourceColumn: CustomerKey
```

Multi-line descriptions become multiple comment lines:

```tmdl
/// Primary metric for campaign performance.
/// Calculated as total impressions divided by reach.
/// Higher values indicate better ad visibility.
measure 'Campaign Frequency' = [Total Impressions] / [Total Reach]
    formatString: #,0.00
```

### Matching Logic

The script:
1. Groups CSV rows by `Table Name`
2. For each table, reads the corresponding `.tmdl` file from `definition\tables\`
3. Uses regex to find column/measure declarations: `^\t(column|measure)\s+('?FieldName'?)`
4. Handles quoted and unquoted field names
5. Looks for existing `///` comments immediately before the declaration
6. Removes old comments (if any) and inserts new ones

### Edge Cases Handled

- **Multi-line descriptions**: Automatically split on newlines (`\r\n`, `\n`, or `\r`)
- **Special characters in names**: Supports quoted field names with spaces, dots, etc.
- **Multiple existing comments**: Removes all consecutive `///` lines before replacing
- **File encoding**: Preserves UTF-8 encoding and CRLF line endings

## Troubleshooting

### Error: "TMDL file not found for table 'X'"
- The `Table Name` in CSV doesn't match any `.tmdl` file in `definition\tables\`
- Check spelling and case sensitivity
- Verify the table exists in the model

### Error: "Field not found: 'X' in table 'Y'"
- The `Field Name` doesn't match any column/measure in that table's `.tmdl` file
- Check spelling, case, and spaces
- Verify the field exists and isn't in a different table

### Error: "Parsing error - Unsupported property"
- This was an issue in earlier versions (before using `///` comments)
- If you see this, ensure you're using the latest version of the script
- TMDL doesn't support `description:` as a property - only `///` comments work

### Power BI Desktop shows error after running script
- Close and reopen the Power BI Desktop file
- If error persists, check the TMDL syntax in the affected `.tmdl` file
- Look for malformed `///` comments or unescaped special characters

## Files in This Folder

- `Add-PBIRDescriptions.ps1` - Main PowerShell script
- `SKILL.md` - This documentation (skill definition)
- `sample-descriptions.csv` - Template CSV file
- `README.md` - Quick start guide (optional)

## Version History

- **v2.0** (2026-06-09): Multi-line description support, proper TMDL `///` syntax
- **v1.0** (2026-06-09): Initial version (incorrect `description:` property)
