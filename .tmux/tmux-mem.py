#!/usr/bin/env python

import psutil

def info():
    mem = psutil.virtual_memory()

    line = "%s/%sMB" % (
        str(int(mem.used / 1024 / 1024)),
        str(int(mem.total / 1024 / 1024))
    )

    return line

def main():
    try:
        print info()
    except (KeyboardInterrupt, SystemExit):
        pass

if __name__ == '__main__':
    main()