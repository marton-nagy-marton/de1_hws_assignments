/*
Author: Marton Nagy
Solution for Data Engineering 1 HW4
*/
use classicmodels;
select o.orderNumber, od.priceEach, od.quantityOrdered,
p.productName, p.productLine, c.city, c.country, o.orderDate
from products p
	inner join orderdetails od
    on p.productCode = od.productCode
		inner join orders o
        on od.orderNumber = o.orderNumber
			inner join customers c
            on o.customerNumber = c.customerNumber;