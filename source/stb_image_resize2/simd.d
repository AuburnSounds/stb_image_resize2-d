module stb_image_resize2.simd;

nothrow @nogc @safe:

import inteli.avx2intrin;
import stb_image_resize2.types;

static if (hasRestrict)
    import core.attribute: restrict;
else
    enum restrict = 0;

enum STBIR_NO_SIMD = false;
enum STBIR_SIMD = true;
enum STBIR_SIMD8 = true; // AVX always here thanks to intel-intrinsics

enum STBIR_SSE2 = true;  // always there thanks to intel-intrinsics
enum STBIR_AVX = true;   // always there thanks to intel-intrinsics
enum STBIR_NEON = false;
enum STBIR_AVX2 = true;  // always there thanks to intel-intrinsics

enum STBIR_FP16C = false; // no support in intel-intrinsics FUTURE
enum STBIR_WASM = false;

// 400IQ move here: intel-intrinsics allows to always have SSE2/AVX2 etc
// which lessen the number of LOC.

alias stbir__simdf = __m128;
alias stbir__simdi = __m128i;

//   Basically, in simd mode, we unroll the proper amount, and we don't want
//   the non-simd remnant loops to be unroll because they only run a few times
//   Adding this switch saves about 5K on clang which is Captain Unroll the 3rd.
// Use it like this: mixin STBIR_NO_UNROLL();
void STBIR_NO_UNROLL(const(void)* p)
{
    // PERF: verify usefulness
    version(LDC)
    {
        import ldc.llvmasm;
        __asm_trusted("", "r", p);
    }
    version(GNU) asm nothrow @nogc @trusted { "" : : : "memory"; }
}
alias STBIR_SIMD_NO_UNROLL = STBIR_NO_UNROLL;


alias stbir_simdi_castf = _mm_castps_si128;
alias stbir_simdf_casti = _mm_castsi128_ps;

void stbir__simdf_load(ref __m128 reg, const(void)* ptr)
    @system /* memsafe if ptr has 16 addressable bytes */
{
    reg = _mm_loadu_ps( cast(const(float)*) ptr );
}

void stbir__simdi_load(ref __m128i reg, const(void)* ptr) @system
{
    reg = _mm_loadu_si128( cast(const(__m128i)*) ptr );
}

// semantic: top values can be random (not denormal or nan for perf)
void stbir__simdf_load1(ref __m128 out_, const(void)* ptr) @system
{
    out_ = _mm_load_ss( cast(const(float)*)ptr );
}

void stbir__simdi_load1(ref __m128i out_, const(void)* ptr) @system
{
    out_ = _mm_castps_si128( _mm_load_ss( cast(const(float)*)ptr ) );
}

// semantic: top values must be zero
alias stbir__simdf_load1z = stbir__simdf_load1;
alias stbir__simdf_frep4 = _mm_set1_ps;
alias stbir__simdf_frep4 = _mm_set1_ps;

void stbir__simdf_load1frep4(ref __m128 out_, float fvar)
{
    out_ = _mm_set1_ps(fvar);
}

// semantic: top values can be random (not denormal or nan for perf)
// but here, we do not take advantage
void stbir__simdf_load2(ref __m128 out_, const(void)* ptr)
@system /* if ptr points to 8 bytes */
{
    out_ = _mm_castsi128_ps( _mm_loadl_epi64( cast(__m128i*)(ptr)) );
}
alias stbir__simdf_load2z = stbir__simdf_load2;

//#define stbir__simdf_load2hmerge( out, reg, ptr ) (out) = _mm_castpd_ps(_mm_loadh_pd( _mm_castps_pd(reg), (double*)(ptr) ))

alias stbir__simdf_zeroP = _mm_setzero_ps;
void stbir__simdf_zero(ref __m128 reg)
{
    reg = _mm_setzero_ps();
}

void stbir__simdf_store(void* ptr, __m128 reg )
    @system // memsafe if ptr has 16 bytes addressible
{
    _mm_storeu_ps( cast(float*)(ptr), reg );
}

void stbir__simdf_store1(void* ptr, __m128 reg )
    @system // memsafe if ptr has 4 bytes addressible
{
    _mm_store_ss( cast(float*)(ptr), reg );
}

void stbir__simdf_store2(void* ptr, __m128 reg )
    @system // memsafe if ptr has 8 bytes addressible
{
    _mm_storel_epi64( cast(__m128i*)(ptr), _mm_castps_si128(reg) );
}

void stbir__simdf_store2h(void* ptr, __m128 reg ) @system
{
    _mm_storeh_pd( cast(double*)(ptr), _mm_castps_pd(reg) );
}

void stbir__simdi_store(void* ptr, __m128i reg )
    @system // memsafe if ptr has 16 bytes addressible
{
    _mm_storeu_si128( cast(__m128i*)(ptr), reg );
}

void stbir__simdi_store1(void* ptr, __m128i reg )
    @system // memsafe if ptr has 4 bytes addressible
{
    _mm_store_ss( cast(float*)(ptr), _mm_castsi128_ps(reg) );
}

void stbir__simdi_store2(void* ptr, __m128i reg )
    @system // memsafe if ptr has 8 bytes addressible
{
    _mm_storel_epi64( cast(__m128i*)(ptr), reg );
}

void stbir__prefetch(const(void)* ptr)
    @system // memsafe if ptr has 16 bytes addressible
{
    _mm_prefetch!_MM_HINT_T0(ptr);
}

void stbir__simdi_expand_u8_to_u32(ref __m128i out0, ref __m128i out1, ref __m128i out2, ref __m128i out3, __m128i ireg)
{
    stbir__simdi zero = _mm_setzero_si128();
    out2 = _mm_unpacklo_epi8( ireg, zero );
    out3 = _mm_unpackhi_epi8( ireg, zero );
    out0 = _mm_unpacklo_epi16( out2, zero );
    out1 = _mm_unpackhi_epi16( out2, zero );
    out2 = _mm_unpacklo_epi16( out3, zero );
    out3 = _mm_unpackhi_epi16( out3, zero );
}

void stbir__simdi_expand_u8_to_1u32(ref __m128i out_, __m128i ireg)
{
    stbir__simdi zero = _mm_setzero_si128();
    out_ = _mm_unpacklo_epi8( ireg, zero );
    out_ = _mm_unpacklo_epi16( out_, zero );
}

void stbir__simdi_expand_u16_to_u32(ref __m128i out0, ref __m128i out1, __m128i ireg)
{
    stbir__simdi zero = _mm_setzero_si128();
    out0 = _mm_unpacklo_epi16( ireg, zero );
    out1 = _mm_unpackhi_epi16( ireg, zero );
}

void stbir__simdf_convert_float_to_i32(ref __m128i i, __m128 f )
{
    i = _mm_cvttps_epi32(f);
}

int stbir__simdf_convert_float_to_int(__m128 f)
{
    return _mm_cvtt_ss2si(f);
}

ubyte stbir__simdf_convert_float_to_uint8(__m128 f )
{
    return (cast(ubyte) _mm_cvtsi128_si32(_mm_cvttps_epi32(_mm_max_ps(_mm_min_ps(f, STBIR_max_uint8_as_float),_mm_setzero_ps()))));
}

short stbir__simdf_convert_float_to_short(__m128 f )
{
    return (cast(ushort)_mm_cvtsi128_si32(_mm_cvttps_epi32(_mm_max_ps(_mm_min_ps(f,STBIR_max_uint16_as_float),_mm_setzero_ps()))));
}

alias stbir__simdi_to_int = _mm_cvtsi128_si32;
alias stbir__simdi_convert_i32_to_float = _mm_cvtepi32_ps;

