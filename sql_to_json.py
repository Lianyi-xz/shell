#!/usr/bin/python
#coding: utf-8
import MySQLdb
import json
import datetime

#处理data类型
def date_handler(obj):
    if hasattr(obj, 'isoformat'):
        return obj.isoformat()
    else:
        raise TypeError

#连接数据库
try:
        conn = MySQLdb.connect (host = "192.168.1.43",
                           user = "root",
                           passwd = "123456",
                           db = "stw",
                           charset = 'utf8')
except Exception as e:
     print(e)
     sys.exit()

#查询数据
select_cursor = conn.cursor ()
selectsql="select * from patient limit 10"
select_cursor.execute(selectsql)
data=select_cursor.fetchall()
fields = select_cursor.description
select_cursor.close()
#关闭数据库连接
conn.commit()
conn.close ()

#定义字段名的列表
column_list = []

# 提取字段名，追加到列表中
for i in fields:
  column_list.append(i[0])

#按行将数据存入数组中，并转换为json格式
#column_size = len(column_list)
sql_list=[]
for row in data:
  result = {}
  for i in range(len(row)):
    result[column_list[i]] = row[i]
  #jsondata = json.dumps(result,default=date_handler)
  sql_list.append(result)

with open("./patient.json", "w") as f:
    f.write(json.dumps(sql_list,default=date_handler))