-- Вывод списка заказов со статусом "В работе", отсортированного по дате оформления
SELECT o.order_id, c.model, o.status, o.order_date
FROM REPAIR_ORDERS o
JOIN CAR c ON o.car_id = c.car_id
WHERE o.status IN ('В работе')
ORDER BY o.order_date DESC;

-- Вывод количества заказов по каждому статусу
SELECT status, COUNT(*) AS total_orders
FROM REPAIR_ORDERS
GROUP BY status
ORDER BY total_orders DESC;

-- Вывод сотрудников, которые изменили статус у заказов на "Завершён"
-- и количечество таких изменений, отсортированных по убыванию
SELECT e.employee_id, e.first_name, e.last_name , COUNT(*) AS completed_count
FROM REPAIR_HISTORY h
JOIN EMPLOYEE e ON h.edit_by = e.employee_id
WHERE h.new_status = 'Завершён'
GROUP BY e.employee_id, e.first_name
HAVING COUNT(*) > 1
ORDER BY completed_count DESC
LIMIT 5;

-- Вывод автомобилей, у которых >= 1 заказов
SELECT c.car_id, c.model, COUNT(*) AS total_repairs
FROM REPAIR_ORDERS r
JOIN CAR c ON r.car_id = c.car_id
GROUP BY c.car_id, c.model
HAVING COUNT(*) >= 1 ;

-- Выводит какие заказы сделал Александр Петров
SELECT 
    oe.employee_id,
    oe.order_id,
    e.first_name,
    e.last_name,
    c.brand,
    c.model
FROM ORDER_EMPLOYEES oe
JOIN EMPLOYEE e ON oe.employee_id = e.employee_id
JOIN REPAIR_ORDERS ro ON oe.order_id = ro.order_id
JOIN CAR c ON ro.car_id = c.car_id
WHERE e.first_name = 'Александр' AND e.last_name = 'Петров';

-- Вывод самого долгого по времени выполнения заказа
SELECT *
FROM (
    SELECT r.order_id,
           r.order_date,
           MAX(h.edit_timestamp) AS completed_time,
           EXTRACT(EPOCH FROM MAX(h.edit_timestamp) - r.order_date)/3600 AS duration_hours,
           RANK() OVER (ORDER BY MAX(h.edit_timestamp) - r.order_date DESC) AS rank
    FROM REPAIR_ORDERS r
    JOIN REPAIR_HISTORY h ON h.order_id = r.order_id
    WHERE h.new_status = 'Завершён'
    GROUP BY r.order_id, r.order_date
) sub
WHERE rank = 1;

-- Вывод заказов, которые имеют 3 смены статуса
SELECT order_id, COUNT(*) AS status_changes_count
FROM REPAIR_HISTORY
GROUP BY order_id
HAVING COUNT(*) = 3;

-- Вывод сотрудников, которые выполняют больше 2 заказов
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    COUNT(oe.order_id) AS orders_count
FROM ORDER_EMPLOYEES oe
JOIN EMPLOYEE e ON oe.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING COUNT(oe.order_id) > 2
ORDER BY orders_count DESC;

-- Вывод автомобилей, заказ на ремонт которых был отменён
SELECT 
    ro.order_id,
    c.brand,
    c.model,
    rh.edit_timestamp AS cancel_date,
    rh.new_status
FROM REPAIR_ORDERS ro
JOIN CAR c ON ro.car_id = c.car_id
JOIN REPAIR_HISTORY rh ON ro.order_id = rh.order_id
WHERE rh.new_status = 'Отменён'
ORDER BY cancel_date DESC;

-- Вывод информации об автомобилях с годом выпуска > 2018
SELECT 
    c.car_id,
    c.brand,
    c.model,
    c.year,
    cl.first_name,
    cl.last_name
FROM CAR c
JOIN CLIENT cl ON c.client_id = cl.client_id
WHERE c.year > 2018
ORDER BY c.year;