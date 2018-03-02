#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
from bfres_tool import *

def extract(name, out_path = "out"):
    print(name)
    out_path = out_path.replace('\"', '')
    inb = open(name, "rb").read()
    if inb[:4] != b"FRES":
        print("Invalid BFRES header!")
        return
    group = groups()
    group.pos = struct.unpack(">I", inb[0x24:0x28])[0]

    if group.pos == 0:
        print("No textures found in this BFRES file!")
        return
    else:
        group.pos += 0x24
        group.file = struct.unpack(">I", inb[group.pos+4:(group.pos+4)+4])[0]

        group.name_pos = []
        group.name = []
        group.data_pos = []

        for i in range(group.file + 1):
            group.name_pos.append(struct.unpack(">I", inb[group.pos+8+(0x10*i)+8:(group.pos+8+(0x10*i)+8)+4])[0])
            group.data_pos.append(struct.unpack(">I", inb[group.pos+8+(0x10*i)+12:(group.pos+8+(0x10*i)+12)+4])[0])


            if group.data_pos[i] == 0:
                group.name.append("")
            else:
                group.name_pos[i] += group.pos + 8 + (0x10*i) + 8
                group.data_pos[i] += group.pos + 8 + (0x10*i) + 12
                group.name.append(find_name(inb, group.name_pos[i]))

        for i in range(group.file):
            ftex_pos = group.data_pos[i + 1]
            name_ = group.name[i + 1]
            (bfrespath,tempfilename) = os.path.split(os.path.abspath(name))
            (bfresname,tempextension) = os.path.splitext(tempfilename)
            if not os.path.exists(out_path + "\\" + bfresname):
                os.makedirs(out_path + "\\" + bfresname)
            format_, numMips = FTEXtoDDS(ftex_pos, inb, name_, out_path + "\\" + bfresname)

if __name__ == "__main__":
    import sys
    extract(sys.argv[1], sys.argv[2])
    #for root, dirs, files in os.walk("./"):
        #for f in files:
            #if os.path.splitext(f)[1].lower() == ".bfres":
                #extract(os.path.join(root, f))