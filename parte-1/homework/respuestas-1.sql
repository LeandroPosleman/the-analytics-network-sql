-- ## Semana 1 - Parte A


-- 1. Mostrar todos los productos dentro de la categoria electro junto con todos los detalles.
select * from stg.product_master
where category = 'Electro'

-- 2. Cuales son los producto producidos en China?
select product_code, name from stg.product_master
where origin = 'China'

-- 3. Mostrar todos los productos de Electro ordenados por nombre.
select product_code, name from stg.product_master
where category = 'Electro'
order by name asc

-- 4. Cuales son las TV que se encuentran activas para la venta?
select product_code, name from stg.product_master
where subcategory = 'TV'
and is_active = 'true'

-- 5. Mostrar todas las tiendas de Argentina ordenadas por fecha de apertura de las mas antigua a la mas nueva.
select address, name from stg.store_master
where country = 'Argentina'
order by start_date asc

-- 6. Cuales fueron las ultimas 5 ordenes de ventas?
select order_number, product, date from stg.order_line_sale
order by date desc
limit 5
  
-- 7. Mostrar los primeros 10 registros de el conteo de trafico por Super store ordenados por fecha.
select * from stg.super_store_count
order by date asc
limit 10

-- 8. Cuales son los producto de electro que no son Soporte de TV ni control remoto.
select product_code, subsubcategory from stg.product_master
where subsubcategory not in ('TV', 'Control remoto')

-- 9. Mostrar todas las lineas de venta donde el monto sea mayor a $100.000 solo para transacciones en pesos.
select product, sale, currency from stg.order_line_sale
where currency = 'ARS'
AND sale > 100000

-- 10. Mostrar todas las lineas de ventas de Octubre 2022.
select * from stg.order_line_sale
where date between '2022-10-1' and '2022-10-31'

-- 11. Mostrar todos los productos que tengan EAN.
select product_code, name, ean from stg.product_master
where ean is not null

-- 12. Mostrar todas las lineas de venta que que hayan sido vendidas entre 1 de Octubre de 2022 y 10 de Noviembre de 2022.
select * from stg.order_line_sale
where date between '2022-10-1' and '2022-11-10'

-- ## Semana 1 - Parte B

-- 1. Cuales son los paises donde la empresa tiene tiendas?
select distinct country
from stg.store_master

-- 2. Cuantos productos por subcategoria tiene disponible para la venta?
select subcategory, count(subcategory)
from stg.product_master
group by subcategory

-- 3. Cuales son las ordenes de venta de Argentina de mayor a $100.000?
with cte1 as(
	
select order_number, product, sale - coalesce(promotion,0) as price
from stg.order_line_sale
where currency = 'ARS')

select order_number, price from cte1
where price > 100000
order by price asc

-- 4. Obtener los decuentos otorgados durante Noviembre de 2022 en cada una de las monedas?
select currency, sum(promotion)
from stg.order_line_sale
where date between '2022-11-1' and '2022-11-30'
group by currency

-- 5. Obtener los impuestos pagados en Europa durante el 2022.
select currency, sum(tax)
from stg.order_line_sale
where 1=1
	AND date between '2022-1-1' and '2022-12-31'
	AND currency = 'EUR'
group by currency

-- 6. En cuantas ordenes se utilizaron creditos?
select count(order_number)
from stg.order_line_sale
where credit is not null

-- 7. Cual es el % de descuentos otorgados (sobre las ventas) por tienda?
with cte1 as 

(select store, sum(sale) as total_sale, sum(promotion) as total_discount
from stg.order_line_sale
group by 1)

select store, total_discount/total_sale * 100
from cte1

-- 8. Cual es el inventario promedio por dia que tiene cada tienda?
with cte1 as

(select store_id, sum(initial) as total_initial, sum(final)as total_final
from stg.inventory
group by store_id)

select store_id, (total_initial + total_final)/2 as avg
from cte1

-- 9. Obtener las ventas netas y el porcentaje de descuento otorgado por producto en Argentina.
WITH CTE1 AS (
	select sale -  coalesce(promotion,0) as ventas_netas
, promotion/sale as descuento
from stg.order_line_sale
where currency = 'ARS')

SELECT VENTAS_NETAS, COALESCE(DESCUENTO,0)
FROM CTE1

-- 10. Las tablas "market_count" y "super_store_count" representan dos sistemas distintos que usa la empresa para contar la cantidad de gente que ingresa a tienda, uno para las tiendas de Latinoamerica y otro para Europa. Obtener en una unica tabla, las entradas a tienda de ambos sistemas.
SELECT store_id, TO_DATE(CAST(date AS VARCHAR), 'YYYYMMDD'),  traffic
FROM stg.market_count
UNION
SELECT store_id, TO_DATE(date, 'YYYY-MM-DD'), traffic
	FROM stg.super_store_count;
