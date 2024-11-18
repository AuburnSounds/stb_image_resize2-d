module stb_image_resize2.coders;

nothrow @nogc @system:

import stb_image_resize2.types;
import stb_image_resize2.simd;

static if (hasRestrict)
    import core.attribute: restrict;
else
    enum restrict = 0;



// VERTICAL RESAMPLING

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

// HORIZONTAL RESAMPLING

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
}


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

version(LDC)
{
    version(X86)
        // Technically the bug was only seen with 7 channels but
        // better be safe.
        enum bool STBIR2_workaround_Issue1 = true;
    else
        enum bool STBIR2_workaround_Issue1 = false;
}
else
enum bool STBIR2_workaround_Issue1 = true;

static if (STBIR2_workaround_Issue1)
{
    // See: https://github.com/AuburnSounds/stb_image_resize2-d/issues/1
    // To avoid a x86 crash, use the generic function. It is 6% slower
    // saves 6kb in binary, and doesn't crash in these conditions.
    static immutable stbir__horizontal_gather_channels_func[12]
        stbir__horizontal_gather_N_channels_funcs(stbir_horz_helper h) =
    [
        &stbir__horizontal_gather_N_channels_with_n_coeffs_any!(1, h.channels),
        &stbir__horizontal_gather_N_channels_with_n_coeffs_any!(2, h.channels),
        &stbir__horizontal_gather_N_channels_with_n_coeffs_any!(3, h.channels),
        &stbir__horizontal_gather_N_channels_with_n_coeffs_any!(4, h.channels),
        &stbir__horizontal_gather_N_channels_with_n_coeffs_any!(5, h.channels),
        &stbir__horizontal_gather_N_channels_with_n_coeffs_any!(6, h.channels),
        &stbir__horizontal_gather_N_channels_with_n_coeffs_any!(7, h.channels),
        &stbir__horizontal_gather_N_channels_with_n_coeffs_any!(8, h.channels),
        &stbir__horizontal_gather_N_channels_with_n_coeffs_any!(9, h.channels),
        &stbir__horizontal_gather_N_channels_with_n_coeffs_any!(10, h.channels),
        &stbir__horizontal_gather_N_channels_with_n_coeffs_any!(11, h.channels),
        &stbir__horizontal_gather_N_channels_with_n_coeffs_any!(12, h.channels),
    ];
}
else
{
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
}

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
 stbir__simdf_0123to0011( c, c);
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



// GP. Super generic horizontal gather function in case of LDC + X86 + 7 channels
// See Issue #1

void stbir__horizontal_gather_N_channels_with_n_coeffs_any(int NumCoeffs, int Channels)(
                                                                                        float * output_buffer,
                                                                                        uint output_sub_size,
                                                                                        const(float)* decode_buffer,
                                                                                        const(stbir__contributors)* horizontal_contributors,
                                                                                        const(float)* horizontal_coefficients,
                                                                                        int coefficient_width)
@system
{
    const(float)* output_end = output_buffer + output_sub_size * Channels;
    @restrict float*  output = output_buffer;
    do
    {
        const(float)* decode = decode_buffer + horizontal_contributors.n0 * Channels;
        const(float)* hc = horizontal_coefficients;

        float[Channels] accum;
        accum[] = 0;

        for (int icoeff = 0; icoeff < NumCoeffs; ++icoeff)
        {
            float coeff = hc[icoeff];
            for (int ch = 0; ch < Channels; ++ch)
            {
                accum[ch] += coeff * decode[Channels * icoeff + ch];
            }
        }

        for (int ch = 0; ch < Channels; ++ch)
        {
            output[ch] = accum[ch];
        }

        horizontal_coefficients += coefficient_width;
        ++horizontal_contributors;
        output += Channels;
    } while ( output < output_end );
}




//========================================================================================================
// scanline decoders and encoders

// Note:  we can probably save a lot of codegen by not supporting
// all those swizzle and just regular order.
// Those are the template arguments of all functions below.
enum CODER_RGBA = CoderHelper(1,     "", false, 0, 1, 2, 3, 0, 1, 2, 3,   null,   null, "i0,i1,i2,i3");
enum CODER_BGRA = CoderHelper(4, "BGRA",  true, 2, 1, 0, 3, 2, 1, 0, 3, "2103", "2103", "i2,i1,i0,i3");
enum CODER_ARGB = CoderHelper(4, "ARGB",  true, 1, 2, 3, 0, 3, 0, 1, 2, "1230", "3012", "i3,i0,i1,i2");
enum CODER_ABGR = CoderHelper(4, "ABGR",  true, 3, 2, 1, 0, 3, 2, 1, 0, "3210", "3210", "i3,i2,i1,i0");
enum CODER_AR   = CoderHelper(2,   "AR",  true, 1, 0, 3, 2, 1, 0, 3, 2, "1032", "1032", "i1,i0,i3,i2");

struct CoderHelper
{
    int stbir__coder_min_num;
    string stbir__decode_suffix;
    bool stbir__decode_swizzle;
    int stbir__decode_order0;
    int stbir__decode_order1;
    int stbir__decode_order2;
    int stbir__decode_order3;
    int stbir__encode_order0;
    int stbir__encode_order1;
    int stbir__encode_order2;
    int stbir__encode_order3;

    string flipName;
    string unflipName;
    string encodeIndices; // same order as unflipName
}

void stbir__decode_simdf8_flip(CoderHelper H)(ref stbir__simdf8 reg)
{
    static if (H.stbir__decode_swizzle)
    {
        mixin("stbir__simdf8_0123to" ~ H.flipName ~ H.flipName ~ "(reg, reg);");
    }
}

void stbir__decode_simdf4_flip(CoderHelper H)(ref stbir__simdf reg)
{
    static if (stbir__decode_swizzle)
    {
        mixin("stbir__simdf_0123to" ~ H.flipName ~ "(reg, reg);");
    }
}

void stbir__encode_simdf8_unflip(CoderHelper H)(ref stbir__simdf8 reg)
{
    static if (H.stbir__decode_swizzle)
    {
        mixin("stbir__simdf8_0123to" ~ H.unflipName ~ H.unflipName ~ "(reg, reg);");
    }
}

void stbir__encode_simdf4_unflip(CoderHelper H)(ref stbir__simdf reg)
{
    static if (H.stbir__decode_swizzle)
    {
        mixin("stbir__simdf_0123to" ~ H.unflipName ~ "(reg, reg);");
    }
}



static if (STBIR_SIMD8)
{
    alias stbir__encode_simdfX_unflip = stbir__encode_simdf8_unflip;
}
else
{
    alias stbir__encode_simdfX_unflip = stbir__encode_simdf4_unflip;
}