void stbir__simdf_add(ref __m128 out_, __m128 a, __m128 b)
{
    out_ = _mm_add_ps(a, b);
}

void stbir__simdf_mult(ref __m128 out_, __m128 a, __m128 b)
{
    out_ = _mm_mul_ps(a, b);
}

void stbir__simdf_mult_mem(ref __m128 out_, __m128 reg, const(void)* ptr )
@system /* memory safe if ptr = 16 bytes addressable */
{
    out_ = _mm_mul_ps(reg, _mm_loadu_ps( cast(const(float)*)(ptr) ) );
}

void stbir__simdf_mult1_mem(ref __m128 out_, __m128 reg, const(void)* ptr)
@system /* memory safe if ptr = 4 bytes addressable */
{
    out_ = _mm_mul_ss(reg, _mm_load_ss( cast(const(float)*)(ptr) ));
}

void stbir__simdf_add_mem(ref __m128 out_, __m128 reg, const(void)* ptr)
@system /* memory safe if ptr = 16 bytes addressable */
{
    out_ = _mm_add_ps(reg, _mm_loadu_ps( cast(const(float)*)(ptr) ) );
}

void stbir__simdf_add1_mem(ref __m128 out_, __m128 reg, const(void)* ptr)
@system /* memory safe if ptr = 4 bytes addressable */
{
    out_ = _mm_add_ss(reg, _mm_load_ss( cast(const(float)*)(ptr) ) );
}

void stbir__simdf_madd(ref __m128 out_, __m128 add, __m128 mul1, __m128 mul2)
{
    out_ = _mm_add_ps( add, _mm_mul_ps( mul1, mul2 ) );
}

void stbir__simdf_madd1(ref __m128 out_, __m128 add, __m128 mul1, __m128 mul2)
{
    out_ = _mm_add_ss( add, _mm_mul_ss( mul1, mul2 ) );
}

void stbir__simdf_madd_mem(ref __m128 out_, __m128 add, __m128 mul, const(void)* ptr)
@system /* memory safe if ptr = 16 bytes addressable */
{
    out_ = _mm_add_ps( add, _mm_mul_ps( mul, _mm_loadu_ps( cast(const(float)*)(ptr) ) ) );
}

void stbir__simdf_madd1_mem(ref __m128 out_, __m128 add, __m128 mul, const(void)* ptr)
@system /* memory safe if ptr = 4 bytes addressable */
{
    out_ = _mm_add_ss( add, _mm_mul_ss( mul, _mm_load_ss( cast(const(float)*)(ptr) ) ) );
}

void stbir__simdf_add1(ref __m128 out_, __m128 reg0, __m128 reg1 )
{
    out_ = _mm_add_ss( reg0, reg1 );
}

void stbir__simdf_mult1(ref __m128 out_, __m128 reg0, __m128 reg1 )
{
    out_ = _mm_mul_ss( reg0, reg1 );
}

void stbir__simdf_and(ref __m128 out_, __m128 reg0, __m128 reg1 )
{
    out_ = _mm_and_ps( reg0, reg1 );
}

void stbir__simdf_or(ref __m128 out_, __m128 reg0, __m128 reg1 )
{
    out_ = _mm_or_ps( reg0, reg1 );
}

void stbir__simdf_min(ref __m128 out_, __m128 reg0, __m128 reg1 )
{
    out_ = _mm_min_ps( reg0, reg1 );
}

void stbir__simdf_max(ref __m128 out_, __m128 reg0, __m128 reg1 )
{
    out_ = _mm_max_ps( reg0, reg1 );
}

void stbir__simdf_min1(ref __m128 out_, __m128 reg0, __m128 reg1 )
{
    out_ = _mm_min_ss( reg0, reg1 );
}

void stbir__simdf_max1(ref __m128 out_, __m128 reg0, __m128 reg1 )
{
    out_ = _mm_max_ss( reg0, reg1 );
}

void stbir__simdf_0123ABCDto3ABx(ref __m128 out_, __m128 reg0, __m128 reg1 )
{
    out_ = _mm_castsi128_ps( _mm_shuffle_epi32!147( _mm_castps_si128( _mm_shuffle_ps!228( reg1,reg0))));
}

void stbir__simdf_0123ABCDto23Ax(ref __m128 out_, __m128 reg0, __m128 reg1 )
{
    out_ = _mm_castsi128_ps( _mm_shuffle_epi32!78( _mm_castps_si128( _mm_shuffle_ps!228( reg1,reg0 )) ) );
}

static immutable stbir__simdf STBIR_zeroones = _mm_setr_ps(0.0f,1.0f,0.0f,1.0f);
static immutable stbir__simdf STBIR_onezeros = _mm_setr_ps(1.0f,0.0f,1.0f,0.0f);

void stbir__simdf_aaa1( __m128 out_, __m128 alp, __m128 ones)
{
    out_ = _mm_castsi128_ps( _mm_shuffle_epi32!149( _mm_castps_si128( _mm_movehl_ps( ones, alp ) ) ) );
}
void stbir__simdf_1aaa( __m128 out_, __m128 alp, __m128 ones)
{
    out_ = _mm_castsi128_ps( _mm_shuffle_epi32!168( _mm_castps_si128( _mm_movelh_ps( ones, alp ) ) ) );
}
void stbir__simdf_a1a1( __m128 out_, __m128 alp, __m128 ones)
{
    out_ = _mm_or_ps( _mm_castsi128_ps( _mm_srli_epi64( _mm_castps_si128(alp), 32 ) ), STBIR_zeroones );
}

void stbir__simdf_1a1a( __m128 out_, __m128 alp, __m128 ones)
{
    out_ = _mm_or_ps( _mm_castsi128_ps( _mm_slli_epi64( _mm_castps_si128(alp), 32 ) ), STBIR_onezeros );
}

__m128 stbir__simdf_swiz(int one, int two, int three, int four)(__m128 reg)
{
    enum int shuf = (one<<0) + (two<<2) + (three<<4) + (four<<6);
    return _mm_castsi128_ps(_mm_shuffle_epi32!shuf( _mm_castps_si128( reg )));
}

void stbir__simdi_and( ref __m128i out_, __m128i reg0, __m128i reg1 )
{
    out_ = _mm_and_si128( reg0, reg1 ) ;
}

void stbir__simdi_or( ref __m128i out_, __m128i reg0, __m128i reg1 )
{
    out_ = _mm_or_si128( reg0, reg1 ) ;
}

void stbir__simdi_16madd( ref __m128i out_, __m128i reg0, __m128i reg1 )
{
    out_ = _mm_madd_epi16( reg0, reg1 ) ;
}

void stbir__simdf_pack_to_8bytes(ref __m128i out_, __m128 aa, __m128 bb)
{
    stbir__simdf af,bf;
    stbir__simdi a,b;
    af = _mm_min_ps( aa, STBIR_max_uint8_as_float );
    bf = _mm_min_ps( bb, STBIR_max_uint8_as_float );
    af = _mm_max_ps( af, _mm_setzero_ps() );
    bf = _mm_max_ps( bf, _mm_setzero_ps() );
    a = _mm_cvttps_epi32( af );
    b = _mm_cvttps_epi32( bf );
    a = _mm_packs_epi32( a, b );
    out_ = _mm_packus_epi16( a, a );
}