-- 11. Cuales son los productos disponibles para la venta (activos) de la marca Phillips?
select product_code, name 
from stg.product_master
where is_active = true
and name like '%PHILIPS%'

-- 12. Obtener el monto vendido por tienda y moneda y ordenarlo de mayor a menor por valor nominal de las ventas (sin importar la moneda).
select store, currency, sum(sale)
from stg.order_line_sale
group by 1,2
order by sum desc

-- 13. Cual es el precio promedio de venta de cada producto en las distintas monedas? Recorda que los valores de venta, impuesto, descuentos y creditos es por el total de la linea.
with cte1 as(
	
select product, currency, sum(sale) as venta, count(product) as cuenta
from stg.order_line_sale
group by 1,2)

select product, currency, venta/cuenta as precio_promedio
from cte1
order by currency desc

-- 14. Cual es la tasa de impuestos que se pago por cada orden de venta?
with cte1 as(
	
select order_number, sale, coalesce(tax,0) as tax
from stg.order_line_sale)

select order_number, tax/sale * 100 as tax_rate
from cte1


-- ## Semana 2 - Parte A

-- 1. Mostrar nombre y codigo de producto, categoria y color para todos los productos de la marca Philips y Samsung, mostrando la leyenda "Unknown" cuando no hay un color disponible
select name, product_code, category, COALESCE(color, 'Unknown')
from stg.product_master
where name like '%PHILIPS%'
or name like '%SAMSUNG%'

-- 2. Calcular las ventas brutas y los impuestos pagados por pais y provincia en la moneda correspondiente.
select country, province, currency, sum(sale) as total_sales, sum(tax) as total_taxes
from stg.order_line_sale ols
left join stg.store_master sm
on ols.store = sm.store_id
group by 1,2,3

-- 3. Calcular las ventas totales por subcategoria de producto para cada moneda ordenados por subcategoria y moneda.
select subcategory, currency, sum(sale) as total_sales
from stg.order_line_sale ols
left join stg.product_master pm
on ols.product = pm.product_code
group by 1,2
order by 1,2

-- 4. Calcular las unidades vendidas por subcategoria de producto y la concatenacion de pais, provincia; usar guion como separador y usarla para ordernar el resultado.
select subcategory, country || '-' || province AS pais_provincia ,count(product_code) as total_sales
from stg.product_master pm
left join stg.order_line_sale ols
	on  pm.product_code = ols.product
left join stg.store_master sm
	on ols.store = sm.store_id
group by 1,2
order by pais_provincia asc, total_sales desc 

-- 5. Mostrar una vista donde sea vea el nombre de tienda y la cantidad de entradas de personas que hubo desde la fecha de apertura para el sistema "super_store".
CREATE VIEW entrada_de_personas as

SELECT ssc.store_id, sum(traffic)
FROM stg.super_store_count ssc
LEFT JOIN stg.store_master ssm
ON ssc.store_id = ssm.store_id
GROUP BY ssc.store_id
	
-- 6. Cual es el nivel de inventario promedio en cada mes a nivel de codigo de producto y tienda; mostrar el resultado con el nombre de la tienda.
CREATE VIEW entrada_de_personas_2 as

SELECT ssc.store_id, name, sum(traffic)
FROM stg.super_store_count ssc
LEFT JOIN stg.store_master ssm
ON ssc.store_id = ssm.store_id
GROUP BY ssc.store_id, 2  

-- 7. Calcular la cantidad de unidades vendidas por material. Para los productos que no tengan material usar 'Unknown', homogeneizar los textos si es necesario.
select store_id
	, SUM(CASE WHEN DATE BETWEEN '2022-01-01' AND '2022-01-31' THEN INITIAL END)	
	, COUNT(CASE WHEN DATE BETWEEN '2022-01-01' AND '2022-01-31' THEN INITIAL END) 
	, SUM(CASE WHEN DATE BETWEEN '2022-01-01' AND '2022-01-31' THEN INITIAL END)/ COUNT(CASE WHEN DATE BETWEEN '2022-01-01' AND '2022-01-31' THEN INITIAL END) as inv_inicial_promedio
from stg.inventory
group by store_id  

-- 8. Mostrar la tabla order_line_sales agregando una columna que represente el valor de venta bruta en cada linea convertido a dolares usando la tabla de tipo de cambio.
  with cte1 as

