declare @NewTable table(
Id int,
median int
)
insert into @NewTable Select Id, 
       AVG(daily_vaccinations) AS MEDIANVAL 
FROM   (SELECT Id, 
               daily_vaccinations, 
               ROW_NUMBER() 
                 OVER ( 
                   PARTITION BY Id 
                   ORDER BY daily_vaccinations ASC, Id ASC) AS ROWASC, 
               ROW_NUMBER() 
                 OVER ( 
                   PARTITION BY Id 
                   ORDER BY daily_vaccinations DESC)                   AS ROWDESC 
        FROM   country_vaccination_stats SOH) X 
WHERE  ROWASC IN ( ROWDESC, ROWDESC - 1, ROWDESC + 1 ) 
GROUP  BY Id 
ORDER  BY Id

update @NewTable set median=0 where median is null

select * from @NewTable

declare @n int,@m int,@z int
set @n=1
set @m=(select distinct count(*) from @NewTable)+1
while(@n<@m)
begin
set @z=(select median from @NewTable where Id=@n)
update country_vaccination_stats set daily_vaccinations=@z where Id=@n and daily_vaccinations is null

set @n=@n+1
end
select * from country_vaccination_stats
