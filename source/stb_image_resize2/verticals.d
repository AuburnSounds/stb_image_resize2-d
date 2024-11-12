module stb_image_resize2.verticals;

nothrow @nogc @system:

import stb_image_resize2.types;
import stb_image_resize2.simd;


static if (hasRestrict)
    import core.attribute: restrict;
else
    enum restrict = 0;

// include all of the vertical resamplers (both scatter and gather versions)


alias STBIR_VERTICAL_GATHERFUNC = void function(float * output, 
                                                const(float)* coeffs, 
                                                const(float)** inputs, 
                                                const(float)* input0_end );

static immutable STBIR_VERTICAL_GATHERFUNC[8] stbir__vertical_gathers =
[
    &stbir__vertical_gather_with_1_coeffs,
    &stbir__vertical_gather_with_2_coeffs,
    &stbir__vertical_gather_with_3_coeffs,
    &stbir__vertical_gather_with_4_coeffs,
    &stbir__vertical_gather_with_5_coeffs,
    &stbir__vertical_gather_with_6_coeffs,
    &stbir__vertical_gather_with_7_coeffs,
    &stbir__vertical_gather_with_8_coeffs
];

static immutable STBIR_VERTICAL_GATHERFUNC[8] stbir__vertical_gathers_continues =
[
    &stbir__vertical_gather_with_1_coeffs_cont,
    &stbir__vertical_gather_with_2_coeffs_cont,
    &stbir__vertical_gather_with_3_coeffs_cont,
    &stbir__vertical_gather_with_4_coeffs_cont,
    &stbir__vertical_gather_with_5_coeffs_cont,
    &stbir__vertical_gather_with_6_coeffs_cont,
    &stbir__vertical_gather_with_7_coeffs_cont,
    &stbir__vertical_gather_with_8_coeffs_cont
];

alias STBIR_VERTICAL_SCATTERFUNC = void function(float ** output, 
                                                 const(float)* coeffs, 
                                                 const(float)* inputs, 
                                                 const(float)* input_end );

static immutable STBIR_VERTICAL_SCATTERFUNC[8] stbir__vertical_scatter_sets =
[
    &stbir__vertical_scatter_with_1_coeffs,
    &stbir__vertical_scatter_with_2_coeffs,
    &stbir__vertical_scatter_with_3_coeffs,
    &stbir__vertical_scatter_with_4_coeffs,
    &stbir__vertical_scatter_with_5_coeffs,
    &stbir__vertical_scatter_with_6_coeffs,
    &stbir__vertical_scatter_with_7_coeffs,
    &stbir__vertical_scatter_with_8_coeffs
];

static immutable STBIR_VERTICAL_SCATTERFUNC[8] stbir__vertical_scatter_blends =
[
    &stbir__vertical_scatter_with_1_coeffs_cont,
    &stbir__vertical_scatter_with_2_coeffs_cont,
    &stbir__vertical_scatter_with_3_coeffs_cont,
    &stbir__vertical_scatter_with_4_coeffs_cont,
    &stbir__vertical_scatter_with_5_coeffs_cont,
    &stbir__vertical_scatter_with_6_coeffs_cont,
    &stbir__vertical_scatter_with_7_coeffs_cont,
    &stbir__vertical_scatter_with_8_coeffs_cont
];




struct stbir_vert_helper
{
    int STBIR__vertical_channels;
    bool STB_IMAGE_RESIZE_VERTICAL_CONTINUE = false;

    alias ch = STBIR__vertical_channels;
}

alias stbir__vertical_scatter_with_1_coeffs = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(1));
alias stbir__vertical_scatter_with_1_coeffs_cont = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(1, true));
alias stbir__vertical_scatter_with_2_coeffs = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(2));
alias stbir__vertical_scatter_with_2_coeffs_cont = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(2, true));
alias stbir__vertical_scatter_with_3_coeffs = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(3));
alias stbir__vertical_scatter_with_3_coeffs_cont = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(3, true));
alias stbir__vertical_scatter_with_4_coeffs = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(4));
alias stbir__vertical_scatter_with_4_coeffs_cont = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(4, true));
alias stbir__vertical_scatter_with_5_coeffs = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(5));
alias stbir__vertical_scatter_with_5_coeffs_cont = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(5, true));
alias stbir__vertical_scatter_with_6_coeffs = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(6));
alias stbir__vertical_scatter_with_6_coeffs_cont = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(6, true));
alias stbir__vertical_scatter_with_7_coeffs = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(7));
alias stbir__vertical_scatter_with_7_coeffs_cont = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(7, true));
alias stbir__vertical_scatter_with_8_coeffs = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(8));
alias stbir__vertical_scatter_with_8_coeffs_cont = stbir__vertical_scatter_with_N_coeffs!(stbir_vert_helper(8, true));

void stbir__vertical_scatter_with_N_coeffs(stbir_vert_helper H)(float ** outputs, 
                                              const(float)* vertical_coefficients, 
                                              const(float)* input, 
                                              const(float)* input_end )
