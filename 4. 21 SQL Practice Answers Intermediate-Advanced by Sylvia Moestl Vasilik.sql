-- Problems From Book "57 SQL Practice Problems" by Sylvia Moestl Vasilik
---------------------------------------------------------------------
----------------------- Intermediate problems------------------------
---------------------------------------------------------------------

------- Problem 20 --------------------
SELECT CategoryName, count(*) as total_products FROM Categories

JOIN products
  ON Categories.categoryID = products.categoryID

GROUP BY CategoryName

ORDER BY total_products desc
;

----------Problem 23 --------
SELECT
  productID,
  productName,
  unitsInStock,
  unitsOnOrder,
  reorderLevel,
  discontinued
FROM
  products
WHERE
  unitsInStock + unitsOnOrder <= reorderLevel
AND
  discontinued = '0';

------------ Problem 24 ---------

SELECT
  custID,
  companyName,
  region
FROM customers
order by
  Case
 when Region is null then 1
 else 0
END,
  region ASC,
custid asc
;



------- Problem 26 --------
SELECT
  shipCountry,
  AVG(freight) AS AverageFreight
FROM orders
  WHERE date_part('year',orderDate) = 2006 
GROUP BY shipCountry
ORDER BY AverageFreight DESC
limit 3;


------- Problem 28-------

SELECT
  shipCountry,
  AVG(freight) AS AverageFreight
FROM orders
  WHERE
  (OrderDate) > (SELECT Max((OrderDate)) from Orders) - interval '12 month'

Group by ShipCountry
ORDER BY AverageFreight DESC
LIMIT 3
;

--------- Problem 29 -------------
-- orders join employee -->> employee lastname and order join order details -->> product Id and qty finally order details JOIN products -->> product name
SELECT
  O.empID ,
  E.lastname,
  O.orderID,
  P.productName,
  OD.qty
FROM
  orders as O
JOIN employee as E
  ON O.empid = E.empid
JOIN order_details AS OD
    ON OD.orderID = O.orderID
JOIN products AS P
  ON P.productID = OD.productID

ORDER BY O.orderID, P.productID;


--------- PROBLEM 31 ------------- Sub queries.

--Subqueries on select statment must return single values
select * from customers
Select
 Customers.custid as Customers_custid,
  Orders.custid as Orders_custid
 From Customers
LEFT JOIN  (SELECT custid
     from orders
     where
     empid = 4) AS Orders
 on cast(Orders.custid as integer )= cast(Customers.custid as integer )
WHERE orders.custid IS NULL
;

----Alternatives
-- The most common way to solve this kind of problem is as above, with a left join. However, here are some alternatives using Not In and Not Exists.
--  Select custid
--  From Customers
--  Where
--  custid not in (select custid from Orders where empid = 4)
--  Select custid
--  From Customers
--  Where Not Exists
--  (
--  Select custid
--  from Orders
--  where Orders.custid = Customers.custid
--  and empid = 4
--  )

---------------------------------------------------------------------
----------------------- Advanced problems------------------------
---------------------------------------------------------------------

-------- Problem 32----------
SELECT
  customers.custid,
  customers.companyName,
  orders.orderID,
  sum(unitPrice * qty) as total_value
  from customers

 join orders

    ON orders.custid = orders.custid

join order_details

    ON orders.orderID = order_details.orderID

WHERE  date_part('year',orderDate) = 2007 

GROUP BY
  orders.orderID, customers.custid

having sum(unitPrice * qty) >= 10000

ORDER BY total_value DESC


------------ Problem 35 ----------------------------------------------
SELECT
  empid,
  orderID,
  orderDate,
   date_trunc('month', Date(orderDate)) + interval '1 month' - interval '1 day' AS DATEsss

  FROM orders

WHERE orderDate = date_trunc('month', Date(orderDate)) + interval '1 month' - interval '1 day'

ORDER BY empid


---------- Problem 38 -------------

SELECT
  order_details.orderID,
  order_details.qty,
  count(order_details.qty) as Duplicate
FROM order_details
--   join orders
--   on orders.orderID = order_details.orderID
--
--   join employee
--   on employee.lastName = 'Leverling'
WHERE qty >= 60
group by order_details.orderID,  qty
having count(*) >1
order by order_details.orderID ASC;


--------- Problem 39 --------------- USING "with" tables
-- Oldest employee
with PotentianDuplicates as (
    SELECT orderID
    FROM
      order_details
    WHERE qty >= 60
    GROUP BY orderID, qty
    HAVING COUNT(*) > 1
)
SELECT
  order_details.orderID,
  productID,
  unitPrice,
  qty,
  discount
  FROM
    order_details

WHERE
  orderID in (SELECT orderID FROM PotentianDuplicates)
ORDER BY
  orderID,
  qty
;

----------- problem 40 ----- Derived table

SELECT
  order_details.orderID,
  productID,
  unitPrice,
  qty,
  discount
FROM order_details

  join (SELECT DISTINCT
      orderID
    FROM order_details
    WHERE qty >=60
    GROUP BY orderID, qty
    HAVING COUNT(*)> 1
    ) as POTENTIALPROBLEMORDERS
  ON POTENTIALPROBLEMORDERS.orderID = order_details.orderID
ORDER BY  order_details.orderID, productID


------------ Problem 42 ----------------------------------- Late orders which employee

SELECT

  orders.empid,
  lastName,
  COUNT(*) AS employeelate
FROM
  orders
  JOIN employee
  ON orders.empid = employee.empid
where
  date(shippedDate) >= date(requiredDate)

GROUP BY orders.empid, lastName

ORDER BY employeelate desc , lastName asc
;


