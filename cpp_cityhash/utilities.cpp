// Copyright (c) 2011 Google, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// CityHash, by Geoff Pike and Jyrki Alakuijala
//
// This file provides CityHash64() and related functions.
//
// much of this was copied from from the original for testing purposes at
// https://github.com/google/cityhash/blob/master/src/city.cc
#include <cstdint>
#include <cstring>  // For memcpy
#include <city.h>


#ifdef _MSC_VER

#include <stdlib.h>
#define bswap_32(x) _byteswap_ulong(x)
#define bswap_64(x) _byteswap_uint64(x)

#elif defined(__APPLE__)

// Mac OS X / Darwin features
#include <libkern/OSByteOrder.h>
#define bswap_32(x) OSSwapInt32(x)
#define bswap_64(x) OSSwapInt64(x)

#elif defined(__sun) || defined(sun)

#include <sys/byteorder.h>
#define bswap_32(x) BSWAP_32(x)
#define bswap_64(x) BSWAP_64(x)

#elif defined(__FreeBSD__)

#include <sys/endian.h>
#define bswap_32(x) bswap32(x)
#define bswap_64(x) bswap64(x)

#elif defined(__OpenBSD__)

#include <sys/types.h>
#define bswap_32(x) swap32(x)
#define bswap_64(x) swap64(x)

#elif defined(__NetBSD__)

#include <sys/types.h>
#include <machine/bswap.h>
#if defined(__BSWAP_RENAME) && !defined(__bswap_32)
#define bswap_32(x) bswap32(x)
#define bswap_64(x) bswap64(x)
#endif

#else

#include <byteswap.h>

#endif

// Some primes between 2^63 and 2^64 for various uses.
static const uint64 k0 = 0xc3a5c85c97cb3127ULL;
static const uint64 k1 = 0xb492b66fbe98f273ULL;
static const uint64 k2 = 0x9ae16a3b2f90404fULL;

// Magic numbers for 32-bit hashing.  Copied from Murmur3.
static const uint32_t c1 = 0xcc9e2d51;
static const uint32_t c2 = 0x1b873593;

// Helper functions that mimic CityHash's Fetch64 logic
static inline uint64 UNALIGNED_LOAD64(const char* p) {
    uint64 result;
    memcpy(&result, p, sizeof(result));  // Copy 64 bits from `p` to `result`
    return result;
}

// Helper functions that mimic CityHash's Fetch64 logic
static inline uint32_t UNALIGNED_LOAD32(const char *p) {
  uint32_t result;
  memcpy(&result, p, sizeof(result));
  return result;
}

static inline uint64 uint64_in_expected_order(uint64 x) {
    // This is for handling endianess (CityHash deals with byte ordering here)
    // Assuming little-endian system; no change needed
    return x;
}
static inline uint32_t uint32_in_expected_order(uint32_t x) {
    // This is for handling endianess (CityHash deals with byte ordering here)
    // Assuming little-endian system; no change needed
    return x;
}

uint64 Fetch64(const char *p) {
    return uint64_in_expected_order(UNALIGNED_LOAD64(p));
}

uint32_t Fetch32(const char *p) {
  return uint32_in_expected_order(UNALIGNED_LOAD32(p));
}

uint32_t Rotate32(uint32_t val, int shift) {
  // Avoid shifting by 32: doing so yields an undefined result.
  return shift == 0 ? val : ((val >> shift) | (val << (32 - shift)));
}

// Bitwise right rotate.  Normally this will compile to a single
// instruction, especially if the shift is a manifest constant.
uint64 Rotate(uint64 val, int shift) {
  // Avoid shifting by 64: doing so yields an undefined result.
  return shift == 0 ? val : ((val >> shift) | (val << (64 - shift)));
}

uint64 ShiftMix(uint64 val) {
  return val ^ (val >> 47);
}
uint64 HashLen33to64(const char *s, size_t len) {
  uint64 mul = k2 + len * 2;
  uint64 a = Fetch64(s) * k2;
  uint64 b = Fetch64(s + 8);
  uint64 e = Fetch64(s + 16) * k2;
  uint64 f = Fetch64(s + 24) * 9;
  uint64 g = Fetch64(s + len - 8);
  uint64 c = Fetch64(s + len - 24);
  uint64 d = Fetch64(s + len - 32);
  uint64 h = Fetch64(s + len - 16) * mul;
  uint64 u = Rotate(a + g, 43) + (Rotate(b, 30) + c) * 9;
  uint64 v = ((a + g) ^ d) + f + 1;
  uint64 w = bswap_64((u + v) * mul) + h;
  uint64 y = (bswap_64((v + w) * mul) + g) * mul;
  uint64 x = Rotate(e + f, 42) + c;
  uint64 z = e + f + c;
  a = bswap_64((x + z) * mul + y) + b;
  b = ShiftMix((z + a) * mul + d + h) * mul;
  return b + x;
}


uint64 HashLen16(uint64 u, uint64 v, uint64 mul) {
  // Murmur-inspired hashing.
  uint64 a = (u ^ v) * mul;
  a ^= (a >> 47);
  uint64 b = (v ^ a) * mul;
  b ^= (b >> 47);
  b *= mul;
  return b;
}

uint64 HashLen16(uint64 u, uint64 v) {
  return Hash128to64(uint128(u, v));
}

uint64 GreaterEq8(const char* s, size_t len) {
    if (len >= 8) {
    uint64 mul = k2 + len * 2;
    uint64 a = Fetch64(s) + k2;
    uint64 b = Fetch64(s + len - 8);
    uint64 c = Rotate(b, 37) * mul + a;
    uint64 d = (Rotate(a, 25) + b) * mul;
    return HashLen16(c, d, mul);
    } else {
	return 0;
    }
}

uint64 Len4to7(const char* s, size_t len) {
    if (len >= 4 && len < 8) {
    uint64 mul = k2 + len * 2;
    uint64 a = Fetch32(s);
    return HashLen16(len + (a << 3), Fetch32(s + len - 4), mul);
    } else {
	return 0;
    }
}

uint64 Len0to3(const char* s, size_t len) {
    if (len > 0 && len < 4) {
    uint8_t a = static_cast<uint8_t>(s[0]);
    uint8_t b = static_cast<uint8_t>(s[len >> 1]);
    uint8_t c = static_cast<uint8_t>(s[len - 1]);
    uint32_t y = static_cast<uint32_t>(a) + (static_cast<uint32_t>(b) << 8);
    uint32_t z = static_cast<uint32_t>(len) + (static_cast<uint32_t>(c) << 2);
    return ShiftMix(y * k2 ^ z * k0) * k2;
    } else {
	return 0;
    }
}

// Return a 16-byte hash for 48 bytes.  Quick and dirty.
// Callers do best to use "random-looking" values for a and b.
std::pair<uint64, uint64> WeakHashLen32WithSeeds(
    uint64 w, uint64 x, uint64 y, uint64 z, uint64 a, uint64 b) {
  a += w;
  b = Rotate(b + a + z, 21);
  uint64 c = a;
  a += x;
  a += y;
  b += Rotate(a, 44);
  return std::make_pair(a + z, b + c);
}

// Return a 16-byte hash for s[0] ... s[31], a, and b.  Quick and dirty.
std::pair<uint64, uint64> WeakHashLen32WithSeeds(
    const char* s, uint64 a, uint64 b) {
  return WeakHashLen32WithSeeds(Fetch64(s),
                                Fetch64(s + 8),
                                Fetch64(s + 16),
                                Fetch64(s + 24),
                                a,
                                b);
}