void stbir__simdf_load4_transposed( ref __m128 o0, ref __m128 o1, ref __m128 o2, ref __m128 o3, const(float)* ptr)
@system /* memory safe if ptr points to 64 adressable bytes */
{
    stbir__simdf_load( o0, (ptr) );
    stbir__simdf_load( o1, (ptr)+4 );
    stbir__simdf_load( o2, (ptr)+8 );
    stbir__simdf_load( o3, (ptr)+12 );
    __m128 tmp0, tmp1, tmp2, tmp3;
    tmp0 = _mm_unpacklo_ps(o0, o1);
    tmp2 = _mm_unpacklo_ps(o2, o3);
    tmp1 = _mm_unpackhi_ps(o0, o1);
    tmp3 = _mm_unpackhi_ps(o2, o3);
    o0 = _mm_movelh_ps(tmp0, tmp2);
    o1 = _mm_movehl_ps(tmp2, tmp0);
    o2 = _mm_movelh_ps(tmp1, tmp3);
    o3 = _mm_movehl_ps(tmp3, tmp1);
}

void stbir__interleave_pack_and_store_16_u8(void* ptr, __m128i r0, __m128i r1, __m128i r2, __m128i r3)
@system /* memory-safe if ptr points to 16 adressable bytes */
{
    r0 = _mm_packs_epi32( r0, r1 );
    r2 = _mm_packs_epi32( r2, r3 );
    r1 = _mm_unpacklo_epi16( r0, r2 );
    r3 = _mm_unpackhi_epi16( r0, r2 );
    r0 = _mm_unpacklo_epi16( r1, r3 );
    r2 = _mm_unpackhi_epi16( r1, r3 );
    r0 = _mm_packus_epi16( r0, r2 );
    stbir__simdi_store( ptr, r0 );
}

void stbir__simdi_32shr(ref __m128i out_, __m128i reg, int imm )
{
    out_ = _mm_srli_epi32( reg, imm );
}

/*

#if defined(_MSC_VER) && !defined(__clang__)
// msvc inits with 8 bytes
#define STBIR__CONST_32_TO_8( v ) (char)(char)((v)&255),(char)(char)(((v)>>8)&255),(char)(char)(((v)>>16)&255),(char)(char)(((v)>>24)&255)
#define STBIR__CONST_4_32i( v ) STBIR__CONST_32_TO_8( v ), STBIR__CONST_32_TO_8( v ), STBIR__CONST_32_TO_8( v ), STBIR__CONST_32_TO_8( v )
#define STBIR__CONST_4d_32i( v0, v1, v2, v3 ) STBIR__CONST_32_TO_8( v0 ), STBIR__CONST_32_TO_8( v1 ), STBIR__CONST_32_TO_8( v2 ), STBIR__CONST_32_TO_8( v3 )
#else
// everything else inits with long long's
#define STBIR__CONST_4_32i( v ) (long long)((((stbir_uint64)(stbir_uint32)(v))<<32)|((stbir_uint64)(stbir_uint32)(v))),(long long)((((stbir_uint64)(stbir_uint32)(v))<<32)|((stbir_uint64)(stbir_uint32)(v)))
#define STBIR__CONST_4d_32i( v0, v1, v2, v3 ) (long long)((((stbir_uint64)(stbir_uint32)(v1))<<32)|((stbir_uint64)(stbir_uint32)(v0))),(long long)((((stbir_uint64)(stbir_uint32)(v3))<<32)|((stbir_uint64)(stbir_uint32)(v2)))
#endif
*/

// Note: If encountering those macros, make a static immutable global
// #define STBIR__SIMDF_CONST(var, x) stbir__simdf var = { x, x, x, x }
// #define STBIR__SIMDI_CONST(var, x) stbir__simdi var = { STBIR__CONST_4_32i(x) }
// #define STBIR__CONSTF(var) (var)
// #define STBIR__CONSTI(var) (var)


void stbir__simdf_pack_to_8words(ref __m128i out_, __m128 reg0, __m128 reg1)
{
    out_ = _mm_packus_epi32(
                            _mm_cvttps_epi32(_mm_max_ps(_mm_min_ps(reg0,STBIR_max_uint16_as_float),_mm_setzero_ps())),
                            _mm_cvttps_epi32(_mm_max_ps(_mm_min_ps(reg1,STBIR_max_uint16_as_float),_mm_setzero_ps()))
                            );
}



alias stbir__simdf8 = __m256;
alias stbir__simdi8 = __m256i;

void stbir__simdf8_load(ref __m256 out_, const(void)* ptr)
@system /* memory-safe if ptr points to 32 bytes */
{
    out_  = _mm256_loadu_ps( cast(const(float)*)ptr );
}

void stbir__simdi8_load(ref __m256i out_, const(void)* ptr)
@system /* memsafe if ptr points to 32 bytes */
{
    out_  = _mm256_loadu_si256( cast(const(__m256i)*)ptr );
}

void stbir__simdf8_mult(ref __m256 out_, __m256 a, __m256 b)
{
    out_  = _mm256_mul_ps(a, b);
}

void stbir__simdi8_store(void* ptr, __m256i reg )
@system /* memsafe if ptr points to 32 bytes */
{
    return _mm256_storeu_si256( cast(__m256i*)ptr, reg);

}

void stbir__simdf8_store(void* ptr, __m256 out_ )
@system /* memsafe if ptr points to 32 bytes */
{
    _mm256_storeu_ps( cast(float*)(ptr), out_ );
}

alias stbir__simdf8_frep8 = _mm256_set1_ps;

void stbir__simdf8_min(ref __m256 out_, __m256 reg0, __m256 reg1 )
{
    out_ = _mm256_min_ps( reg0, reg1 );
}

void stbir__simdf8_max(ref __m256 out_, __m256 reg0, __m256 reg1 )
{
    out_ = _mm256_max_ps( reg0, reg1 );
}

void stbir__simdf8_add4halves( ref __m128 out_, __m128 bot4, __m256 top8 )
{
    out_ = _mm_add_ps( bot4, _mm256_extractf128_ps!1( top8) );
}

void stbir__simdf8_mult_mem(ref __m256 out_, __m256 reg, const(void)* ptr )
    @system /* memsafe if ptr points to 32 bytes */
{
    out_ = _mm256_mul_ps( reg, _mm256_loadu_ps( cast(const(float)*)ptr ) );
}

void stbir__simdf8_add_mem(ref __m256 out_, __m256 reg, const(void)* ptr )
@system /* memsafe if ptr points to 32 bytes */
{
    out_ = _mm256_add_ps( reg, _mm256_loadu_ps( cast(const(float)*)ptr ) );
}

void stbir__simdf8_add(ref __m256 out_, __m256 reg0, __m256 reg1 )
{
    out_ = _mm256_add_ps(reg0, reg1);
}

void stbir__simdf8_load1b(ref __m256 out_, const(void)* ptr )
@system /* memsafe if ptr points to 4 bytes */
{
    out_ = _mm256_broadcast_ss(cast(const(float)*)ptr);
}

void stbir__simdf_load1rep4(ref __m128 out_, const(void)* ptr )
@system /* memsafe if ptr points to 4 bytes */
{
    out_ = _mm_broadcast_ss(cast(const(float)*)ptr); // avx load instruction
}

void stbir__simdi8_convert_i32_to_float(ref __m256 out_, __m256i ireg)
{
    out_ = _mm256_cvtepi32_ps(ireg);
}

void stbir__simdi8_convert_i32_to_float(ref __m256i out_,  __m256 f)
{
    out_ = _mm256_cvttps_epi32(f);
}

void stbir__simdf8_bot4s( ref __m256 out_, __m256 a, __m256 b )
{
    out_ = _mm256_permute2f128_ps!((0<<0)+(2<<4))(a,b);
}

void stbir__simdf8_top4s( ref __m256 out_, __m256 a, __m256 b )
{
    out_ = _mm256_permute2f128_ps!((1<<0)+(3<<4))(a,b);
}

