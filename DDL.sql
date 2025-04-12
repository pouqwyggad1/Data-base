CREATE TABLE CLIENT (
    client_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL UNIQUE CHECK (phone_number ~ '^[0-9]{3,15}$')
);

CREATE TABLE CAR (
    car_id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES CLIENT(client_id),
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL CHECK (year >= 1900 AND year <= EXTRACT(YEAR FROM CURRENT_DATE))
);

CREATE TABLE EMPLOYEE (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL UNIQUE CHECK (phone_number ~ '^[0-9]{3,15}$'),
    status VARCHAR(20) NOT NULL CHECK (status IN ('На смене', 'Не на смене'))
);

CREATE TABLE REPAIR_ORDERS (
    order_id SERIAL PRIMARY KEY,
    car_id INTEGER NOT NULL REFERENCES CAR(car_id),
    status VARCHAR(50) NOT NULL CHECK (status IN ('Принят', 'В работе', 'Завершён', 'Отменён')),
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status_update_time TIMESTAMP CHECK (status_update_time >= order_date OR status_update_time IS NOT NULL)
);

CREATE TABLE REPAIR_HISTORY (
    history_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES REPAIR_ORDERS(order_id),
    old_status VARCHAR(50) NOT NULL CHECK (old_status IN ('Принят', 'В работе', 'Завершён', 'Отменён')),
    new_status VARCHAR(50) NOT NULL CHECK (new_status IN ('Принят', 'В работе', 'Завершён', 'Отменён')),
    edit_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    edit_by INTEGER NOT NULL REFERENCES EMPLOYEE(employee_id)
    CHECK (
        (old_status = 'Принят' AND new_status IN ('Принят', 'В работе', 'Отменён')) OR
        (old_status = 'В работе' AND new_status IN ('Завершён', 'Отменён')) OR
        (old_status IN ('Завершён', 'Отменён') AND new_status = old_status)
    )
);

CREATE TABLE ORDER_EMPLOYEES (
    order_id INTEGER NOT NULL REFERENCES REPAIR_ORDERS(order_id),
    employee_id INTEGER NOT NULL REFERENCES EMPLOYEE(employee_id),
    PRIMARY KEY (order_id, employee_id)
);

CREATE TABLE SERVICE (
    service_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE ORDER_SERVICES (
    order_id INTEGER NOT NULL REFERENCES REPAIR_ORDERS(order_id),
    service_id INTEGER NOT NULL REFERENCES SERVICE(service_id),
    PRIMARY KEY (order_id, service_id)
);
