
-- General 
-- - Ventas brutas, netas y margen (USD)
with cte1 as
		(select order_number,
		CASE 
			WHEN currency = 'ARS' THEN sale/fx_rate_usd_peso
			WHEN currency = 'URU' THEN sale/fx_rate_usd_uru
			WHEN currency = 'EUR' THEN sale/fx_rate_usd_eur
			ELSE sale
			END AS venta_en_usd
		from stg.order_line_sale ols
		left join stg.monthly_average_fx_rate fx
		on date_trunc('month',ols.date) = fx.month)
select sum(venta_en_usd) as venta_bruta_usd
from cte1



-- - Margen por categoria de producto (USD)

-- - ROI por categoria de producto. ROI = ventas netas / Valor promedio de inventario (USD)

-- - AOV (Average order value), valor promedio de la orden. (USD)

-- Contabilidad (USD)
-- - Impuestos pagados

-- - Tasa de impuesto. Impuestos / Ventas netas 

-- - Cantidad de creditos otorgados

-- - Valor pagado final por order de linea. Valor pagado: Venta - descuento + impuesto - credito

-- Supply Chain (USD)
-- - Costo de inventario promedio por tienda

-- - Costo del stock de productos que no se vendieron por tienda

-- - Cantidad y costo de devoluciones


-- Tiendas
-- - Ratio de conversion. Cantidad de ordenes generadas / Cantidad de gente que entra

