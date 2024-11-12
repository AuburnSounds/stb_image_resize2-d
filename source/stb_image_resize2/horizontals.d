module stb_image_resize2.horizontals;

nothrow @nogc @safe:

import stb_image_resize2.types;
import stb_image_resize2.simd;

static if (hasRestrict)
    import core.attribute: restrict;
else
    enum restrict = 0;

struct stbir_horz_helper
{
    int channels;
    alias STBIR__horizontal_channels = channels;

    string stbir__1_coeff_only;
    string stbir__2_coeff_only;
    string stbir__3_coeff_only;
    string stbir__store_output_tiny;
    string stbir__4_coeff_start;
    string stbir__4_coeff_continue_from_4;
    string stbir__1_coeff_remnant;
    string stbir__2_coeff_remnant;
    string stbir__3_coeff_setup;
    string stbir__3_coeff_remnant;
    string stbir__store_output;

    //alias stbir__store_output_tiny = stbir__store_output;

  /*  string stbir__2_coeff_only()
    {
        return stbir__1_coeff_only 
             ~ "ofs = 1
    }*/
}

/+

#ifndef stbir__2_coeff_only
#define stbir__2_coeff_only()             
    stbir__1_coeff_only();                
    stbir__1_coeff_remnant(1);
#endif

#ifndef stbir__2_coeff_remnant
#define stbir__2_coeff_remnant( ofs )     
    stbir__1_coeff_remnant(ofs);          
    stbir__1_coeff_remnant((ofs)+1);
#endif

#ifndef stbir__3_coeff_only
#define stbir__3_coeff_only()             
    stbir__2_coeff_only();                
    stbir__1_coeff_remnant(2);
#endif

#ifndef stbir__3_coeff_remnant
#define stbir__3_coeff_remnant( ofs )     
    stbir__2_coeff_remnant(ofs);          
    stbir__1_coeff_remnant((ofs)+2);
#endif

#ifndef stbir__3_coeff_setup
#define stbir__3_coeff_setup()
#endif

#ifndef stbir__4_coeff_start
#define stbir__4_coeff_start()            
    stbir__2_coeff_only();                
    stbir__2_coeff_remnant(2);
#endif

#ifndef stbir__4_coeff_continue_from_4
#define stbir__4_coeff_continue_from_4( ofs )     
    stbir__2_coeff_remnant(ofs);                  
    stbir__2_coeff_remnant((ofs)+2);
#endif


+/

