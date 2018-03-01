from aliyunsdkcore import client
from aliyunsdkrds.request.v20140815 import DescribeRegionsRequest
import json
#import pymysql
import MySQLdb
import time
import numpy as np
'''
DescribeDBInstancePerformance:性能参数

    MySQL_DetailedSpaceUsage:MySQL实例空间占用详情：
        ins_size实例总空间使用量
        data_size数据空间
        log_size日志空间
        tmp_size临时空间
        other_size系统空间
        
    MySQL_COMDML:平均每秒DML/DDL语句执行次数
        
    MySQL_Sessions:MySQL连接数：
        active_session活跃连接数
        total_session总连接数
    MySQL_IOPS:MySQL实例的IOPS：
        io每秒IO请求次数
    MySQL_QPSTPS
    MySQL_NetworkTraffic
        

        
    MySQL_InnoDBBufferRatio
    MySQL_InnoDBDataReadWriten
    MySQL_InnoDBLogRequests
    MySQL_MemCpuUsage:MySQL内存和CPU使用率：
        cpuusage内存使用率
        memusageCPU使用率
    
    
create table MySQL_Type(
  	id         int(10)        primary key	auto_increment,
  	type       varchar(10)    comment'数据库实例ID',
  	type_name  varchar(10)    comment'数据库实例昵称',
);
MySQL_Type数据
1   rm-1    PRD_RDS(生产)
2   rm-2    PRE_RDS_TEST1(开发)

create table MySQL_DetailedSpaceUsage(
	id         int(10)        primary key	auto_increment,
	type       int(10)        default 1,
    ins_size   decimal(12,2) comment'实例总空间使用量 mb',
    data_size  decimal(12,2) comment'数据空间',
    log_size   decimal(12,2) comment'日志空间',
    tmp_size   decimal(12,2) comment'临时空间',
    other_size decimal(12,2) comment'系统空间',
    date       datetime      comment'日期',
    constraint fk_type_DetailedSpaceUsage foreign key(type) references MySQL_Type (id),
);

create table MySQL_COMDML(
	id                  int(10)      primary key	auto_increment,
	type                int(10)      default 1,
	com_delete          decimal(8,2) comment'平均每秒Delete语句执行次数',
	com_insert          decimal(8,2) comment'平均每秒Insert语句执行次数',
	com_insert_select   decimal(8,2) comment'平均每秒Insert_Select语句执行次数',
	com_replace         decimal(8,2) comment'平均每秒Replace语句执行次数',
	com_replace_select  decimal(8,2) comment'平均每秒Replace_Select语句执行次数',
	com_select          decimal(8,2) comment'平均每秒Select语句执行次数',
	com_update          decimal(8,2) comment'平均每秒Update语句执行次数',
   date                datetime     comment'日期',
   constraint fk_type_COMDML foreign key(type) references MySQL_Type (id),
);

create table MySQL_Normal(
	id                  int(10)      primary key	auto_increment,
	type                int(10)      default 1,
	io                  decimal(8,2) comment'IOPS(每秒IO请求次数)',
	recv_k              decimal(8,2) comment'平均每秒钟的输入流量 KB',
	sent_k              decimal(8,2) comment'平均每秒钟的输出流量',
	QPS                 decimal(8,2) comment'平均每秒SQL语句执行次数',
	TPS                 decimal(8,2) comment'平均每秒事务数',
	active_session      int(10)      comment'当前活跃连接数',
	total_session       int(10)      comment'当前总连接数',
	date                datetime     comment'日期',
	constraint fk_type_Normal foreign key(type) references MySQL_Type (id),
);
create table MySQL_InnoDB(
	id                  int(10)      primary key	auto_increment,
	type                int(10)      default 1,
	ibuf_read_hit       decimal(8,2) comment'InnoDB缓冲池的读命中率',
	ibuf_use_ratio      decimal(8,2) comment'InnoDB缓冲池的利用率',
	ibuf_dirty_ratio    decimal(8,2) comment'InnoDB缓冲池脏块的百分率',
	inno_data_read      decimal(8,2) comment'InnoDB平均每秒钟读取的数据量 KB',
	inno_data_written   decimal(8,2) comment'InnoDB平均每秒钟写入的数据量',
	ibuf_request_r      decimal(8,2) comment'平均每秒向InnoDB缓冲池的读次数',
	ibuf_request_w      decimal(8,2) comment'平均每秒向InnoDB缓冲池的写次数',
	cpuusage            decimal(8,2) comment'CPU使用率(占操作系统总数)',
	memusage            decimal(8,2) comment'内存使用率(占操作系统总数)',
	date                datetime     comment'日期',
	constraint fk_type_InnoDB  keyforeign(type) references MySQL_Type (id),
);

aliyun_rds_config.json
{
    "AccessKeyID":"xxxxxxxxxx",
    "AccessKeySecret":"xxxxxxxxxxxx",
    "RegionID":"cn-shanghai"
}
'''


