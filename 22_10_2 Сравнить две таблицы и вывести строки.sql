/* #SQL #Fundamentals (JOIN)

    В качестве диалекта SQL использовал DB Engine PostgreSQL 14.5, все запросы можно запустить

    Задача:
Есть таблицы А и В, в каждой только 1 поле paramA и paramB.
Нужно сравнить эти таблицы и вывести все строки А, которых нет в В, а также все строки B, которых нет в A.
*/
--создадим такие таблицы
CREATE TEMPORARY TABLE a
    (
    paramA varchar(40)
    );

CREATE TEMPORARY TABLE b
    (
    paramB varchar(40)
    );

--наполним таблицы данными, например именами
INSERT INTO a (paramA) VALUES
    ('Clinton'),
    ('Granville'),
    ('Emery'),
    ('Gerardo'),
    ('Susie'),
    ('Freddie'),
    ('Eichmann'),
    ('Camylle'),
    ('Dario'),
    ('Devan');

INSERT INTO b (paramB) VALUES
    ('Clinton'),
    ('Granville'),
    ('Emery'),
    ('Gerardo'),
    ('Susie'),
    ('Freddie'),
    ('Bertram'),
    ('Gulgowski'),
    ('Goodwin'),
    ('Beatty');

--выполним запрос к двум таблицам
SELECT * FROM a
    FULL JOIN b ON b.paramB = a.paramA
WHERE paramA IS NULL OR paramB IS NULL;

/*получаем результат
+--------+---------+
|parama  |paramb   |
+--------+---------+
|Eichmann|null     |
|Camylle |null     |
|Dario   |null     |
|Devan   |null     |
|null    |Goodwin  |
|null    |Bertram  |
|null    |Gulgowski|
|null    |Beatty   |
+--------+---------+
*/