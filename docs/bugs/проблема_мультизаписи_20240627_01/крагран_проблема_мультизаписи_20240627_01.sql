select * from public.crcomp_pair_ohlc_1d_history
WHERE currency = 'BTC' AND reference_currency = 'USDT'
             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '160 DAYS' 
order by timestamp_point asc  ;

-- зафиксировано 20240627 перед отъездом на море
-- выявлена проблема задваивания записей
select count(*), timestamp_point, currency, reference_currency
       from public.crcomp_pair_ohlc_1m_history
	   group by timestamp_point, currency, reference_currency
	   having count(*) > 1
	   order by 1 desc
-- и их количество
select count(*) from
(select count(*), timestamp_point, currency, reference_currency
       from public.crcomp_pair_ohlc_1m_history
	   group by timestamp_point, currency, reference_currency
	   having count(*) > 1
	   order by 1 desc) a ;
-- мультизаписей для 1М - 137435 - даже если их по 5, это около 800 тыс. на 45 млн. таблицу
-- -- -- ext. После исправления - ноль таких записей

-- а вот совершенно одинаковые
select count(*), timestamp_point, currency, reference_currency, price_open, price_low, price_high, price_close, volume_from, volume_to
       from public.crcomp_pair_ohlc_1m_history
	   group by timestamp_point, currency, reference_currency, price_open, price_low, price_high, price_close, volume_from, volume_to
	   having count(*) > 1
	   order by 1 desc
-- и их количество
select count(*) from 
       (select count(*), timestamp_point, currency, reference_currency, price_open, price_low, price_high, price_close, volume_from, volume_to
       from public.crcomp_pair_ohlc_1m_history
	   group by timestamp_point, currency, reference_currency, price_open, price_low, price_high, price_close, volume_from, volume_to
	   having count(*) > 1
	   order by 1 desc) a ;
-- одинаковых мультизаписей для 1М - 136694 - почти все записи с одинаковыми данными, отличается 741 запись

--- 1M 20240807 ---
-- пофиксено для таблицы 1M 20240807 - скрипты в файле "перезагрузка_таблицы_1М_20240806_02.sql"
-- по дороге столкнулись с необходимостью заливки данных в правильной последовательности - по парам монет, а внутри - от старых записей к молодым.
-- Первая заливка была по времени, потом по монетам, моделируя заполнение в реальном времени, и не указан ASC при сортировке, но в доке он по умолчанию
-- Однако запросы после этого тормозило сильно, ведь фактическу вставка идёт группами записей по одной монете









select * 
       from public.crcomp_pair_ohlc_1m_history 
	   where timestamp_point = TO_TIMESTAMP('2024-04-17 03:57:00','YYYY-MM-DD HH24:MI:SS')
	         and currency = 'CELO' and reference_currency = 'USDT'


select * 
       from public.crcomp_pair_ohlc_1h_history 
	   where timestamp_point = TO_TIMESTAMP('2023-08-05 18:00:00','YYYY-MM-DD HH24:MI:SS')
	         and currency = 'FIL' and reference_currency = 'BTC'

BEGIN
 
           SELECT count(*) INTO cntEditString_nochanged
                  FROM crcomp_pair_OHLC_1D_history
                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point
                        AND price_open = v_price_open AND price_high = v_price_high AND price_low = v_price_low AND price_close = v_price_close AND volume_from = v_volume_from AND volume_to = v_volume_to ;
                        IF cntEditString_nochanged = 0 THEN
                           UPDATE crcomp_pair_OHLC_1D_history SET change_ts = now(), price_open = v_price_open, price_high = v_price_high, price_low = v_price_low, price_close = v_price_close, volume_from = v_volume_from, volume_to = v_volume_to 
                                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
                        END IF ;
        ELSE
           insert into crcomp_pair_OHLC_1D_history (change_ts, currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from, volume_to)
                  values (now(), v_currency, v_reference_currency, v_timestamp_point, v_price_open, v_price_high, v_price_low, v_price_close, v_volume_from, v_volume_to) ;
        END IF ;
END ;

BEGIN

           SELECT count(*) INTO cntEditString_nochanged
                  FROM crcomp_pair_OHLC_1H_history
                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point
                        AND price_open = v_price_open AND price_high = v_price_high AND price_low = v_price_low AND price_close = v_price_close AND volume_from = v_volume_from AND volume_to = v_volume_to ;
                        IF cntEditString_nochanged = 0 THEN
                           UPDATE crcomp_pair_OHLC_1H_history SET change_ts = now(), price_open = v_price_open, price_high = v_price_high, price_low = v_price_low, price_close = v_price_close, volume_from = v_volume_from, volume_to = v_volume_to 
                                  WHERE currency = v_currency AND reference_currency = v_reference_currency AND timestamp_point = v_timestamp_point ;
                        END IF ;
        ELSE
           insert into crcomp_pair_OHLC_1H_history (change_ts, currency, reference_currency, timestamp_point, price_open, price_high, price_low, price_close, volume_from, volume_to)
                  values (now(), v_currency, v_reference_currency, v_timestamp_point, v_price_open, v_price_high, v_price_low, v_price_close, v_volume_from, v_volume_to) ;
        END IF ;
END ;









WHERE currency = 'BTC' AND reference_currency = 'USDT'
             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '160 DAYS' 
order by timestamp_point asc  ;


SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
       price_open as PRICE_OPEN, price_low as PRICE_MIN, price_high as PRICE_MAX, price_close PRICE_CLOSE,
       extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, 
	   extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, 
	   extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
       volume_from as VOLUME_FROM, volume_to as VOLUME_TO
       FROM crcomp_pair_OHLC_1D_history
       WHERE currency = 'BTC' AND reference_currency = 'USDT'
             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '160 DAYS' 
			 order by timestamp_point ASC
			 
SELECT currency, reference_currency, TO_CHAR((timestamp_point + INTERVAL '3 HOURS'),'YYYY-MM-DD HH24:MI:SS'),
                       price_open as PRICE_OPEN, price_low as PRICE_MIN, price_high as PRICE_MAX, price_close PRICE_CLOSE,
                       extract(day from (timestamp_point + INTERVAL '3 HOURS')) days, 
					   extract(hour from (timestamp_point + INTERVAL '3 HOURS')) hours, 
					   extract(minute from (timestamp_point + INTERVAL '3 HOURS')) minutes,
                       volume_from as VOLUME_FROM, volume_to as VOLUME_TO
                       FROM crcomp_pair_OHLC_1D_history
                       WHERE currency = 'BTC' AND reference_currency = 'USDT'
                             AND (timestamp_point + INTERVAL '3 HOURS') > CURRENT_DATE - INTERVAL '260 DAYS' 
							 order by timestamp_point ASC			 