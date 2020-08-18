create view newview

as

select top 100 * from tablename


union all 
select top 100 * from tablename1