alias stbir__simdf8_gettop4 = _mm256_extractf128_ps!1;

void stbir__simdi8_expand_u8_to_u32(ref __m256i out0, ref __m256i out1, __m128i ireg)
{
    stbir__simdi8 a, zero  =_mm256_setzero_si256();
    enum ubyte Permute = (0<<0)+(2<<2)+(1<<4)+(3<<6);
    a = _mm256_permute4x64_epi64!Permute( _mm256_unpacklo_epi8( _mm256_permute4x64_epi64!Permute(_mm256_castsi128_si256(ireg)), zero ));
    out0 = _mm256_unpacklo_epi16( a, zero );
    out1 = _mm256_unpackhi_epi16( a, zero );
}
/*
{
    stbir__simdi a,zero = _mm_setzero_si128();
    a = _mm_unpacklo_epi8( ireg, zero );
    out0 = _mm256_setr_m128i( _mm_unpacklo_epi16( a, zero ), _mm_unpackhi_epi16( a, zero ) );
    a = _mm_unpackhi_epi8( ireg, zero );
    out1 = _mm256_setr_m128i( _mm_unpacklo_epi16( a, zero ), _mm_unpackhi_epi16( a, zero ) );
}
*/

void stbir__simdf8_pack_to_16bytes(ref __m128i out_, __m256 aa, __m256 bb)
{
    stbir__simdi t;
    stbir__simdf8 af,bf;
    stbir__simdi8 a,b;
    af = _mm256_min_ps( aa, STBIR_max_uint8_as_floatX );
    bf = _mm256_min_ps( bb, STBIR_max_uint8_as_floatX );
    af = _mm256_max_ps( af, _mm256_setzero_ps() );
    bf = _mm256_max_ps( bf, _mm256_setzero_ps() );
    a = _mm256_cvttps_epi32( af );
    b = _mm256_cvttps_epi32( bf );
    out_ = _mm_packs_epi32( _mm256_castsi256_si128(a), _mm256_extractf128_si256!1( a ) );
    out_ = _mm_packus_epi16( out_, out_ );
    t = _mm_packs_epi32( _mm256_castsi256_si128(b), _mm256_extractf128_si256!1( b ) );
    t = _mm_packus_epi16( t, t );
    out_ = _mm_castps_si128( _mm_shuffle_ps!( (0<<0)+(1<<2)+(0<<4)+(1<<6) )( _mm_castsi128_ps(out_), _mm_castsi128_ps(t) ) ) ;
}
/* PERF: this should be faster in AVX2
{
    stbir__simdi8 t;
    stbir__simdf8 af,bf;
    stbir__simdi8 a,b;
    af = _mm256_min_ps( aa, STBIR_max_uint8_as_floatX );
    bf = _mm256_min_ps( bb, STBIR_max_uint8_as_floatX );
    af = _mm256_max_ps( af, _mm256_setzero_ps() );
    bf = _mm256_max_ps( bf, _mm256_setzero_ps() );
    a = _mm256_cvttps_epi32( af );
    b = _mm256_cvttps_epi32( bf );
    t = _mm256_permute4x64_epi64( _mm256_packs_epi32( a, b ), (0<<0)+(2<<2)+(1<<4)+(3<<6) );
    out_ = _mm256_castsi256_si128( _mm256_permute4x64_epi64( _mm256_packus_epi16( t, t ), (0<<0)+(2<<2)+(1<<4)+(3<<6) ) );
}*/

void stbir__simdi8_expand_u16_to_u32(ref __m256i out_, __m128i ireg)
{
    out_ = _mm256_unpacklo_epi16( _mm256_permute4x64_epi64!((0<<0)+(2<<2)+(1<<4)+(3<<6))(_mm256_castsi128_si256(ireg)), _mm256_setzero_si256() );
}


// TODO: need that one AVX2 intrin
void stbir__simdf8_pack_to_16words(ref __m256i out_, __m256 aa, __m256 bb)
{
    stbir__simdf8 af,bf;
    stbir__simdi8 a,b;
    af = _mm256_min_ps( aa, STBIR_max_uint16_as_floatX );
    bf = _mm256_min_ps( bb, STBIR_max_uint16_as_floatX );
    af = _mm256_max_ps( af, _mm256_setzero_ps() );
    bf = _mm256_max_ps( bf, _mm256_setzero_ps() );
    a = _mm256_cvttps_epi32( af );
    b = _mm256_cvttps_epi32( bf );
    out_ = _mm256_permute4x64_epi64!((0<<0)+(2<<2)+(1<<4)+(3<<6))( _mm256_packus_epi32(a, b));
}

void stbir__simdf8_0123to00001111(ref __m256 out_, __m256 in_ )
{
    __m256i stbir_00001111 = _mm256_setr_epi32(0, 0, 0, 0, 1, 1, 1, 1);
    out_ = _mm256_permutevar_ps ( in_, stbir_00001111 );
}

void stbir__simdf8_0123to22223333(ref __m256 out_, __m256 in_ )
{
    __m256i stbir_22223333 = _mm256_setr_epi32(2, 2, 2, 2, 3, 3, 3, 3);
    out_ = _mm256_permutevar_ps ( in_, stbir_22223333 );
}

void stbir__simdf8_0123to2222(ref __m128 out_, __m256 in_ )
{
    out_ = stbir__simdf_swiz!(2, 2, 2, 2)(_mm256_castps256_ps128(in_));
}


/*
#else



#define stbir__simdi8_expand_u16_to_u32(out,ireg)
{
stbir__simdi a,b,zero = _mm_setzero_si128();
a = _mm_unpacklo_epi16( ireg, zero );
b = _mm_unpackhi_epi16( ireg, zero );
out = _mm256_insertf128_si256( _mm256_castsi128_si256( a ), b, 1 );
}

#define stbir__simdf8_pack_to_16words(out,aa,bb)
{
stbir__simdi t0,t1;
stbir__simdf8 af,bf;
stbir__simdi8 a,b;
af = _mm256_min_ps( aa, STBIR_max_uint16_as_floatX );
bf = _mm256_min_ps( bb, STBIR_max_uint16_as_floatX );
af = _mm256_max_ps( af, _mm256_setzero_ps() );
bf = _mm256_max_ps( bf, _mm256_setzero_ps() );
a = _mm256_cvttps_epi32( af );
b = _mm256_cvttps_epi32( bf );
t0 = _mm_packus_epi32( _mm256_castsi256_si128(a), _mm256_extractf128_si256( a, 1 ) );
t1 = _mm_packus_epi32( _mm256_castsi256_si128(b), _mm256_extractf128_si256( b, 1 ) );
out = _mm256_setr_m128i( t0, t1 );
}

#endif


#define stbir__simdf8_0123to2222( out, in ) (out) = stbir__simdf_swiz(_mm256_castps256_ps128(in), 2,2,2,2 )
*/

void stbir__simdf8_load4b(ref __m256 out_, const(void)* ptr)
    @system // memsafe if ptr points to 16 adressable bytes
{
    out_ = _mm256_broadcast_ps( cast(const(__m128)*)ptr );
}

void stbir__simdf8_0123to00112233(ref __m256 out_, __m256 in_)
{
    __m256i stbir_00112233 = _mm256_setr_epi32(0, 0, 1, 1, 2, 2, 3, 3);
    out_ = _mm256_permutevar_ps (in_, stbir_00112233);
}

void stbir__simdf8_add4(ref __m256 out_, __m256 a8, __m128 b)
{
    out_ = _mm256_add_ps( a8,  _mm256_castps128_ps256( b ) );
}

