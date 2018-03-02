/*----------------------------------------------------------------------------*/
/*--  LZ eXtended coding for Nintendo WiiU Paper Mario Color Splash         --*/
/*--  Copyright (C) 2018 shenhaiyu                                          --*/
/*--                                                                        --*/
/*--  This program is free software: you can redistribute it and/or modify  --*/
/*--  it under the terms of the GNU General Public License as published by  --*/
/*--  the Free Software Foundation, either version 3 of the License, or     --*/
/*--  (at your option) any later version.                                   --*/
/*--                                                                        --*/
/*--  This program is distributed in the hope that it will be useful,       --*/
/*--  but WITHOUT ANY WARRANTY; without even the implied warranty of        --*/
/*--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the          --*/
/*--  GNU General Public License for more details.                          --*/
/*--                                                                        --*/
/*--  You should have received a copy of the GNU General Public License     --*/
/*--  along with this program. If not, see <http://www.gnu.org/licenses/>.  --*/
/*----------------------------------------------------------------------------*/
// various code from LZ eXtended coding for Nintendo GBA/DS V1.4 by CUE 2011
// https://gbatemp.net/threads/nintendo-ds-gba-compressors.313278
//
// uncompress code from QuickBMS project by Luigi Auriemma
// http://aluigi.altervista.org/quickbms.htm
//
// Paper Mario Color Splash lz file fit by shenhaiyu
//
/*----------------------------------------------------------------------------*/
#include <io.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
/*----------------------------------------------------------------------------*/
#define CMD_DECODE    0x00       // decode
#define CMD_ENCODE    0x11       // LZX big endian magic number

#define LZX_WRAM      0x00       // VRAM file not compatible (0)
#define LZX_VRAM      0x01       // VRAM file compatible (1)

#define LZX_SHIFT     1          // bits to shift
#define LZX_MASK      0x80       // first bit to check
                                 // ((((1 << LZX_SHIFT) - 1) << (8 - LZX_SHIFT)

#define LZX_THRESHOLD 2          // max number of bytes to not encode
#define LZX_N         0x1000     // max offset (1 << 12)
#define LZX_F         0x10       // max coded (1 << 4)
#define LZX_F1        0x110      // max coded ((1 << 4) + (1 << 8))
#define LZX_F2        0x10110    // max coded ((1 << 4) + (1 << 8) + (1 << 16))

#define RAW_MINIM     0x00000000 // empty file, 0 bytes
#define RAW_MAXIM     0x7FFFFFFF // 32-1 Bits length, 2GB - 1MB

#define LZX_MINIM     0x00000004 // header only (empty RAW file)
#define LZX_MAXIM     0x01400000 // * padded to 18MB, 0x01200006
                                 // * header, 4
                                 // * length, RAW_MAXIM = 0x00FFFFFF
                                 // * flags,  (RAW_MAXIM + 7) / 8 = 0x00200000
                                 // * ends,   3 (flag + 2 end-bytes)
                                 // 4 + 0x00FFFFFF + 0x00200000 + 3 + padding(0x01200006) = 0x240000C
/*----------------------------------------------------------------------------*/
#define EXIT(text)  { printf(text); exit(1); }
/*----------------------------------------------------------------------------*/

void           Save(char *filename, unsigned char *buffer, int length);
unsigned char *Load(char *filename, unsigned int  *length, int min, int max);
unsigned char *Memory(int length, int size);

unsigned int   LZX_Decode(char *filename, char *outputfilename);
unsigned int   LZX_Encode(char *filename, char *outputfilename);
unsigned int   unlz77wii_raw11(unsigned char *lz_buffer, int lz_len, unsigned char *raw_buffer, int raw_len, int return_msize);
unsigned char *lz77wii_raw11(unsigned char *raw_buffer, unsigned int raw_len, unsigned int *new_len);

/*----------------------------------------------------------------------------*/

