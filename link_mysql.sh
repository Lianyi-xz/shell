 #!/bin/bash
table=a
echo "table = $table"
mysql -u root -p  -e "use stw;
create table if not exists $table(a int);"