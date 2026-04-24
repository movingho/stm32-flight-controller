#include <stdint.h>

/* 링커 스크립트에서 정의한 심볼 */
extern uint32_t _sdata;
extern uint32_t _edata;
extern uint32_t _sbss;
extern uint32_t _ebss;
extern uint32_t _estack;

/* main 함수 선언 */
extern int main(void);

/* Reset Handler 전방 선언 */
void Reset_Handler(void);

/* 인터럽트 벡터 테이블 */
__attribute__((section(".isr_vector")))
uint32_t vector_table[] = {
    (uint32_t)&_estack,          /* 스택 시작 주소 */
    (uint32_t)&Reset_Handler,    /* Reset */
    0, 0, 0, 0, 0, 0, 0, 0,     /* 나머지 예외 */
    0, 0, 0, 0, 0,
};

/* Reset Handler */
void Reset_Handler(void)
{
    uint32_t *src, *dst;

    /* .data 섹션 Flash → RAM 복사 */
    src = &_edata;
    dst = &_sdata;
    while (dst < &_edata) {
        *dst++ = *src++;
    }

    /* .bss 섹션 0으로 초기화 */
    dst = &_sbss;
    while (dst < &_ebss) {
        *dst++ = 0;
    }

    /* main 호출 */
    main();

    /* main이 리턴하면 무한루프 */
    while(1);
}
