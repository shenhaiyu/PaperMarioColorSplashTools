/*----------------------------------------------------------------------------*/
/*--  fs.table update for Nintendo WiiU Paper Mario Color Splash            --*/
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
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*----------------------------------------------------------------------------*/
#define EXIT(text) { printf(text); exit(1); }
/*----------------------------------------------------------------------------*/

void           Save(char *filename, unsigned char *buffer, int length);
unsigned char *Load(char *filename, unsigned int  *length);
unsigned char *Memory(int length, int size);
unsigned int   ReplaceStr(char *sSrc, char *sMatchStr, char *sReplaceStr);
unsigned int   Contains(char *string, int stringSize, FILE *fp);
unsigned int   fstableUpdate(char *lzfile, char *fstablefile, char *splitStr);

/*----------------------------------------------------------------------------*/

int main(int argc, char **argv) {

  if (argc != 4) EXIT(
    "Nintendo WiiU Paper Mario Color Splash fs.table file update tool\n"
    "Code by (c) shenhaiyu 2018\n"
    "\n"
    "Usage: fstableTool fullpath(*.lz) fs.table splitStr\n"
    "       fstableTool c:\\PM\translate\\fonts\\mario.bffnt.lz translate\\fs.table translate"
    "\n"
    "Notice: Only for *.msbt.lz or *.bffnt.lz or *.bfres.lz\n"
  );

  return fstableUpdate(argv[1], argv[2], argv[3]);
}

/*----------------------------------------------------------------------------*/

void Save(char *filename, unsigned char *buffer, int length) {
  FILE *fp;
  if ((fp = fopen(filename, "wb")) == NULL) EXIT("\nFile create error\n");
  if (fwrite(buffer, 1, length, fp) != length) EXIT("\nFile write error\n");
  if (fclose(fp) == EOF) EXIT("\nFile close error\n");
}