void stbir__decode_uint8_linear_scaled(CoderHelper H)(float * decodep,
                                                      int width_times_channels,
                                                      const(void)* inputp)
{
  @restrict float* decode = decodep;
  float * decode_end = cast(float*) decode + width_times_channels;
  const(char)* input = cast(const(char)*)inputp;

  const(char)* end_input_m16 = input + width_times_channels - 16;
  if ( width_times_channels >= 16 )
  {
    decode_end -= 16;
    for(;;)
    {
      stbir__simdi i; stbir__simdi8 o0,o1;
      stbir__simdf8 of0, of1;
      STBIR_NO_UNROLL(decode);
      stbir__simdi_load( i, input );
      stbir__simdi8_expand_u8_to_u32( o0, o1, i );
      stbir__simdi8_convert_i32_to_float( of0, o0 );
      stbir__simdi8_convert_i32_to_float( of1, o1 );
      stbir__simdf8_mult( of0, of0, STBIR_max_uint8_as_float_inverted8);
      stbir__simdf8_mult( of1, of1, STBIR_max_uint8_as_float_inverted8);
      stbir__decode_simdf8_flip!H( of0 );
      stbir__decode_simdf8_flip!H( of1 );
      stbir__simdf8_store( decode + 0, of0 );
      stbir__simdf8_store( decode + 8, of1 );
      decode += 16;
      input += 16;
      if ( decode <= decode_end )
        continue;
      if ( decode == ( decode_end + 16 ) )
        break;
      decode = decode_end; // backup and do last couple
      input = end_input_m16;
    }
    return;
  }

  // try to do blocks of 4 when you can
  static if (H.stbir__coder_min_num != 3)
  {
      // doesn't divide cleanly by four
      decode += 4;
      while( decode <= decode_end )
      {
        STBIR_SIMD_NO_UNROLL(decode);
        decode[0-4] = (cast(float)(input[H.stbir__decode_order0])) * stbir__max_uint8_as_float_inverted;
        decode[1-4] = (cast(float)(input[H.stbir__decode_order1])) * stbir__max_uint8_as_float_inverted;
        decode[2-4] = (cast(float)(input[H.stbir__decode_order2])) * stbir__max_uint8_as_float_inverted;
        decode[3-4] = (cast(float)(input[H.stbir__decode_order3])) * stbir__max_uint8_as_float_inverted;
        decode += 4;
        input += 4;
      }
      decode -= 4;
  }

  // do the remnants
  static if (H.stbir__coder_min_num < 4)
  {
      while( decode < decode_end )
      {
        STBIR_NO_UNROLL(decode);
        decode[0] = (cast(float)(input[H.stbir__decode_order0])) * stbir__max_uint8_as_float_inverted;
        static if (H.stbir__coder_min_num >= 2)
        {
            decode[1] = (cast(float)(input[H.stbir__decode_order1])) * stbir__max_uint8_as_float_inverted;
        }
        static if (H.stbir__coder_min_num >= 3)
        {
            decode[2] = (cast(float)(input[H.stbir__decode_order2])) * stbir__max_uint8_as_float_inverted;
        }
        decode += H.stbir__coder_min_num;
        input += H.stbir__coder_min_num;
      }
  }
}

void stbir__encode_uint8_linear_scaled(CoderHelper H)(void* outputp, int width_times_channels, const(float)* encode )
{
  @restrict char* output = cast(char *) outputp;
  char * end_output = ( cast(char *) output ) + width_times_channels;

  if ( width_times_channels >= stbir__simdfX_float_count*2 )
  {
    const(float)* end_encode_m8 = encode + width_times_channels - stbir__simdfX_float_count*2;
    end_output -= stbir__simdfX_float_count*2;
    for(;;)
    {
      stbir__simdfX e0, e1;
      stbir__simdi i;
      STBIR_SIMD_NO_UNROLL(encode);
      stbir__simdfX_madd_mem( e0, STBIR_simd_point5X, STBIR_max_uint8_as_floatX, encode );
      stbir__simdfX_madd_mem( e1, STBIR_simd_point5X, STBIR_max_uint8_as_floatX, encode+stbir__simdfX_float_count );
      stbir__encode_simdfX_unflip!H( e0 );
      stbir__encode_simdfX_unflip!H( e1 );
      stbir__simdf8_pack_to_16bytes( i, e0, e1 );
      stbir__simdi_store( output, i );
      encode += stbir__simdfX_float_count*2;
      output += stbir__simdfX_float_count*2;
      if ( output <= end_output )
        continue;
      if ( output == ( end_output + stbir__simdfX_float_count*2 ) )
        break;
      output = end_output; // backup and do last couple
      encode = end_encode_m8;
    }
    return;
  }

  // try to do blocks of 4 when you can
  static if (H.stbir__coder_min_num != 3) // doesn't divide cleanly by four
  {
      output += 4;
      while( output <= end_output )
      {
        stbir__simdf e0;
        stbir__simdi i0;
        STBIR_NO_UNROLL(encode);
        stbir__simdf_load( e0, encode );
        stbir__simdf_madd( e0, STBIR_simd_point5, STBIR_max_uint8_as_float, e0 );
        stbir__encode_simdf4_unflip!H( e0 );
        stbir__simdf_pack_to_8bytes( i0, e0, e0 );  // only use first 4
        *cast(int*)(output-4) = stbir__simdi_to_int( i0 );
        output += 4;
        encode += 4;
      }
      output -= 4;
  }

  // do the remnants
  static if (H.stbir__coder_min_num < 4)
  {
      while( output < end_output )
      {
        stbir__simdf e0;
        STBIR_NO_UNROLL(encode);
        stbir__simdf_madd1_mem( e0, STBIR_simd_point5, STBIR_max_uint8_as_float, encode+H.stbir__encode_order0 ); output[0] = stbir__simdf_convert_float_to_uint8( e0 );
        static if (H.stbir__coder_min_num >= 2)
        {
            stbir__simdf_madd1_mem( e0, STBIR_simd_point5, STBIR_max_uint8_as_float, encode+H.stbir__encode_order1 ); output[1] = stbir__simdf_convert_float_to_uint8( e0 );
        }
        static if (H.stbir__coder_min_num >= 3)
        {
            stbir__simdf_madd1_mem( e0, STBIR_simd_point5, STBIR_max_uint8_as_float, encode+H.stbir__encode_order2 ); output[2] = stbir__simdf_convert_float_to_uint8( e0 );
        }
        output += H.stbir__coder_min_num;
        encode += H.stbir__coder_min_num;
      }
  }

}

void stbir__decode_uint8_linear(CoderHelper H)
                        (float * decodep,
                        int width_times_channels,
                        const(void)* inputp )
{
  @restrict float* decode = decodep;
  float * decode_end = cast(float*) decode + width_times_channels;
  const(char)* input = cast(const(char)*)inputp;

  const(char)* end_input_m16 = input + width_times_channels - 16;
  if ( width_times_channels >= 16 )
  {
    decode_end -= 16;
    for(;;)
    {
      stbir__simdi i; stbir__simdi8 o0,o1;
      stbir__simdf8 of0, of1;
      STBIR_NO_UNROLL(decode);
      stbir__simdi_load( i, input );
      stbir__simdi8_expand_u8_to_u32( o0, o1, i );
      stbir__simdi8_convert_i32_to_float( of0, o0 );
      stbir__simdi8_convert_i32_to_float( of1, o1 );
      stbir__decode_simdf8_flip!H( of0 );
      stbir__decode_simdf8_flip!H( of1 );
      stbir__simdf8_store( decode + 0, of0 );
      stbir__simdf8_store( decode + 8, of1 );
      decode += 16;
      input += 16;
      if ( decode <= decode_end )
        continue;
      if ( decode == ( decode_end + 16 ) )
        break;
      decode = decode_end; // backup and do last couple
      input = end_input_m16;
    }
    return;
  }

  // try to do blocks of 4 when you can
  static if (H.stbir__coder_min_num != 3) // doesn't divide cleanly by four
  {
      decode += 4;
      while( decode <= decode_end )
      {
        STBIR_SIMD_NO_UNROLL(decode);
        decode[0-4] = (cast(float)(input[H.stbir__decode_order0]));
        decode[1-4] = (cast(float)(input[H.stbir__decode_order1]));
        decode[2-4] = (cast(float)(input[H.stbir__decode_order2]));
        decode[3-4] = (cast(float)(input[H.stbir__decode_order3]));
        decode += 4;
        input += 4;
      }
      decode -= 4;
  }

  // do the remnants
  static if (H.stbir__coder_min_num < 4) // doesn't divide cleanly by four
  {
      while( decode < decode_end )
      {
        STBIR_NO_UNROLL(decode);
        decode[0] = (cast(float)(input[H.stbir__decode_order0]));
        static if (H.stbir__coder_min_num >= 2) // doesn't divide cleanly by four
        {
            decode[1] = (cast(float)(input[H.stbir__decode_order1]));
        }
        static if (H.stbir__coder_min_num >= 3)
        {
            decode[2] = (cast(float)(input[H.stbir__decode_order2]));
        }
        decode += H.stbir__coder_min_num;
        input  += H.stbir__coder_min_num;
      }
  }
}

