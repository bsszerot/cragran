#exit 0 ;

export PGPASSWORD="WWWWWWWWWWW" ; 

psql -U crypta -h 127.0.0.1 -d crypta <<EOT
delete from curr_pair_history where price_min = 0 or price_min is null ;
delete from crcomp_pair_OHLC_1H_history where price_low = 0 or price_low is null ;
delete from crcomp_pair_OHLC_1M_history where price_low = 0 or price_low is null ;
-- 20240615 quit ;
EOT

