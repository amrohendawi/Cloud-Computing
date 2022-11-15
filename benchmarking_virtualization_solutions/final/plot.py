#!/usr/bin/env python3
# Before running this script, install required Pythons package manager:
#   sudo apt update && sudo apt install -y python-pip
# Then install required packages:
#   pip install numpy matplotlib

import matplotlib.pyplot as plt
import matplotlib.dates as md
import numpy as np
import datetime as dt


def make_image(data_name, time, data, source):
    ax = plt.gca()
    xfmt = md.DateFormatter('%d.%m.%Y %H:%M:%S')
    ax.xaxis.set_major_formatter(xfmt)
    plt.xticks(rotation = 25)

    plt.plot(time, data, label=source)
    
    plt.xlabel('time')
    plt.ylabel(data_name)
    plt.legend()

def convert_time(raw_time):
    return md.date2num([ dt.datetime.fromtimestamp(ts) for ts in raw_time ])

print("Loading data")
for benchmark in ['cpu', 'mem', 'diskRand', 'diskSeq', 'fork', 'uplink']:
    for source in ["native", "docker", "kvm", "qemu"]:
        data_time, data_cpu, data_mem, data_diskRand, data_diskSeq, data_fork, data_uplink = np.loadtxt(source + '-results.csv', delimiter=',', unpack=True, skiprows=1)
        parsed_time = convert_time(data_time)
        if benchmark == 'cpu':
            make_image('cpu', parsed_time, data_cpu,source)
        elif benchmark == 'mem':
            make_image('mem', parsed_time, data_mem,source)
        elif benchmark == 'diskRand':
            make_image('diskRand', parsed_time, data_diskRand,source)
        elif benchmark == 'diskSeq':
            make_image('diskSeq', parsed_time, data_diskSeq,source)
        elif benchmark == 'fork':
            make_image('fork', parsed_time, data_fork,source)
        elif benchmark == 'uplink':
            make_image('uplink', parsed_time, data_uplink,source)
    image_name = benchmark + '-plot' + '.png'
    print("Plotting " + image_name)
    plt.savefig(image_name, bbox_inches='tight')
    plt.clf()