#!/usr/bin/env python
# coding:utf-8

import os
import paramiko


def ssh_copy_id_via_paramiko(host, user, pwd, p=22, timeout=8):
    with open(os.path.expanduser('~/.ssh/id_rsa.pub')) as f:
        pubkey = f.read()
    cmd = """
    mkdir -p $HOME/.ssh/ && echo "%s" >> $HOME/.ssh/authorized_keys && chmod 600 $HOME/.ssh/authorized_keys && chmod 700 $HOME/.ssh
    """ % pubkey
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(hostname=host, port=p, username=user, password=pwd, timeout=timeout)
        stdin, stdout, stderr = client.exec_command(cmd)
    except Exception as e:
        with open('copy_id_fail.log', 'a+') as log:
            log.write('%s\t%s\n' % (host, e))


if __name__ == '__main__':
    with open('hosts') as f:
        for line in f.readlines():
            if not line.startswith('#'):
                hostname, port, username, password = line.split()
                ssh_copy_id_via_paramiko(hostname, username, password, int(port))
                
#vim hosts
web01   22  root    root_passwd
web02   22  root    root_passwd
ha01    3222    sa01    sa01_passwd
db01    3222    sa01    sa01_passwd
