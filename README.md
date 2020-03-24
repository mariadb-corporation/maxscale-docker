# REAL World Project

## Prerequisites
-docker
-docker-compose
-mariadb-client
-git

## Clonning
Run git clone https://github.com/gustanik/CNA350

## MaxScale docker-compose setup

1. run sudo docker-compose up -d --build

2. run sudo docker-compose exec maxscale maxctrl list servers
┌─────────┬─────────┬──────┬─────────────┬─────────────────┬──────────┐
│ Server  │ Address │ Port │ Connections │ State           │ GTID     │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼──────────┤
│ server1 │ master  │ 3306 │ 0           │ Master, Running │ 0-3000-32│
├─────────┼─────────┼──────┼─────────────┼─────────────────┼──────────┤
│ server2 │ slave1  │ 3306 │ 0           │ Slave, Running  │ 0-3000-32│
├─────────┼─────────┼──────┼─────────────┼─────────────────┼──────────┤
│ server3 │ master2 │ 3306 │ 0           │ Master, Running │ 0-3002-31│
└─────────┴─────────┴──────┴─────────────┴─────────────────┴──────────┘
├─────────┼─────────┼──────┼─────────────┼─────────────────┼──────────┤
│ server4 │ slave2  │ 3306 │ 0           │ Slave, Running  │ 0-3002-31│
└─────────┴─────────┴──────┴─────────────┴─────────────────┴──────────┘
├─────────┼─────────┼──────┼─────────────┼─────────────────┼──────────┤
│ shard-A │127.0.0.1│ 4006 │ 0           │ Running         │          │
├─────────┼─────────┼──────┼─────────────┼─────────────────┼──────────┤
│ Shard-B │127.0.0.1│ 4007 │ 0           │ Running         │          │
└─────────┴─────────┴──────┴─────────────┴─────────────────┴──────────┘

## Accessing master shard database zipcode one
run mysql -umaxuser -pmaxpwd -h 127.0.0.1 -P 3306 -e "SELECT * FROM zipcodes_one.zipcodes_one LIMIT 5;" 
 
 Zipcode | ZipCodeType | City | State | LocationType | Coord_Lat | Coord_Long | Location | Decommisioned | TaxReturnsFiled | EstimatedPopulation | TotalWages | +---------+-------------+----------+-------+--------------+-----------+------------+-------------------+---------------+-----------------+---------------------+------------+ | 705 | STANDARD | AIBONITO | PR | PRIMARY | 18.14 | -66.26 | NA-US-PR-AIBONITO | FALSE | | | | | 610 | STANDARD | ANASCO | PR | PRIMARY | 18.28 | -67.14 | NA-US-PR-ANASCO | FALSE | | | | | 611 | PO BOX | ANGELES | PR | PRIMARY | 18.28 | -66.79 | NA-US-PR-ANGELES | FALSE | | | | | 612 | STANDARD | ARECIBO | PR | PRIMARY | 18.45 | -66.73 | NA-US-PR-ARECIBO | FALSE | | | | | 601 | STANDARD | ADJUNTAS | PR | PRIMARY | 18.16 | -66.72 | NA-US-PR-ADJUNTAS | FALSE | | | | +---------+-------------+----------+-------+--------------+-----------+------------+-------------------+---------------+-----------------+---------------------+
 ## Accessing master shard database zipcode two
run mysql -umaxuser -pmaxpwd -h 127.0.0.1 -P 3306 -e "SELECT * FROM zipcodes_two.zipcodes_two LIMIT 5;" 

| Zipcode | ZipCodeType | City | State | LocationType | Coord_Lat | Coord_Long | Location | Decommisioned | TaxReturnsFiled | EstimatedPopulation | TotalWages | +---------+-------------+-------------+-------+--------------+-----------+------------+----------------------+---------------+-----------------+---------------------+------------+ | 42040 | STANDARD | FARMINGTON | KY | PRIMARY | 36.67 | -88.53 | NA-US-KY-FARMINGTON | FALSE | 465 | 896 | 11562973 | | 41524 | STANDARD | FEDSCREEK | KY | PRIMARY | 37.4 | -82.24 | NA-US-KY-FEDSCREEK | FALSE | | | | | 42533 | STANDARD | FERGUSON | KY | PRIMARY | 37.06 | -84.59 | NA-US-KY-FERGUSON | FALSE | 429 | 761 | 9555412 | | 40022 | STANDARD | FINCHVILLE | KY | PRIMARY | 38.15 | -85.31 | NA-US-KY-FINCHVILLE | FALSE | 437 | 839 | 19909942 | | 40023 | STANDARD | FISHERVILLE | KY | PRIMARY | 38.16 | -85.42 | NA-US-KY-FISHERVILLE | FALSE | 1884 | 3733 | 113020684 | +---------+-------------+-------------+-------+--------------+-----------+------------+----------------------+---------------+-----------------+---------------------+------------+