int main(int argc, char **argv) {
  unsigned int cmd = 0;
  if (argc < 4) EXIT(
    "WiiU Paper Mario Color Splash lz file (de)compression tool\n"
    "LZ eXtended coding for Nintendo WiiU\n"
    "Source Code From: LZX - (c) CUE 2011 & QuickBMS - (c) Luigi Auriemma 2016\n"
    "\n"
    "Modified by shenhaiyu 2018\n"
    "\n"
    "Usage: lzTool command inputfile outputfile\n"
    "\n"
    "command:\n"
    "  d ..... decode infile' 'outfile'\n"
    "  c ..... encode infile' 'outfile'\n"
  );

  if      (!strcmpi(argv[1], "d")) { cmd = CMD_DECODE; }
  else if (!strcmpi(argv[1], "c")) { cmd = CMD_ENCODE; }
  else EXIT("Command not supported\n");
  if (argc != 4) EXIT("Parameter error\n");

  switch (cmd) {
    case CMD_DECODE:
      return LZX_Decode(argv[2], argv[3]);
      break;
    case CMD_ENCODE:
      return LZX_Encode(argv[2], argv[3]);
      break;
  }
  return 1;
}

/*----------------------------------------------------------------------------*/

void Save(char *filename, unsigned char *buffer, int length) {
  FILE *fp;
  if ((fp = fopen(filename, "wb")) == NULL) EXIT("\nFile create error\n");
  if (fwrite(buffer, 1, length, fp) != length) EXIT("\nFile write error\n");
  if (fclose(fp) == EOF) EXIT("\nFile close error\n");
}

unsigned char *Load(char *filename, unsigned int *length, int min, int max) {
  FILE          *fp;
  unsigned int   fs;
  unsigned char *fb;
  if ((fp = fopen(filename, "rb")) == NULL) EXIT("\nFile open error\n");
  fs = filelength(fileno(fp));
  if ((fs < min) || (fs > max)) EXIT("\nFile size overload\n");
  fb = Memory(fs + 3, sizeof(char));
  if (fread(fb, 1, fs, fp) != fs) EXIT("\nFile read error\n");
  if (fclose(fp) == EOF) EXIT("\nFile close error\n");
  *length = fs;
  return(fb);
}

unsigned char *Memory(int length, int size) {
  unsigned char *fb;
  fb = (unsigned char *) calloc(length, size);
  if (fb == NULL) EXIT("\nMemory error\n");
  return(fb);
}

/*----------------------------------------------------------------------------*/

unsigned int LZX_Decode(char *filename, char *outputfilename) {
  unsigned char *big_buffer, *raw_buffer, *raw;
  //unsigned char *pak_buffer, *raw_buffer, *pak, *raw, *pak_end, *raw_end;
  unsigned int   pak_len, raw_len, header, raw_end;

  // for Paper Mario Color Splash lz file 12 Byte Header;
  big_buffer = Load(filename, &pak_len, LZX_MINIM, LZX_MAXIM);
  raw_len = *(unsigned int *)(big_buffer + 4);
  //memcpy(&raw_len, big_buffer + 4, 4);
  pak_len -= 12;
  unsigned char *pak_buffer = malloc((size_t)(pak_len));
  memcpy(pak_buffer, big_buffer + 12, (size_t)(pak_len));
  free(big_buffer);

  header = *pak_buffer;
  if (header != CMD_ENCODE) {
    free(pak_buffer);
    EXIT("\nWARNING: file is not LZX encoded!\n");
  }

  raw_buffer = (unsigned char *) Memory(raw_len, sizeof(char));
  raw = raw_buffer;
  raw_end = unlz77wii_raw11(pak_buffer + 4, pak_len - 4, raw_buffer, raw_len, 0);
  if(raw != raw_buffer || raw_len != raw_end || raw_end == 0) EXIT("\nWARNING: unexpected end of encoded file!\n");

  Save(outputfilename, raw_buffer, raw_len);

  free(raw_buffer);
  free(pak_buffer);

  return 0;
}