(select order_number, sale, currency, fx_rate_usd_peso, fx_rate_usd_uru, fx_rate_usd_eur
	from stg.order_line_sale ols
	left join stg.monthly_average_fx_rate fx
		on date_trunc('month',ols.date) = fx.month)
		
select order_number,
	CASE WHEN currency = 'ARS' THEN sale * fx_rate_usd_peso
	WHEN currency = 'URU' THEN sale * fx_rate_usd_uru
	ELSE sale * fx_rate_usd_eur END AS venta_en_usd
FROM cte1

-- 9. Calcular cantidad de ventas totales de la empresa en dolares.
  with cte1 as

(select order_number, sale, currency, fx_rate_usd_peso, fx_rate_usd_uru, fx_rate_usd_eur
	from stg.order_line_sale ols
	left join stg.monthly_average_fx_rate fx
		on date_trunc('month',ols.date) = fx.month),
		
cte2 as
(select order_number,
	CASE WHEN currency = 'ARS' THEN sale * fx_rate_usd_peso
	WHEN currency = 'URU' THEN sale * fx_rate_usd_uru
	ELSE sale * fx_rate_usd_eur END AS venta_en_usd
FROM cte1)

select sum(venta_en_usd) as venta_total_usd
from cte2

-- 10. Mostrar en la tabla de ventas el margen de venta por cada linea. Siendo margen = (venta - descuento) - costo expresado en dolares.
 with cte1 as(
	
select ols.order_number, sale, currency, fx_rate_usd_peso, fx_rate_usd_uru, fx_rate_usd_eur, product_cost_usd
	from stg.monthly_average_fx_rate fx
	left join stg.order_line_sale ols
	on date_trunc('month',ols.date) = fx.month
		left join stg.cost c
		on c.product_code = ols.product),

cte2 as
(select order_number, 
	CASE WHEN currency = 'ARS' THEN sale * fx_rate_usd_peso 
	WHEN currency = 'URU' THEN sale * fx_rate_usd_uru
	ELSE sale * fx_rate_usd_eur END AS venta_en_usd,
	product_cost_usd
	from cte1)
	
	select order_number, venta_en_usd - product_cost_usd as margin
	from cte2

-- 11. Calcular la cantidad de items distintos de cada subsubcategoria que se llevan por numero de orden.
select order_number, subsubcategory, count(distinct product)
from stg.order_line_sale ols
left join stg.product_master pm
on ols.product = pm.product_code
group by 1,2
order by count desc


-- ## Semana 2 - Parte B

-- 1. Crear un backup de la tabla product_master. Utilizar un esquema llamada "bkp" y agregar un prefijo al nombre de la tabla con la fecha del backup en forma de numero entero.
  
-- 2. Hacer un update a la nueva tabla (creada en el punto anterior) de product_master agregando la leyendo "N/A" para los valores null de material y color. Pueden utilizarse dos sentencias.
  
-- 3. Hacer un update a la tabla del punto anterior, actualizando la columa "is_active", desactivando todos los productos en la subsubcategoria "Control Remoto".
  
-- 4. Agregar una nueva columna a la tabla anterior llamada "is_local" indicando los productos producidos en Argentina y fuera de Argentina.
  
-- 5. Agregar una nueva columna a la tabla de ventas llamada "line_key" que resulte ser la concatenacion de el numero de orden y el codigo de producto.
  
-- 6. Crear una tabla llamada "employees" (por el momento vacia) que tenga un id (creado de forma incremental), name, surname, start_date, end_name, phone, country, province, store_id, position. Decidir cual es el tipo de dato mas acorde.
  
-- 7. Insertar nuevos valores a la tabla "employees" para los siguientes 4 empleados:
    -- Juan Perez, 2022-01-01, telefono +541113869867, Argentina, Santa Fe, tienda 2, Vendedor.
    -- Catalina Garcia, 2022-03-01, Argentina, Buenos Aires, tienda 2, Representante Comercial
    -- Ana Valdez, desde 2020-02-21 hasta 2022-03-01, España, Madrid, tienda 8, Jefe Logistica
    -- Fernando Moralez, 2022-04-04, España, Valencia, tienda 9, Vendedor.

  
-- 8. Crear un backup de la tabla "cost" agregandole una columna que se llame "last_updated_ts" que sea el momento exacto en el cual estemos realizando el backup en formato datetime.
  
-- 9. En caso de hacer un cambio que deba revertirse en la tabla "order_line_sale" y debemos volver la tabla a su estado original, como lo harias?