void stbir__simdf8_load6z(ref __m256 out_, const(void)* ptr )
    @system // memsafe if ptr points to 24 bytes
{
    // Port: Can't use maskload, different semantics in intel-intrinsics vs x86
    const(float)* p = cast(const(float)*)ptr;
    for (int n = 0; n < 6; ++n)
    {
        out_.ptr[n] = p[n];
    }
    out_.ptr[6] = 0;
    out_.ptr[7] = 0;
}

void stbir__simdf8_0123to00000000(ref __m256 out_, __m256 in_) { out_ = _mm256_shuffle_ps!0   (in_, in_); }
void stbir__simdf8_0123to11111111(ref __m256 out_, __m256 in_) { out_ = _mm256_shuffle_ps!85  (in_, in_); }
void stbir__simdf8_0123to22222222(ref __m256 out_, __m256 in_) { out_ = _mm256_shuffle_ps!170 (in_, in_); }
void stbir__simdf8_0123to33333333(ref __m256 out_, __m256 in_) { out_ = _mm256_shuffle_ps!255 (in_, in_); }
void stbir__simdf8_0123to21032103(ref __m256 out_, __m256 in_) { out_ = _mm256_shuffle_ps!198 (in_, in_); }
void stbir__simdf8_0123to32103210(ref __m256 out_, __m256 in_) { out_ = _mm256_shuffle_ps!27  (in_, in_); }
void stbir__simdf8_0123to12301230(ref __m256 out_, __m256 in_) { out_ = _mm256_shuffle_ps!57  (in_, in_); }
void stbir__simdf8_0123to10321032(ref __m256 out_, __m256 in_) { out_ = _mm256_shuffle_ps!177 (in_, in_); }
void stbir__simdf8_0123to30123012(ref __m256 out_, __m256 in_) { out_ = _mm256_shuffle_ps!147 (in_, in_); }
void stbir__simdf8_0123to11331133(ref __m256 out_, __m256 in_) { out_ = _mm256_shuffle_ps!245 (in_, in_); }
void stbir__simdf8_0123to00220022(ref __m256 out_, __m256 in_) { out_ = _mm256_shuffle_ps!160 (in_, in_); }

void stbir__simdf8_aaa1(ref __m256 out_, __m256 alp, __m256 ones )
{
    enum int Blimm8 = (1<<0)+(1<<1)+(1<<2)+(0<<3)+(1<<4)+(1<<5)+(1<<6)+(0<<7);
    out_ = _mm256_blend_ps!Blimm8( alp, ones);
    enum int ShufImm8 = (3<<0) + (3<<2) + (3<<4) + (0<<6);
    out_ = _mm256_shuffle_ps!ShufImm8(out_, out_);
}

void stbir__simdf8_1aaa(ref __m256 out_, __m256 alp, __m256 ones )
{
    enum int Blimm8 = (0<<0)+(1<<1)+(1<<2)+(1<<3)+(0<<4)+(1<<5)+(1<<6)+(1<<7);
    out_ = _mm256_blend_ps!Blimm8( alp, ones);
    enum int ShufImm8 = (1<<0) + (0<<2) + (0<<4) + (0<<6);
    out_ = _mm256_shuffle_ps!ShufImm8(out_, out_);
}

void stbir__simdf8_a1a1(ref __m256 out_, __m256 alp, __m256 ones)
{
    enum int Blimm8 = (1<<0)+(0<<1)+(1<<2)+(0<<3)+(1<<4)+(0<<5)+(1<<6)+(0<<7);
    out_ = _mm256_blend_ps!Blimm8( alp, ones);
    enum int ShufImm8 = (1<<0) + (0<<2) + (3<<4) + (2<<6);
    out_ = _mm256_shuffle_ps!ShufImm8(out_, out_);
}

void stbir__simdf8_1a1a(ref __m256 out_, __m256 alp, __m256 ones)
{
    enum int Blimm8 = (0<<0)+(1<<1)+(0<<2)+(1<<3)+(0<<4)+(1<<5)+(0<<6)+(1<<7);
    out_ = _mm256_blend_ps!Blimm8( alp, ones);
    enum int ShufImm8 = (1<<0) + (0<<2) + (3<<4) + (2<<6);
    out_ = _mm256_shuffle_ps!ShufImm8(out_, out_);
}


/*void stbir__simdf8_zero(ref __m256 reg)
{
    reg = _mm256_setzero_ps();
}*/

// PERF FMA

/*
#ifdef STBIR_USE_FMA           // not on by default to maintain bit identical simd to non-simd
#define stbir__simdf8_madd( out, add, mul1, mul2 ) (out) = _mm256_fmadd_ps( mul1, mul2, add )
#define stbir__simdf8_madd_mem( out, add, mul, ptr ) (out) = _mm256_fmadd_ps( mul, _mm256_loadu_ps( (float const*)(ptr) ), add )
#define stbir__simdf8_madd_mem4( out, add, mul, ptr )(out) = _mm256_fmadd_ps( _mm256_setr_m128( mul, _mm_setzero_ps() ), _mm256_setr_m128( _mm_loadu_ps( (float const*)(ptr) ), _mm_setzero_ps() ), add )
#else
*/

void stbir__simdf8_madd(ref __m256 out_, __m256 add, __m256 mul1, __m256 mul2 )
{
    out_ = _mm256_add_ps( add, _mm256_mul_ps( mul1, mul2 ) );
}

void stbir__simdf8_madd_mem(ref __m256 out_, __m256 add, __m256 mul, const(void)* ptr )
    @system /* memory-safe if ptr has 32 bytes addressible */
{
    out_ = _mm256_add_ps( add, _mm256_mul_ps( mul, _mm256_loadu_ps( cast(const(float)*)(ptr) ) ) );
}

void stbir__simdf8_madd_mem4(ref __m256 out_, __m256 add, __m128 mul, const(void)* ptr )
    @system /* memory-safe if ptr has 16 bytes addressible */
{
    out_ = _mm256_add_ps( add, _mm256_setr_m128( _mm_mul_ps( mul, _mm_loadu_ps( cast(const(float)*)(ptr) ) ), _mm_setzero_ps() ) );
}

alias stbir__if_simdf8_cast_to_simdf4 = _mm256_castps256_ps128;


alias STBIR_FLOORF = stbir_simd_floorf;
static float stbir_simd_floorf(float x)  // martins floorf
{
    // FUTURE: use _mm_floor_ss when optimal in intel-intrinsics
    // See original stb_image_resize2.h
    __m128 f = _mm_set_ss(x);
    __m128 t = _mm_cvtepi32_ps(_mm_cvttps_epi32(f));
    __m128 r = _mm_add_ss(t, _mm_and_ps(_mm_cmplt_ss(f, t), _mm_set_ss(-1.0f)));
    return _mm_cvtss_f32(r);
}

alias STBIR_CEILF = stbir_simd_ceilf;
static float stbir_simd_ceilf(float x)  // martins ceilf
{
    // FUTURE: use _mm_ceil_ss when optimal in intel-intrinsics
    // See original stb_image_resize2.h
    __m128 f = _mm_set_ss(x);
    __m128 t = _mm_cvtepi32_ps(_mm_cvttps_epi32(f));
    __m128 r = _mm_add_ss(t, _mm_and_ps(_mm_cmplt_ss(t, f), _mm_set_ss(1.0f)));
    return _mm_cvtss_f32(r);
}