unsigned int unlz77wii_raw11(unsigned char *lz_buffer, int lz_len, unsigned char *raw_buffer, int raw_len, int return_msize) {
// various code from DSDecmp: http://code.google.com/p/dsdecmp/
// original code of unlz77wii_raw10 from "Hector Martin <marcan@marcansoft.com>" http://wiibrew.org/wiki/Wii.py
// ported to C by Luigi Auriemma
// Modifyed by shenhaiyu

  unsigned char *inl;
  unsigned char  b1, bt, b2, b3, flags;
  unsigned int   i, j, disp = 0, len = 0, flag, cdest;
  unsigned int   threshold = 1;
  unsigned int   curr_size, msize = 0, lsize;

  inl  = lz_buffer + lz_len;
  lsize = lz_len;
  curr_size = 0;
  while (curr_size < raw_len) {
    if (lz_buffer >= inl) break;
    flags = *lz_buffer++;

    for (i = 0; i < 8 && curr_size < raw_len; i++) {
      flag = (flags & (0x80 >> i)) > 0;
      if (flag) {
        if (lz_buffer >= inl) break;
        b1 = *lz_buffer++;

        switch (b1 >> 4) {
          //#region case 0
          case 0: {
            // ab cd ef
            // =>
            // len = abc + 0x11 = bc + 0x11
            // disp = def
            len = b1 << 4;
            if (lz_buffer >= inl) break;
            bt = *lz_buffer++;
            len |= bt >> 4;
            len += 0x11;

            disp = (bt & 0x0F) << 8;
            if (lz_buffer >= inl) break;
            b2 = *lz_buffer++;
            disp |= b2;
            break;
          }
          //#endregion

          //#region case 1
          case 1: {
            // ab cd ef gh
            // =>
            // len = bcde + 0x111
            // disp = fgh
            // 10 04 92 3F => disp = 0x23F, len = 0x149 + 0x11 = 0x15A
            if ((lz_buffer + 3) > inl) break;
            bt = *lz_buffer++;
            b2 = *lz_buffer++;
            b3 = *lz_buffer++;

            len = (b1 & 0xF) << 12; // len = b000
            len |= bt << 4; // len = bcd0
            len |= (b2 >> 4); // len = bcde
            len += 0x111; // len = bcde + 0x111
            disp = (b2 & 0x0F) << 8; // disp = f
            disp |= b3; // disp = fgh
            break;
          }
          //#endregion

          //#region other
          default: {
            // ab cd
            // =>
            // len = a + threshold = a + 1
            // disp = bcd
            len = (b1 >> 4) + threshold;
            disp = (b1 & 0x0F) << 8;
            if (lz_buffer >= inl) break;
            b2 = *lz_buffer++;
            disp |= b2;
            break;
          }
          //#endregion
        }

        if (disp > curr_size) return 0;
        cdest = curr_size;

        for (j = 0; j < len && curr_size < raw_len; j++) {
          raw_buffer[curr_size++] = raw_buffer[cdest - disp - 1 + j];
        }
        if (curr_size > raw_len) {
          //throw new Exception(String.Format("File {0:s} is not a valid LZ77 file; actual output size > output size in header", filein));
          //Console.WriteLine(String.Format("File {0:s} is not a valid LZ77 file; actual output size > output size in header; {1:x} > {2:x}.", filein, curr_size, decomp_size));
          break;
        }
      }
      else {
        if (lz_buffer >= inl) break;
        raw_buffer[curr_size++] = *lz_buffer++;

        if (curr_size > raw_len) {
          //throw new Exception(String.Format("File {0:s} is not a valid LZ77 file; actual output size > output size in header", filein));
          //Console.WriteLine(String.Format("File {0:s} is not a valid LZ77 file; actual output size > output size in header; {1:x} > {2:x}", filein, curr_size, decomp_size));
          break;
        }
      }
      lsize = curr_size + (inl - lz_buffer);
      if (msize < lsize) msize = lsize;
    }
  }

  switch (return_msize) {
    case 0:
      return curr_size;
      break;
    case 1:
      return msize;
      break;
  }
  return 0;
}

/*----------------------------------------------------------------------------*/

unsigned int LZX_Encode(char *filename, char *outputfilename) {
  unsigned char *raw_buffer, *pak_buffer, *new_buffer;
  unsigned int   raw_len, pak_len, new_len;

  raw_buffer = Load(filename, &raw_len, RAW_MINIM, RAW_MAXIM);

  pak_buffer = NULL;
  pak_len = LZX_MAXIM + 1;

  new_buffer = lz77wii_raw11(raw_buffer, raw_len, &new_len);

  if (new_len < pak_len) {
    if (pak_buffer != NULL) free(pak_buffer);
    pak_buffer = new_buffer;
    pak_len = new_len;
  }

  Save(outputfilename, pak_buffer, pak_len);

  free(pak_buffer);
  free(raw_buffer);

  return 0;
}

