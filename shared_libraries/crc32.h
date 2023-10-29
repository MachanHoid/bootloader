#include <inttypes.h>
#include <stdint.h>

static const uint32_t CRC32_Table[256];
uint32_t update_crc32 (const void *buf, int len, uint32_t crc);