---------- Problem 43 ----------------------------
with lateorders as (
SELECT

  orders.empid,
  lastName,
  COUNT(*) AS employeelate
FROM
  orders
  JOIN employee
  ON orders.empid = employee.empid
where
  date(shippedDate) > date(requiredDate)

GROUP BY orders.empid, lastName

ORDER BY employeelate desc , lastName asc)


SELECT orders.empid,
  lastName,
  COUNT(*) as AllOrders,
  employeelate

  FROM orders
    join lateorders
    ON lateorders.empid = orders.empid

GROUP BY orders.empid, lastName, lateorders.empid, employeelate
order by orders.empid;

------------------ Problem 44 --------------------------------------------
-- In case of a employee doesn't have a late order we must use a left Join to show Null values on the right column

------------------ Problem 45 ----------- ISNULL(MySQL) Statement OR Coalesce (PostGres) Or NVR oracle
with lateorders as (
SELECT

  orders.empid,
  lastName,
  COUNT(*) AS employeelate, 0
FROM
  orders
  JOIN employee
  ON orders.empid = employee.empid
where
  date(shippedDate) > date(requiredDate)

GROUP BY orders.empid, lastName

ORDER BY employeelate desc , lastName asc)


SELECT orders.empid,
  lastName,
  COUNT(*) as AllOrders,
  COALESCE(employeelate, 0)--- or Case WHEN employeelate isnull then 0
                          -------------ELSE employee
                          -------------END

  FROM orders
    join lateorders
    ON lateorders.empid = orders.empid

GROUP BY orders.empid, lastName, lateorders.empid, employeelate
order by orders.empid;


---------- Problem 47------------------------------------------------------ round and cast statement
with lateorders as (
SELECT

  orders.empid,
  lastName,
  COUNT(*) AS employeelate, 0
FROM
  orders
  JOIN employee
  ON orders.empid = employee.empid
where
  date(shippedDate) > date(requiredDate)

GROUP BY orders.empid, lastName

ORDER BY employeelate desc , lastName asc),

Allorders as (
SELECT orders.empid,
  lastName,
  COUNT(*) as AllOrders
  FROM orders
    join lateorders
    ON lateorders.empid = orders.empid

GROUP BY orders.empid, lastName, lateorders.empid, employeelate
order by orders.empid)

SELECT
  Allorders.empid,
  Allorders.lastName,
  Allorders.AllOrders,
  employeelate,
  round(employeelate::numeric / Allorders.AllOrders::numeric , 2) as PERCENTAGE
  FROM Allorders
JOIN lateorders
    ON Allorders.empid = lateorders.empid
;

------------- Problem 48 ----------------- Customer grouping
with highlevelclients as (
SELECT
  customers.custid,
  customers.companyName,
  sum(unitPrice * qty) as total_value

  from customers

 join orders

    ON orders.custid = orders.custid

join order_details

    ON orders.orderID = order_details.orderID

WHERE date_part('year',orderDate) = 2007 

GROUP BY
   customers.custid, companyName

ORDER BY total_value DESC)

SELECT
  custid,
  companyName,

  CASE
    WHEN total_value between 0 and 1000 THEN 'Low'
    WHEN total_value between 1001 and 5000 THEN 'Medium'
    WHEN total_value between 50001 and 10000 then 'High'
    When total_value > 10000 then 'Very High'
    END AS CustumerGrouping

  FROM highlevelclients
  order by custid
;



------------ Problem 53 ------------------------------

with SupplierCountries as (
  SELECT DISTINCT country from suppliers
),
  CustumerCountries as (
    SELECT distinct country from customers
  )
SELECT  SupplierCountries.country as SupplierCoutry,
        CustumerCountries.country as CustomerCountry
FROM SupplierCountries
FULL OUTER JOIN CustumerCountries
  ON CustumerCountries.country = SupplierCountries.country
ORDER BY SupplierCoutry ASC;

-------------- Problem 54 ---------------------------------
with SupplierCountries as (
  SELECT country,
    count(*) as TotalSuppliers
  from suppliers
group by country),

  CustumerCountries as (
    SELECT country,
      count(*) as totalCustumers
    from customers
    group by country
  )

SELECT coalesce(CustumerCountries.country, SupplierCountries.country) as countries,
  coalesce(TotalSuppliers,0) as totalsuppliers,
  coalesce(totalCustumers,0) as totalcustomers
from CustumerCountries
full join  SupplierCountries
ON CustumerCountries.country = SupplierCountries.country
order by countries
;

----------- Problem 55 ------------------------------------
with CountruFirstOrder as (
SELECT distinct
  shipCountry,
  min(orderID) as FirstOrder
from
  orders
group by shipCountry
order by shipCountry asc)

SELECT distinct
CountruFirstOrder.shipCountry,
  custid,
  orderID,
  FirstOrder
FROM
  CountruFirstOrder
join orders
  on FirstOrder = orderID
group by CountruFirstOrder.shipCountry, custid, orderID, FirstOrder
order by CountruFirstOrder.shipCountry asc ;

--------------- Problem 56 --------------------------------------------- self join
SELECT
  InitialOrders.custid,
  InitialOrders.orderID,
  date(InitialOrders.orderDate),
  NextOrders.orderID,
  date(NextOrders.orderDate),
  date_part('days',NextOrders.orderDate - InitialOrders.orderDate) as daysbetween

  FROM orders AS InitialOrders
join orders as NextOrders
    on InitialOrders.custid = NextOrders.custid

  where InitialOrders.orderID < NextOrders.orderID
        and
      date_part('days',NextOrders.orderDate - InitialOrders.orderDate) <= 5

order by  InitialOrders.custid,InitialOrders.orderDate;


