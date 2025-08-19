
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