void stbir__encode_uint8_linear(CoderHelper H)( void * outputp, int width_times_channels, const(float)* encode )
{
  @restrict char* output = cast(char *) outputp;
  char * end_output = ( cast(char *) output ) + width_times_channels;

  if ( width_times_channels >= stbir__simdfX_float_count*2 )
  {
    const(float)* end_encode_m8 = encode + width_times_channels - stbir__simdfX_float_count*2;
    end_output -= stbir__simdfX_float_count*2;
    for(;;)
    {
      stbir__simdfX e0, e1;
      stbir__simdi i;
      STBIR_SIMD_NO_UNROLL(encode);
      stbir__simdfX_add_mem( e0, STBIR_simd_point5X, encode );
      stbir__simdfX_add_mem( e1, STBIR_simd_point5X, encode+stbir__simdfX_float_count );
      stbir__encode_simdfX_unflip!H( e0 );
      stbir__encode_simdfX_unflip!H( e1 );
      stbir__simdf8_pack_to_16bytes( i, e0, e1 );
      stbir__simdi_store( output, i );
      encode += stbir__simdfX_float_count*2;
      output += stbir__simdfX_float_count*2;
      if ( output <= end_output )
        continue;
      if ( output == ( end_output + stbir__simdfX_float_count*2 ) )
        break;
      output = end_output; // backup and do last couple
      encode = end_encode_m8;
    }
    return;
  }

  // try to do blocks of 4 when you can
  static if (H.stbir__coder_min_num != 3) // doesn't divide cleanly by four
  {
      output += 4;
      while( output <= end_output )
      {
        stbir__simdf e0;
        stbir__simdi i0;
        STBIR_NO_UNROLL(encode);
        stbir__simdf_load( e0, encode );
        stbir__simdf_add( e0, STBIR_simd_point5, e0 );
        stbir__encode_simdf4_unflip!H( e0 );
        stbir__simdf_pack_to_8bytes( i0, e0, e0 );  // only use first 4
        *cast(int*)(output-4) = stbir__simdi_to_int( i0 );
        output += 4;
        encode += 4;
      }
      output -= 4;
  }

  // do the remnants

  static if (H.stbir__coder_min_num < 4)
  {
      while( output < end_output )
      {
        float f;
        STBIR_NO_UNROLL(encode);
        f = encode[H.stbir__encode_order0] + 0.5f; STBIR_CLAMP(f, 0, 255); output[0] = cast(char)f;
        static if (H.stbir__coder_min_num >= 2)
        {
            f = encode[H.stbir__encode_order1] + 0.5f; STBIR_CLAMP(f, 0, 255); output[1] = cast(char)f;
        }
        static if (H.stbir__coder_min_num >= 3)
        {
            f = encode[H.stbir__encode_order2] + 0.5f; STBIR_CLAMP(f, 0, 255); output[2] = cast(char)f;
        }
        output += H.stbir__coder_min_num;
        encode += H.stbir__coder_min_num;
      }
  }
}

void stbir__decode_uint8_srgb(CoderHelper H)(float * decodep, int width_times_channels, const(void)* inputp )
{
  @restrict float* decode = decodep;
  const(float)* decode_end = cast(float*) decode + width_times_channels;
  const(char)* input = cast(const(char)*) inputp;

  // try to do blocks of 4 when you can
  static if (H.stbir__coder_min_num != 3) // doesn't divide cleanly by four
  {
      decode += 4;
      while( decode <= decode_end )
      {
        decode[0-4] = stbir__srgb_uchar_to_linear_float[ input[ H.stbir__decode_order0 ] ];
        decode[1-4] = stbir__srgb_uchar_to_linear_float[ input[ H.stbir__decode_order1 ] ];
        decode[2-4] = stbir__srgb_uchar_to_linear_float[ input[ H.stbir__decode_order2 ] ];
        decode[3-4] = stbir__srgb_uchar_to_linear_float[ input[ H.stbir__decode_order3 ] ];
        decode += 4;
        input += 4;
      }
      decode -= 4;
  }

  // do the remnants
  static if (H.stbir__coder_min_num < 4) // doesn't divide cleanly by four
  {
      while( decode < decode_end )
      {
        STBIR_NO_UNROLL(decode);
        decode[0] = stbir__srgb_uchar_to_linear_float[ input[ H.stbir__decode_order0 ] ];
        static if (H.stbir__coder_min_num >= 2)
        {
            decode[1] = stbir__srgb_uchar_to_linear_float[ input[ H.stbir__decode_order1 ] ];
        }
        static if (H.stbir__coder_min_num >= 3)
        {
            decode[2] = stbir__srgb_uchar_to_linear_float[ input[ H.stbir__decode_order2 ] ];
        }
        decode += H.stbir__coder_min_num;
        input += H.stbir__coder_min_num;
      }
  }
}

void stbir__min_max_shift20 (ref stbir__simdi i, ref stbir__simdf f)
{
    stbir__simdf_max( f, f, stbir_simdf_casti( STBIR_almost_zero ) );
    stbir__simdf_min( f, f, stbir_simdf_casti( STBIR_almost_one  ) );
    stbir__simdi_32shr( i, stbir_simdi_castf( f ), 20 );
}

void stbir__scale_and_convert(ref stbir__simdi i, ref stbir__simdf f)
{
    stbir__simdf_madd( f, STBIR_simd_point5, STBIR_max_uint8_as_float, f );
    stbir__simdf_max( f, f, stbir__simdf_zeroP() );
    stbir__simdf_min( f, f, STBIR_max_uint8_as_float );
    stbir__simdf_convert_float_to_i32( i, f );
}

void stbir__linear_to_srgb_finish(ref stbir__simdi i, ref stbir__simdf f)
{
    stbir__simdi temp;
    stbir__simdi_32shr( temp, stbir_simdi_castf( f ), 12 ) ;
    stbir__simdi_and( temp, temp, STBIR_mastissa_mask );
    stbir__simdi_or( temp, temp, cast(stbir__simdi) STBIR_topscale );
    stbir__simdi_16madd( i, i, temp );
    stbir__simdi_32shr( i, i, 16 );
}

void stbir__simdi_table_lookup1(ref stbir__simdi v0, const(uint)* table)
{
    v0.ptr[0] = table[v0.array[0]];
    v0.ptr[1] = table[v0.array[1]];
    v0.ptr[2] = table[v0.array[2]];
    v0.ptr[3] = table[v0.array[3]];
}

void stbir__simdi_table_lookup2(ref stbir__simdi v0,
                                ref stbir__simdi v1,
                                const(uint)* table )
{
    stbir__simdi_table_lookup1(v0, table);
    stbir__simdi_table_lookup1(v1, table);
}

void stbir__simdi_table_lookup3(ref stbir__simdi v0,
                                ref stbir__simdi v1,
                                ref stbir__simdi v2,
                                const(uint)* table )
{
    stbir__simdi_table_lookup1(v0, table);
    stbir__simdi_table_lookup1(v1, table);
    stbir__simdi_table_lookup1(v2, table);
}