alias stbir__simdfX = stbir__simdf8;
alias stbir__simdiX = stbir__simdi8;
alias stbir__simdfX_load = stbir__simdf8_load;
alias stbir__simdiX_load = stbir__simdi8_load;
alias stbir__simdfX_mult = stbir__simdf8_mult;
alias stbir__simdfX_add_mem = stbir__simdf8_add_mem;
alias stbir__simdfX_madd_mem = stbir__simdf8_madd_mem;
alias stbir__simdfX_store = stbir__simdf8_store;
alias stbir__simdiX_store = stbir__simdi8_store;
alias stbir__simdf_frepX =  stbir__simdf8_frep8;
alias stbir__simdfX_madd = stbir__simdf8_madd;
alias stbir__simdfX_min = stbir__simdf8_min;
alias stbir__simdfX_max = stbir__simdf8_max;
alias stbir__simdfX_aaa1 = stbir__simdf8_aaa1;
alias stbir__simdfX_1aaa = stbir__simdf8_1aaa;
alias stbir__simdfX_a1a1 = stbir__simdf8_a1a1;
alias stbir__simdfX_1a1a = stbir__simdf8_1a1a;
//alias stbir__simdfX_convert_float_to_i32 = stbir__simdf8_convert_float_to_i32;
alias stbir__simdfX_pack_to_words = stbir__simdf8_pack_to_16words;
//alias stbir__simdfX_zero = stbir__simdf8_zero;
alias STBIR_onesX = STBIR_ones8;
alias STBIR_max_uint8_as_floatX = STBIR_max_uint8_as_float8;
alias STBIR_max_uint16_as_floatX = STBIR_max_uint16_as_float8;
alias STBIR_simd_point5X = STBIR_simd_point58;
enum stbir__simdfX_float_count = 8;
alias stbir__simdfX_0123to1230 = stbir__simdf8_0123to12301230;
alias stbir__simdfX_0123to2103 = stbir__simdf8_0123to21032103;

static immutable __m256 STBIR_max_uint16_as_float_inverted8 = _mm256_set1_ps(stbir__max_uint16_as_float_inverted);
static immutable __m256 STBIR_max_uint8_as_float_inverted8 = _mm256_set1_ps(stbir__max_uint8_as_float_inverted);
static immutable __m256 STBIR_ones8 = _mm256_set1_ps(1.0);
static immutable __m256 STBIR_simd_point58 = _mm256_set1_ps(0.5);
static immutable __m256 STBIR_max_uint8_as_float8 = _mm256_set1_ps(stbir__max_uint8_as_float);
static immutable __m256 STBIR_max_uint16_as_float8 = _mm256_set1_ps(stbir__max_uint16_as_float);


// FUTURE: have a dedicated float16_t type?
alias stbir__FP16 = ushort;

// PERF FUTURE: use FP16C in intel-intrinsics



// Fabian's half float routines, see: https://gist.github.com/rygorous/2156668

float stbir__half_to_float( stbir__FP16 h ) @trusted
{
    static immutable stbir__FP32 magic = { (254 - 15) << 23 };
    static immutable stbir__FP32 was_infnan = { (127 + 16) << 23 };
    stbir__FP32 o;

    o.u = (h & 0x7fff) << 13;     // exponent/mantissa bits
    o.f *= magic.f;                 // exponent adjust
    if (o.f >= was_infnan.f)        // make sure Inf/NaN survive
        o.u |= 255 << 23;
    o.u |= (h & 0x8000) << 16;    // sign bit
    return o.f;
}

stbir__FP16 stbir__float_to_half(float val) @trusted
{
    stbir__FP32 f32infty = { 255 << 23 };
    stbir__FP32 f16max   = { (127 + 16) << 23 };
    stbir__FP32 denorm_magic = { ((127 - 15) + (23 - 10) + 1) << 23 };
    uint sign_mask = 0x80000000u;
    stbir__FP16 o = 0;
    stbir__FP32 f;
    uint sign;

    f.f = val;
    sign = f.u & sign_mask;
    f.u ^= sign;

    if (f.u >= f16max.u) // result is Inf or NaN (all exponent bits set)
        o = (f.u > f32infty.u) ? 0x7e00 : 0x7c00; // NaN.qNaN and Inf.Inf
    else // (De)normalized number or zero
    {
        if (f.u < (113 << 23)) // resulting FP16 is subnormal or zero
        {
            // use a magic value to align our 10 mantissa bits at the bottom of
            // the float. as long as FP addition is round-to-nearest-even this
            // just works.
            f.f += denorm_magic.f;
            // and one integer subtract of the bias later, we have our final float!
            o = cast(ushort) ( f.u - denorm_magic.u );
        }
        else
        {
            uint mant_odd = (f.u >> 13) & 1; // resulting mantissa is odd
            // update exponent, rounding bias part 1
            f.u = f.u + ((15u - 127) << 23) + 0xfff;
            // rounding bias part 2
            f.u += mant_odd;
            // take the bits!
            o = cast(ushort) ( f.u >> 13 );
        }
    }
    o |= sign >> 16;
    return o;
}


// Note: stb_image_resize2.d had implementation for FP16C operations on arm and wasm,
// here we just kept the SSE2 version

// Fabian's half float routines, see: https://gist.github.com/rygorous/2156668
void stbir__half_to_float_SIMD(float* output, const(void)* input)
@system /* memsafe if input points to 16 bytes, and output points to 32 bytes */
{
    static immutable __m128i mask_nosign      = _mm_set1_epi32(0x7fff);
    static immutable __m128i smallest_normal  = _mm_set1_epi32(0x0400);
    static immutable __m128i infinity         = _mm_set1_epi32(0x7c00);
    static immutable __m128i expadjust_normal = _mm_set1_epi32((127 - 15) << 23);
    static immutable __m128i magic_denorm     = _mm_set1_epi32(113 << 23);

    __m128i i = _mm_loadu_si128 ( cast(const(__m128i)*)(input) );
    __m128i h = _mm_unpacklo_epi16 ( i, _mm_setzero_si128() );
    __m128i mnosign     = mask_nosign;
    __m128i eadjust     = expadjust_normal;
    __m128i smallest    = smallest_normal;
    __m128i infty       = infinity;
    __m128i expmant     = _mm_and_si128(mnosign, h);
    __m128i justsign    = _mm_xor_si128(h, expmant);
    __m128i b_notinfnan = _mm_cmpgt_epi32(infty, expmant);
    __m128i b_isdenorm  = _mm_cmpgt_epi32(smallest, expmant);
    __m128i shifted     = _mm_slli_epi32(expmant, 13);
    __m128i adj_infnan  = _mm_andnot_si128(b_notinfnan, eadjust);
    __m128i adjusted    = _mm_add_epi32(eadjust, shifted);
    __m128i den1        = _mm_add_epi32(shifted, magic_denorm);
    __m128i adjusted2   = _mm_add_epi32(adjusted, adj_infnan);
    __m128  den2        = _mm_sub_ps(_mm_castsi128_ps(den1), *cast(const(__m128)*)&magic_denorm);
    __m128  adjusted3   = _mm_and_ps(den2, _mm_castsi128_ps(b_isdenorm));
    __m128  adjusted4   = _mm_andnot_ps(_mm_castsi128_ps(b_isdenorm), _mm_castsi128_ps(adjusted2));
    __m128  adjusted5   = _mm_or_ps(adjusted3, adjusted4);
    __m128i sign        = _mm_slli_epi32(justsign, 16);
    __m128  final_      = _mm_or_ps(adjusted5, _mm_castsi128_ps(sign));
    stbir__simdf_store( output + 0,  final_ );

    h = _mm_unpackhi_epi16 ( i, _mm_setzero_si128() );
    expmant     = _mm_and_si128(mnosign, h);
    justsign    = _mm_xor_si128(h, expmant);
    b_notinfnan = _mm_cmpgt_epi32(infty, expmant);
    b_isdenorm  = _mm_cmpgt_epi32(smallest, expmant);
    shifted     = _mm_slli_epi32(expmant, 13);
    adj_infnan  = _mm_andnot_si128(b_notinfnan, eadjust);
    adjusted    = _mm_add_epi32(eadjust, shifted);
    den1        = _mm_add_epi32(shifted, magic_denorm);
    adjusted2   = _mm_add_epi32(adjusted, adj_infnan);
    den2        = _mm_sub_ps(_mm_castsi128_ps(den1), *cast(const(__m128)*)&magic_denorm);
    adjusted3   = _mm_and_ps(den2, _mm_castsi128_ps(b_isdenorm));
    adjusted4   = _mm_andnot_ps(_mm_castsi128_ps(b_isdenorm), _mm_castsi128_ps(adjusted2));
    adjusted5   = _mm_or_ps(adjusted3, adjusted4);
    sign        = _mm_slli_epi32(justsign, 16);
    final_      = _mm_or_ps(adjusted5, _mm_castsi128_ps(sign));
    stbir__simdf_store( output + 4,  final_);

    // ~38 SSE2 ops for 8 values
}

