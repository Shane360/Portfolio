Business questions that are answered in the analysis:

a. Hourly Revenue Analysis
b. Profit and Revenue Trends
c. Seasonal Revenue
d. Rider Segmentation metrics


NORTHSTAR METRICS
a. Sales: Total Revenue, Total Profit, Profit Margin, Hourly Revenue, Seasonal Revenue.
b. Riders: Total Riders, Average number of Riders per month, distribution of riders by type.
c.KPIs: Average Revenue, Average Profit.

DIMENSIONS
Dimensions: Year and Rider Type


SQL QUERY:
WITH bike_fact as (
SELECT * FROM bike_share_yr_0
UNION ALL
SELECT * FROM bike_share_yr_1)

SELECT
dteday,
season,
bf.yr,
weekday,
hr, 
rider_type,
riders,
price,
COGS,
riders * price as revenue,
riders * price - COGS as profit
FROM bike_fact as bf
LEFT JOIN cost_table ct
ON bf.yr = ct.yr 



DAX MEASURES
1.% Price Increase = 
  VAR Avg_21 =
  CALCULATE(
    AVERAGE(factBike_data[price]),
    FILTER(dimDate, dimDate[year] = 2021)
  )
  VAR Avg_22 = 
  CALCULATE(
    AVERAGE(factBike_data[price]),
    FILTER(dimDate, dimDate[year] = 2022)
  )
  RETURN 
  DIVIDE((Avg_22 - Avg_21), Avg_21, 0)

   
2. % Rider Increase = 
  VAR riders_21 = 
  CALCULATE(
    SUM(factBike_data[riders]),
    FILTER(dimDate,
    dimDate[year] = 2021)
  )
  VAR riders_22 = 
  CALCULATE(
    SUM(factBike_data[riders]),
    FILTER(dimDate,
    dimDate[year] = 2022)
  )
  RETURN
  DIVIDE((riders_22 - riders_21), riders_21, 0)

3. Price Elasticity of Demand = DIVIDE(64.9,25.1) (% Rider Increase/ % Price Increase)
  
4. Avg Riders Per Month = 
  CALCULATE(
    AVERAGE(factBike_data[riders]),
    dimDate[monthNum]

  )

5. Profit Margin = (SUM(factBike_data[revenue]) - SUM(factBike_data[profit])) / SUM(factBike_data[profit])