void stbir__simdi_table_lookup4(ref stbir__simdi v0,
                                ref stbir__simdi v1,
                                ref stbir__simdi v2,
                                ref stbir__simdi v3,
                                const(uint)* table )
{
    stbir__simdi_table_lookup2(v0, v1, table);
    stbir__simdi_table_lookup2(v1, v2, table);
}

void stbir__encode_uint8_srgb(CoderHelper H)( void * outputp, int width_times_channels, const(float)* encode )
{
  @restrict char* output = cast(char*) outputp;
  char * end_output = ( cast(char*) output ) + width_times_channels;


  if ( width_times_channels >= 16 )
  {
    const(float)* end_encode_m16 = encode + width_times_channels - 16;
    end_output -= 16;
    for(;;)
    {
      stbir__simdf f0, f1, f2, f3;
      stbir__simdi i0, i1, i2, i3;
      STBIR_SIMD_NO_UNROLL(encode);

      stbir__simdf_load4_transposed( f0, f1, f2, f3, encode );

      stbir__min_max_shift20( i0, f0 );
      stbir__min_max_shift20( i1, f1 );
      stbir__min_max_shift20( i2, f2 );
      stbir__min_max_shift20( i3, f3 );

      stbir__simdi_table_lookup4( i0, i1, i2, i3, ( fp32_to_srgb8_tab4.ptr - (127-13)*8 ) );

      stbir__linear_to_srgb_finish( i0, f0 );
      stbir__linear_to_srgb_finish( i1, f1 );
      stbir__linear_to_srgb_finish( i2, f2 );
      stbir__linear_to_srgb_finish( i3, f3 );

      mixin(`stbir__interleave_pack_and_store_16_u8(output, ` ~ H.encodeIndices ~ `);`);

      encode += 16;
      output += 16;
      if ( output <= end_output )
        continue;
      if ( output == ( end_output + 16 ) )
        break;
      output = end_output; // backup and do last couple
      encode = end_encode_m16;
    }
    return;
  }

  // try to do blocks of 4 when you can
  static if (H.stbir__coder_min_num != 3) // doesn't divide cleanly by four
  {
      output += 4;
      while ( output <= end_output )
      {
        STBIR_SIMD_NO_UNROLL(encode);

        output[0-4] = stbir__linear_to_srgb_uchar( encode[H.stbir__encode_order0] );
        output[1-4] = stbir__linear_to_srgb_uchar( encode[H.stbir__encode_order1] );
        output[2-4] = stbir__linear_to_srgb_uchar( encode[H.stbir__encode_order2] );
        output[3-4] = stbir__linear_to_srgb_uchar( encode[H.stbir__encode_order3] );

        output += 4;
        encode += 4;
      }
      output -= 4;
  }

  // do the remnants
  static if (H.stbir__coder_min_num < 4) // doesn't divide cleanly by four
  {
      while( output < end_output )
      {
        STBIR_NO_UNROLL(encode);
        output[0] = stbir__linear_to_srgb_uchar( encode[H.stbir__encode_order0] );
        static if (H.stbir__coder_min_num >= 2)
            output[1] = stbir__linear_to_srgb_uchar( encode[H.stbir__encode_order1] );
        static if (H.stbir__coder_min_num >= 3)
            output[2] = stbir__linear_to_srgb_uchar( encode[H.stbir__encode_order2] );
        output += H.stbir__coder_min_num;
        encode += H.stbir__coder_min_num;
      }
  }
}

void stbir__decode_uint8_srgb4_linearalpha(CoderHelper H)( float * decodep, int width_times_channels, const(void)* inputp )
{
    static assert( (H.stbir__coder_min_num == 4)
        || ( ( H.stbir__coder_min_num == 1 ) && ( !H.stbir__decode_swizzle ) ) );

  @restrict float* decode = decodep;
  const(float)* decode_end = cast(float*) decode + width_times_channels;
  const(char)* input = cast(const(char)*) inputp;
  do {
    decode[0] = stbir__srgb_uchar_to_linear_float[ input[H.stbir__decode_order0] ];
    decode[1] = stbir__srgb_uchar_to_linear_float[ input[H.stbir__decode_order1] ];
    decode[2] = stbir__srgb_uchar_to_linear_float[ input[H.stbir__decode_order2] ];
    decode[3] = ( cast(float) input[H.stbir__decode_order3] ) * stbir__max_uint8_as_float_inverted;
    input += 4;
    decode += 4;
  } while( decode < decode_end );
}


void stbir__encode_uint8_srgb4_linearalpha(CoderHelper H)(void * outputp, int width_times_channels, const(float)* encode )
{
    static assert( (H.stbir__coder_min_num == 4)
         || ( ( H.stbir__coder_min_num == 1 ) && ( !H.stbir__decode_swizzle ) ) );

  @restrict char* output = cast(char*) outputp;
  char * end_output = ( cast(char*) output ) + width_times_channels;

  if ( width_times_channels >= 16 )
  {
    const(float)* end_encode_m16 = encode + width_times_channels - 16;
    end_output -= 16;
    for(;;)
    {
      stbir__simdf f0, f1, f2, f3;
      stbir__simdi i0, i1, i2, i3;

      STBIR_SIMD_NO_UNROLL(encode);
      stbir__simdf_load4_transposed( f0, f1, f2, f3, encode );

      stbir__min_max_shift20( i0, f0 );
      stbir__min_max_shift20( i1, f1 );
      stbir__min_max_shift20( i2, f2 );
      stbir__scale_and_convert( i3, f3 );

      stbir__simdi_table_lookup3( i0, i1, i2, ( fp32_to_srgb8_tab4.ptr - (127-13)*8 ) );

      stbir__linear_to_srgb_finish( i0, f0 );
      stbir__linear_to_srgb_finish( i1, f1 );
      stbir__linear_to_srgb_finish( i2, f2 );

      mixin(`stbir__interleave_pack_and_store_16_u8(output, ` ~ H.encodeIndices ~ `);`);

      output += 16;
      encode += 16;

      if ( output <= end_output )
        continue;
      if ( output == ( end_output + 16 ) )
        break;
      output = end_output; // backup and do last couple
      encode = end_encode_m16;
    }
    return;
  }

  do {
    float f;
    STBIR_SIMD_NO_UNROLL(encode);

    output[H.stbir__decode_order0] = stbir__linear_to_srgb_uchar( encode[0] );
    output[H.stbir__decode_order1] = stbir__linear_to_srgb_uchar( encode[1] );
    output[H.stbir__decode_order2] = stbir__linear_to_srgb_uchar( encode[2] );

    f = encode[3] * stbir__max_uint8_as_float + 0.5f;
    STBIR_CLAMP(f, 0, 255);
    output[H.stbir__decode_order3] = cast(char) f;

    output += 4;
    encode += 4;
  } while( output < end_output );
}



void stbir__decode_uint8_srgb2_linearalpha(CoderHelper H)(float * decodep,
                                              int width_times_channels,
                                              const(void)* inputp )
{
    static assert( (H.stbir__coder_min_num == 2)
                   || ( ( H.stbir__coder_min_num == 1 ) && ( !H.stbir__decode_swizzle ) ) );


  @restrict float* decode = decodep;
  const(float)* decode_end = cast(float*) decode + width_times_channels;
  const(char)* input = cast(const(char)*)inputp;
  decode += 4;
  while( decode <= decode_end )
  {
    decode[0-4] = stbir__srgb_uchar_to_linear_float[ input[H.stbir__decode_order0] ];
    decode[1-4] = ( cast(float) input[H.stbir__decode_order1] ) * stbir__max_uint8_as_float_inverted;
    decode[2-4] = stbir__srgb_uchar_to_linear_float[ input[H.stbir__decode_order0+2] ];
    decode[3-4] = ( cast(float) input[H.stbir__decode_order1+2] ) * stbir__max_uint8_as_float_inverted;
    input += 4;
    decode += 4;
  }
  decode -= 4;
  if( decode < decode_end )
  {
    decode[0] = stbir__srgb_uchar_to_linear_float[ H.stbir__decode_order0 ];
    decode[1] = ( cast(float) input[H.stbir__decode_order1] ) * stbir__max_uint8_as_float_inverted;
  }
}