unsigned char *lz77wii_raw11(unsigned char *raw_buffer, unsigned int raw_len, unsigned int *new_len) {
  unsigned char *pak_buffer, *pak, *raw, *raw_end, *flg = NULL, *new_pack;
  unsigned char  mask;
  unsigned int   pak_len, len, pos, len_best, pos_best, mem_len;

  pak_len = 4 + raw_len + ((raw_len + 7) / 8) + 3;
  pak_buffer = (unsigned char *) Memory(pak_len, sizeof(char));

  *(unsigned int *)pak_buffer = CMD_ENCODE | (raw_len << 8);

  pak = pak_buffer + 4;
  raw = raw_buffer;
  raw_end = raw_buffer + raw_len;
  mask = 0;

  //------------------------------------------------------------------------------
  //LZ11: - if x>1: xA BC <-------- copy ('x'   +  0x1) bytes from -('ABC'+1)
  //      - if x=0: 0a bA BC <----- copy ('ab'  + 0x11) bytes from -('ABC'+1)
  //      - if x=1: 1a bc dA BC <-- copy ('abcd'+0x111) bytes from -('ABC'+1)
  //------------------------------------------------------------------------------
  while (raw < raw_end) {
    if (!(mask >>= LZX_SHIFT)) {
      *(flg = pak++) = 0;
      mask = LZX_MASK;
    }

    len_best = LZX_THRESHOLD;

    pos = raw - raw_buffer >= LZX_N ? LZX_N : raw - raw_buffer;
    for ( ; pos > LZX_VRAM; pos--) {
      for (len = 0; len < LZX_F2; len++) {
        if (raw + len == raw_end) break;
        if (*(raw + len) != *(raw + len - pos)) break;
      }

      if (len > len_best) {
        pos_best = pos;
        if ((len_best = len) == LZX_F2) break;
      }
    }

    if (len_best > LZX_THRESHOLD) {
      raw += len_best;
      *flg |= mask;
      if (len_best > LZX_F1) {
        len_best -= LZX_F1 + 1;
        *pak++ = 0x10 | (len_best >> 12);
        *pak++ = (len_best >> 4) & 0xFF;
        *pak++ = ((len_best & 0xF) << 4) | ((pos_best - 1) >> 8);
        *pak++ = (pos_best - 1) & 0xFF;
      }
      else if (len_best > LZX_F) {
        len_best -= LZX_F + 1;
        *pak++ = len_best >> 4;
        *pak++ = ((len_best & 0xF) << 4) | ((pos_best - 1) >> 8);
        *pak++ = (pos_best - 1) & 0xFF;
      }
      else {
        len_best--;
        *pak++ = ((len_best & 0xF) << 4) | ((pos_best - 1) >> 8);
        *pak++ = (pos_best - 1) & 0xFF;
      }
    }
    else {
      *pak++ = *raw++;
    }
  }

  // Add Paper Mario Color Splash lz file 12 Byte Header;
  *new_len = pak - pak_buffer + 12;
  mem_len = unlz77wii_raw11(pak_buffer + 4, pak - pak_buffer - 4, raw_buffer, raw_len, 1);
  if (!mem_len) EXIT("Encode calculate MemorySize error!\n");
  new_pack = malloc((size_t)*new_len);
  //memcpy(new_pack, &mem_len, 4);
  //memcpy(new_pack + 4, &raw_len, 4);
  *(unsigned int*)(new_pack) = mem_len;
  *(unsigned int*)(new_pack + 4) = raw_len;
  *(unsigned int*)(new_pack + 8) = mem_len << 8 | 0x12 | 1;
  memcpy(new_pack + 12, pak_buffer, (size_t)(pak - pak_buffer));

  //return(pak_buffer);
  return(new_pack);
}
/*----------------------------------------------------------------------------*/
/*--  Modifyed by shenhaiyu 2018                                            --*/
/*----------------------------------------------------------------------------*/