# 从数据库中读取数据
def get_mysql(DBid,startTime,endTime,k):
    # 读取json配置文件
    #设置定时任务时，需使用绝对地址
    with open('aliyun_rds_config.json') as fp:
        aliyun_config = json.loads(fp.read())

    # 设置访问凭证
    clt = client.AcsClient(
        aliyun_config.get('AccessKeyID'),
        aliyun_config.get('AccessKeySecret'),
        aliyun_config.get('RegionID'),
    )

    # 创建Request对象，并对其中参数赋值
    request = DescribeRegionsRequest.DescribeRegionsRequest()
    request.set_accept_format('json')

    # 当前活跃连接数，IOPS,磁盘空间
    request.set_action_name('DescribeDBInstancePerformance')
    #request.set_query_params(
    #dict(DBInstanceId="rm-uf66901541fyse77g", key="MySQL_InnoDBBufferRatio,MySQL_InnoDBDataReadWriten,MySQL_InnoDBLogRequests,MySQL_MemCpuUsage",
    #         StartTime="2018-02-26T06:10Z", EndTime="2018-02-26T11:41Z"))
    request.set_query_params(dict(DBInstanceId=DBid, key=k, StartTime=startTime, EndTime=endTime))
    return json.loads(clt.do_action_with_exception(request).decode('utf-8'))


def describe_json(api_data,rds,table):
    if rds == "rm-1":
        tabletype = 1
    elif rds == "rm-2":
        tabletype = 2
    else:
        exit()

    if table == "MySQL_DetailedSpaceUsage":
        tablename = "MySQL_DetailedSpaceUsage"
    elif table == "MySQL_COMDML":
        tablename = "MySQL_COMDML"
    elif table == "MySQL_Sessions,MySQL_IOPS,MySQL_QPSTPS,MySQL_NetworkTraffic":
        tablename = "MySQL_Normal"
    elif table == "MySQL_InnoDBBufferRatio,MySQL_InnoDBDataReadWriten,MySQL_InnoDBLogRequests,MySQL_MemCpuUsage":
        tablename = "MySQL_InnoDB"
    else:
        exit()

    apikey = api_data['PerformanceKeys']['PerformanceKey']
    tablecolumn=[]
    tablevalues=[[],[],[],[],[],[],[],[],[],[],[],[]]
    date=[]
    for i in apikey:
        tablevalue=[]
        # 定义列名
        tablecolumn.append(i['ValueFormat'].replace("&", ","))
        apivalues = i['Values']['PerformanceValue']
        for d in apivalues:
            value= [d['Value'].replace("&", ",")]
            tablevalue.append(value)
            if len(date) <12:
                date.append(d['Date'].replace("T", " ").replace("Z"," "))

        #tablevalues.append(tablevalue)
        tablevalues=np.concatenate((tablevalues,tablevalue),axis=1)
    # print(",".join(tablecolumn)+",date,type")
    # print(tablevalues)
    #sql=[]
    valuelist=[]
    halfsql="insert into "+tablename+" ("+",".join(tablecolumn)+",date,type) values"
    for i in range(len(tablevalues)):
        valuelist.append("("+",".join(tablevalues[i])+",'"+date[i]+"',"+str(tabletype)+")")
    sql = halfsql+",".join(valuelist)+";"
    return sql

def insert_mysql(sqllist):
    try:
        conn = MySQLdb.connect(host="192.168.0.1",
                               user="root",
                               passwd="123456",
                               db="system",
                               charset='utf8')
    except Exception as e:
        print(e)
        sys.exit()

    ins_cursor = conn.cursor()
    for i in sqllist:
        ins_cursor.execute(i)
    ins_cursor.close()

    conn.commit()
    conn.close()

if __name__ == "__main__":
    endTime = time.strftime('%Y-%m-%dT%H:%MZ',time.localtime(time.time()-32400))
    startTime = time.strftime('%Y-%m-%dT%H:%MZ',time.localtime(time.time()-36000))
    key = ["MySQL_DetailedSpaceUsage","MySQL_COMDML","MySQL_Sessions,MySQL_IOPS,MySQL_QPSTPS,MySQL_NetworkTraffic",\
           "MySQL_InnoDBBufferRatio,MySQL_InnoDBDataReadWriten,MySQL_InnoDBLogRequests,MySQL_MemCpuUsage"]

    DBid = ['rm-1','rm-2']
    sqllist = []
    for i in DBid:
        for k in key:
            api_data = get_mysql(i,startTime,endTime,k)
            sqllist.append(describe_json(api_data,i,k))


    insert_mysql(sqllist)