void stbir__encode_uint8_srgb2_linearalpha(CoderHelper H)( void * outputp, int width_times_channels, const(float)* encode )
{
    static assert( (H.stbir__coder_min_num == 2)
                   || ( ( H.stbir__coder_min_num == 1 ) && ( !H.stbir__decode_swizzle ) ) );

  @restrict char* output = cast(char*) outputp;
  char * end_output = ( cast(char*) output ) + width_times_channels;

  if ( width_times_channels >= 16 )
  {
    const(float)* end_encode_m16 = encode + width_times_channels - 16;
    end_output -= 16;
    for(;;)
    {
      stbir__simdf f0, f1, f2, f3;
      stbir__simdi i0, i1, i2, i3;

      STBIR_SIMD_NO_UNROLL(encode);
      stbir__simdf_load4_transposed( f0, f1, f2, f3, encode );

      stbir__min_max_shift20( i0, f0 );
      stbir__scale_and_convert( i1, f1 );
      stbir__min_max_shift20( i2, f2 );
      stbir__scale_and_convert( i3, f3 );

      stbir__simdi_table_lookup2( i0, i2, ( fp32_to_srgb8_tab4.ptr - (127-13)*8 ) );

      stbir__linear_to_srgb_finish( i0, f0 );
      stbir__linear_to_srgb_finish( i2, f2 );

      mixin(`stbir__interleave_pack_and_store_16_u8(output, ` ~ H.encodeIndices ~ `);`);

      output += 16;
      encode += 16;
      if ( output <= end_output )
        continue;
      if ( output == ( end_output + 16 ) )
        break;
      output = end_output; // backup and do last couple
      encode = end_encode_m16;
    }
    return;
  }

  do {
    float f;
    STBIR_SIMD_NO_UNROLL(encode);

    output[H.stbir__decode_order0] = stbir__linear_to_srgb_uchar( encode[0] );

    f = encode[1] * stbir__max_uint8_as_float + 0.5f;
    STBIR_CLAMP(f, 0, 255);
    output[H.stbir__decode_order1] = cast(char) f;

    output += 2;
    encode += 2;
  } while( output < end_output );
}


void stbir__decode_uint16_linear_scaled(CoderHelper H)( float * decodep, int width_times_channels, const(void)* inputp)
{
  @restrict float* decode = decodep;
  float * decode_end = cast(float*) decode + width_times_channels;
  const(ushort)* input = cast(const(ushort)*) inputp;

  const(ushort)* end_input_m8 = input + width_times_channels - 8;
  if ( width_times_channels >= 8 )
  {
    decode_end -= 8;
    for(;;)
    {
      stbir__simdi i; stbir__simdi8 o;
      stbir__simdf8 of;
      STBIR_NO_UNROLL(decode);
      stbir__simdi_load( i, input );
      stbir__simdi8_expand_u16_to_u32( o, i );
      stbir__simdi8_convert_i32_to_float( of, o );
      stbir__simdf8_mult( of, of, STBIR_max_uint16_as_float_inverted8);
      stbir__decode_simdf8_flip!H( of );
      stbir__simdf8_store( decode + 0, of );
      decode += 8;
      input += 8;
      if ( decode <= decode_end )
        continue;
      if ( decode == ( decode_end + 8 ) )
        break;
      decode = decode_end; // backup and do last couple
      input = end_input_m8;
    }
    return;
  }

  // try to do blocks of 4 when you can
  static if (H.stbir__coder_min_num != 3) // doesn't divide cleanly by four
  {
      decode += 4;
      while( decode <= decode_end )
      {
        STBIR_SIMD_NO_UNROLL(decode);
        decode[0-4] = (cast(float)(input[H.stbir__decode_order0])) * stbir__max_uint16_as_float_inverted;
        decode[1-4] = (cast(float)(input[H.stbir__decode_order1])) * stbir__max_uint16_as_float_inverted;
        decode[2-4] = (cast(float)(input[H.stbir__decode_order2])) * stbir__max_uint16_as_float_inverted;
        decode[3-4] = (cast(float)(input[H.stbir__decode_order3])) * stbir__max_uint16_as_float_inverted;
        decode += 4;
        input += 4;
      }
      decode -= 4;
  }

  // do the remnants
  static if (H.stbir__coder_min_num < 4)
  {
      while( decode < decode_end )
      {
        STBIR_NO_UNROLL(decode);
        decode[0] = (cast(float)(input[H.stbir__decode_order0])) * stbir__max_uint16_as_float_inverted;
        static if (H.stbir__coder_min_num >= 2)
        {
            decode[1] = (cast(float)(input[H.stbir__decode_order1])) * stbir__max_uint16_as_float_inverted;
        }
        static if (H.stbir__coder_min_num >= 3)
        {
            decode[2] = (cast(float)(input[H.stbir__decode_order2])) * stbir__max_uint16_as_float_inverted;
        }
        decode += H.stbir__coder_min_num;
        input  += H.stbir__coder_min_num;
      }
  }
}

void stbir__encode_uint16_linear_scaled(CoderHelper H)(void * outputp, int width_times_channels, const(float)* encode )
{
  @restrict ushort* output = cast(ushort*) outputp;
  ushort * end_output = ( cast(ushort*) output ) + width_times_channels;

  {
    if ( width_times_channels >= stbir__simdfX_float_count*2 )
    {
      const(float)* end_encode_m8 = encode + width_times_channels - stbir__simdfX_float_count*2;
      end_output -= stbir__simdfX_float_count*2;
      for(;;)
      {
        stbir__simdfX e0, e1;
        stbir__simdiX i;
        STBIR_SIMD_NO_UNROLL(encode);
        stbir__simdfX_madd_mem( e0, STBIR_simd_point5X, STBIR_max_uint16_as_floatX, encode );
        stbir__simdfX_madd_mem( e1, STBIR_simd_point5X, STBIR_max_uint16_as_floatX, encode+stbir__simdfX_float_count );
        stbir__encode_simdfX_unflip!H( e0 );
        stbir__encode_simdfX_unflip!H( e1 );
        stbir__simdfX_pack_to_words( i, e0, e1 );
        stbir__simdiX_store( output, i );
        encode += stbir__simdfX_float_count*2;
        output += stbir__simdfX_float_count*2;
        if ( output <= end_output )
          continue;
        if ( output == ( end_output + stbir__simdfX_float_count*2 ) )
          break;
        output = end_output;     // backup and do last couple
        encode = end_encode_m8;
      }
      return;
    }
  }

  // try to do blocks of 4 when you can
  static if (H.stbir__coder_min_num != 3) // doesn't divide cleanly by four
  {
      output += 4;
      while( output <= end_output )
      {
        stbir__simdf e;
        stbir__simdi i;
        STBIR_NO_UNROLL(encode);
        stbir__simdf_load( e, encode );
        stbir__simdf_madd( e, STBIR_simd_point5, STBIR_max_uint16_as_float, e );
        stbir__encode_simdf4_unflip!H( e );
        stbir__simdf_pack_to_8words( i, e, e );  // only use first 4
        stbir__simdi_store2( output-4, i );
        output += 4;
        encode += 4;
      }
      output -= 4;
  }

    // do the remnants
    static if (H.stbir__coder_min_num < 4)
    {
        while( output < end_output )
        {
            stbir__simdf e;
            STBIR_NO_UNROLL(encode);
            stbir__simdf_madd1_mem( e, STBIR_simd_point5, STBIR_max_uint16_as_float, encode+H.stbir__encode_order0 ); output[0] = stbir__simdf_convert_float_to_short( e );
            static if (H.stbir__coder_min_num >= 2)
                stbir__simdf_madd1_mem( e, (STBIR_simd_point5), (STBIR_max_uint16_as_float), encode+H.stbir__encode_order1 ); output[1] = stbir__simdf_convert_float_to_short( e );
            static if (H.stbir__coder_min_num >= 3)
                stbir__simdf_madd1_mem( e, (STBIR_simd_point5), (STBIR_max_uint16_as_float), encode+H.stbir__encode_order2 ); output[2] = stbir__simdf_convert_float_to_short( e );
            output += H.stbir__coder_min_num;
            encode += H.stbir__coder_min_num;
        }
    }
}