// Fabian's round-to-nearest-even float to half
// ~48 SSE2 ops for 8 output
static void stbir__float_to_half_SIMD(void * output, const(float)* input)
@system /* memsafe if input points to 32 bytes, and output points to 16 bytes */
{
    static immutable __m128i mask_sign       = _mm_set1_epi32(0x80000000);
    static immutable __m128i c_f16max        = _mm_set1_epi32( (127 + 16) << 23); // all FP32 values >=this round to +inf
    static immutable __m128i c_nanbit        = _mm_set1_epi32(0x200);
    static immutable __m128i c_infty_as_fp16 = _mm_set1_epi32(0x7c00);
    static immutable __m128i c_min_normal    = _mm_set1_epi32((127 - 14) << 23); // smallest FP32 that yields a normalized FP16
    static immutable __m128i c_subnorm_magic = _mm_set1_epi32(((127 - 15) + (23 - 10) + 1) << 23);
    static immutable __m128i c_normal_bias   = _mm_set1_epi32(0xfff - ((127 - 15) << 23)); // adjust exponent and add mantissa rounding
    __m128  f           =  _mm_loadu_ps(input);
    __m128  msign       = _mm_castsi128_ps(mask_sign);
    __m128  justsign    = _mm_and_ps(msign, f);
    __m128  absf        = _mm_xor_ps(f, justsign);
    __m128i absf_int    = _mm_castps_si128(absf); // the cast is "free" (extra bypass latency, but no thruput hit)
    __m128i f16max       = c_f16max;
    __m128  b_isnan     = _mm_cmpunord_ps(absf, absf); // is this a NaN?
    __m128i b_isregular = _mm_cmpgt_epi32(f16max, absf_int); // (sub)normalized or special?
    __m128i nanbit      = _mm_and_si128(_mm_castps_si128(b_isnan), c_nanbit);
    __m128i inf_or_nan  = _mm_or_si128(nanbit, c_infty_as_fp16); // output for specials

    __m128i min_normal  = c_min_normal;
    __m128i b_issub     = _mm_cmpgt_epi32(min_normal, absf_int);

    // "result is subnormal" path
    __m128  subnorm1    = _mm_add_ps(absf, _mm_castsi128_ps(c_subnorm_magic)); // magic value to round output mantissa
    __m128i subnorm2    = _mm_sub_epi32(_mm_castps_si128(subnorm1), c_subnorm_magic); // subtract out bias

    // "result is normal" path
    __m128i mantoddbit  = _mm_slli_epi32(absf_int, 31 - 13); // shift bit 13 (mantissa LSB) to sign
    __m128i mantodd     = _mm_srai_epi32(mantoddbit, 31); // -1 if FP16 mantissa odd, else 0

    __m128i round1      = _mm_add_epi32(absf_int, c_normal_bias);
    __m128i round2      = _mm_sub_epi32(round1, mantodd); // if mantissa LSB odd, bias towards rounding up (RTNE)
    __m128i normal      = _mm_srli_epi32(round2, 13); // rounded result

    // combine the two non-specials
    __m128i nonspecial  = _mm_or_si128(_mm_and_si128(subnorm2, b_issub), _mm_andnot_si128(b_issub, normal));

    // merge in specials as well
    __m128i joined      = _mm_or_si128(_mm_and_si128(nonspecial, b_isregular), _mm_andnot_si128(b_isregular, inf_or_nan));

    __m128i sign_shift  = _mm_srai_epi32(_mm_castps_si128(justsign), 16);
    __m128i final2, final_ = _mm_or_si128(joined, sign_shift);

    f           =  _mm_loadu_ps(input+4);
    justsign    = _mm_and_ps(msign, f);
    absf        = _mm_xor_ps(f, justsign);
    absf_int    = _mm_castps_si128(absf); // the cast is "free" (extra bypass latency, but no thruput hit)
    b_isnan     = _mm_cmpunord_ps(absf, absf); // is this a NaN?
    b_isregular = _mm_cmpgt_epi32(f16max, absf_int); // (sub)normalized or special?
    nanbit      = _mm_and_si128(_mm_castps_si128(b_isnan), c_nanbit);
    inf_or_nan  = _mm_or_si128(nanbit, c_infty_as_fp16); // output for specials

    b_issub     = _mm_cmpgt_epi32(min_normal, absf_int);

    // "result is subnormal" path
    subnorm1    = _mm_add_ps(absf, _mm_castsi128_ps(c_subnorm_magic)); // magic value to round output mantissa
    subnorm2    = _mm_sub_epi32(_mm_castps_si128(subnorm1), c_subnorm_magic); // subtract out bias

    // "result is normal" path
    mantoddbit  = _mm_slli_epi32(absf_int, 31 - 13); // shift bit 13 (mantissa LSB) to sign
    mantodd     = _mm_srai_epi32(mantoddbit, 31); // -1 if FP16 mantissa odd, else 0

    round1      = _mm_add_epi32(absf_int, c_normal_bias);
    round2      = _mm_sub_epi32(round1, mantodd); // if mantissa LSB odd, bias towards rounding up (RTNE)
    normal      = _mm_srli_epi32(round2, 13); // rounded result

    // combine the two non-specials
    nonspecial  = _mm_or_si128(_mm_and_si128(subnorm2, b_issub), _mm_andnot_si128(b_issub, normal));

    // merge in specials as well
    joined      = _mm_or_si128(_mm_and_si128(nonspecial, b_isregular), _mm_andnot_si128(b_isregular, inf_or_nan));

    sign_shift  = _mm_srai_epi32(_mm_castps_si128(justsign), 16);
    final2      = _mm_or_si128(joined, sign_shift);
    final_      = _mm_packs_epi32(final_, final2);
    stbir__simdi_store( output,final_);
}

