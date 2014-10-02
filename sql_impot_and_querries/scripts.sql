--create dbase
USE PrimeDice

--create table

CREATE TABLE Init
(
game_id			INT,
game_time		VARCHAR(20),
user_id			INT,
user_name		VARCHAR(20),
game_pwin		FLOAT,
game_multip		FLOAT,
game_roll		FLOAT,
game_outcome	BOOLEAN,
game_bet		FLOAT,
game_pay		FLOAT
)

--load table from unix made csv

BULK
INSERT Init
FROM 'c:\csvtest.txt'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '0x0a'
)

--create distinct table

SELECT DISTINCT * INTO InitDist 
FROM Init

--create game table

CREATE TABLE Game
(
game_id			INT PRIMARY KEY, 
user_id			INT,
game_time		smalldatetime, --preconversion was made with awk script
game_pwin		FLOAT,
game_multip		FLOAT,
game_roll		FLOAT,
game_outcome	BIT,  --0 lose, 1 win
game_bet		FLOAT,
game_pay		FLOAT
)


SELECT DISTINCT game_id, user_id, min(game_time), game_pwin, game_multip, game_roll, game_outcome, game_bet, game_pay
INTO Game 
FROM InitDist
GROUP BY game_id, user_id, game_pwin, game_multip, game_roll, game_outcome, game_bet, game_pay; --sometimes there are duplicates in game_id, so we only take the first occurrence

--create user table

CREATE TABLE Users
(
user_id			INT PRIMARY KEY,
user_num	INT,
user_betsum	FLOAT,
user_betavg	FLOAT,
user_betmin	FLOAT,
user_betmax	FLOAT,
user_fake BIT
)

--fill user table with statistics

INSERT INTO Users
SELECT
user_id,
COUNT(DISTINCT game_id) AS user_num,
SUM(game_bet) AS user_betsum,
AVG(game_bet) AS user_betavg,
MIN(game_bet) AS user_betmin,
MAX(game_bet) AS user_betmax,
CAST(CASE WHEN user_id < 24 THEN 1 ELSE 0 END AS BIT) AS user_fake  --outlier users with repeating user names... obviously fakes
FROM Game
GROUP BY user_id


--drop work table

DROP TABLE Init
DROP TABLE InitDist

--day statistics

SELECT
DATEADD(dd, 0, DATEDIFF(dd, 0, game_time)) AS daystat_day,
COUNT(DISTINCT game_id) AS daystat_num,
MIN(game_id) AS daystat_min,
MAX(game_id) AS daystat_max
GROUP BY  DATEADD(dd, 0, DATEDIFF(dd, 0, game_time))
INTO Daystat
FROM Game

ALTER TABLE Daystat DROP COLUMN daystat_perc
ALTER TABLE Daystat ADD daystat_perc AS (CAST(daystat_num AS FLOAT)/(daystat_max-daystat_min));
SELECT * FROM Daystat

--data export to make table of subsequent plays and accounts

checkpoint
  SELECT user_id,
  game_id,
  DATEDIFF(mi,'2014-02-13 00:00:00',game_time) AS game_timediff,
  game_bet,
  game_pwin,
  game_outcome,
  game_pay
  FROM Game
  WHERE  game_time BETWEEN '2014-02-13 00:00:00' AND '2014-03-09 23:59:59'
  ORDER BY user_id, game_id

--calculate the result with subsec_calc.awk, then import back
  
 CREATE TABLE Subseq
(
game_id			INT PRIMARY KEY, 
user_id			INT,
returt_time		INT, --in minutes
return_betchange FLOAT,
return_pwin		FLOAT,
last_outcome	BIT,
last_pay		FLOAT
)
GO

BULK INSERT INTO Subseq
FROM '\\retdb02\Data\Temp\user\sampaat\subseq_res.dat'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '0x0a'
)
GO

--calculate the result with pd_account.awk, then import back

CREATE TABLE Balance
(
game_id	INT PRIMARY KEY, 
balance FLOAT		
)

--load table from unix made csv

BULK
INSERT Balance
FROM '\\retdb02\Data\Temp\user\sampaat\balance_res.dat'
WITH
(
FIELDTERMINATOR = ',',
ROWTERMINATOR = '0x0a'
)