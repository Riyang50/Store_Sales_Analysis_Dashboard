"""
data_cleaning.py
-----------------
Store Sales Analysis Dashboard - Data Cleaning & Feature Engineering

Author : Riyangshu Mahato
Purpose: Clean the raw retail sales export (Dataset/sales.csv), fix data types,
         handle missing values and duplicates, engineer new features, flag
         outliers, and export an analysis-ready dataset for SQL / Power BI.

Run:
    python data_cleaning.py
"""

import pandas as pd
import numpy as np
from pathlib import Path

RAW_PATH = Path("../Dataset/sales.csv")
CLEAN_CSV_PATH = Path("../Dataset/Cleaned_Data.csv")
CLEAN_XLSX_PATH = Path("../Dataset/Cleaned_Data.xlsx")


def load_data(path: Path) -> pd.DataFrame:
    df = pd.read_csv(path)
    print(f"Loaded {len(df):,} raw rows from {path.name}")
    return df


def clean_text_columns(df: pd.DataFrame) -> pd.DataFrame:
    """Strip whitespace and standardize casing on categorical text columns."""
    text_cols = ["Segment", "City", "State", "Region", "Product Category",
                 "Sub Category", "Product Name", "Payment Mode", "Order Priority",
                 "Customer Name"]
    for col in text_cols:
        df[col] = df[col].astype(str).str.strip()
        df[col] = df[col].replace({"nan": np.nan, "None": np.nan})
        df[col] = df[col].str.title()

    # Fix known inconsistent city name variants
    city_fixes = {
        "St Louis": "St. Louis",
        "Newyork City": "New York City",
    }
    df["City"] = df["City"].replace(city_fixes)
    return df


def clean_numeric_columns(df: pd.DataFrame) -> pd.DataFrame:
    """Strip stray currency symbols / whitespace and cast to proper numeric dtypes."""
    df["Sales"] = (
        df["Sales"].astype(str).str.replace("$", "", regex=False).str.strip().astype(float)
    )
    df["Quantity"] = (
        df["Quantity"].astype(str).str.strip().astype(float).astype("Int64")
    )
    df["Discount"] = pd.to_numeric(df["Discount"], errors="coerce")
    df["Profit"] = pd.to_numeric(df["Profit"], errors="coerce")
    df["Shipping Cost"] = pd.to_numeric(df["Shipping Cost"], errors="coerce")
    return df


def clean_dates(df: pd.DataFrame) -> pd.DataFrame:
    """Parse mixed-format date strings into a single consistent datetime dtype."""
    for col in ["Order Date", "Ship Date"]:
        df[col] = pd.to_datetime(df[col], format="mixed", dayfirst=False, errors="coerce")
    return df


def handle_missing_values(df: pd.DataFrame) -> pd.DataFrame:
    """Impute or drop missing values using business-appropriate rules."""
    before = len(df)

    # Customer Name: fill from Customer ID lookup where another row has it
    name_lookup = (
        df.dropna(subset=["Customer Name"])
        .drop_duplicates("Customer ID")
        .set_index("Customer ID")["Customer Name"]
    )
    df["Customer Name"] = df["Customer Name"].fillna(df["Customer ID"].map(name_lookup))

    # City: fill with the most common city for that State
    city_mode = df.groupby("State")["City"].agg(lambda s: s.mode().iat[0] if not s.mode().empty else np.nan)
    df["City"] = df.apply(
        lambda r: city_mode.get(r["State"]) if pd.isna(r["City"]) else r["City"], axis=1
    )

    # Discount: assume no discount when missing
    df["Discount"] = df["Discount"].fillna(0)

    # Shipping Cost: fill with category median
    df["Shipping Cost"] = df["Shipping Cost"].fillna(
        df.groupby("Product Category")["Shipping Cost"].transform("median")
    )

    # Order Priority: fill with mode
    df["Order Priority"] = df["Order Priority"].fillna(df["Order Priority"].mode().iat[0])

    # Profit: recompute from Sales/Discount/Shipping Cost where missing
    est_profit = df["Sales"] * (1 - df["Discount"]) * 0.30 - df["Shipping Cost"]
    df["Profit"] = df["Profit"].fillna(est_profit)

    # Drop any row still missing a critical key field (Order ID, dates, Sales)
    df = df.dropna(subset=["Order ID", "Order Date", "Sales", "Quantity"])

    print(f"Missing-value handling complete. Rows: {before:,} -> {len(df):,}")
    return df


