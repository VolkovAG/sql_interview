/* #SQL #Fundamentals #Databases (JOIN/HAVING)

   В качестве диалекта SQL использован DB Engine PostgreSQL 14.5, все запросы можно запустить

    Задача:
Вывести имена клиентов, у которых есть как минимум один активный счет, открытый больше года назад, и которые за
последний месяц по всем своим счетам совершили покупок меньше, чем на 5000 рублей.

*/--Структура таблиц по условию задачи
CREATE TEMPORARY TABLE client
    (
    id integer, -- ID клиента
    name varchar(100) -- имя клиента
    );
----------------------------------------------------------
CREATE TEMPORARY TABLE account
    (
    id integer, -- ID счета
    client_id integer, -- ID клиента
    open_dt date, -- дата открытия счета
    close_dt date -- дата закрытия счета
    );
----------------------------------------------------------
CREATE TEMPORARY TABLE transaction
    (
    id integer, -- ID транзакции
    account_id integer, -- ID счета
    transaction_date date, -- дата транзакции
    amount numeric(10,2), -- сумма транзакции
    type varchar(3) -- тип транзакции
    );

--Для наглядности заполним таблицы набором рандомных данных ------------------------------------------------------------
--таблица клиентов
INSERT INTO client (id, name) VALUES
    (1, 'Clinton Botsford'),
    (2, 'Granville Ruecker PhD'),
    (3, 'Emery Leannon'),
    (4, 'Mrs. Gerardo Gaylord'),
    (5, 'Dr. Susie Barton');

--таблица открытых/закрытых счетов
INSERT INTO account (id, client_id, open_dt, close_dt) VALUES
    (1, 3, '2021-01-01', null),
    (2, 3, '2021-02-01', '2022-08-01'),
    (3, 5, '2021-01-01', null),
    (4, 4, '2021-03-01', '2022-08-01'),
    (5, 1, '2021-01-01', null),
    (6, 5, '2021-04-01', '2022-08-01'),
    (7, 1, '2021-01-01', '2022-08-01'),
    (8, 4, '2021-05-01', null),
    (9, 2, '2021-12-01', null),
    (10,2, '2021-06-01', null);

--Сгенерируем таблицу случайными данными транзакций >1000 записей
INSERT INTO transaction (id, account_id, transaction_date, amount, type)
    SELECT  trunc(random()*200+1), -- рандомные знаячения в пределах 200
            generate_series(1, trunc(random()*10+1)::int, 1), -- генерируем числа от 1 до 10
            (select '2022-05-01'::date + make_interval(0, 0, 1, i) as gs), --генерируем дату транзакций чтобы была больше месяца
            trunc(random()*trunc(random()*250+1)::int+50), --генерируем случайные суммы
            ('[0:2]={ref,wit,buy}'::text[])[floor(random()*3)] --генерируем тип транзакции ref-пополнение/wit-снятие средств/buy-покупка
            FROM generate_series(0, 250, 1) as i;

/*т.к. при генерации можем зайти за текущую даты, нужно их удалить */
DELETE FROM transaction WHERE transaction_date > '2022-10-14';

--Напишем и выполним запрос который выдаст требуемые имена клиентов в соответствии с заданым условием
SELECT c.name FROM client c
    INNER JOIN account a ON c.id = a.client_id
    INNER JOIN transaction t ON a.id = t.account_id
    WHERE
        a.open_dt < (now() - interval '1 year')::date AND a.close_dt IS NULL AND --условие! у которых есть как минимум один активный счет, открытый больше года назад, т.е. текущая дата - 1 год
        t.transaction_date > (now() - interval '30 day')::date AND --условие! за последний месяц, т.е. текущая дата -30 дней
        t.type = 'buy'
    GROUP BY c.name
    HAVING SUM(amount) <5000; --условие! по всем своим счетам совершили покупок меньше, чем на 5000 рублей.

/* результат выполнения
+---------------------+
|name                 |
+---------------------+
|Clinton Botsford     |
|Dr. Susie Barton     |
|Emery Leannon        |
|Mrs. Gerardo Gaylord |
+---------------------+
*/