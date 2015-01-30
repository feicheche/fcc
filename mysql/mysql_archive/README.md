利用pt-archive工具进行mysql归档的shell脚本!
===================


说明 
-------------

mysql的备份策略应该从两方面考虑，本脚本主要进行归档工作。

- 归档
- 备份


归档主要是定期将线上数据库数据轻量化以提高ddl语句的效率，提高数据库的性能。

针对具体情况制订了两种归档策略：

- 删主留从
- 主从全清

备份主要是为了防止线上库的误操作，定期进行全量与增量备份，为能及时恢复误删除数据做准备，比较好实现，这里暂不讨论。



归档 
-------------

### 删主留从

通过set sql_log_bin=0参数，删除主库的指定数据并保留从上的相关数据，同时，在归档过程中，将数据保留一份到数据仓库。

语句

time pt-archiver --set-vars='set session sql_log_bin=0' \
--source h=ip,p=passwd,P=port,u=user,D=database,t=table \
--dest h=ip,p=passwd,P=port,u=user,D=del_bak,t=table \
--where "id <= xxxxx" --limit 10000 --commit-each --no-check-charset --progress=10000 --statistics

### 主从全清

直接在主库上清理指定条件的数据，不设置set sql_log_bin=0参数，这样从上的相关数据也一并被删除。

语句

pt-archiver --source h=ip,u=user,p=passwd,D=database,t=table --where 'id < xxxx' --limit 10000 --commit-each --statistics --progress=10000 --purge --no-check-charset

### 执行计划

每天定期执行计划任务来归档数据

```
10 01 * * * /bin/bash /root/bin/mysql_archive/archive.sh >> /tmp/archive.log 2>&1
```


脚本说明（待完善）
-------------

- KeyId
	关键ID：pt-archive工具在归档的时候，尽量要选用主键或有索引的字段做归档条件字段。
- KeyTime
	归档时间：即归档多久的数据。

