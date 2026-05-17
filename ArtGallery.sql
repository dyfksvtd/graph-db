USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'ArtGallery')
BEGIN
    ALTER DATABASE ArtGallery SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ArtGallery;
END
GO

CREATE DATABASE ArtGallery;
GO
USE ArtGallery;
GO

CREATE TABLE Artist (
    id INT NOT NULL PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    birth_year INT
) AS NODE;

CREATE TABLE Painting (
    id INT NOT NULL PRIMARY KEY,
    title NVARCHAR(100) NOT NULL,
    style NVARCHAR(50)
) AS NODE;

CREATE TABLE Exhibition (
    id INT NOT NULL PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    city NVARCHAR(50)
) AS NODE;

CREATE TABLE Gallery (
    id INT NOT NULL PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    city NVARCHAR(50)
) AS NODE;

CREATE TABLE AuthoredBy AS EDGE;    
CREATE TABLE OwnedBy AS EDGE;      
CREATE TABLE DisplayedAt AS EDGE; 

ALTER TABLE AuthoredBy ADD CONSTRAINT EC_Authored CONNECTION (Artist TO Painting);
ALTER TABLE OwnedBy ADD CONSTRAINT EC_Owned CONNECTION (Gallery TO Painting);
ALTER TABLE DisplayedAt ADD CONSTRAINT EC_Displayed CONNECTION (Painting TO Exhibition);

INSERT INTO Artist (id, name, birth_year) VALUES 
(1, N'Леонардо да Винчи', 1452), (2, N'Винсент ван Гог', 1853),
(3, N'Пабло Пикассо', 1881), (4, N'Клод Моне', 1840),
(5, N'Сальвадор Дали', 1904), (6, N'Иван Шишкин', 1832),
(7, N'Казимир Малевич', 1879), (8, N'Эдвард Мунк', 1863),
(9, N'Рембрандт', 1606), (10, N'Микеланджело', 1475);

INSERT INTO Painting (id, title, style) VALUES 
(1, N'Мона Лиза', N'Ренессанс'), (2, N'Звездная ночь', N'Постимпрессионизм'), 
(3, N'Герника', N'Кубизм'), (4, N'Водяные лилии', N'Импрессионизм'),
(5, N'Постоянство памяти', N'Сюрреализм'), (6, N'Утро в сосновом лесу', N'Реализм'),
(7, N'Черный квадрат', N'Супрематизм'), (8, N'Крик', N'Экспрессионизм'),
(9, N'Ночной дозор', N'Барокко'), (10, N'Сотворение Адама', N'Ренессанс');

INSERT INTO Exhibition (id, name, city) VALUES 
(1, N'Шедевры Европы', N'Париж'), (2, N'Мир красок', N'Амстердам'),
(3, N'Испанская гордость', N'Мадрид'), (4, N'Русский лес', N'Москва'),
(5, N'Современники', N'Нью-Йорк'), (6, N'Классика', N'Лондон'),
(7, N'Авангард', N'Берлин'), (8, N'Свет и тень', N'Париж'),
(9, N'Сюрреалисты', N'Барселона'), (10, N'Эпоха титанов', N'Рим');

INSERT INTO Gallery (id, name, city) VALUES 
(1, N'Лувр', N'Париж'), (2, N'Музей ван Гога', N'Амстердам'),
(3, N'Прадо', N'Мадрид'), (4, N'Третьяковка', N'Москва'),
(5, N'Музей МОМА', N'Нью-Йорк'), (6, N'Британский музей', N'Лондон'),
(7, N'Эрмитаж', N'Санкт-Петербург'), (8, N'Галерея Уффици', N'Флоренция'),
(9, N'Музей Мунка', N'Осло'), (10, N'Рейксмюсеум', N'Амстердам');

INSERT INTO AuthoredBy ($from_id, $to_id) VALUES 
((SELECT $node_id FROM Artist WHERE id=1), (SELECT $node_id FROM Painting WHERE id=1)),
((SELECT $node_id FROM Artist WHERE id=2), (SELECT $node_id FROM Painting WHERE id=2)),
((SELECT $node_id FROM Artist WHERE id=3), (SELECT $node_id FROM Painting WHERE id=3)),
((SELECT $node_id FROM Artist WHERE id=4), (SELECT $node_id FROM Painting WHERE id=4)),
((SELECT $node_id FROM Artist WHERE id=5), (SELECT $node_id FROM Painting WHERE id=5)),
((SELECT $node_id FROM Artist WHERE id=6), (SELECT $node_id FROM Painting WHERE id=6)),
((SELECT $node_id FROM Artist WHERE id=7), (SELECT $node_id FROM Painting WHERE id=7)),
((SELECT $node_id FROM Artist WHERE id=8), (SELECT $node_id FROM Painting WHERE id=8)),
((SELECT $node_id FROM Artist WHERE id=9), (SELECT $node_id FROM Painting WHERE id=9)),
((SELECT $node_id FROM Artist WHERE id=10), (SELECT $node_id FROM Painting WHERE id=10));

