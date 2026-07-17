# Power BI Dashboard — Build Guide & DAX Measures

> **Note on this folder:** the `.pbix` file itself is not included in this repository export
> because it must be built inside the Power BI Desktop application on your own machine — it
> is a binary format tied to a live Power BI session and can't be generated outside of it.
> Everything below is a complete, copy-paste-ready build spec (data model, every DAX measure,
> every visual, every slicer) so the dashboard can be reproduced in about 60–90 minutes.
> Mockups of the finished layout are in `Dashboard Images/` for reference.

## 1. Data Source & Model

1. Open Power BI Desktop → **Get Data → Text/CSV** → load `Dataset/Cleaned_Data.csv`
   (or connect directly to `store_sales_db` in MySQL via **Get Data → MySQL Database** using
   the schema created by `MySQL/database.sql`).
2. In Power Query, confirm data types: `Order Date`/`Ship Date` = Date, `Sales`/`Profit`/
   `Shipping Cost` = Decimal Number, `Quantity` = Whole Number, `Discount`/`Profit Margin` =
   Percentage.
3. Create a dedicated **Date table** (Modeling → New Table):

```dax
DateTable =
CALENDAR ( MIN ( Cleaned_Data[Order Date] ), MAX ( Cleaned_Data[Order Date] ) )
```
Mark it as a Date Table (Table tools → Mark as Date Table), then relate `DateTable[Date]`
(1) → `Cleaned_Data[Order Date]` (many).

## 2. Core DAX Measures

```dax
Total Sales = SUM ( Cleaned_Data[Sales] )

Total Profit = SUM ( Cleaned_Data[Profit] )

Total Orders = DISTINCTCOUNT ( Cleaned_Data[Order ID] )

Total Quantity = SUM ( Cleaned_Data[Quantity] )

Average Order Value = DIVIDE ( [Total Sales], [Total Orders] )

Profit Margin % = DIVIDE ( [Total Profit], [Total Sales] )

Total Customers = DISTINCTCOUNT ( Cleaned_Data[Customer ID] )

Average Shipping Days = AVERAGE ( Cleaned_Data[Shipping Days] )
```

## 3. Time-Intelligence Measures

```dax
Sales LY =
CALCULATE ( [Total Sales], SAMEPERIODLASTYEAR ( DateTable[Date] ) )

Sales YoY % =
DIVIDE ( [Total Sales] - [Sales LY], [Sales LY] )

Sales MTD = TOTALMTD ( [Total Sales], DateTable[Date] )

Sales QTD = TOTALQTD ( [Total Sales], DateTable[Date] )

Sales YTD = TOTALYTD ( [Total Sales], DateTable[Date] )

Running Total Sales =
CALCULATE (
    [Total Sales],
    FILTER ( ALLSELECTED ( DateTable[Date] ), DateTable[Date] <= MAX ( DateTable[Date] ) )
)
```

## 4. Rank & Contribution Measures (for Top-N visuals and tooltips)

```dax
Product Sales Rank =
RANKX ( ALL ( Cleaned_Data[Product Name] ), [Total Sales], , DESC )

Customer Sales Rank =
RANKX ( ALL ( Cleaned_Data[Customer Name] ), [Total Sales], , DESC )

% of Total Sales =
DIVIDE ( [Total Sales], CALCULATE ( [Total Sales], ALLSELECTED ( Cleaned_Data ) ) )

Top 10 Customer Sales =
CALCULATE ( [Total Sales], TOPN ( 10, ALL ( Cleaned_Data[Customer Name] ), [Total Sales], DESC ) )
```

## 5. Discount & Profitability Measures

```dax
Avg Discount % = AVERAGE ( Cleaned_Data[Discount] )

Profit per Order = DIVIDE ( [Total Profit], [Total Orders] )

High Discount Profit Loss =
CALCULATE ( [Total Profit], Cleaned_Data[Discount Band] = "High (30%+)" )

Outlier Order Count =
CALCULATE ( COUNTROWS ( Cleaned_Data ), Cleaned_Data[Is_Profit_Outlier] = TRUE )
```

## 6. Dashboard Pages & Visuals

### Page 1 — Executive Overview
| Visual | Fields |
|---|---|
| Card ×5 | Total Sales, Total Profit, Total Orders, Average Order Value, Profit Margin % |
| Line chart | X: DateTable[Date] (Month), Y: Total Sales, Sales LY |
| Clustered bar chart | Axis: Region, Values: Total Sales, Total Profit |
| Treemap | Group: Product Category → Sub Category, Values: Total Sales |
| Donut chart | Legend: Segment, Values: Total Sales |
| Map | Location: State, Bubble size: Total Sales |

### Page 2 — Product & Category Performance
| Visual | Fields |
|---|---|
| Stacked bar chart | Axis: Sub Category, Legend: Segment, Values: Total Sales |
| Ribbon chart | Axis: Order Month Name, Legend: Product Category, Values: Total Sales |
| Scatter plot | X: Avg Discount %, Y: Profit Margin %, Size: Total Sales, Legend: Sub Category |
| Table | Product Name, Total Sales, Total Profit, Product Sales Rank (top 10 filter) |

### Page 3 — Customer & Regional Insights
| Visual | Fields |
|---|---|
| Waterfall chart | Category: Order Month Name, Breakdown values: Total Sales |
| Pie chart | Legend: Payment Mode, Values: Total Orders |
| Bar chart | Axis: Customer Name (Top 10 via filter), Values: Total Sales |
| Table with conditional formatting | State, Total Sales, Total Profit, Profit Margin % (data bars) |

## 7. Slicers (add to every page via a synced slicer panel)

- Date range slicer on `DateTable[Date]`
- State (`Cleaned_Data[State]`)
- Region (`Cleaned_Data[Region]`)
- Product Category (`Cleaned_Data[Product Category]`)
- Segment (`Cleaned_Data[Segment]`)

Format → Sync slicers across all 3 pages (View → Sync Slicers).

## 8. Interactivity

- **Drill-through page**: build a "Customer Detail" page, right-click a customer in any
  table/bar chart → Drill Through, filtered by `Customer ID`.
- **Tooltips**: create a small tooltip page (Page size = Tooltip) showing Monthly Sales
  trend + Profit Margin %, then assign it as the tooltip for the Region bar chart.
- **Bookmarks & Navigation buttons**: create a bookmark per page, add a button group at the
  top of every page (Insert → Buttons → Blank) with bookmark actions for one-click navigation.

## 9. Theme

Use a modern, dark-accent theme: primary `#1F4E78` (deep blue), accent `#DD8452` (amber),
positive `#55A868` (green), negative `#C44E52` (red), background `#F5F6FA`. Import as a
custom theme JSON via View → Themes → Browse for themes if you want it saved as a `.json`.
