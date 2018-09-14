#!/usr/bin/env python3

from urllib.request import urlopen
import csv
import urllib
import os
from xml.dom.minidom import parse
import xml.dom.minidom


class Entry():
    def __init__(self):
        self.address = ''
        self.source = ''


def load_from_cryptoioc_ch(name_pools, ip_pools):
    """
    https://cryptoioc.ch/downloads/csv

    IP
    NAME
    """

    POOLS_SOURCE = 'https://cryptoioc.ch/downloads/csv'

    os.system('wget ' + POOLS_SOURCE + ' -O /tmp/csv')

    with open('/tmp/csv', 'r') as file_stream:
        line = csv.reader(file_stream, delimiter=',', quotechar='"')
        for i in range(0,5):
            next(line, None)

        for row in line:

            tmp_pool_name = Entry()
            tmp_pool_name.address = row[0]
            tmp_pool_name.source = POOLS_SOURCE

            tmp_pool_ip = Entry()
            tmp_pool_ip.address = row[1]
            tmp_pool_ip.source = POOLS_SOURCE

            name_pools.append(tmp_pool_name)
            ip_pools.append(tmp_pool_ip)

    os.system('rm /tmp/csv')


def load_from_isc_sans_edu(ip_pools):
    """"
    https://isc.sans.edu/api/threatlist/miner
    IP
    """

    IP_POOLS_SOURCE = 'https://isc.sans.edu/api/threatlist/miner'

    os.system('wget ' + IP_POOLS_SOURCE + ' -O /tmp/miner')

    DOMTree = xml.dom.minidom.parse('/tmp/miner')
    collection = DOMTree.documentElement

    miners = collection.getElementsByTagName('miner')

    for miner in miners:
        tmp_pool = Entry()
        tmp_pool.address = miner.getElementsByTagName('ipv4')[0].childNodes[0].data
        tmp_pool.source = IP_POOLS_SOURCE
        ip_pools.append(tmp_pool)

    os.system('rm /tmp/miner')


def load_from_andoniaf_mining_pools_list(name_pools, ip_pools):
    """
    https://raw.githubusercontent.com/andoniaf/mining-pools-list/master/mining-pools.lst
    https://raw.githubusercontent.com/andoniaf/mining-pools-list/master/mining-pools_IP.lst

    IP
    NAME
    """

    NAME_POOLS_SOURCE = 'https://raw.githubusercontent.com/andoniaf/mining-pools-list/master/mining-pools.lst'
    IP_POOLS_SOURCE = 'https://raw.githubusercontent.com/andoniaf/mining-pools-list/master/mining-pools_IP.lst'

    file = urlopen(NAME_POOLS_SOURCE)

    for line in file:
        tmp_pool = Entry()
        line = line.decode('utf-8').replace('\n', '')

        tmp_pool.address = line
        tmp_pool.source = NAME_POOLS_SOURCE
        name_pools.append(tmp_pool)

    file = urlopen(IP_POOLS_SOURCE)
    for line in file:
        tmp_pool = Entry()
        line = line.decode('utf-8').replace('\n', '')
        tmp_pool.address = line
        tmp_pool.source = IP_POOLS_SOURCE
        ip_pools.append(tmp_pool)


def export_pools_as_csv(name_pools, ip_pools):
    with open('pools-IP.csv', 'w', newline='') as file_stream:

        fieldnames = ['address', 'source']
        writer = csv.DictWriter(file_stream, fieldnames=fieldnames,delimiter=',', quotechar='"')

        writer.writeheader()
        for pool in ip_pools:
            writer.writerow({'address': pool.address, 'source': pool.source})

    with open('pools-name.csv', 'w', newline='') as file_stream:

        fieldnames = ['address', 'source']
        writer = csv.DictWriter(file_stream, fieldnames=fieldnames, delimiter=',', quotechar='"')

        writer.writeheader()
        for pool in name_pools:
            writer.writerow({'address': pool.address, 'source': pool.source})


def main():
    name_pools = list()
    ip_pools = list()

    load_from_andoniaf_mining_pools_list(name_pools, ip_pools)
    load_from_cryptoioc_ch(name_pools, ip_pools)
    load_from_isc_sans_edu(ip_pools)

    export_pools_as_csv(name_pools, ip_pools)


if __name__ == '__main__':
    main()