@system
{
    enum CH = H.ch;
    static if (CH>=1) { float* output0 = outputs[0]; float c0s = vertical_coefficients[0]; }
    static if (CH>=2) { float* output1 = outputs[1]; float c1s = vertical_coefficients[1]; }
    static if (CH>=3) { float* output2 = outputs[2]; float c2s = vertical_coefficients[2]; }
    static if (CH>=4) { float* output3 = outputs[3]; float c3s = vertical_coefficients[3]; }
    static if (CH>=5) { float* output4 = outputs[4]; float c4s = vertical_coefficients[4]; }
    static if (CH>=6) { float* output5 = outputs[5]; float c5s = vertical_coefficients[5]; }
    static if (CH>=7) { float* output6 = outputs[6]; float c6s = vertical_coefficients[6]; }
    static if (CH>=8) { float* output7 = outputs[7]; float c7s = vertical_coefficients[7]; }

    static if (true) // SIMD there or not...
    {
        static if (CH>=1){ stbir__simdfX c0 = stbir__simdf_frepX( c0s ); }
        static if (CH>=2){ stbir__simdfX c1 = stbir__simdf_frepX( c1s ); }
        static if (CH>=3){ stbir__simdfX c2 = stbir__simdf_frepX( c2s ); }
        static if (CH>=4){ stbir__simdfX c3 = stbir__simdf_frepX( c3s ); }
        static if (CH>=5){ stbir__simdfX c4 = stbir__simdf_frepX( c4s ); }
        static if (CH>=6){ stbir__simdfX c5 = stbir__simdf_frepX( c5s ); }
        static if (CH>=7){ stbir__simdfX c6 = stbir__simdf_frepX( c6s ); }
        static if (CH>=8){ stbir__simdfX c7 = stbir__simdf_frepX( c7s ); }

        while ( ( cast(char*)input_end - cast(char*) input ) >= (16*stbir__simdfX_float_count) )
        {
            stbir__simdfX o0, o1, o2, o3, r0, r1, r2, r3;
            STBIR_SIMD_NO_UNROLL(output0);

            stbir__simdfX_load( r0, input );               stbir__simdfX_load( r1, input+stbir__simdfX_float_count );     stbir__simdfX_load( r2, input+(2*stbir__simdfX_float_count) );      stbir__simdfX_load( r3, input+(3*stbir__simdfX_float_count) );

            static if (H.STB_IMAGE_RESIZE_VERTICAL_CONTINUE)
            {
                static if (CH>=1){ stbir__simdfX_load( o0, output0 );     stbir__simdfX_load( o1, output0+stbir__simdfX_float_count );   stbir__simdfX_load( o2, output0+(2*stbir__simdfX_float_count) );    stbir__simdfX_load( o3, output0+(3*stbir__simdfX_float_count) );
                        stbir__simdfX_madd( o0, o0, r0, c0 );  stbir__simdfX_madd( o1, o1, r1, c0 );  stbir__simdfX_madd( o2, o2, r2, c0 );   stbir__simdfX_madd( o3, o3, r3, c0 );
                        stbir__simdfX_store( output0, o0 );    stbir__simdfX_store( output0+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output0+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output0+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=2){ stbir__simdfX_load( o0, output1 );     stbir__simdfX_load( o1, output1+stbir__simdfX_float_count );   stbir__simdfX_load( o2, output1+(2*stbir__simdfX_float_count) );    stbir__simdfX_load( o3, output1+(3*stbir__simdfX_float_count) );
                        stbir__simdfX_madd( o0, o0, r0, c1 );  stbir__simdfX_madd( o1, o1, r1, c1 );  stbir__simdfX_madd( o2, o2, r2, c1 );   stbir__simdfX_madd( o3, o3, r3, c1 );
                        stbir__simdfX_store( output1, o0 );    stbir__simdfX_store( output1+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output1+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output1+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=3){ stbir__simdfX_load( o0, output2 );     stbir__simdfX_load( o1, output2+stbir__simdfX_float_count );   stbir__simdfX_load( o2, output2+(2*stbir__simdfX_float_count) );    stbir__simdfX_load( o3, output2+(3*stbir__simdfX_float_count) );
                        stbir__simdfX_madd( o0, o0, r0, c2 );  stbir__simdfX_madd( o1, o1, r1, c2 );  stbir__simdfX_madd( o2, o2, r2, c2 );   stbir__simdfX_madd( o3, o3, r3, c2 );
                        stbir__simdfX_store( output2, o0 );    stbir__simdfX_store( output2+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output2+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output2+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=4){ stbir__simdfX_load( o0, output3 );     stbir__simdfX_load( o1, output3+stbir__simdfX_float_count );   stbir__simdfX_load( o2, output3+(2*stbir__simdfX_float_count) );    stbir__simdfX_load( o3, output3+(3*stbir__simdfX_float_count) );
                        stbir__simdfX_madd( o0, o0, r0, c3 );  stbir__simdfX_madd( o1, o1, r1, c3 );  stbir__simdfX_madd( o2, o2, r2, c3 );   stbir__simdfX_madd( o3, o3, r3, c3 );
                        stbir__simdfX_store( output3, o0 );    stbir__simdfX_store( output3+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output3+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output3+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=5){ stbir__simdfX_load( o0, output4 );     stbir__simdfX_load( o1, output4+stbir__simdfX_float_count );   stbir__simdfX_load( o2, output4+(2*stbir__simdfX_float_count) );    stbir__simdfX_load( o3, output4+(3*stbir__simdfX_float_count) );
                        stbir__simdfX_madd( o0, o0, r0, c4 );  stbir__simdfX_madd( o1, o1, r1, c4 );  stbir__simdfX_madd( o2, o2, r2, c4 );   stbir__simdfX_madd( o3, o3, r3, c4 );
                        stbir__simdfX_store( output4, o0 );    stbir__simdfX_store( output4+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output4+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output4+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=6){ stbir__simdfX_load( o0, output5 );     stbir__simdfX_load( o1, output5+stbir__simdfX_float_count );   stbir__simdfX_load( o2, output5+(2*stbir__simdfX_float_count));    stbir__simdfX_load( o3, output5+(3*stbir__simdfX_float_count) );
                        stbir__simdfX_madd( o0, o0, r0, c5 );  stbir__simdfX_madd( o1, o1, r1, c5 );  stbir__simdfX_madd( o2, o2, r2, c5 );   stbir__simdfX_madd( o3, o3, r3, c5 );
                        stbir__simdfX_store( output5, o0 );    stbir__simdfX_store( output5+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output5+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output5+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=7){ stbir__simdfX_load( o0, output6 );     stbir__simdfX_load( o1, output6+stbir__simdfX_float_count );   stbir__simdfX_load( o2, output6+(2*stbir__simdfX_float_count) );    stbir__simdfX_load( o3, output6+(3*stbir__simdfX_float_count) );
                        stbir__simdfX_madd( o0, o0, r0, c6 );  stbir__simdfX_madd( o1, o1, r1, c6 );  stbir__simdfX_madd( o2, o2, r2, c6 );   stbir__simdfX_madd( o3, o3, r3, c6 );
                        stbir__simdfX_store( output6, o0 );    stbir__simdfX_store( output6+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output6+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output6+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=8){ stbir__simdfX_load( o0, output7 );     stbir__simdfX_load( o1, output7+stbir__simdfX_float_count );   stbir__simdfX_load( o2, output7+(2*stbir__simdfX_float_count) );    stbir__simdfX_load( o3, output7+(3*stbir__simdfX_float_count) );
                        stbir__simdfX_madd( o0, o0, r0, c7 );  stbir__simdfX_madd( o1, o1, r1, c7 );  stbir__simdfX_madd( o2, o2, r2, c7 );   stbir__simdfX_madd( o3, o3, r3, c7 );
                        stbir__simdfX_store( output7, o0 );    stbir__simdfX_store( output7+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output7+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output7+(3*stbir__simdfX_float_count), o3 ); }
            }
            else
            {
                static if (CH>=1){ stbir__simdfX_mult( o0, r0, c0 );      stbir__simdfX_mult( o1, r1, c0 );      stbir__simdfX_mult( o2, r2, c0 );       stbir__simdfX_mult( o3, r3, c0 );
                        stbir__simdfX_store( output0, o0 );    stbir__simdfX_store( output0+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output0+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output0+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=2){ stbir__simdfX_mult( o0, r0, c1 );      stbir__simdfX_mult( o1, r1, c1 );      stbir__simdfX_mult( o2, r2, c1 );       stbir__simdfX_mult( o3, r3, c1 );
                        stbir__simdfX_store( output1, o0 );    stbir__simdfX_store( output1+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output1+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output1+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=3){ stbir__simdfX_mult( o0, r0, c2 );      stbir__simdfX_mult( o1, r1, c2 );      stbir__simdfX_mult( o2, r2, c2 );       stbir__simdfX_mult( o3, r3, c2 );
                        stbir__simdfX_store( output2, o0 );    stbir__simdfX_store( output2+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output2+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output2+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=4){ stbir__simdfX_mult( o0, r0, c3 );      stbir__simdfX_mult( o1, r1, c3 );      stbir__simdfX_mult( o2, r2, c3 );       stbir__simdfX_mult( o3, r3, c3 );
                        stbir__simdfX_store( output3, o0 );    stbir__simdfX_store( output3+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output3+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output3+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=5){ stbir__simdfX_mult( o0, r0, c4 );      stbir__simdfX_mult( o1, r1, c4 );      stbir__simdfX_mult( o2, r2, c4 );       stbir__simdfX_mult( o3, r3, c4 );
                        stbir__simdfX_store( output4, o0 );    stbir__simdfX_store( output4+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output4+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output4+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=6){ stbir__simdfX_mult( o0, r0, c5 );      stbir__simdfX_mult( o1, r1, c5 );      stbir__simdfX_mult( o2, r2, c5 );       stbir__simdfX_mult( o3, r3, c5 );
                        stbir__simdfX_store( output5, o0 );    stbir__simdfX_store( output5+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output5+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output5+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=7){ stbir__simdfX_mult( o0, r0, c6 );      stbir__simdfX_mult( o1, r1, c6 );      stbir__simdfX_mult( o2, r2, c6 );       stbir__simdfX_mult( o3, r3, c6 );
                        stbir__simdfX_store( output6, o0 );    stbir__simdfX_store( output6+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output6+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output6+(3*stbir__simdfX_float_count), o3 ); }
                static if (CH>=8){ stbir__simdfX_mult( o0, r0, c7 );      stbir__simdfX_mult( o1, r1, c7 );      stbir__simdfX_mult( o2, r2, c7 );       stbir__simdfX_mult( o3, r3, c7 );
                        stbir__simdfX_store( output7, o0 );    stbir__simdfX_store( output7+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output7+(2*stbir__simdfX_float_count), o2 );   stbir__simdfX_store( output7+(3*stbir__simdfX_float_count), o3 ); }
            }

            input += (4*stbir__simdfX_float_count);
            static if (CH>=1){ output0 += (4*stbir__simdfX_float_count); } 
            static if (CH>=2){ output1 += (4*stbir__simdfX_float_count); } 
            static if (CH>=3){ output2 += (4*stbir__simdfX_float_count); } 
            static if (CH>=4){ output3 += (4*stbir__simdfX_float_count); } 
            static if (CH>=5){ output4 += (4*stbir__simdfX_float_count); } 
            static if (CH>=6){ output5 += (4*stbir__simdfX_float_count); } 
            static if (CH>=7){ output6 += (4*stbir__simdfX_float_count); } 
            static if (CH>=8){ output7 += (4*stbir__simdfX_float_count); }
        }

        while ( ( cast(char*)input_end - cast(char*) input ) >= 16 )
        {
            stbir__simdf o0, r0;
            STBIR_SIMD_NO_UNROLL(output0);

            stbir__simdf_load( r0, input );

            static if (H.STB_IMAGE_RESIZE_VERTICAL_CONTINUE)
            {
                static if (CH>=1){ stbir__simdf_load( o0, output0 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c0 ) );  stbir__simdf_store( output0, o0 ); }
                static if (CH>=2){ stbir__simdf_load( o0, output1 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c1 ) );  stbir__simdf_store( output1, o0 ); }
                static if (CH>=3){ stbir__simdf_load( o0, output2 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c2 ) );  stbir__simdf_store( output2, o0 ); }
                static if (CH>=4){ stbir__simdf_load( o0, output3 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c3 ) );  stbir__simdf_store( output3, o0 ); }
                static if (CH>=5){ stbir__simdf_load( o0, output4 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c4 ) );  stbir__simdf_store( output4, o0 ); }
                static if (CH>=6){ stbir__simdf_load( o0, output5 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c5 ) );  stbir__simdf_store( output5, o0 ); }
                static if (CH>=7){ stbir__simdf_load( o0, output6 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c6 ) );  stbir__simdf_store( output6, o0 ); }
                static if (CH>=8){ stbir__simdf_load( o0, output7 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c7 ) );  stbir__simdf_store( output7, o0 ); }
            }
            else
            {
                static if (CH>=1){ stbir__simdf_mult( o0, r0, stbir__if_simdf8_cast_to_simdf4( c0 ) );   stbir__simdf_store( output0, o0 ); }
                static if (CH>=2){ stbir__simdf_mult( o0, r0, stbir__if_simdf8_cast_to_simdf4( c1 ) );   stbir__simdf_store( output1, o0 ); }
                static if (CH>=3){ stbir__simdf_mult( o0, r0, stbir__if_simdf8_cast_to_simdf4( c2 ) );   stbir__simdf_store( output2, o0 ); }
                static if (CH>=4){ stbir__simdf_mult( o0, r0, stbir__if_simdf8_cast_to_simdf4( c3 ) );   stbir__simdf_store( output3, o0 ); }
                static if (CH>=5){ stbir__simdf_mult( o0, r0, stbir__if_simdf8_cast_to_simdf4( c4 ) );   stbir__simdf_store( output4, o0 ); }
                static if (CH>=6){ stbir__simdf_mult( o0, r0, stbir__if_simdf8_cast_to_simdf4( c5 ) );   stbir__simdf_store( output5, o0 ); }
                static if (CH>=7){ stbir__simdf_mult( o0, r0, stbir__if_simdf8_cast_to_simdf4( c6 ) );   stbir__simdf_store( output6, o0 ); }
                static if (CH>=8){ stbir__simdf_mult( o0, r0, stbir__if_simdf8_cast_to_simdf4( c7 ) );   stbir__simdf_store( output7, o0 ); }
            }
            input += 4;
            static if (CH>=1){ output0 += 4; }
            static if (CH>=2){ output1 += 4; }
            static if (CH>=3){ output2 += 4; }
            static if (CH>=4){ output3 += 4; }
            static if (CH>=5){ output4 += 4; }
            static if (CH>=6){ output5 += 4; }
            static if (CH>=7){ output6 += 4; }
            static if (CH>=8){ output7 += 4; }
        }
    } // if SIMD
    else
    {
        while ( ( cast(char*)input_end - cast(char*) input ) >= 16 )
        {
            float r0, r1, r2, r3;
            STBIR_NO_UNROLL(input);
  
            r0 = input[0], r1 = input[1], r2 = input[2], r3 = input[3];
  
            static if (H.STB_IMAGE_RESIZE_VERTICAL_CONTINUE)
            {
                static if (CH>=1){ output0[0] += ( r0 * c0s ); output0[1] += ( r1 * c0s ); output0[2] += ( r2 * c0s ); output0[3] += ( r3 * c0s ); }
                static if (CH>=2){ output1[0] += ( r0 * c1s ); output1[1] += ( r1 * c1s ); output1[2] += ( r2 * c1s ); output1[3] += ( r3 * c1s ); }
                static if (CH>=3){ output2[0] += ( r0 * c2s ); output2[1] += ( r1 * c2s ); output2[2] += ( r2 * c2s ); output2[3] += ( r3 * c2s ); }
                static if (CH>=4){ output3[0] += ( r0 * c3s ); output3[1] += ( r1 * c3s ); output3[2] += ( r2 * c3s ); output3[3] += ( r3 * c3s ); }
                static if (CH>=5){ output4[0] += ( r0 * c4s ); output4[1] += ( r1 * c4s ); output4[2] += ( r2 * c4s ); output4[3] += ( r3 * c4s ); }
                static if (CH>=6){ output5[0] += ( r0 * c5s ); output5[1] += ( r1 * c5s ); output5[2] += ( r2 * c5s ); output5[3] += ( r3 * c5s ); }
                static if (CH>=7){ output6[0] += ( r0 * c6s ); output6[1] += ( r1 * c6s ); output6[2] += ( r2 * c6s ); output6[3] += ( r3 * c6s ); }
                static if (CH>=8){ output7[0] += ( r0 * c7s ); output7[1] += ( r1 * c7s ); output7[2] += ( r2 * c7s ); output7[3] += ( r3 * c7s ); }
            }
            else
            {
                static if (CH>=1){ output0[0]  = ( r0 * c0s ); output0[1]  = ( r1 * c0s ); output0[2]  = ( r2 * c0s ); output0[3]  = ( r3 * c0s ); }
                static if (CH>=2){ output1[0]  = ( r0 * c1s ); output1[1]  = ( r1 * c1s ); output1[2]  = ( r2 * c1s ); output1[3]  = ( r3 * c1s ); }
                static if (CH>=3){ output2[0]  = ( r0 * c2s ); output2[1]  = ( r1 * c2s ); output2[2]  = ( r2 * c2s ); output2[3]  = ( r3 * c2s ); }
                static if (CH>=4){ output3[0]  = ( r0 * c3s ); output3[1]  = ( r1 * c3s ); output3[2]  = ( r2 * c3s ); output3[3]  = ( r3 * c3s ); }
                static if (CH>=5){ output4[0]  = ( r0 * c4s ); output4[1]  = ( r1 * c4s ); output4[2]  = ( r2 * c4s ); output4[3]  = ( r3 * c4s ); }
                static if (CH>=6){ output5[0]  = ( r0 * c5s ); output5[1]  = ( r1 * c5s ); output5[2]  = ( r2 * c5s ); output5[3]  = ( r3 * c5s ); }
                static if (CH>=7){ output6[0]  = ( r0 * c6s ); output6[1]  = ( r1 * c6s ); output6[2]  = ( r2 * c6s ); output6[3]  = ( r3 * c6s ); }
                static if (CH>=8){ output7[0]  = ( r0 * c7s ); output7[1]  = ( r1 * c7s ); output7[2]  = ( r2 * c7s ); output7[3]  = ( r3 * c7s ); }
            }
    
            input += 4;
            static if (CH>=1){ output0 += 4; }
            static if (CH>=2){ output1 += 4; }
            static if (CH>=3){ output2 += 4; }
            static if (CH>=4){ output3 += 4; }
            static if (CH>=5){ output4 += 4; }
            static if (CH>=6){ output5 += 4; }
            static if (CH>=7){ output6 += 4; }
            static if (CH>=8){ output7 += 4; }
        }
    }

    while ( input < input_end )
    {
        float r = input[0];
        STBIR_NO_UNROLL(output0);

        static if (H.STB_IMAGE_RESIZE_VERTICAL_CONTINUE)
        {
            static if (CH>=1){ output0[0] += ( r * c0s ); }
            static if (CH>=2){ output1[0] += ( r * c1s ); }
            static if (CH>=3){ output2[0] += ( r * c2s ); }
            static if (CH>=4){ output3[0] += ( r * c3s ); }
            static if (CH>=5){ output4[0] += ( r * c4s ); }
            static if (CH>=6){ output5[0] += ( r * c5s ); }
            static if (CH>=7){ output6[0] += ( r * c6s ); }
            static if (CH>=8){ output7[0] += ( r * c7s ); }
        }
        else
        {
            static if (CH>=1){ output0[0]  = ( r * c0s ); }
            static if (CH>=2){ output1[0]  = ( r * c1s ); }
            static if (CH>=3){ output2[0]  = ( r * c2s ); }
            static if (CH>=4){ output3[0]  = ( r * c3s ); }
            static if (CH>=5){ output4[0]  = ( r * c4s ); }
            static if (CH>=6){ output5[0]  = ( r * c5s ); }
            static if (CH>=7){ output6[0]  = ( r * c6s ); }
            static if (CH>=8){ output7[0]  = ( r * c7s ); }
        }

        ++input;
        static if (CH>=1){ ++output0; }
        static if (CH>=2){ ++output1; }
        static if (CH>=3){ ++output2; }
        static if (CH>=4){ ++output3; }
        static if (CH>=5){ ++output4; }
        static if (CH>=6){ ++output5; }
        static if (CH>=7){ ++output6; }
        static if (CH>=8){ ++output7; }
    }
}

alias stbir__vertical_gather_with_1_coeffs = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(1));
alias stbir__vertical_gather_with_1_coeffs_cont = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(1, true));
alias stbir__vertical_gather_with_2_coeffs = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(2));
alias stbir__vertical_gather_with_2_coeffs_cont = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(2, true));
alias stbir__vertical_gather_with_3_coeffs = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(3));
alias stbir__vertical_gather_with_3_coeffs_cont = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(3, true));
alias stbir__vertical_gather_with_4_coeffs = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(4));
alias stbir__vertical_gather_with_4_coeffs_cont = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(4, true));
alias stbir__vertical_gather_with_5_coeffs = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(5));
alias stbir__vertical_gather_with_5_coeffs_cont = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(5, true));
alias stbir__vertical_gather_with_6_coeffs = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(6));
alias stbir__vertical_gather_with_6_coeffs_cont = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(6, true));
alias stbir__vertical_gather_with_7_coeffs = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(7));
alias stbir__vertical_gather_with_7_coeffs_cont = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(7, true));
alias stbir__vertical_gather_with_8_coeffs = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(8));
alias stbir__vertical_gather_with_8_coeffs_cont = stbir__vertical_gather_with_N_coeffs!(stbir_vert_helper(8, true));