def remove_duplicates(df: pd.DataFrame) -> pd.DataFrame:
    before = len(df)
    df = df.drop_duplicates(subset=["Order ID", "Product Name", "Customer ID"], keep="first")
    print(f"Removed {before - len(df):,} duplicate rows")
    return df


def flag_outliers(df: pd.DataFrame) -> pd.DataFrame:
    """Flag statistical outliers in Profit using the IQR method (kept, not dropped, but tagged)."""
    q1, q3 = df["Profit"].quantile([0.25, 0.75])
    iqr = q3 - q1
    lower, upper = q1 - 1.5 * iqr, q3 + 1.5 * iqr
    df["Is_Profit_Outlier"] = ~df["Profit"].between(lower, upper)
    print(f"Flagged {df['Is_Profit_Outlier'].sum():,} profit outliers (IQR method)")
    return df


def engineer_features(df: pd.DataFrame) -> pd.DataFrame:
    """Add derived columns used throughout SQL, EDA, and Power BI layers."""
    df["Order Year"] = df["Order Date"].dt.year
    df["Order Month"] = df["Order Date"].dt.month
    df["Order Month Name"] = df["Order Date"].dt.strftime("%b")
    df["Order Quarter"] = df["Order Date"].dt.quarter
    df["Shipping Days"] = (df["Ship Date"] - df["Order Date"]).dt.days
    df["Profit Margin"] = (df["Profit"] / df["Sales"]).replace([np.inf, -np.inf], np.nan)
    df["Discount Band"] = pd.cut(
        df["Discount"], bins=[-0.01, 0, 0.15, 0.30, 1],
        labels=["No Discount", "Low (0-15%)", "Medium (15-30%)", "High (30%+)"]
    )
    df["Order Value Tier"] = pd.cut(
        df["Sales"], bins=[0, 100, 500, 1500, np.inf],
        labels=["Small (<$100)", "Medium ($100-500)", "Large ($500-1500)", "Very Large ($1500+)"]
    )
    return df


def final_type_pass(df: pd.DataFrame) -> pd.DataFrame:
    df["Quantity"] = df["Quantity"].astype(int)
    df["Sales"] = df["Sales"].round(2)
    df["Profit"] = df["Profit"].round(2)
    df["Discount"] = df["Discount"].round(2)
    df["Shipping Cost"] = df["Shipping Cost"].round(2)
    df["Profit Margin"] = df["Profit Margin"].round(4)
    return df


def main():
    df = load_data(RAW_PATH)
    df = clean_text_columns(df)
    df = clean_numeric_columns(df)
    df = clean_dates(df)
    df = handle_missing_values(df)
    df = remove_duplicates(df)
    df = flag_outliers(df)
    df = engineer_features(df)
    df = final_type_pass(df)

    df.to_csv(CLEAN_CSV_PATH, index=False)
    df.to_excel(CLEAN_XLSX_PATH, index=False, engine="openpyxl")

    print(f"\nFinal cleaned dataset: {len(df):,} rows, {df.shape[1]} columns")
    print(f"Saved -> {CLEAN_CSV_PATH} and {CLEAN_XLSX_PATH}")
    print("\nMissing values remaining per column:")
    print(df.isna().sum()[df.isna().sum() > 0])


if __name__ == "__main__":
    main()