unsigned char *Load(char *filename, unsigned int *length) {
  FILE          *fp;
  unsigned int   fs;
  unsigned char *fb;
  if ((fp = fopen(filename, "rb")) == NULL) EXIT("\nFile open error\n");
  fs = filelength(fileno(fp));
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

unsigned int ReplaceStr(char *sSrc, char *sMatchStr, char *sReplaceStr) {
  int  StringLen;
  char caNewString[255];

  char *FindPos = strstr(sSrc, sMatchStr);
  if ((!FindPos) || (!sMatchStr)) return -1;
  while (FindPos) {
    memset(caNewString, 0, sizeof(caNewString));
    StringLen = FindPos - sSrc;
    strncpy(caNewString, sSrc, StringLen);
    strcat(caNewString, sReplaceStr);
    strcat(caNewString, FindPos + strlen(sMatchStr));
    strcpy(sSrc, caNewString);
    FindPos = strstr(sSrc, sMatchStr);
  }
  return 0;
}

unsigned int Contains(char *string, int stringSize, FILE *fp) {
  unsigned  int i = 0, j, end;
  char     *part = (char *)calloc(stringSize, sizeof(char));
  fseek(fp, 0L, SEEK_END);
  end = ftell(fp) - stringSize + 2;

  while (i < end) {
    j = 0;
    fseek(fp, (long)i++, SEEK_SET);
    fgets(part, stringSize, fp);
    while (*part) {
      if (*string == *part) {
        j++;
        string++;
        part++;
        continue;
      }
      break;
    }
    if (j == stringSize - 1) {
      return i - 1;
      break;
    }
    else {
      string -= j;
      part -= j;
    }
  }
  free(part);
  return 0;
}

unsigned int fstableUpdate(char *lzfile, char *fstablefile, char *splitStr) {

  unsigned char *fs_buffer, *lz_buffer, *lz_spath;
  unsigned char  lzm_len_BN[4], lzf_len_BN[4], fsm_len_BN[4], fsf_len_BN[4];
  unsigned int   fs_len, lz_len, lzm_len, lzf_len, str_pos;
  FILE *fp;

  // Get MemorySize and FileSize from *.lz file;
  lz_buffer = Load(lzfile, &lz_len);
  lzm_len = *(unsigned int*)(lz_buffer);
  lzf_len = *(unsigned int*)(lz_buffer + 4);
  free(lz_buffer);

  // Convert *.lz file full path to the short path as fs.table;
  lz_spath = (unsigned char*)(strstr(lzfile, splitStr) + strlen(splitStr));
  if (!lz_spath) {EXIT("\nPath split error\n");}
  ReplaceStr((char*)lz_spath, "\\", "/");
  ReplaceStr((char*)lz_spath, ".lz", "");
  char findstr[strlen((char*)lz_spath) + 12];
  strcpy(findstr, "/vol/content");
  strcat(findstr, (char*)lz_spath);

  // Open and find the short path's position in the fs.table;
  if ((fp = fopen(fstablefile, "rb")) == 0) EXIT("\nFile open error\n");
  fs_len = filelength(fileno(fp));
  fs_buffer = Memory(fs_len + 3, sizeof(char));
  if (fread(fs_buffer, 1, fs_len, fp) != fs_len) EXIT("\nFile read error\n");
  str_pos = Contains(findstr, strlen(findstr), fp);
  if (fclose(fp) == EOF) EXIT("\nFile close error\n");
  if (str_pos == 0) EXIT("\nFile not found in fs.table\n");
  memcpy(fsm_len_BN, fs_buffer + str_pos - 8, 4); //Get MemorySize from fs.table file
  memcpy(fsf_len_BN, fs_buffer + str_pos - 4, 4); //Get FileSize from fs.table file

  //Convert *.lz file's MemorySize and FileSize to Big-endian;
  lzm_len_BN[0] = ((lzm_len >> 24) & 0xFF);
  lzm_len_BN[1] = ((lzm_len >> 16) & 0xFF);
  lzm_len_BN[2] = ((lzm_len >> 8) & 0xFF);
  lzm_len_BN[3] =  (lzm_len & 0xFF);
  lzf_len_BN[0] = ((lzf_len >> 24) & 0xFF);
  lzf_len_BN[1] = ((lzf_len >> 16) & 0xFF);
  lzf_len_BN[2] = ((lzf_len >> 8) & 0xFF);
  lzf_len_BN[3] =  (lzf_len & 0xFF);

  // Skip the special case;
//printf("%d\n",  !memcmp(fsm_len_BN, lzm_len_BN, 4)  );
//printf("%d\n",  !memcmp(fsf_len_BN, lzf_len_BN, 4)  );
//printf("%d\n",  !memcmp(fsm_len_BN, "\0\0\0\0", 4)  );
//printf("%d\n",  !memcmp(fsf_len_BN, "\0\0\0\0", 4)  );
  if (!memcmp(fsm_len_BN, lzm_len_BN, 4) && !memcmp(fsf_len_BN, lzf_len_BN, 4)) {
    // Both MemorySize and FileSize are the same betwen *.lz and fs.tabl
    free(fs_buffer);
    return 0;
  }

  if (!memcmp(fsm_len_BN, "\0\0\0\0", 4) || !memcmp(fsf_len_BN, "\0\0\0\0", 4)) {
    // One of MemorySize or FileSize is "\0\0\0\0"
    free(fs_buffer);
    EXIT("\nFound 00 00 00 00 data in fs.table\n");
  }

  // Write to new fs.table;
  memcpy(fs_buffer + str_pos - 8, lzm_len_BN, 4);
  memcpy(fs_buffer + str_pos - 4, lzf_len_BN, 4);
  Save(fstablefile, fs_buffer, fs_len);
  free(fs_buffer);

  return 0;
}
/*----------------------------------------------------------------------------*/
/*--  Code by shenhaiyu 2018                                                --*/
/*----------------------------------------------------------------------------*/
