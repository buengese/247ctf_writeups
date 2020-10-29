/* Copyright (C) 2007 MySQL AB, Sergei Golubchik & Michael Widenius

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1335 USA */

/*
  implements Universal Unique Identifiers (UUIDs), as in
    DCE 1.1: Remote Procedure Call,
    Open Group Technical Standard Document Number C706, October 1997,
    (supersedes C309 DCE: Remote Procedure Call 8/1994,
    which was basis for ISO/IEC 11578:1996 specification)

  A UUID has the following structure:

  Field                     NDR Data Type  Octet #          Note
 time_low                   unsigned long    0-3     The low field of the
                                                     timestamp.
 time_mid                   unsigned short   4-5     The middle field of
                                                     the timestamp.
 time_hi_and_version        unsigned short   6-7     The high field of the
                                                     timestamp multiplexed
                                                     with the version number.
 clock_seq_hi_and_reserved  unsigned small   8       The high field of the
                                                     clock sequence multi-
                                                     plexed with the variant.
 clock_seq_low              unsigned small   9       The low field of the
                                                     clock sequence.
 node                       character        10-15   The spatially unique node
                                                     identifier.
*/

#include <string.h>
#include <stdio.h>

// Stupid mysql uses way to many different names for the same types
typedef unsigned long	ulong;
typedef unsigned long long int ulonglong;
typedef long long int longlong;
typedef unsigned int uint;
typedef unsigned char uchar;
typedef unsigned short uint16;
typedef unsigned long uint32;

// MySQL macros
#define mi_int2store(T,A)   { uint def_temp= (uint) (A) ;\
                              ((uchar*) (T))[1]= (uchar) (def_temp);\
                              ((uchar*) (T))[0]= (uchar) (def_temp >> 8); }
#define mi_int3store(T,A)   { /*lint -save -e734 */\
                              ulong def_temp= (ulong) (A);\
                              ((uchar*) (T))[2]= (uchar) (def_temp);\
                              ((uchar*) (T))[1]= (uchar) (def_temp >> 8);\
                              ((uchar*) (T))[0]= (uchar) (def_temp >> 16);\
                              /*lint -restore */}
#define mi_int4store(T,A)   { ulong def_temp= (ulong) (A);\
                              ((uchar*) (T))[3]= (uchar) (def_temp);\
                              ((uchar*) (T))[2]= (uchar) (def_temp >> 8);\
                              ((uchar*) (T))[1]= (uchar) (def_temp >> 16);\
                              ((uchar*) (T))[0]= (uchar) (def_temp >> 24); }

#define MY_MIN(a,b) ((a<b)?(a):(b))

const char _dig_vec_lower[] =
  "0123456789abcdefghijklmnopqrstuvwxyz";

static char my_uuid_inited= 0;
static uint nanoseq;
static ulonglong uuid_time= 0;
static longlong interval_timer_offset;
static uchar uuid_suffix[2+6]; /* clock_seq and node */

/*
  Number of 100-nanosecond intervals between
  1582-10-15 00:00:00.00 and 1970-01-01 00:00:00.00
*/

#define MY_UUID_SIZE 16
#define MY_UUID_STRING_LENGTH (8+1+4+1+4+1+4+1+12)

#define UUID_TIME_OFFSET ((ulonglong) 141427 * 24 * 60 * 60 * \
                          1000 * 1000 * 10)
#define UUID_VERSION      0x1000
#define UUID_VARIANT      0x8000


/* Helper function */

static void set_clock_seq()
{
  uint16 clock_seq= 10287 | UUID_VARIANT; // hardcoding might be enough for no
  mi_int2store(uuid_suffix, clock_seq);
}

#define ETHER_ADDR_LEN 6

char my_gethwaddr(unsigned char *to) {
  // The mac address stays the same even if you restart the challenge
	static unsigned char mac[6] = {0x02, 0x42, 0xAC, 0x11, 0x00, 0x05};
	memcpy(to, (unsigned char *)mac, ETHER_ADDR_LEN);
}

void my_uuid_init()
{
	uchar *mac= uuid_suffix + 2;
	ulonglong now;
	nanoseq = 0;

	my_gethwaddr(mac);
	set_clock_seq();
}

/**
   Create a global unique identifier (uuid)

   @func  my_uuid()
   @param to   Store uuid here. Must be of size MY_UUID_SIZE (16)
*/

void my_uuid(uchar *to, ulonglong time)
{
  ulonglong tv;
  uint32 time_low;
  uint16 time_mid, time_hi_and_version;

  tv= UUID_TIME_OFFSET + time;

  uuid_time=tv;

  time_low=            (uint32) (tv & 0xFFFFFFFF);
  time_mid=            (uint16) ((tv >> 32) & 0xFFFF);
  time_hi_and_version= (uint16) ((tv >> 48) | UUID_VERSION);

  /*
    Note, that the standard does NOT specify byte ordering in
    multi-byte fields. it's implementation defined (but must be
    the same for all fields).
    We use big-endian, so we can use memcmp() to compare UUIDs
    and for straightforward UUID to string conversion.
  */
  mi_int4store(to, time_low);
  mi_int2store(to+4, time_mid);
  mi_int2store(to+6, time_hi_and_version);
  memmove(to+8, uuid_suffix, sizeof(uuid_suffix));
}


/**
   Convert uuid to string representation

   @func  my_uuid2str()
   @param guid uuid
   @param s    Output buffer.Must be at least MY_UUID_STRING_LENGTH+1 large.
*/
void my_uuid2str(const uchar *guid, char *s)
{
  int i;
  for (i=0; i < MY_UUID_SIZE; i++)
  {
    *s++= _dig_vec_lower[guid[i] >>4];
    *s++= _dig_vec_lower[guid[i] & 15];
    /* Set '-' at intervals 3, 5, 7 and 9 */
    if ((1 << i) & ((1 << 3) | (1 << 5) | (1 << 7) | (1 << 9)))
      *s++= '-';
  }
}

int main(int argc, char **argv) {
	uchar buf[MY_UUID_SIZE];
	char uuid_str[MY_UUID_STRING_LENGTH];

	ulonglong time = 16035495114650309;
	my_uuid_init();
	my_uuid(buf, time);
	my_uuid2str(buf, uuid_str);
	uuid_str[MY_UUID_STRING_LENGTH]= 0;
	printf(uuid_str);
}