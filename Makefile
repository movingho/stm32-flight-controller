CC = arm-none-eabi-gcc
MCU = -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
CFLAGS = $(MCU) -O2 -Wall -Wextra -std=c99

# 경로
SRC_DIR = src
DRIVERS_DIR = drivers
FREERTOS_DIR = freertos
INC_DIR = include
BUILD_DIR = build

#소스 파일
SRCS = $(wildcard $(SRC_DIR)/*.c) \
       $(wildcard $(DRIVERS_DIR)/*.c) \
       $(wildcard $(FREERTOS_DIR)/*.c) \
       $(wildcard $(FREERTOS_DIR)/portable/GCC/ARM_CM4F/*.c) \
       $(wildcard $(FREERTOS_DIR)/portable/MemMang/heap_4.c)

# 오브젝트 파일 목록
OBJS = $(patsubst %.c, $(BUILD_DIR)/%.o, $(notdir $(SRCS)))

# 헤더 경로
INCLUDES = -I$(INC_DIR) \
           -I$(FREERTOS_DIR)/include \
           -I$(FREERTOS_DIR)/portable/GCC/ARM_CM4F

# 출력 파일
TARGET = $(BUILD_DIR)/firmware

# 기본 타겟
all: $(BUILD_DIR) $(TARGET).elf $(TARGET).bin

# 빌드 폴더 생성
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# .c → .o 컴파일 규칙
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR)/%.o: $(DRIVERS_DIR)/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR)/%.o: $(FREERTOS_DIR)/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR)/%.o: $(FREERTOS_DIR)/portable/GCC/ARM_CM4F/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(BUILD_DIR)/%.o: $(FREERTOS_DIR)/portable/MemMang/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

LDFLAGS = -T src/stm32f4.ld -Wl,--gc-sections -nostartfiles


# .o → .elf 링킹
$(TARGET).elf: $(OBJS)
	$(CC) $(MCU) $(LDFLAGS) $(OBJS) -o $@

# .elf → .bin 변환
$(TARGET).bin: $(TARGET).elf
	arm-none-eabi-objcopy -O binary $< $@

# 빌드 결과물 삭제
clean:
	rm -rf $(BUILD_DIR)
