# Business Insights — Store Sales Analysis Dashboard

Derived from `Dataset/Cleaned_Data.csv` (15,200 orders, ~$22.5M total revenue) using the
Python EDA (`Python/eda.ipynb`) and SQL business-insight queries
(`MySQL/sql_queries.sql`, Section 8).

## Revenue & Growth

1. Total revenue across the analysis period is **$22.5M** across 15,200 orders and 1,400 unique customers.
2. Yearly revenue grew from $3.5M to a peak of $7.7M before the most recent partial year, indicating a strong multi-year upward trend.
3. Q4 is the strongest quarter ($5.98M), roughly 11% ahead of Q1 ($5.38M), consistent with a seasonal year-end buying pattern.
4. The average order value is **$1,482**, with Consumer, Corporate, and Home Office segments all clustering within 2% of each other — no single segment dominates order size.
5. Average orders per customer sit at **~10.9**, suggesting a healthy repeat-purchase base rather than a one-time-buyer pattern.

## Category & Product Performance

6. **Technology** is the clear revenue leader at **$13.48M** (60% of total revenue) and also the top profit contributor at **$1.5M**.
7. **Furniture** contributes **$8.23M** in revenue but converts it at essentially the same margin as the other categories (~11%), so its "high sales, average profitability" reputation in retail data is not as pronounced here — worth flagging as a category to watch rather than assume.
8. **Office Supplies** is the smallest category by revenue ($824K) but sees frequent, small-basket repeat orders (Binders, Paper, Fasteners, Labels, Art all rank among the lowest-profit sub-categories in absolute dollars, simply due to low unit price).
9. **Machines, Accessories, Copiers, and Phones** are the four highest-revenue sub-categories, together accounting for over $13M — the Technology category's sub-categories dominate the top of the list.
10. The **Office Copier A3** and **Compact Copier** are the two top-selling individual products by revenue (~$1.65–1.69M each).
11. The three lowest-profit products by absolute dollars are all low-unit-price Office Supplies items (3-Ring Binder, Colored Pencils, Stapler) — high volume, thin per-unit margin.
12. Profit margin is nearly identical across all three categories (11.0–11.2%), so category mix alone doesn't explain profitability gaps — discount behavior (see below) is a stronger driver.

## Discounts & Profitability

13. Orders with **no discount** average **$407 profit**; orders in the **30%+ discount band average a $205 loss** — a clear, almost linear erosion of profit as discount depth increases.
14. Discount and profit are **negatively correlated (r ≈ -0.39)**, one of the strongest relationships in the dataset — discounting is the single biggest lever affecting profitability.
15. Sales and profit are only moderately correlated (r ≈ 0.36), confirming that higher-revenue orders don't automatically mean proportionally higher profit — margin management matters as much as volume.
16. "Very Large" orders (**$1,500+**) average **$404 profit per order**, over 70x the average profit of "Small" orders (**$5.47**) — large orders are disproportionately valuable and worth prioritizing in retention efforts.
17. **2,410 orders (~16% of all orders)** are flagged as statistical profit outliers (IQR method), a large enough share to warrant a deeper root-cause review (likely a mix of heavy discounting and a few high-cost-ratio SKUs).

## Regional Performance

18. The **West region** generates the highest revenue (**$5.83M**), narrowly ahead of South, East, and Central, which are all within 8% of each other — regional performance is comparatively balanced rather than concentrated in one area.
19. The **Central region**, despite the lowest revenue, posts the **highest total profit** ($646K) — a signal that Central's order mix carries better margins even at lower volume.
20. **New Jersey, California, and North Carolina** are the top three states by revenue, each contributing just over $1M.
21. Average shipping time varies sharply by region: **South (1.8 days) and West (2.3 days)** ship notably faster than **East (4.1 days) and Central (4.0 days)** — a logistics gap worth investigating operationally.

## Customers & Segments

22. The top 10% of customers by spend generate **~19.8% of total revenue** — a meaningful but not extreme concentration, suggesting a broad, relatively healthy customer base rather than dependency on a handful of accounts.
23. Average order value is nearly flat across segments (Consumer $1,490, Corporate $1,482, Home Office $1,474), so segment alone is not a strong predictor of basket size in this dataset.
24. Payment mode usage is evenly distributed across all five methods (each between 19–20% of orders), indicating no single payment channel dominates and all integrations should be treated as equally important.

## Operations

25. **Critical-priority orders are the largest single group** (4,124 orders, ~27% of all orders) — worth checking that fulfillment capacity is aligned with this priority mix rather than assuming an even spread across priority levels.

---
*All figures are computed directly from the cleaned dataset and are reproducible via
`Python/eda.ipynb` or the SQL queries in `MySQL/sql_queries.sql`.*
