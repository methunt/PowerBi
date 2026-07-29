# Add Power BI Field Descriptions from CSV

Quick tool to add field descriptions to Power BI semantic models (PBIR TMDL format) from a CSV file.

## Quick Start

1. **Prepare your CSV** with these columns:
   - `Table Name` - the table name (e.g., `dim_Customer`)
   - `Field Name` - the column or measure name
   - `Field Type` - either `Column`, `Measure`, `Calculated Column`, or `Field Parameter`
   - `Description` - the description text

   See `sample-descriptions.csv` for an example.

2. **Run the script:**

   ```powershell
   .\Add-PBIRDescriptions.ps1 `
       -SemanticModelPath "D:\Path\To\YourModel.SemanticModel" `
       -CsvPath "C:\Path\To\descriptions.csv"
   ```

3. **Check the output** - the script will report how many descriptions were added/updated.

## Requirements

- Power BI semantic model must be saved in **TMDL format**
  - Enable in Power BI Desktop: File > Options > Preview Features > "Store semantic model using TMDL format"
  - Your model should have a `definition\tables` folder (not `model.bim`)

## What It Does

Adds TMDL documentation comments (`///`) above each field declaration. These appear as tooltips in Power BI Desktop's field list.

**Before:**
```tmdl
column CustomerKey
    dataType: int64
```

**After:**
```tmdl
/// Unique identifier for customer records. Used as primary key in relationships.
column CustomerKey
    dataType: int64
```

## Documentation

See `SKILL.md` for complete documentation, troubleshooting, and technical details.
