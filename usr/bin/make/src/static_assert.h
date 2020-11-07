#ifndef ALIX_MAKE_STATIC_ASSERT_H
#define ALIX_MAKE_STATIC_ASSERT_H	1

#define STATIC_ASSERT(COND,MSG) typedef char static_assertion_##MSG[(COND)?1:-1]

#endif