void stbir__decode_uint16_linear(CoderHelper H)(float * decodep, int width_times_channels, const(void)* inputp)
{
  @restrict float* decode = decodep;
  float * decode_end = cast(float*) decode + width_times_channels;
  const(ushort)* input= cast(const(ushort)*) inputp;

  const(ushort)* end_input_m8 = input + width_times_channels - 8;
  if ( width_times_channels >= 8 )
  {
    decode_end -= 8;
    for(;;)
    {
      stbir__simdi i; stbir__simdi8 o;
      stbir__simdf8 of;
      STBIR_NO_UNROLL(decode);
      stbir__simdi_load( i, input );
      stbir__simdi8_expand_u16_to_u32( o, i );
      stbir__simdi8_convert_i32_to_float( of, o );
      stbir__decode_simdf8_flip!H( of );
      stbir__simdf8_store( decode + 0, of );
      decode += 8;
      input += 8;
      if ( decode <= decode_end )
        continue;
      if ( decode == ( decode_end + 8 ) )
        break;
      decode = decode_end; // backup and do last couple
      input = end_input_m8;
    }
    return;
  }

  // try to do blocks of 4 when you can
  static if (H.stbir__coder_min_num != 3)
  {
      decode += 4;
      while( decode <= decode_end )
      {
        STBIR_SIMD_NO_UNROLL(decode);
        decode[0-4] = (cast(float)(input[H.stbir__decode_order0]));
        decode[1-4] = (cast(float)(input[H.stbir__decode_order1]));
        decode[2-4] = (cast(float)(input[H.stbir__decode_order2]));
        decode[3-4] = (cast(float)(input[H.stbir__decode_order3]));
        decode += 4;
        input += 4;
      }
      decode -= 4;
  }

  // do the remnants
  static if (H.stbir__coder_min_num < 4)
  {
      while( decode < decode_end )
      {
        STBIR_NO_UNROLL(decode);
        decode[0] = (cast(float)(input[H.stbir__decode_order0]));
        static if (H.stbir__coder_min_num >= 2)
            decode[1] = (cast(float)(input[H.stbir__decode_order1]));
        static if (H.stbir__coder_min_num >= 3)
            decode[2] = (cast(float)(input[H.stbir__decode_order2]));
        decode += H.stbir__coder_min_num;
        input += H.stbir__coder_min_num;
      }
  }
}

void stbir__encode_uint16_linear(CoderHelper H)( void * outputp, int width_times_channels, const(float)* encode )
{
  @restrict ushort* output = cast(ushort*) outputp;
  ushort * end_output = ( cast(ushort*) output ) + width_times_channels;

  {
    if ( width_times_channels >= stbir__simdfX_float_count*2 )
    {
      const(float)* end_encode_m8 = encode + width_times_channels - stbir__simdfX_float_count*2;
      end_output -= stbir__simdfX_float_count*2;
      for(;;)
      {
        stbir__simdfX e0, e1;
        stbir__simdiX i;
        STBIR_SIMD_NO_UNROLL(encode);
        stbir__simdfX_add_mem( e0, STBIR_simd_point5X, encode );
        stbir__simdfX_add_mem( e1, STBIR_simd_point5X, encode+stbir__simdfX_float_count );
        stbir__encode_simdfX_unflip!H( e0 );
        stbir__encode_simdfX_unflip!H( e1 );
        stbir__simdfX_pack_to_words( i, e0, e1 );
        stbir__simdiX_store( output, i );
        encode += stbir__simdfX_float_count*2;
        output += stbir__simdfX_float_count*2;
        if ( output <= end_output )
          continue;
        if ( output == ( end_output + stbir__simdfX_float_count*2 ) )
          break;
        output = end_output; // backup and do last couple
        encode = end_encode_m8;
      }
      return;
    }
  }

  // try to do blocks of 4 when you can
  static if (H.stbir__coder_min_num != 3) // doesn't divide cleanly by four
  {
      output += 4;
      while( output <= end_output )
      {
        stbir__simdf e;
        stbir__simdi i;
        STBIR_NO_UNROLL(encode);
        stbir__simdf_load( e, encode );
        stbir__simdf_add( e, STBIR_simd_point5, e );
        stbir__encode_simdf4_unflip!H( e );
        stbir__simdf_pack_to_8words( i, e, e );  // only use first 4
        stbir__simdi_store2( output-4, i );
        output += 4;
        encode += 4;
      }
      output -= 4;
  }
}

void stbir__decode_half_float_linear(CoderHelper H)(float * decodep, int width_times_channels, const(void)* inputp)
{
  @restrict float* decode = decodep;
  float * decode_end = cast(float*) decode + width_times_channels;
  const(stbir__FP16)* input = cast(const(stbir__FP16)*)inputp;

  if ( width_times_channels >= 8 )
  {
    const(stbir__FP16)* end_input_m8 = input + width_times_channels - 8;
    decode_end -= 8;
    for(;;)
    {
      STBIR_NO_UNROLL(decode);

      stbir__half_to_float_SIMD( decode, input );
      static if (H.stbir__decode_swizzle)
      {
        stbir__simdf8 of;
        stbir__simdf8_load( of, decode );
        stbir__decode_simdf8_flip!H( of );
        stbir__simdf8_store( decode, of );
      }
      decode += 8;
      input += 8;
      if ( decode <= decode_end )
        continue;
      if ( decode == ( decode_end + 8 ) )
        break;
      decode = decode_end; // backup and do last couple
      input = end_input_m8;
    }
    return;
  }

  // try to do blocks of 4 when you can
  static if (H.stbir__coder_min_num != 3) // doesn't divide cleanly by four
  {
      decode += 4;
      while( decode <= decode_end )
      {
        STBIR_SIMD_NO_UNROLL(decode);
        decode[0-4] = stbir__half_to_float(input[H.stbir__decode_order0]);
        decode[1-4] = stbir__half_to_float(input[H.stbir__decode_order1]);
        decode[2-4] = stbir__half_to_float(input[H.stbir__decode_order2]);
        decode[3-4] = stbir__half_to_float(input[H.stbir__decode_order3]);
        decode += 4;
        input += 4;
      }
      decode -= 4;
  }
  // do the remnants
  static if (H.stbir__coder_min_num < 4)
  {
      while( decode < decode_end )
      {
        STBIR_NO_UNROLL(decode);
        decode[0] = stbir__half_to_float(input[H.stbir__decode_order0]);
        static if (H.stbir__coder_min_num >= 2)
            decode[1] = stbir__half_to_float(input[H.stbir__decode_order1]);
        static if (H.stbir__coder_min_num >= 3)
            decode[2] = stbir__half_to_float(input[H.stbir__decode_order2]);
        decode += H.stbir__coder_min_num;
        input += H.stbir__coder_min_num;
      }
  }
}

