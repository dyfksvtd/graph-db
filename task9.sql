-- Найти все галереи мира, которые предоставили свои картины для конкретной выставки и вывести названия этих картин.

SELECT 
    G.name AS [Gallery],
    G.country AS [Country],
    P.title AS [Picture],
    E.name AS [Exhibition]
FROM 
    Gallery G, 
    OwnedBy ob, 
    Painting P, 
    DisplayedAt da, 
    Exhibition E
WHERE MATCH(G-(ob)->P-(da)->E)
  AND E.city = N'Париж';