void stbir__vertical_gather_with_N_coeffs(stbir_vert_helper H)(
        float * outputp, 
        const(float)* vertical_coefficients, 
        const(float)** inputs, 
        const(float)* input0_end )
@system
{
  @restrict float* output = outputp;
  enum CH = H.ch;

    static if (CH>=1){ const(float)* input0 = inputs[0]; float c0s = vertical_coefficients[0]; }
    static if (CH>=2){ const(float)* input1 = inputs[1]; float c1s = vertical_coefficients[1]; }
    static if (CH>=3){ const(float)* input2 = inputs[2]; float c2s = vertical_coefficients[2]; }
    static if (CH>=4){ const(float)* input3 = inputs[3]; float c3s = vertical_coefficients[3]; }
    static if (CH>=5){ const(float)* input4 = inputs[4]; float c4s = vertical_coefficients[4]; }
    static if (CH>=6){ const(float)* input5 = inputs[5]; float c5s = vertical_coefficients[5]; }
    static if (CH>=7){ const(float)* input6 = inputs[6]; float c6s = vertical_coefficients[6]; }
    static if (CH>=8){ const(float)* input7 = inputs[7]; float c7s = vertical_coefficients[7]; }

    static if ((CH == 1) && !H.STB_IMAGE_RESIZE_VERTICAL_CONTINUE)
    {
        STBIR_MEMCPY( output, input0, cast(char*)input0_end - cast(char*)input0 );
        return;
    }
    else
    {
        enum bool USE_SIMD = true;

        static if (USE_SIMD) // SIMD sampler
        {  
            static if (CH>=1){ stbir__simdfX c0 = stbir__simdf_frepX( c0s ); }
            static if (CH>=2){ stbir__simdfX c1 = stbir__simdf_frepX( c1s ); }
            static if (CH>=3){ stbir__simdfX c2 = stbir__simdf_frepX( c2s ); }
            static if (CH>=4){ stbir__simdfX c3 = stbir__simdf_frepX( c3s ); }
            static if (CH>=5){ stbir__simdfX c4 = stbir__simdf_frepX( c4s ); }
            static if (CH>=6){ stbir__simdfX c5 = stbir__simdf_frepX( c5s ); }
            static if (CH>=7){ stbir__simdfX c6 = stbir__simdf_frepX( c6s ); }
            static if (CH>=8){ stbir__simdfX c7 = stbir__simdf_frepX( c7s ); }

            while ( ( cast(char*)input0_end - cast(char*) input0 ) >= (16*stbir__simdfX_float_count) )
            {
                stbir__simdfX o0, o1, o2, o3, r0, r1, r2, r3;
                STBIR_SIMD_NO_UNROLL(output);

                // prefetch four loop iterations ahead (doesn't affect much for small resizes, but helps with big ones)
                static if (CH>=1){ stbir__prefetch( input0 + (16*stbir__simdfX_float_count) ); }
                static if (CH>=2){ stbir__prefetch( input1 + (16*stbir__simdfX_float_count) ); }
                static if (CH>=3){ stbir__prefetch( input2 + (16*stbir__simdfX_float_count) ); }
                static if (CH>=4){ stbir__prefetch( input3 + (16*stbir__simdfX_float_count) ); }
                static if (CH>=5){ stbir__prefetch( input4 + (16*stbir__simdfX_float_count) ); }
                static if (CH>=6){ stbir__prefetch( input5 + (16*stbir__simdfX_float_count) ); }
                static if (CH>=7){ stbir__prefetch( input6 + (16*stbir__simdfX_float_count) ); }
                static if (CH>=8){ stbir__prefetch( input7 + (16*stbir__simdfX_float_count) ); }

                static if (H.STB_IMAGE_RESIZE_VERTICAL_CONTINUE)
                {
                    static if (CH>=1)
                    {
                          stbir__simdfX_load( o0, output );      stbir__simdfX_load( o1, output+stbir__simdfX_float_count );   stbir__simdfX_load( o2, output+(2*stbir__simdfX_float_count) );   stbir__simdfX_load( o3, output+(3*stbir__simdfX_float_count) );
                          stbir__simdfX_load( r0, input0 );      stbir__simdfX_load( r1, input0+stbir__simdfX_float_count );   stbir__simdfX_load( r2, input0+(2*stbir__simdfX_float_count) );   stbir__simdfX_load( r3, input0+(3*stbir__simdfX_float_count) );
                          stbir__simdfX_madd( o0, o0, r0, c0 );  stbir__simdfX_madd( o1, o1, r1, c0 );                         stbir__simdfX_madd( o2, o2, r2, c0 );                             stbir__simdfX_madd( o3, o3, r3, c0 ); 
                    }
                }
                else
                {
                    static if (CH>=1)
                    { 
                        stbir__simdfX_load( r0, input0 );      stbir__simdfX_load( r1, input0+stbir__simdfX_float_count );   stbir__simdfX_load( r2, input0+(2*stbir__simdfX_float_count) );   stbir__simdfX_load( r3, input0+(3*stbir__simdfX_float_count) );
                        stbir__simdfX_mult( o0, r0, c0 );      stbir__simdfX_mult( o1, r1, c0 );                             stbir__simdfX_mult( o2, r2, c0 );                                 stbir__simdfX_mult( o3, r3, c0 );
                    }
                }

                static if (CH>=2){ stbir__simdfX_load( r0, input1 );      stbir__simdfX_load( r1, input1+stbir__simdfX_float_count );   stbir__simdfX_load( r2, input1+(2*stbir__simdfX_float_count) );   stbir__simdfX_load( r3, input1+(3*stbir__simdfX_float_count) );
                      stbir__simdfX_madd( o0, o0, r0, c1 );  stbir__simdfX_madd( o1, o1, r1, c1 );                         stbir__simdfX_madd( o2, o2, r2, c1 );                             stbir__simdfX_madd( o3, o3, r3, c1 ); }
                static if (CH>=3){ stbir__simdfX_load( r0, input2 );      stbir__simdfX_load( r1, input2+stbir__simdfX_float_count );   stbir__simdfX_load( r2, input2+(2*stbir__simdfX_float_count) );   stbir__simdfX_load( r3, input2+(3*stbir__simdfX_float_count) );
                      stbir__simdfX_madd( o0, o0, r0, c2 );  stbir__simdfX_madd( o1, o1, r1, c2 );                         stbir__simdfX_madd( o2, o2, r2, c2 );                             stbir__simdfX_madd( o3, o3, r3, c2 ); }
                static if (CH>=4){ stbir__simdfX_load( r0, input3 );      stbir__simdfX_load( r1, input3+stbir__simdfX_float_count );   stbir__simdfX_load( r2, input3+(2*stbir__simdfX_float_count) );   stbir__simdfX_load( r3, input3+(3*stbir__simdfX_float_count) );
                      stbir__simdfX_madd( o0, o0, r0, c3 );  stbir__simdfX_madd( o1, o1, r1, c3 );                         stbir__simdfX_madd( o2, o2, r2, c3 );                             stbir__simdfX_madd( o3, o3, r3, c3 ); }
                static if (CH>=5){ stbir__simdfX_load( r0, input4 );      stbir__simdfX_load( r1, input4+stbir__simdfX_float_count );   stbir__simdfX_load( r2, input4+(2*stbir__simdfX_float_count) );   stbir__simdfX_load( r3, input4+(3*stbir__simdfX_float_count) );
                      stbir__simdfX_madd( o0, o0, r0, c4 );  stbir__simdfX_madd( o1, o1, r1, c4 );                         stbir__simdfX_madd( o2, o2, r2, c4 );                             stbir__simdfX_madd( o3, o3, r3, c4 ); }
                static if (CH>=6){ stbir__simdfX_load( r0, input5 );      stbir__simdfX_load( r1, input5+stbir__simdfX_float_count );   stbir__simdfX_load( r2, input5+(2*stbir__simdfX_float_count) );   stbir__simdfX_load( r3, input5+(3*stbir__simdfX_float_count) );
                      stbir__simdfX_madd( o0, o0, r0, c5 );  stbir__simdfX_madd( o1, o1, r1, c5 );                         stbir__simdfX_madd( o2, o2, r2, c5 );                             stbir__simdfX_madd( o3, o3, r3, c5 ); }
                static if (CH>=7){ stbir__simdfX_load( r0, input6 );      stbir__simdfX_load( r1, input6+stbir__simdfX_float_count );   stbir__simdfX_load( r2, input6+(2*stbir__simdfX_float_count) );   stbir__simdfX_load( r3, input6+(3*stbir__simdfX_float_count) );
                      stbir__simdfX_madd( o0, o0, r0, c6 );  stbir__simdfX_madd( o1, o1, r1, c6 );                         stbir__simdfX_madd( o2, o2, r2, c6 );                             stbir__simdfX_madd( o3, o3, r3, c6 ); }
                static if (CH>=8){ stbir__simdfX_load( r0, input7 );      stbir__simdfX_load( r1, input7+stbir__simdfX_float_count );   stbir__simdfX_load( r2, input7+(2*stbir__simdfX_float_count) );   stbir__simdfX_load( r3, input7+(3*stbir__simdfX_float_count) );
                      stbir__simdfX_madd( o0, o0, r0, c7 );  stbir__simdfX_madd( o1, o1, r1, c7 );                         stbir__simdfX_madd( o2, o2, r2, c7 );                             stbir__simdfX_madd( o3, o3, r3, c7 ); }

                stbir__simdfX_store( output, o0 );             stbir__simdfX_store( output+stbir__simdfX_float_count, o1 );  stbir__simdfX_store( output+(2*stbir__simdfX_float_count), o2 );  stbir__simdfX_store( output+(3*stbir__simdfX_float_count), o3 );
                output += (4*stbir__simdfX_float_count);
                static if (CH>=1){ input0 += (4*stbir__simdfX_float_count); } 
                static if (CH>=2){ input1 += (4*stbir__simdfX_float_count); } 
                static if (CH>=3){ input2 += (4*stbir__simdfX_float_count); } 
                static if (CH>=4){ input3 += (4*stbir__simdfX_float_count); } 
                static if (CH>=5){ input4 += (4*stbir__simdfX_float_count); } 
                static if (CH>=6){ input5 += (4*stbir__simdfX_float_count); } 
                static if (CH>=7){ input6 += (4*stbir__simdfX_float_count); } 
                static if (CH>=8){ input7 += (4*stbir__simdfX_float_count); }
            }

            while ( ( cast(char*)input0_end - cast(char*) input0 ) >= 16 )
            {
                stbir__simdf o0, r0;
                STBIR_SIMD_NO_UNROLL(output);

                static if (H.STB_IMAGE_RESIZE_VERTICAL_CONTINUE)
                {
                    static if (CH>=1)
                    {
                        stbir__simdf_load( o0, output );   stbir__simdf_load( r0, input0 ); stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c0 ) ); 
                    }
                }
                else
                {
                    static if (CH>=1)
                    {
                        stbir__simdf_load( r0, input0 );  stbir__simdf_mult( o0, r0, stbir__if_simdf8_cast_to_simdf4( c0 ) );
                    }
                }

                static if (CH>=2){ stbir__simdf_load( r0, input1 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c1 ) ); }
                static if (CH>=3){ stbir__simdf_load( r0, input2 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c2 ) ); }
                static if (CH>=4){ stbir__simdf_load( r0, input3 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c3 ) ); }
                static if (CH>=5){ stbir__simdf_load( r0, input4 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c4 ) ); }
                static if (CH>=6){ stbir__simdf_load( r0, input5 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c5 ) ); }
                static if (CH>=7){ stbir__simdf_load( r0, input6 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c6 ) ); }
                static if (CH>=8){ stbir__simdf_load( r0, input7 );  stbir__simdf_madd( o0, o0, r0, stbir__if_simdf8_cast_to_simdf4( c7 ) ); }

                stbir__simdf_store( output, o0 );
                output += 4;
                static if (CH>=1){ input0 += 4; }
                static if (CH>=2){ input1 += 4; }
                static if (CH>=3){ input2 += 4; }
                static if (CH>=4){ input3 += 4; }
                static if (CH>=5){ input4 += 4; }
                static if (CH>=6){ input5 += 4; }
                static if (CH>=7){ input6 += 4; }
                static if (CH>=8){ input7 += 4; }
            }
        } 
        else // no SIMD
        {
            while ( ( cast(char*)input0_end - cast(char*) input0 ) >= 16 )
            {
                float o0, o1, o2, o3;
                STBIR_NO_UNROLL(output);

                static if (H.STB_IMAGE_RESIZE_VERTICAL_CONTINUE)
                {
                    static if (CH>=1){ o0 = output[0] + input0[0] * c0s; o1 = output[1] + input0[1] * c0s; o2 = output[2] + input0[2] * c0s; o3 = output[3] + input0[3] * c0s; }
                }
                else
                {
                    static if (CH>=1){ o0  = input0[0] * c0s; o1  = input0[1] * c0s; o2  = input0[2] * c0s; o3  = input0[3] * c0s; }
                }

                static if (CH>=2){ o0 += input1[0] * c1s; o1 += input1[1] * c1s; o2 += input1[2] * c1s; o3 += input1[3] * c1s; }
                static if (CH>=3){ o0 += input2[0] * c2s; o1 += input2[1] * c2s; o2 += input2[2] * c2s; o3 += input2[3] * c2s; }
                static if (CH>=4){ o0 += input3[0] * c3s; o1 += input3[1] * c3s; o2 += input3[2] * c3s; o3 += input3[3] * c3s; }
                static if (CH>=5){ o0 += input4[0] * c4s; o1 += input4[1] * c4s; o2 += input4[2] * c4s; o3 += input4[3] * c4s; }
                static if (CH>=6){ o0 += input5[0] * c5s; o1 += input5[1] * c5s; o2 += input5[2] * c5s; o3 += input5[3] * c5s; }
                static if (CH>=7){ o0 += input6[0] * c6s; o1 += input6[1] * c6s; o2 += input6[2] * c6s; o3 += input6[3] * c6s; }
                static if (CH>=8){ o0 += input7[0] * c7s; o1 += input7[1] * c7s; o2 += input7[2] * c7s; o3 += input7[3] * c7s; }
                output[0] = o0; output[1] = o1; output[2] = o2; output[3] = o3;
                output += 4;
                static if (CH>=1){ input0 += 4; }
                static if (CH>=2){ input1 += 4; }
                static if (CH>=3){ input2 += 4; }
                static if (CH>=4){ input3 += 4; }
                static if (CH>=5){ input4 += 4; }
                static if (CH>=6){ input5 += 4; }
                static if (CH>=7){ input6 += 4; }
                static if (CH>=8){ input7 += 4; }
            }
        }

        while ( input0 < input0_end )
        {
            float o0;
            STBIR_NO_UNROLL(output);
            static if (H.STB_IMAGE_RESIZE_VERTICAL_CONTINUE)
            {
                static if (CH>=1){ o0 = output[0] + input0[0] * c0s; }
            }
            else
            {
                static if (CH>=1){ o0  = input0[0] * c0s; }
            }
            static if (CH>=2){ o0 += input1[0] * c1s; }
            static if (CH>=3){ o0 += input2[0] * c2s; }
            static if (CH>=4){ o0 += input3[0] * c3s; }
            static if (CH>=5){ o0 += input4[0] * c4s; }
            static if (CH>=6){ o0 += input5[0] * c5s; }
            static if (CH>=7){ o0 += input6[0] * c6s; }
            static if (CH>=8){ o0 += input7[0] * c7s; }
            output[0] = o0;
            ++output;
            static if (CH>=1){ ++input0; }
            static if (CH>=2){ ++input1; }
            static if (CH>=3){ ++input2; }
            static if (CH>=4){ ++input3; }
            static if (CH>=5){ ++input4; }
            static if (CH>=6){ ++input5; }
            static if (CH>=7){ ++input6; }
            static if (CH>=8){ ++input7; }
        }
    }
}
