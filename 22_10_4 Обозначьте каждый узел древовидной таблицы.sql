/* #SQL #Fundamentals #Tree (WITH RECURSIVE/UNION/JOIN/CASE)

    В качестве диалекта SQL использовал DB Engine PostgreSQL 14.5, все запросы можно запустить

    Задача:
Есть таблица tree с двумя столбцами: в первом указаны узлы, а во втором — родительские узлы.

node   parent
1       2
2       5
3       5
4       3
5       NULL

Задача: написать SQL таким образом, чтобы мы обозначили каждый узел как внутренний (inner),
корневой (root) или конечный узел/лист (leaf)
 */

--Создадим табличку по условию
CREATE TEMPORARY TABLE tree (
    node int,
    parent int);

--Наполним данными из задания
INSERT INTO tree (node, parent) VALUES
    (1, 2),
    (2, 5),
    (3, 5),
    (4, 3),
    (5, NULL);

--Выполним задачу используя рекурсивный запрос
WITH RECURSIVE temp1 (node, parent, level) AS ( --создадим временную таблицу
    SELECT t1.node, t1.parent, 1 FROM tree t1 --сделаем первую часть запроса и вернем одну строку пометив ее как 1-й уровень (корневой) т.е. исходная точка отсчета
        WHERE t1.parent IS NULL
    UNION
    SELECT t2.node, t2.parent, LEVEL + 1 FROM tree t2 --сделаем первую часть запроса где пронумеруем уровни вложенности
        INNER JOIN temp1 ON(temp1.node = t2.parent))
    SELECT --выберем теперь все поля
        node,
        parent,
        CASE level --и через CASE присвоим имена в соответствии с уровнями
            WHEN 1 THEN 'root'
            WHEN 2 THEN 'inner'
            WHEN 3 THEN 'leaf'
        END
        FROM temp1 ORDER BY level; --для красоты отсортируем по уровню level

/* результат запроса
+----+------+-----+
|node|parent|case |
+----+------+-----+
|5   |null  |root |
|2   |5     |inner|
|3   |5     |inner|
|1   |2     |leaf |
|4   |3     |leaf |
+----+------+-----+
 */