INSERT INTO OwnedBy ($from_id, $to_id) VALUES 
((SELECT $node_id FROM Gallery WHERE id=1), (SELECT $node_id FROM Painting WHERE id=1)), 
((SELECT $node_id FROM Gallery WHERE id=2), (SELECT $node_id FROM Painting WHERE id=2)),
((SELECT $node_id FROM Gallery WHERE id=3), (SELECT $node_id FROM Painting WHERE id=3)),
((SELECT $node_id FROM Gallery WHERE id=10), (SELECT $node_id FROM Painting WHERE id=9)),
((SELECT $node_id FROM Gallery WHERE id=4), (SELECT $node_id FROM Painting WHERE id=6)),
((SELECT $node_id FROM Gallery WHERE id=7), (SELECT $node_id FROM Painting WHERE id=9));

INSERT INTO DisplayedAt ($from_id, $to_id) VALUES 
((SELECT $node_id FROM Painting WHERE id=1), (SELECT $node_id FROM Exhibition WHERE id=1)),
((SELECT $node_id FROM Painting WHERE id=2), (SELECT $node_id FROM Exhibition WHERE id=2)),
((SELECT $node_id FROM Painting WHERE id=5), (SELECT $node_id FROM Exhibition WHERE id=9)),
((SELECT $node_id FROM Painting WHERE id=10), (SELECT $node_id FROM Exhibition WHERE id=10)),
((SELECT $node_id FROM Painting WHERE id=6), (SELECT $node_id FROM Exhibition WHERE id=4));
GO

-- Автор конкретной картины
SELECT A.name FROM Artist A, AuthoredBy ab, Painting P
WHERE MATCH(A-(ab)->P) AND P.title = N'Мона Лиза';

-- Где физически выставляется картина, принадлежащая Лувру?
SELECT P.title, E.name as [Exhibition], E.city 
FROM Gallery G, OwnedBy ob, Painting P, DisplayedAt da, Exhibition E
WHERE MATCH(G-(ob)->P-(da)->E) AND G.name = N'Лувр';

-- Список всех картин, выставляемых в Париже
SELECT P.title, A.name as [Author]
FROM Artist A, AuthoredBy ab, Painting P, DisplayedAt da, Exhibition E
WHERE MATCH(A-(ab)->P-(da)->E) AND E.city = N'Париж';

-- Найти художников, чьи картины находятся в одном стиле с "Звездной ночью"
SELECT DISTINCT A.name 
FROM Painting P1, Painting P2, AuthoredBy ab, Artist A
WHERE P1.title = N'Звездная ночь' 
  AND P1.style = P2.style 
  AND MATCH(A-(ab)->P2)
  AND P1.id <> P2.id;

-- Какие галереи владеют работами в стиле "Ренессанс"?
SELECT DISTINCT G.name 
FROM Gallery G, OwnedBy ob, Painting P
WHERE MATCH(G-(ob)->P) AND P.style = N'Ренессанс';

-- Кратчайший путь от Художника до Картины 
SELECT 
    Artist.name AS [Artist],
    STRING_AGG(Painting.title, ' -> ') WITHIN GROUP (GRAPH PATH) AS [PathToPainting],
    LAST_VALUE(Painting.title) WITHIN GROUP (GRAPH PATH) AS [FinalWork]
FROM 
    Artist, 
    AuthoredBy FOR PATH AS ab, 
    Painting FOR PATH AS Painting
WHERE MATCH(SHORTEST_PATH(Artist(-(ab)->Painting)+))
AND Artist.name = N'Леонардо да Винчи';

-- Поиск всех картин художника
SELECT 
    StartNode.name AS Artist,
    STRING_AGG(TargetNode.title, ', ') WITHIN GROUP (GRAPH PATH) AS [Paintings]
FROM 
    Artist AS StartNode,
    AuthoredBy FOR PATH AS ab,
    Painting FOR PATH AS TargetNode
WHERE MATCH(SHORTEST_PATH(StartNode(-(ab)->TargetNode){1,3}))
AND StartNode.name = N'Винсент ван Гог';
GO