void stbir__horizontal_gather_N_channels_with_1_coeff(stbir_horz_helper h)
    (float * output_buffer, uint output_sub_size, const(float)* decode_buffer, 
     const(stbir__contributors)* horizontal_contributors, 
     const(float)* horizontal_coefficients, int coefficient_width )
    @system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float* output = output_buffer;
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    const(float)* hc = horizontal_coefficients;
    mixin(h.stbir__1_coeff_only);
    mixin(h.stbir__store_output_tiny);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_2_coeffs(stbir_horz_helper h)
    (float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
    @system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    const(float)* hc = horizontal_coefficients;
    mixin(h.stbir__2_coeff_only);
    mixin(h.stbir__store_output_tiny);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_3_coeffs(stbir_horz_helper h)
    (float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
@system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    const(float)* hc = horizontal_coefficients;
    mixin(h.stbir__3_coeff_only);
    mixin(h.stbir__store_output_tiny);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_4_coeffs(stbir_horz_helper h)
     ( float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
@system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    const(float)* hc = horizontal_coefficients;
    mixin(h.stbir__4_coeff_start);
    mixin(h.stbir__store_output);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_5_coeffs(stbir_horz_helper h)
    ( float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
@system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    const(float)* hc = horizontal_coefficients;
    mixin(h.stbir__4_coeff_start);
    {
        int ofs = 4;
        mixin(h.stbir__1_coeff_remnant);
    }
    mixin(h.stbir__store_output);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_6_coeffs(stbir_horz_helper h)
    ( float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
@system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    const(float)* hc = horizontal_coefficients;
    mixin(h.stbir__4_coeff_start);
    {
        int ofs = 4;
        mixin(h.stbir__2_coeff_remnant);
    }
    mixin(h.stbir__store_output);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_7_coeffs(stbir_horz_helper h)
    ( float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
@system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  mixin(h.stbir__3_coeff_setup);
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    const(float)* hc = horizontal_coefficients;

    mixin(h.stbir__4_coeff_start);
    {
        int ofs = 4;
        mixin(h.stbir__3_coeff_remnant);
    }
    mixin(h.stbir__store_output);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_8_coeffs(stbir_horz_helper h)
    ( float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
@system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    const(float)* hc = horizontal_coefficients;
    mixin(h.stbir__4_coeff_start);
    {
        int ofs = 4;
        mixin(h.stbir__4_coeff_continue_from_4);
    }
    mixin(h.stbir__store_output);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_9_coeffs(stbir_horz_helper h)
    ( float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
@system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    const(float)* hc = horizontal_coefficients;
    mixin(h.stbir__4_coeff_start);
    {
        int ofs = 4;
        mixin(h.stbir__4_coeff_continue_from_4);
    }
    {
        int ofs = 8;
        mixin(h.stbir__1_coeff_remnant);
    }
    mixin(h.stbir__store_output);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_10_coeffs(stbir_horz_helper h)
    ( float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
@system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    const(float)* hc = horizontal_coefficients;
    mixin(h.stbir__4_coeff_start);    
    {
        int ofs = 4;
        mixin(h.stbir__4_coeff_continue_from_4);
    }
    {
        int ofs = 8;
        mixin(h.stbir__2_coeff_remnant);
    }
    mixin(h.stbir__store_output);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_11_coeffs(stbir_horz_helper h)
    ( float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
@system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  mixin(h.stbir__3_coeff_setup);
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    const(float)* hc = horizontal_coefficients;
    mixin(h.stbir__4_coeff_start);
    {
        int ofs = 4;
        mixin(h.stbir__4_coeff_continue_from_4);
    }
    {
        int ofs = 8;
        mixin(h.stbir__3_coeff_remnant);
    }
    mixin(h.stbir__store_output);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_12_coeffs(stbir_horz_helper h)
    ( float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
@system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    const(float)* hc = horizontal_coefficients;
    mixin(h.stbir__4_coeff_start);
    {
        int ofs = 4;
        mixin(h.stbir__4_coeff_continue_from_4);
    }
    {
        int ofs = 8;
        mixin(h.stbir__4_coeff_continue_from_4);
    }
    mixin(h.stbir__store_output);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_n_coeffs_mod0(stbir_horz_helper h)
    ( float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
    @system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    int n = ( ( horizontal_contributors.n1 - horizontal_contributors.n0 + 1 ) - 4 + 3 ) >> 2;
    const(float)* hc = horizontal_coefficients;

    mixin(h.stbir__4_coeff_start);
    do {
      hc += 4;
      decode += h.channels * 4;
      int ofs = 0;
      mixin(h.stbir__4_coeff_continue_from_4);
      --n;
    } while ( n > 0 );
    mixin(h.stbir__store_output);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_n_coeffs_mod1(stbir_horz_helper h)
    ( float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
    @system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    int n = ( ( horizontal_contributors.n1 - horizontal_contributors.n0 + 1 ) - 5 + 3 ) >> 2;
    const(float)* hc = horizontal_coefficients;

    mixin(h.stbir__4_coeff_start);
    do {
      hc += 4;
      decode += h.channels * 4;
      int ofs = 0;
      mixin(h.stbir__4_coeff_continue_from_4);
      --n;
    } while ( n > 0 );
    {
        int ofs = 4;
        mixin(h.stbir__1_coeff_remnant);
    }
    mixin(h.stbir__store_output);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_n_coeffs_mod2(stbir_horz_helper h)
    ( float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
    @system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    int n = ( ( horizontal_contributors.n1 - horizontal_contributors.n0 + 1 ) - 6 + 3 ) >> 2;
    const(float)* hc = horizontal_coefficients;

    mixin(h.stbir__4_coeff_start);
    do {
      hc += 4;
      decode += h.channels * 4;
      int ofs = 0;
      mixin(h.stbir__4_coeff_continue_from_4);
      --n;
    } while ( n > 0 );

    {
        int ofs = 4;
        mixin(h.stbir__2_coeff_remnant);
    }

    mixin(h.stbir__store_output);
  } while ( output < output_end );
}

void stbir__horizontal_gather_N_channels_with_n_coeffs_mod3(stbir_horz_helper h)
    ( float * output_buffer, uint output_sub_size, const(float)* decode_buffer, const(stbir__contributors)* horizontal_contributors, const(float)* horizontal_coefficients, int coefficient_width )
    @system
{
  const(float)* output_end = output_buffer + output_sub_size * h.channels;
  @restrict float*  output = output_buffer;
  mixin(h.stbir__3_coeff_setup);
  do {
    const(float)* decode = decode_buffer + horizontal_contributors.n0 * h.channels;
    int n = ( ( horizontal_contributors.n1 - horizontal_contributors.n0 + 1 ) - 7 + 3 ) >> 2;
    const(float)* hc = horizontal_coefficients;

    mixin(h.stbir__4_coeff_start);
    do {
      hc += 4;
      decode += h.channels * 4;
      int ofs = 0;
      mixin(h.stbir__4_coeff_continue_from_4);
      --n;
    } while ( n > 0 );
    {
        int ofs = 4;
        mixin(h.stbir__3_coeff_remnant);
    }

    mixin(h.stbir__store_output);
  } while ( output < output_end );
}

static immutable stbir__horizontal_gather_channels_func[4] 
    stbir__horizontal_gather_N_channels_with_n_coeffs_funcs(stbir_horz_helper h) =
[
    &stbir__horizontal_gather_N_channels_with_n_coeffs_mod0!h,
    &stbir__horizontal_gather_N_channels_with_n_coeffs_mod1!h,
    &stbir__horizontal_gather_N_channels_with_n_coeffs_mod2!h,
    &stbir__horizontal_gather_N_channels_with_n_coeffs_mod3!h,
];

static immutable stbir__horizontal_gather_channels_func[12] 
    stbir__horizontal_gather_N_channels_funcs(stbir_horz_helper h) =
[
    &stbir__horizontal_gather_N_channels_with_1_coeff!h,
    &stbir__horizontal_gather_N_channels_with_2_coeffs!h,
    &stbir__horizontal_gather_N_channels_with_3_coeffs!h,
    &stbir__horizontal_gather_N_channels_with_4_coeffs!h,
    &stbir__horizontal_gather_N_channels_with_5_coeffs!h,
    &stbir__horizontal_gather_N_channels_with_6_coeffs!h,
    &stbir__horizontal_gather_N_channels_with_7_coeffs!h,
    &stbir__horizontal_gather_N_channels_with_8_coeffs!h,
    &stbir__horizontal_gather_N_channels_with_9_coeffs!h,
    &stbir__horizontal_gather_N_channels_with_10_coeffs!h,
    &stbir__horizontal_gather_N_channels_with_11_coeffs!h,
    &stbir__horizontal_gather_N_channels_with_12_coeffs!h,
];

static immutable stbir__horizontal_gather_channels_func*[8] stbir__horizontal_gather_n_coeffs_funcs =
[
    null, 
    stbir__horizontal_gather_N_channels_with_n_coeffs_funcs!stbir_horz_helper_1ch.ptr, 
    stbir__horizontal_gather_N_channels_with_n_coeffs_funcs!stbir_horz_helper_2ch.ptr, 
    stbir__horizontal_gather_N_channels_with_n_coeffs_funcs!stbir_horz_helper_3ch.ptr, 
    stbir__horizontal_gather_N_channels_with_n_coeffs_funcs!stbir_horz_helper_4ch.ptr, 
    null,
    null, 
    stbir__horizontal_gather_N_channels_with_n_coeffs_funcs!stbir_horz_helper_7ch.ptr
];

static immutable stbir__horizontal_gather_channels_func[][8] stbir__horizontal_gather_channels_funcs =
[
    null, 
    stbir__horizontal_gather_N_channels_funcs!stbir_horz_helper_1ch, 
    stbir__horizontal_gather_N_channels_funcs!stbir_horz_helper_2ch,
    stbir__horizontal_gather_N_channels_funcs!stbir_horz_helper_3ch,
    stbir__horizontal_gather_N_channels_funcs!stbir_horz_helper_4ch,
    null,
    null, 
    stbir__horizontal_gather_N_channels_funcs!stbir_horz_helper_7ch
];




//=================
// Do 1 channel horizontal routine


enum stbir_horz_helper_1ch = stbir_horz_helper
(
    1,

    // stbir__1_coeff_only
    `stbir__simdf tot,c;
    STBIR_SIMD_NO_UNROLL(decode);
    stbir__simdf_load1( c, hc );
    stbir__simdf_mult1_mem( tot, c, decode );`,

    // stbir__2_coeff_only
    `stbir__simdf tot,c,d;
    STBIR_SIMD_NO_UNROLL(decode);
    stbir__simdf_load2z( c, hc );
    stbir__simdf_load2( d, decode );
    stbir__simdf_mult( tot, c, d );
    stbir__simdf_0123to1230( c, tot );
    stbir__simdf_add1( tot, tot, c );`,

    // stbir__3_coeff_only
    `stbir__simdf tot,c,t;
    STBIR_SIMD_NO_UNROLL(decode);
    stbir__simdf_load( c, hc );
    stbir__simdf_mult_mem( tot, c, decode );
    stbir__simdf_0123to1230( c, tot );
    stbir__simdf_0123to2301( t, tot );
    stbir__simdf_add1( tot, tot, c );
    stbir__simdf_add1( tot, tot, t );`,

    // stbir__store_output_tiny
    `stbir__simdf_store1( output, tot );
    horizontal_coefficients += coefficient_width;
    ++horizontal_contributors;
    output += 1;`,

     // stbir__4_coeff_start
    `stbir__simdf tot,c;
    STBIR_SIMD_NO_UNROLL(decode);
    stbir__simdf_load( c, hc );
    stbir__simdf_mult_mem( tot, c, decode );`,

    // stbir__4_coeff_continue_from_4
    `STBIR_SIMD_NO_UNROLL(decode);
    stbir__simdf_load( c, hc + (ofs) );
    stbir__simdf_madd_mem( tot, tot, c, decode+(ofs) );`,

    // stbir__1_coeff_remnant
    `{ stbir__simdf d;
    stbir__simdf_load1z( c, hc + (ofs) );
    stbir__simdf_load1( d, decode + (ofs) );
    stbir__simdf_madd( tot, tot, d, c ); }`,

    // stbir__2_coeff_remnant
    `{ stbir__simdf d;
    stbir__simdf_load2z( c, hc+(ofs) );
    stbir__simdf_load2( d, decode+(ofs) );
    stbir__simdf_madd( tot, tot, d, c ); }`,

    // stbir__3_coeff_setup
    `stbir__simdf mask;
    stbir__simdf_load( mask, STBIR_mask.ptr + 3 );`,

    // stbir__3_coeff_remnant
    `stbir__simdf_load( c, hc+(ofs) );
    stbir__simdf_and( c, c, mask );
    stbir__simdf_madd_mem( tot, tot, c, decode+(ofs) );`,

    // stbir__store_output
    `stbir__simdf_0123to2301( c, tot );
    stbir__simdf_add( tot, tot, c );
    stbir__simdf_0123to1230( c, tot );
    stbir__simdf_add1( tot, tot, c );
    stbir__simdf_store1( output, tot );
    horizontal_coefficients += coefficient_width;
    ++horizontal_contributors;
    output += 1;`
);

//=================
// Do 2 channel horizontal routines

enum stbir_horz_helper_2ch = stbir_horz_helper
(
    2,

    // stbir__1_coeff_only
    `stbir__simdf tot,c,d;             
    STBIR_SIMD_NO_UNROLL(decode);     
    stbir__simdf_load1z( c, hc );     
    stbir__simdf_0123to0011( c, c );  
    stbir__simdf_load2( d, decode );  
    stbir__simdf_mult( tot, d, c );`,


    // stbir__2_coeff_only
    `stbir__simdf tot,c;               
    STBIR_SIMD_NO_UNROLL(decode);     
    stbir__simdf_load2( c, hc );      
    stbir__simdf_0123to0011( c, c );  
    stbir__simdf_mult_mem( tot, c, decode );`,

    // stbir__3_coeff_only
    `stbir__simdf tot,c,cs,d;                 
    STBIR_SIMD_NO_UNROLL(decode);            
    stbir__simdf_load( cs, hc );             
    stbir__simdf_0123to0011( c, cs );        
    stbir__simdf_mult_mem( tot, c, decode ); 
    stbir__simdf_0123to2222( c, cs );        
    stbir__simdf_load2z( d, decode+4 );      
    stbir__simdf_madd( tot, tot, d, c );`,

    // stbir__store_output_tiny
    `stbir__simdf_0123to2301( c, tot );            
    stbir__simdf_add( tot, tot, c );              
    stbir__simdf_store2( output, tot );           
    horizontal_coefficients += coefficient_width; 
    ++horizontal_contributors;                    
    output += 2;`,

    // stbir__4_coeff_start
    `stbir__simdf8 tot0,c,cs;                      
    STBIR_SIMD_NO_UNROLL(decode);                 
    stbir__simdf8_load4b( cs, hc );               
    stbir__simdf8_0123to00112233( c, cs );        
    stbir__simdf8_mult_mem( tot0, c, decode );`,

    // stbir__4_coeff_continue_from_4
    `STBIR_SIMD_NO_UNROLL(decode);                    
    stbir__simdf8_load4b( cs, hc + (ofs) );          
    stbir__simdf8_0123to00112233( c, cs );           
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*2 );`,

    // stbir__1_coeff_remnant
    `{ stbir__simdf t;                                
    stbir__simdf_load1z( t, hc + (ofs) );            
    stbir__simdf_0123to0011( t, t );                 
    stbir__simdf_mult_mem( t, t, decode+(ofs)*2 );   
    stbir__simdf8_add4( tot0, tot0, t ); }`,

    // stbir__2_coeff_remnant
    `{ stbir__simdf t;                                
    stbir__simdf_load2( t, hc + (ofs) );             
    stbir__simdf_0123to0011( t, t );                 
    stbir__simdf_mult_mem( t, t, decode+(ofs)*2 );   
    stbir__simdf8_add4( tot0, tot0, t ); }`,


    // stbir__3_coeff_setup
    ``,

    // stbir__3_coeff_remnant
    `{ stbir__simdf8 d;                               
    stbir__simdf8_load4b( cs, hc + (ofs) );          
    stbir__simdf8_0123to00112233( c, cs );           
    stbir__simdf8_load6z( d, decode+(ofs)*2 );       
    stbir__simdf8_madd( tot0, tot0, c, d ); }`,

    // stbir__store_output
    `{ stbir__simdf t,d;                           
    stbir__simdf8_add4halves( t, stbir__if_simdf8_cast_to_simdf4(tot0), tot0 );    
    stbir__simdf_0123to2301( d, t );              
    stbir__simdf_add( t, t, d );                  
    stbir__simdf_store2( output, t );             
    horizontal_coefficients += coefficient_width; 
    ++horizontal_contributors;                    
    output += 2; }`
 );



//=================
// Do 3 channel horizontal routines

enum stbir_horz_helper_3ch = stbir_horz_helper
(
    3,

    // stbir__1_coeff_only
    `stbir__simdf tot,c,d;             
    STBIR_SIMD_NO_UNROLL(decode);     
    stbir__simdf_load1z( c, hc );     
    stbir__simdf_0123to0001( c, c );  
    stbir__simdf_load( d, decode );   
    stbir__simdf_mult( tot, d, c );`,


    // stbir__2_coeff_only
    `stbir__simdf tot,c,cs,d;          
    STBIR_SIMD_NO_UNROLL(decode);     
    stbir__simdf_load2( cs, hc );     
    stbir__simdf_0123to0000( c, cs ); 
    stbir__simdf_load( d, decode );   
    stbir__simdf_mult( tot, d, c );   
    stbir__simdf_0123to1111( c, cs ); 
    stbir__simdf_load( d, decode+3 ); 
    stbir__simdf_madd( tot, tot, d, c );`,

    // stbir__3_coeff_only
    `stbir__simdf tot,c,d,cs;             
    STBIR_SIMD_NO_UNROLL(decode);        
    stbir__simdf_load( cs, hc );         
    stbir__simdf_0123to0000( c, cs );    
    stbir__simdf_load( d, decode );      
    stbir__simdf_mult( tot, d, c );      
    stbir__simdf_0123to1111( c, cs );    
    stbir__simdf_load( d, decode+3 );    
    stbir__simdf_madd( tot, tot, d, c ); 
    stbir__simdf_0123to2222( c, cs );    
    stbir__simdf_load( d, decode+6 );    
    stbir__simdf_madd( tot, tot, d, c );`,

    // stbir__store_output_tiny
    `stbir__simdf_store2( output, tot );           
    stbir__simdf_0123to2301( tot, tot );          
    stbir__simdf_store1( output+2, tot );         
    horizontal_coefficients += coefficient_width; 
    ++horizontal_contributors;                    
    output += 3;`,

    // we're loading from the XXXYYY decode by -1 to get the XXXYYY into different halves of the AVX reg fyi

    // stbir__4_coeff_start
    `stbir__simdf8 tot0,tot1,c,cs; stbir__simdf t;  
    STBIR_SIMD_NO_UNROLL(decode);                  
    stbir__simdf8_load4b( cs, hc );                
    stbir__simdf8_0123to00001111( c, cs );         
    stbir__simdf8_mult_mem( tot0, c, decode - 1 ); 
    stbir__simdf8_0123to22223333( c, cs );         
    stbir__simdf8_mult_mem( tot1, c, decode+6 - 1 );`,


    // stbir__4_coeff_continue_from_4
    `STBIR_SIMD_NO_UNROLL(decode);                  
    stbir__simdf8_load4b( cs, hc + (ofs) );        
    stbir__simdf8_0123to00001111( c, cs );         
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*3 - 1 ); 
    stbir__simdf8_0123to22223333( c, cs );         
    stbir__simdf8_madd_mem( tot1, tot1, c, decode+(ofs)*3 + 6 - 1 );`,

    // stbir__1_coeff_remnant
    `STBIR_SIMD_NO_UNROLL(decode);                              
    stbir__simdf_load1rep4( t, hc + (ofs) );                   
    stbir__simdf8_madd_mem4( tot0, tot0, t, decode+(ofs)*3 - 1 );`,

    // stbir__2_coeff_remnant
    `STBIR_SIMD_NO_UNROLL(decode);                              
    stbir__simdf8_load4b( cs, hc + (ofs) - 2 );                
    stbir__simdf8_0123to22223333( c, cs );                     
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*3 - 1 );`,

    // stbir__3_coeff_setup
    ``,

    // stbir__3_coeff_remnant
    `STBIR_SIMD_NO_UNROLL(decode);                                
    stbir__simdf8_load4b( cs, hc + (ofs) );                      
    stbir__simdf8_0123to00001111( c, cs );                       
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*3 - 1 ); 
    stbir__simdf8_0123to2222( t, cs );                           
    stbir__simdf8_madd_mem4( tot1, tot1, t, decode+(ofs)*3 + 6 - 1 );`,

    // stbir__store_output
    `stbir__simdf8_add( tot0, tot0, tot1 );          
    stbir__simdf_0123to1230( t, stbir__if_simdf8_cast_to_simdf4( tot0 ) ); 
    stbir__simdf8_add4halves( t, t, tot0 );         
    horizontal_coefficients += coefficient_width;   
    ++horizontal_contributors;                      
    output += 3;                                    
    if ( output < output_end )                      
    {                                               
    stbir__simdf_store( output-3, t );            
    continue;                                     
    }                                               
    { stbir__simdf tt; stbir__simdf_0123to2301( tt, t ); 
    stbir__simdf_store2( output-3, t );             
    stbir__simdf_store1( output+2-3, tt ); }        
    break;`
 );


//=================
// Do 4 channel horizontal routines

enum stbir_horz_helper_4ch = stbir_horz_helper
(
    4,

    // stbir__1_coeff_only
    `stbir__simdf tot,c;                   
    STBIR_SIMD_NO_UNROLL(decode);         
    stbir__simdf_load1( c, hc );          
    stbir__simdf_0123to0000( c, c );      
    stbir__simdf_mult_mem( tot, c, decode );`,


    // stbir__2_coeff_only
    `stbir__simdf tot,c,cs;                          
    STBIR_SIMD_NO_UNROLL(decode);                   
    stbir__simdf_load2( cs, hc );                   
    stbir__simdf_0123to0000( c, cs );               
    stbir__simdf_mult_mem( tot, c, decode );        
    stbir__simdf_0123to1111( c, cs );               
    stbir__simdf_madd_mem( tot, tot, c, decode+4 );`,

    // stbir__3_coeff_only
    `stbir__simdf tot,c,cs;                          
    STBIR_SIMD_NO_UNROLL(decode);                   
    stbir__simdf_load( cs, hc );                    
    stbir__simdf_0123to0000( c, cs );               
    stbir__simdf_mult_mem( tot, c, decode );        
    stbir__simdf_0123to1111( c, cs );               
    stbir__simdf_madd_mem( tot, tot, c, decode+4 ); 
    stbir__simdf_0123to2222( c, cs );               
    stbir__simdf_madd_mem( tot, tot, c, decode+8 );`,

    // stbir__store_output_tiny
    `stbir__simdf_store( output, tot );            
    horizontal_coefficients += coefficient_width; 
    ++horizontal_contributors;                    
    output += 4;`,

    // stbir__4_coeff_start
    `stbir__simdf8 tot0,c,cs; stbir__simdf t;  
    STBIR_SIMD_NO_UNROLL(decode);                  
    stbir__simdf8_load4b( cs, hc );                
    stbir__simdf8_0123to00001111( c, cs );         
    stbir__simdf8_mult_mem( tot0, c, decode );     
    stbir__simdf8_0123to22223333( c, cs );         
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+8 );`,


    // stbir__4_coeff_continue_from_4
    `STBIR_SIMD_NO_UNROLL(decode);                              
    stbir__simdf8_load4b( cs, hc + (ofs) );                    
    stbir__simdf8_0123to00001111( c, cs );                     
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*4 );   
    stbir__simdf8_0123to22223333( c, cs );                     
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*4+8 );`,


    // stbir__1_coeff_remnant
    `STBIR_SIMD_NO_UNROLL(decode);                              
    stbir__simdf_load1rep4( t, hc + (ofs) );                   
    stbir__simdf8_madd_mem4( tot0, tot0, t, decode+(ofs)*4 );`,


    // stbir__2_coeff_remnant
    `STBIR_SIMD_NO_UNROLL(decode);                              
    stbir__simdf8_load4b( cs, hc + (ofs) - 2 );                
    stbir__simdf8_0123to22223333( c, cs );                     
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*4 );`,


    // stbir__3_coeff_setup
    "",

    // stbir__3_coeff_remnant
    `STBIR_SIMD_NO_UNROLL(decode);                              
    stbir__simdf8_load4b( cs, hc + (ofs) );                    
    stbir__simdf8_0123to00001111( c, cs );                     
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*4 );   
    stbir__simdf8_0123to2222( t, cs );                         
    stbir__simdf8_madd_mem4( tot0, tot0, t, decode+(ofs)*4+8 );`,

    // stbir__store_output
    `stbir__simdf8_add4halves( t, stbir__if_simdf8_cast_to_simdf4(tot0), tot0 );     
    stbir__simdf_store( output, t );               
    horizontal_coefficients += coefficient_width;  
    ++horizontal_contributors;                     
    output += 4;`,
 );


//=================
// Do 7 channel horizontal routines

enum stbir_horz_helper_7ch = stbir_horz_helper
(
    7,

    `stbir__simdf tot0,tot1,c;                   
    STBIR_SIMD_NO_UNROLL(decode);               
    stbir__simdf_load1( c, hc );                
    stbir__simdf_0123to0000( c, c );            
    stbir__simdf_mult_mem( tot0, c, decode );   
    stbir__simdf_mult_mem( tot1, c, decode+3 );`,

    `stbir__simdf tot0,tot1,c,cs;                      
    STBIR_SIMD_NO_UNROLL(decode);                     
    stbir__simdf_load2( cs, hc );                     
    stbir__simdf_0123to0000( c, cs );                 
    stbir__simdf_mult_mem( tot0, c, decode );         
    stbir__simdf_mult_mem( tot1, c, decode+3 );       
    stbir__simdf_0123to1111( c, cs );                 
    stbir__simdf_madd_mem( tot0, tot0, c, decode+7 ); 
    stbir__simdf_madd_mem( tot1, tot1, c,decode+10 );`,

    `stbir__simdf tot0,tot1,c,cs;                        
    STBIR_SIMD_NO_UNROLL(decode);                       
    stbir__simdf_load( cs, hc );                        
    stbir__simdf_0123to0000( c, cs );                   
    stbir__simdf_mult_mem( tot0, c, decode );           
    stbir__simdf_mult_mem( tot1, c, decode+3 );         
    stbir__simdf_0123to1111( c, cs );                   
    stbir__simdf_madd_mem( tot0, tot0, c, decode+7 );   
    stbir__simdf_madd_mem( tot1, tot1, c, decode+10 );  
    stbir__simdf_0123to2222( c, cs );                   
    stbir__simdf_madd_mem( tot0, tot0, c, decode+14 );  
    stbir__simdf_madd_mem( tot1, tot1, c, decode+17 );`,

    `stbir__simdf_store( output+3, tot1 );         
    stbir__simdf_store( output, tot0 );           
    horizontal_coefficients += coefficient_width; 
    ++horizontal_contributors;                    
    output += 7;`,

    `stbir__simdf8 tot0,tot1,c,cs;                  
    STBIR_SIMD_NO_UNROLL(decode);                  
    stbir__simdf8_load4b( cs, hc );                
    stbir__simdf8_0123to00000000( c, cs );         
    stbir__simdf8_mult_mem( tot0, c, decode );     
    stbir__simdf8_0123to11111111( c, cs );         
    stbir__simdf8_mult_mem( tot1, c, decode+7 );   
    stbir__simdf8_0123to22222222( c, cs );         
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+14 );  
    stbir__simdf8_0123to33333333( c, cs );         
    stbir__simdf8_madd_mem( tot1, tot1, c, decode+21 );`,

    `STBIR_SIMD_NO_UNROLL(decode);                               
    stbir__simdf8_load4b( cs, hc + (ofs) );                     
    stbir__simdf8_0123to00000000( c, cs );                      
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*7 );    
    stbir__simdf8_0123to11111111( c, cs );                      
    stbir__simdf8_madd_mem( tot1, tot1, c, decode+(ofs)*7+7 );  
    stbir__simdf8_0123to22222222( c, cs );                      
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*7+14 ); 
    stbir__simdf8_0123to33333333( c, cs );                      
    stbir__simdf8_madd_mem( tot1, tot1, c, decode+(ofs)*7+21 );`,

    `STBIR_SIMD_NO_UNROLL(decode);                               
    stbir__simdf8_load1b( c, hc + (ofs) );                      
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*7 );`,

    `STBIR_SIMD_NO_UNROLL(decode);                               
    stbir__simdf8_load1b( c, hc + (ofs) );                      
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*7 );    
    stbir__simdf8_load1b( c, hc + (ofs)+1 );                    
    stbir__simdf8_madd_mem( tot1, tot1, c, decode+(ofs)*7+7 );`,

    // stbir__3_coeff_setup
    ``,

    `STBIR_SIMD_NO_UNROLL(decode);                               
    stbir__simdf8_load4b( cs, hc + (ofs) );                     
    stbir__simdf8_0123to00000000( c, cs );                      
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*7 );    
    stbir__simdf8_0123to11111111( c, cs );                      
    stbir__simdf8_madd_mem( tot1, tot1, c, decode+(ofs)*7+7 );  
    stbir__simdf8_0123to22222222( c, cs );                      
    stbir__simdf8_madd_mem( tot0, tot0, c, decode+(ofs)*7+14 );`,

    `stbir__simdf8_add( tot0, tot0, tot1 );        
    horizontal_coefficients += coefficient_width; 
    ++horizontal_contributors;                    
    output += 7;                                  
    if ( output < output_end )                    
    {                                             
    stbir__simdf8_store( output-7, tot0 );      
    continue;                                   
    }                                             
    stbir__simdf_store( output-7+3, stbir__simdf_swiz!(0,0,1,2)(stbir__simdf8_gettop4(tot0)) ); 
    stbir__simdf_store( output-7, stbir__if_simdf8_cast_to_simdf4(tot0) );           
    break;`,
 );
