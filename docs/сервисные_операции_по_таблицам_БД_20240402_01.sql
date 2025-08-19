
-- посмотреть количество записей
select count(*) from curr_pair_history ;
select count(*) from gecko_coin_list ;
select count(*) from gecko_coins_history_data ;

-- посмотреть записи
select * from curr_pair_history ;
select * from gecko_coin_list ;
select * from gecko_coins_history_data ;

-- выбрать уникальные записи
select distinct currency from curr_pair_history ;
select distinct currency from gecko_coins_history_data ;
select distinct LOWER(currency) from curr_pair_history ;

-- выбрать  для монет, присутствующих в таблице криптокомпаре
select id_gecko_curr 
       from gecko_coin_list 
       where symb_gecko_curr in (select distinct LOWER(currency) from curr_pair_history) order by 1;

commit ;

--delete from gecko_coins_history_data ;        

-- посмотреть  по загруженны данным по каждой монете (предстоит расписать)


-- 20240402

create table gecko_coin_list_20240402_00 as (select * from gecko_coin_list) ;
select count(*) from gecko_coin_list_20240402_00 ;
select * from gecko_coin_list order by 1 ;
alter table gecko_coin_list add column hands_comment varchar(254) ;

--drop table tmp_top_100_coin_20240402_01 ;
create table tmp_top_100_coin_20240402_01 (coin_range int, coin_short_name varchar(254), coin_name varchar(254)) ;