void stbir__encode_half_float_linear(CoderHelper H)( void * outputp, int width_times_channels, const(float)* encode )
{
  @restrict stbir__FP16* output = cast(stbir__FP16*) outputp;
  stbir__FP16* end_output = ( cast(stbir__FP16*) output ) + width_times_channels;

  if ( width_times_channels >= 8 )
  {
    const(float)* end_encode_m8 = encode + width_times_channels - 8;
    end_output -= 8;
    for(;;)
    {
      STBIR_SIMD_NO_UNROLL(encode);
      static if (H.stbir__decode_swizzle)
      {
        stbir__simdf8 of;
        stbir__simdf8_load( of, encode );
        stbir__encode_simdf8_unflip!H( of );
        stbir__float_to_half_SIMD( output, cast(float*)&of );
      }
      else
      {
        stbir__float_to_half_SIMD( output, encode );
      }
      encode += 8;
      output += 8;
      if ( output <= end_output )
        continue;
      if ( output == ( end_output + 8 ) )
        break;
      output = end_output; // backup and do last couple
      encode = end_encode_m8;
    }
    return;
  }

  // try to do blocks of 4 when you can
  static if (H.stbir__coder_min_num != 3) // doesn't divide cleanly by four
  {
      output += 4;
      while( output <= end_output )
      {
        STBIR_SIMD_NO_UNROLL(output);
        output[0-4] = stbir__float_to_half(encode[H.stbir__encode_order0]);
        output[1-4] = stbir__float_to_half(encode[H.stbir__encode_order1]);
        output[2-4] = stbir__float_to_half(encode[H.stbir__encode_order2]);
        output[3-4] = stbir__float_to_half(encode[H.stbir__encode_order3]);
        output += 4;
        encode += 4;
      }
      output -= 4;
  }

  // do the remnants
  static if (H.stbir__coder_min_num < 4) // doesn't divide cleanly by four
  {
      while( output < end_output )
      {
        STBIR_NO_UNROLL(output);
        output[0] = stbir__float_to_half(encode[H.stbir__encode_order0]);
        static if (H.stbir__coder_min_num >= 2)
            output[1] = stbir__float_to_half(encode[H.stbir__encode_order1]);
        static if (H.stbir__coder_min_num >= 3)
            output[2] = stbir__float_to_half(encode[H.stbir__encode_order2]);
        output += H.stbir__coder_min_num;
        encode += H.stbir__coder_min_num;
      }
  }
}

void stbir__decode_float_linear(CoderHelper H)(float * decodep, int width_times_channels, const(void)* inputp)
{
    static if (H.stbir__decode_swizzle)
    {
        @restrict float* decode = decodep;
        float * decode_end = cast(float*) decode + width_times_channels;
        const(float)* input = cast(const(float)*)inputp;

        if ( width_times_channels >= 16 )
        {
            const(float)* end_input_m16 = input + width_times_channels - 16;
            decode_end -= 16;
            for(;;)
            {
                STBIR_NO_UNROLL(decode);
                static if (H.stbir__decode_swizzle)
                {
                    stbir__simdf8 of0,of1;
                    stbir__simdf8_load( of0, input );
                    stbir__simdf8_load( of1, input+8 );
                    stbir__decode_simdf8_flip!H( of0 );
                    stbir__decode_simdf8_flip!H( of1 );
                    stbir__simdf8_store( decode, of0 );
                    stbir__simdf8_store( decode+8, of1 );
                }
                decode += 16;
                input += 16;
                if ( decode <= decode_end )
                    continue;
                if ( decode == ( decode_end + 16 ) )
                    break;
                decode = decode_end; // backup and do last couple
                input = end_input_m16;
            }
            return;
        }

        // try to do blocks of 4 when you can
        static if (H.stbir__coder_min_num != 3) // doesn't divide cleanly by four
        {
            decode += 4;
            while( decode <= decode_end )
            {
                STBIR_SIMD_NO_UNROLL(decode);
                decode[0-4] = input[H.stbir__decode_order0];
                decode[1-4] = input[H.stbir__decode_order1];
                decode[2-4] = input[H.stbir__decode_order2];
                decode[3-4] = input[H.stbir__decode_order3];
                decode += 4;
                input += 4;
            }
            decode -= 4;
        }

        static if (H.stbir__coder_min_num < 4)
        {
            while( decode < decode_end )
            {
                STBIR_NO_UNROLL(decode);
                decode[0] = input[H.stbir__decode_order0];
                static if (H.stbir__coder_min_num >= 2)
                    decode[1] = input[H.stbir__decode_order1];
                static if (H.stbir__coder_min_num >= 3)
                    decode[2] = input[H.stbir__decode_order2];
                decode += H.stbir__coder_min_num;
                input += H.stbir__coder_min_num;
            }
        }
    }
    else
    {
        if ( cast(void*)decodep != inputp )
            STBIR_MEMCPY( decodep, inputp, width_times_channels * float.sizeof );
    }
}

// Note: we choose to never clamp float output
// so STBIR_FLOAT_HIGH_CLAMP and STBIR_FLOAT_LO_CLAMP aren't defined

void stbir__encode_float_linear(CoderHelper H)(void * outputp, int width_times_channels, const(float)* encode)
{
    static if (!H.stbir__decode_swizzle)
    {
        if ( cast(void*)outputp != cast(void*) encode )
            STBIR_MEMCPY( outputp, encode, width_times_channels * float.sizeof );
    }
    else
    {
        @restrict float* output = cast(float*) outputp;
        float * end_output = ( cast(float*) output ) + width_times_channels;

        static void stbir_scalar_hi_clamp(ref float v) { }
        static void stbir_scalar_lo_clamp(ref float v) { }

        if ( width_times_channels >= ( stbir__simdfX_float_count * 2 ) )
        {
            const(float)* end_encode_m8 = encode + width_times_channels - ( stbir__simdfX_float_count * 2 );
            end_output -= ( stbir__simdfX_float_count * 2 );
            for(;;)
            {
                stbir__simdfX e0, e1;
                STBIR_SIMD_NO_UNROLL(encode);
                stbir__simdfX_load( e0, encode );
                stbir__simdfX_load( e1, encode+stbir__simdfX_float_count );
                stbir__encode_simdfX_unflip!H( e0 );
                stbir__encode_simdfX_unflip!H( e1 );
                stbir__simdfX_store( output, e0 );
                stbir__simdfX_store( output+stbir__simdfX_float_count, e1 );
                encode += stbir__simdfX_float_count * 2;
                output += stbir__simdfX_float_count * 2;
                if ( output < end_output )
                    continue;
                if ( output == ( end_output + ( stbir__simdfX_float_count * 2 ) ) )
                    break;
                output = end_output; // backup and do last couple
                encode = end_encode_m8;
            }
            return;
        }

        // try to do blocks of 4 when you can
        static if (H.stbir__coder_min_num != 3) // doesn't divide cleanly by four
        {
            output += 4;
            while( output <= end_output )
            {
                stbir__simdf e0;
                STBIR_NO_UNROLL(encode);
                stbir__simdf_load( e0, encode );
                stbir__encode_simdf4_unflip!H( e0 );
                stbir__simdf_store( output-4, e0 );
                output += 4;
                encode += 4;
            }
            output -= 4;
        }
    }
}

