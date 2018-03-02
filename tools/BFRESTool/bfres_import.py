#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
from bfres_tool import *

def import_dds(filename, out_path = "new"):
    print(filename)
    out_path = out_path.replace('\"', '')
    inb = open(filename, "rb").read()
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
            name = group.name[i + 1]
            (bfrespath,tempfilename) = os.path.split(os.path.abspath(filename))
            (bfresname,tempextension) = os.path.splitext(tempfilename)
            format_ = None

#Format ATI2
            dds_name = out_path + "\\" + bfresname + "\\" + name + ".ATI2.dds"
            if os.path.isfile(dds_name):
                print("  import", name + ".ATI2.dds", end="")
                format_ = struct.unpack(">I", inb[ftex_pos+0x18:ftex_pos+0x1C])[0]
                numMips = struct.unpack(">I", inb[ftex_pos+0x14:ftex_pos+0x18])[0]
                if format_ in formats:
                    #tv = 'Replace "' + name + '"\nMipmaps: ' + str(numMips-1) + '\n' + formats2[format_]
                    DDStoBFRES(ftex_pos, dds_name, filename)
                    print("  ok")
            #else:
                #print("    skip", name + ".ATI2.dds")

#Format DXT1
            dds_name = out_path + "\\" + bfresname + "\\" + name + ".DXT1.dds"
            if os.path.isfile(dds_name):
                print("  import", name + ".DXT1.dds", end="")
                format_ = struct.unpack(">I", inb[ftex_pos+0x18:ftex_pos+0x1C])[0]
                numMips = struct.unpack(">I", inb[ftex_pos+0x14:ftex_pos+0x18])[0]
                if format_ in formats:
                    #tv = 'Replace "' + name + '"\nMipmaps: ' + str(numMips-1) + '\n' + formats2[format_]
                    DDStoBFRES(ftex_pos, dds_name, filename)
                    print("  ok")
            #else:
                #print("    skip", name + ".DXT1.dds")

#Format DXT5
            dds_name = out_path + "\\" + bfresname + "\\" + name + ".DXT5.dds"
            if os.path.isfile(dds_name):
                print("  import", name + ".DXT5.dds", end="")
                format_ = struct.unpack(">I", inb[ftex_pos+0x18:ftex_pos+0x1C])[0]
                numMips = struct.unpack(">I", inb[ftex_pos+0x14:ftex_pos+0x18])[0]
                if format_ in formats:
                    #tv = 'Replace "' + name + '"\nMipmaps: ' + str(numMips-1) + '\n' + formats2[format_]
                    DDStoBFRES(ftex_pos, dds_name, filename)
                    print("  ok")
            #else:
                #print("    skip", name + ".DXT5.dds")

#Format RGB8
            dds_name = out_path + "\\" + bfresname + "\\" + name + ".RGB8.dds"
            if os.path.isfile(dds_name):
                print("  import", name + ".RGB8.dds", end="")
                format_ = struct.unpack(">I", inb[ftex_pos+0x18:ftex_pos+0x1C])[0]
                numMips = struct.unpack(">I", inb[ftex_pos+0x14:ftex_pos+0x18])[0]
                if format_ in formats:
                    #tv = 'Replace "' + name + '"\nMipmaps: ' + str(numMips-1) + '\n' + formats2[format_]
                    DDStoBFRES(ftex_pos, dds_name, filename)
                    print("  ok")
            #else:
                #print("    skip", name + ".RGB8.dds")

if __name__ == "__main__":
    import sys
    import_dds(sys.argv[1], sys.argv[2])
    #for root, dirs, files in os.walk("./"):
        #for f in files:
            #if os.path.splitext(f)[1].lower() == ".bfres":
                #import_dds(os.path.join(root, f))