insert into tmp_top_100_coin_20240402_01 values (1,'BTC',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (2,'ETH',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (3,'USDT',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (4,'BNB',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (5,'SOL',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (6,'XRP',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (7,'USDC',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (8,'DOGE',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (9,'ADA',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (10,'AVAX',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (11,'TON',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (12,'SHIB',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (13,'DOT',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (14,'BCH',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (15,'LINK',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (16,'TRX',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (17,'MATIC',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (18,'ICP',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (19,'UNI',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (20,'NEAR',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (21,'LTC',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (22,'APT',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (23,'LEO',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (24,'DAI',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (25,'STX',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (26,'FIL',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (27,'ETC',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (28,'ATOM',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (29,'WIF',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (30,'ARB',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (31,'IMX',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (32,'MNT',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (33,'XLM',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (34,'RNDR',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (35,'CRO',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (36,'HBAR',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (37,'OKB',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (38,'OP',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (39,'PEPE',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (40,'GRT',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (41,'MKR',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (42,'TAO',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (43,'INJ',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (44,'VET',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (45,'KAS',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (46,'THETA',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (47,'RUNE',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (48,'FTM',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (49,'LDO',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (50,'FET',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (51,'FDUSD',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (52,'AR',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (53,'TIA',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (54,'FLOKI',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (55,'XMR',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (56,'SUI',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (57,'SEI',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (58,'ALGO',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (59,'GALA',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (60,'JUP',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (61,'FLOW',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (62,'SVBSV',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (63,'AAVE',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (64,'CFX',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (65,'BONK',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (66,'BEAM',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (67,'AGIX',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (68,'QNT',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (69,'EGLD',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (70,'FLR',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (71,'DYDX',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (72,'SAND',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (73,'STRK',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (74,'AXS',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (75,'BTT',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (76,'SNX',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (77,'ORDI',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (78,'CORE',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (79,'BGB',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (80,'PYTH',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (81,'WLD',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (82,'XTZ',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (83,'MINA',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (84,'CHZ',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (85,'ONDO',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (86,'XEC',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (87,'MANA',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (88,'AXL',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (89,'PENDLE',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (90,'EOS',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (91,'APE',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (92,'RON',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (93,'SATS',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (94,'CAKE',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (95,'NEO',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (96,'KAVA',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (97,'AKT',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (98,'IOTA',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (99,'KCS',NULL) ;
insert into tmp_top_100_coin_20240402_01 values (100,'JASMY',NULL) ;

select * from gecko_coin_list 
where id_gecko_curr = 'shiba-inu' or symb_gecko_curr = 'shiba-inu' or name_gecko_curr = 'shiba-inu' 
order by 1 ;

insert into gecko_coin_list values('internet-computer', 'ICP', 'HANDS_ICP', 'HANDS_ICP') ;
insert into gecko_coin_list values('shiba-inu', 'SHIB', 'HANDS_SHIB', 'HANDS_SHIB') ;
insert into gecko_coin_list values('near', 'NEAR', 'HANDS_NEAR', 'HANDS_NEAR') ;
insert into gecko_coin_list values('the-graph', 'GRT', 'HANDS_GRT', 'HANDS_GRT') ;
insert into gecko_coin_list values('theta-token', 'THETA', 'HANDS_THETA', 'HANDS_THETA') ;
insert into gecko_coin_list values('lido-dao', 'LDO', 'HANDS_LDO', 'HANDS_LDO') ;
insert into gecko_coin_list values('first-digital-usd', 'FDUSD', 'HANDS_FDUSD', 'HANDS_FDUSD') ;
insert into gecko_coin_list values('the-sandbox', 'SAND', 'HANDS_SAND', 'HANDS_SAND') ;
insert into gecko_coin_list values('bitget-token', 'BGB', 'HANDS_BGB', 'HANDS_BGB') ;
insert into gecko_coin_list values('pyth-network', 'PYTH', 'HANDS_PYTH', 'HANDS_PYTH') ;
insert into gecko_coin_list values('ethereum-classic', 'ETC', 'HANDS_ETC', 'HANDS_ETC') ;
insert into gecko_coin_list values('cosmos', 'ATOM', 'HANDS_ATOM', 'HANDS_ATOM') ;
insert into gecko_coin_list values('axie-infinity', 'AXS', 'HANDS_AXS', 'HANDS_AXS') ;
insert into gecko_coin_list values('mina-protocol', 'MINA', 'HANDS_MINA', 'HANDS_MINA') ;
insert into gecko_coin_list values('sats-ordinals', 'SATS', 'HANDS_SATS', 'HANDS_SATS') ;
insert into gecko_coin_list values('akash-network', 'AKT', 'HANDS_AKT', 'HANDS_AKT') ;
insert into gecko_coin_list values('bitcoin-cash', 'BCH', 'HANDS_BCH', 'HANDS_BCH') ;
insert into gecko_coin_list values('leo-token', 'LEO', 'HANDS_LEO', 'HANDS_LEO') ;

-- проверяем после ручной вставки, что с таким значением в таблице больше нет
select * from gecko_coin_list a1, gecko_coin_list a2
       where UPPER(a1.id_gecko_curr) = UPPER(a2.id_gecko_curr) and a2.HANDS_COMMENT IS NOT NULL ;

-- убеждаемся, что наша первая сотня и там и там заполнена
SELECT * FROM tmp_top_100_coin_20240402_01 
              LEFT OUTER JOIN 
              gecko_coin_list gl_01
              ON UPPER(gl_01.symb_gecko_curr) = coin_short_name 
         order by coin_range

-- выбираем данные по короткому имени и добавляем в конфигурацию
SELECT tp.coin_short_name FROM tmp_top_100_coin_20240402_01 tp
              LEFT OUTER JOIN 
              gecko_coin_list gl_01
              ON UPPER(gl_01.symb_gecko_curr) = tp.coin_short_name 
         group by tp.coin_short_name, tp.coin_range
         order by tp.coin_range

-- выбираем данные по gecko имени и добавляем в конфигурацию - из за дублирования свреяем следующим списком
SELECT gl_01.id_gecko_curr FROM tmp_top_100_coin_20240402_01 tp
              LEFT OUTER JOIN 
              gecko_coin_list gl_01
              ON UPPER(gl_01.symb_gecko_curr) = tp.coin_short_name 
         group by gl_01.id_gecko_curr, gl_01.symb_gecko_curr, tp.coin_range
         order by tp.coin_range

SELECT tp.coin_range, gl_01.id_gecko_curr, gl_01.symb_gecko_curr FROM tmp_top_100_coin_20240402_01 tp
              LEFT OUTER JOIN 
              gecko_coin_list gl_01
              ON UPPER(gl_01.symb_gecko_curr) = tp.coin_short_name 
         group by gl_01.id_gecko_curr, gl_01.symb_gecko_curr, tp.coin_range
         order by tp.coin_range