void stbir__simdf_0123to3333(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(3,3,3,3)( reg, ); }
void stbir__simdf_0123to2222(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(2,2,2,2)( reg, ); }
void stbir__simdf_0123to1111(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(1,1,1,1)( reg, ); }
void stbir__simdf_0123to0000(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(0,0,0,0)( reg, ); }
void stbir__simdf_0123to0003(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(0,0,0,3)( reg, ); }
void stbir__simdf_0123to0001(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(0,0,0,1)( reg, ); }
void stbir__simdf_0123to1122(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(1,1,2,2)( reg, ); }
void stbir__simdf_0123to2333(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(2,3,3,3)( reg, ); }
void stbir__simdf_0123to0023(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(0,0,2,3)( reg, ); }
void stbir__simdf_0123to1230(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(1,2,3,0)( reg, ); }
void stbir__simdf_0123to2103(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(2,1,0,3)( reg, ); }
void stbir__simdf_0123to3210(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(3,2,1,0)( reg, ); }
void stbir__simdf_0123to2301(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(2,3,0,1)( reg, ); }
void stbir__simdf_0123to3012(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(3,0,1,2)( reg, ); }
void stbir__simdf_0123to0011(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(0,0,1,1)( reg, ); }
void stbir__simdf_0123to1100(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(1,1,0,0)( reg, ); }
void stbir__simdf_0123to2233(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(2,2,3,3)( reg, ); }
void stbir__simdf_0123to1133(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(1,1,3,3)( reg, ); }
void stbir__simdf_0123to0022(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(0,0,2,2)( reg, ); }
void stbir__simdf_0123to1032(ref __m128 out_, __m128 reg ) { out_ = stbir__simdf_swiz!(1,0,3,2)( reg, ); }

deprecated union stbir__simdi_u32
{
    stbir_uint32[4] m128i_u32;
    int[4] m128i_i32;
    stbir__simdi m128i_i128;
}

static immutable int[9] STBIR_mask = [ 0,0,0,-1,-1,-1,0,0,0 ];

static immutable __m128 STBIR_max_uint8_as_float           = _mm_set1_ps(stbir__max_uint8_as_float);
static immutable __m128 STBIR_max_uint16_as_float          = _mm_set1_ps(stbir__max_uint16_as_float);
static immutable __m128 STBIR_max_uint8_as_float_inverted  = _mm_set1_ps(stbir__max_uint8_as_float_inverted);
static immutable __m128 STBIR_max_uint16_as_float_inverted = _mm_set1_ps(stbir__max_uint16_as_float_inverted);

static immutable __m128 STBIR_simd_point5   = _mm_set1_ps(0.5f);
static immutable __m128 STBIR_ones          = _mm_set1_ps(1.0f);
static immutable __m128i STBIR_almost_zero   = _mm_set1_epi32((127 - 13) << 23);
static immutable __m128i STBIR_almost_one    = _mm_set1_epi32(0x3f7fffff);
static immutable __m128i STBIR_mastissa_mask = _mm_set1_epi32(0xff);
static immutable __m128i STBIR_topscale      = _mm_set1_epi32(0x02000000);


enum bool STBIR_implements_memcpy = true;

static if ( ! STBIR_implements_memcpy)
{
    alias STBIR_MEMCPY = memcpy;
}
else
{
    // override normal use of memcpy with much simpler copy (faster and smaller with our sized copies)
    void STBIR_MEMCPY( void * dest, const(void)* src, size_t bytes ) @system
    {
        @restrict char* d = cast(char*) dest;
        @restrict char* d_end = (cast(char*) dest) + bytes;
        ptrdiff_t ofs_to_src = cast(char*)src - cast(char*)dest;

        // check overlaps
        assert( ( ( d >= ( cast(char*)src) + bytes ) ) || ( ( d + bytes ) <= cast(char*)src ) );

        if ( bytes < (16*stbir__simdfX_float_count) )
        {
            if ( bytes < 16 )
            {
                if ( bytes )
                {
                    do
                    {
                        STBIR_SIMD_NO_UNROLL(d);
                        d[ 0 ] = d[ ofs_to_src ];
                        ++d;
                    } while ( d < d_end );
                }
            }
            else
            {
                stbir__simdf x;
                // do one unaligned to get us aligned for the stream out below
                stbir__simdf_load( x, ( d + ofs_to_src ) );
                stbir__simdf_store( d, x );
                d = cast(char*)( ( ( cast(size_t)d ) + 16 ) & ~15 );

                for(;;)
                {
                    STBIR_SIMD_NO_UNROLL(d);

                    if ( d > ( d_end - 16 ) )
                    {
                        if ( d == d_end )
                            return;
                        d = d_end - 16;
                    }

                    stbir__simdf_load( x, ( d + ofs_to_src ) );
                    stbir__simdf_store( d, x );
                    d += 16;
                }
            }
        }
        else
        {
            stbir__simdfX x0,x1,x2,x3;

            // do one unaligned to get us aligned for the stream out below
            stbir__simdfX_load( x0, ( d + ofs_to_src ) +  0*stbir__simdfX_float_count );
            stbir__simdfX_load( x1, ( d + ofs_to_src ) +  4*stbir__simdfX_float_count );
            stbir__simdfX_load( x2, ( d + ofs_to_src ) +  8*stbir__simdfX_float_count );
            stbir__simdfX_load( x3, ( d + ofs_to_src ) + 12*stbir__simdfX_float_count );
            stbir__simdfX_store( d +  0*stbir__simdfX_float_count, x0 );
            stbir__simdfX_store( d +  4*stbir__simdfX_float_count, x1 );
            stbir__simdfX_store( d +  8*stbir__simdfX_float_count, x2 );
            stbir__simdfX_store( d + 12*stbir__simdfX_float_count, x3 );
            d = cast(char*)( ( ( cast(size_t)d ) + (16*stbir__simdfX_float_count) ) & ~((16*stbir__simdfX_float_count)-1) );

            for(;;)
            {
                STBIR_SIMD_NO_UNROLL(d);

                if ( d > ( d_end - (16*stbir__simdfX_float_count) ) )
                {
                    if ( d == d_end )
                        return;
                    d = d_end - (16*stbir__simdfX_float_count);
                }

                stbir__simdfX_load( x0, ( d + ofs_to_src ) +  0*stbir__simdfX_float_count );
                stbir__simdfX_load( x1, ( d + ofs_to_src ) +  4*stbir__simdfX_float_count );
                stbir__simdfX_load( x2, ( d + ofs_to_src ) +  8*stbir__simdfX_float_count );
                stbir__simdfX_load( x3, ( d + ofs_to_src ) + 12*stbir__simdfX_float_count );
                stbir__simdfX_store( d +  0*stbir__simdfX_float_count, x0 );
                stbir__simdfX_store( d +  4*stbir__simdfX_float_count, x1 );
                stbir__simdfX_store( d +  8*stbir__simdfX_float_count, x2 );
                stbir__simdfX_store( d + 12*stbir__simdfX_float_count, x3 );
                d += (16*stbir__simdfX_float_count);
            }
        }
    }
}

// memcpy that is specically intentionally overlapping (src is smaller then dest, so can be
//   a normal forward copy, bytes is divisible by 4 and bytes is greater than or equal to
//   the diff between dest and src)
void stbir_overlapping_memcpy( void * dest, const(void)* src, size_t bytes ) @system
{
    @restrict char* sd = cast(char*) src;
    @restrict char* s_end = (cast(char*) src) + bytes;
    ptrdiff_t ofs_to_dest = cast(char*)dest - cast(char*)src;

    if ( ofs_to_dest >= 16 ) // is the overlap more than 16 away?
    {
        @restrict char* s_end16 = (cast(char*) src) + (bytes&~15);
        do
        {
            stbir__simdf x;
            STBIR_SIMD_NO_UNROLL(sd);
            stbir__simdf_load( x, sd );
            stbir__simdf_store(  ( sd + ofs_to_dest ), x );
            sd += 16;
        } while ( sd < s_end16 );

        if ( sd == s_end )
            return;
    }

    do
    {
        STBIR_SIMD_NO_UNROLL(sd);
        *cast(int*)( sd + ofs_to_dest ) = *cast(int*) sd;
        sd += 4;
    } while ( sd < s_end );
}