static immutable float[256] stbir__srgb_uchar_to_linear_float =
[
    0.000000f, 0.000304f, 0.000607f, 0.000911f, 0.001214f, 0.001518f, 0.001821f, 0.002125f, 0.002428f, 0.002732f, 0.003035f,
    0.003347f, 0.003677f, 0.004025f, 0.004391f, 0.004777f, 0.005182f, 0.005605f, 0.006049f, 0.006512f, 0.006995f, 0.007499f,
    0.008023f, 0.008568f, 0.009134f, 0.009721f, 0.010330f, 0.010960f, 0.011612f, 0.012286f, 0.012983f, 0.013702f, 0.014444f,
    0.015209f, 0.015996f, 0.016807f, 0.017642f, 0.018500f, 0.019382f, 0.020289f, 0.021219f, 0.022174f, 0.023153f, 0.024158f,
    0.025187f, 0.026241f, 0.027321f, 0.028426f, 0.029557f, 0.030713f, 0.031896f, 0.033105f, 0.034340f, 0.035601f, 0.036889f,
    0.038204f, 0.039546f, 0.040915f, 0.042311f, 0.043735f, 0.045186f, 0.046665f, 0.048172f, 0.049707f, 0.051269f, 0.052861f,
    0.054480f, 0.056128f, 0.057805f, 0.059511f, 0.061246f, 0.063010f, 0.064803f, 0.066626f, 0.068478f, 0.070360f, 0.072272f,
    0.074214f, 0.076185f, 0.078187f, 0.080220f, 0.082283f, 0.084376f, 0.086500f, 0.088656f, 0.090842f, 0.093059f, 0.095307f,
    0.097587f, 0.099899f, 0.102242f, 0.104616f, 0.107023f, 0.109462f, 0.111932f, 0.114435f, 0.116971f, 0.119538f, 0.122139f,
    0.124772f, 0.127438f, 0.130136f, 0.132868f, 0.135633f, 0.138432f, 0.141263f, 0.144128f, 0.147027f, 0.149960f, 0.152926f,
    0.155926f, 0.158961f, 0.162029f, 0.165132f, 0.168269f, 0.171441f, 0.174647f, 0.177888f, 0.181164f, 0.184475f, 0.187821f,
    0.191202f, 0.194618f, 0.198069f, 0.201556f, 0.205079f, 0.208637f, 0.212231f, 0.215861f, 0.219526f, 0.223228f, 0.226966f,
    0.230740f, 0.234551f, 0.238398f, 0.242281f, 0.246201f, 0.250158f, 0.254152f, 0.258183f, 0.262251f, 0.266356f, 0.270498f,
    0.274677f, 0.278894f, 0.283149f, 0.287441f, 0.291771f, 0.296138f, 0.300544f, 0.304987f, 0.309469f, 0.313989f, 0.318547f,
    0.323143f, 0.327778f, 0.332452f, 0.337164f, 0.341914f, 0.346704f, 0.351533f, 0.356400f, 0.361307f, 0.366253f, 0.371238f,
    0.376262f, 0.381326f, 0.386430f, 0.391573f, 0.396755f, 0.401978f, 0.407240f, 0.412543f, 0.417885f, 0.423268f, 0.428691f,
    0.434154f, 0.439657f, 0.445201f, 0.450786f, 0.456411f, 0.462077f, 0.467784f, 0.473532f, 0.479320f, 0.485150f, 0.491021f,
    0.496933f, 0.502887f, 0.508881f, 0.514918f, 0.520996f, 0.527115f, 0.533276f, 0.539480f, 0.545725f, 0.552011f, 0.558340f,
    0.564712f, 0.571125f, 0.577581f, 0.584078f, 0.590619f, 0.597202f, 0.603827f, 0.610496f, 0.617207f, 0.623960f, 0.630757f,
    0.637597f, 0.644480f, 0.651406f, 0.658375f, 0.665387f, 0.672443f, 0.679543f, 0.686685f, 0.693872f, 0.701102f, 0.708376f,
    0.715694f, 0.723055f, 0.730461f, 0.737911f, 0.745404f, 0.752942f, 0.760525f, 0.768151f, 0.775822f, 0.783538f, 0.791298f,
    0.799103f, 0.806952f, 0.814847f, 0.822786f, 0.830770f, 0.838799f, 0.846873f, 0.854993f, 0.863157f, 0.871367f, 0.879622f,
    0.887923f, 0.896269f, 0.904661f, 0.913099f, 0.921582f, 0.930111f, 0.938686f, 0.947307f, 0.955974f, 0.964686f, 0.973445f,
    0.982251f, 0.991102f, 1.0f
];


// From https://gist.github.com/rygorous/2203834

static immutable stbir_uint32[104] fp32_to_srgb8_tab4 =
[
    0x0073000d, 0x007a000d, 0x0080000d, 0x0087000d, 0x008d000d, 0x0094000d, 0x009a000d, 0x00a1000d,
    0x00a7001a, 0x00b4001a, 0x00c1001a, 0x00ce001a, 0x00da001a, 0x00e7001a, 0x00f4001a, 0x0101001a,
    0x010e0033, 0x01280033, 0x01410033, 0x015b0033, 0x01750033, 0x018f0033, 0x01a80033, 0x01c20033,
    0x01dc0067, 0x020f0067, 0x02430067, 0x02760067, 0x02aa0067, 0x02dd0067, 0x03110067, 0x03440067,
    0x037800ce, 0x03df00ce, 0x044600ce, 0x04ad00ce, 0x051400ce, 0x057b00c5, 0x05dd00bc, 0x063b00b5,
    0x06970158, 0x07420142, 0x07e30130, 0x087b0120, 0x090b0112, 0x09940106, 0x0a1700fc, 0x0a9500f2,
    0x0b0f01cb, 0x0bf401ae, 0x0ccb0195, 0x0d950180, 0x0e56016e, 0x0f0d015e, 0x0fbc0150, 0x10630143,
    0x11070264, 0x1238023e, 0x1357021d, 0x14660201, 0x156601e9, 0x165a01d3, 0x174401c0, 0x182401af,
    0x18fe0331, 0x1a9602fe, 0x1c1502d2, 0x1d7e02ad, 0x1ed4028d, 0x201a0270, 0x21520256, 0x227d0240,
    0x239f0443, 0x25c003fe, 0x27bf03c4, 0x29a10392, 0x2b6a0367, 0x2d1d0341, 0x2ebe031f, 0x304d0300,
    0x31d105b0, 0x34a80555, 0x37520507, 0x39d504c5, 0x3c37048b, 0x3e7c0458, 0x40a8042a, 0x42bd0401,
    0x44c20798, 0x488e071e, 0x4c1c06b6, 0x4f76065d, 0x52a50610, 0x55ac05cc, 0x5892058f, 0x5b590559,
    0x5e0c0a23, 0x631c0980, 0x67db08f6, 0x6c55087f, 0x70940818, 0x74a007bd, 0x787d076c, 0x7c330723,
];

ubyte stbir__linear_to_srgb_uchar(float in_)
{
    stbir__FP32 almostone;
    almostone.u = 0x3f7fffff;
    stbir__FP32 minval;
    minval.u = (127-13) << 23;

    stbir_uint32 tab,bias,scale,t;
    stbir__FP32 f;

    // Clamp to [2^(-13), 1-eps]; these two values map to 0 and 1, respectively.
    // The tests are carefully written so that NaNs map to 0, same as in the reference
    // implementation.
    if (!(in_ > minval.f)) // written this way to catch NaNs
        return 0;
    if (in_ > almostone.f)
        return 255;

    // Do the table lookup and unpack bias, scale
    f.f = in_;
    tab = fp32_to_srgb8_tab4[(f.u - minval.u) >> 20];
    bias = (tab >> 16) << 9;
    scale = tab & 0xffff;

    // Grab next-highest mantissa bits and perform linear interpolation
    t = (f.u >> 12) & 0xff;
    return cast(ubyte) ((bias + scale*t) >> 16);
}

