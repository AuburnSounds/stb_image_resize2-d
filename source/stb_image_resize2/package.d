module stb_image_resize2;

nothrow @nogc @system:

/* stb_image_resize2 - v2.07 - public domain image resizing

   by Jeff Roberts (v2) and Jorge L Rodriguez
   http://github.com/nothings/stb

   Can be threaded with the extended API. SSE2, AVX, Neon and WASM SIMD support. Only
   scaling and translation is supported, no rotations or shears.

   COMPILING & LINKING
      In one C/C++ file that #includes this file, do this:
         #define STB_IMAGE_RESIZE_IMPLEMENTATION
      before the #include. That will create the implementation in that file.

   PORTING FROM VERSION 1

      The API has changed. You can continue to use the old version of stb_image_resize.h,
      which is available in the "deprecated/" directory.

      If you're using the old simple-to-use API, porting is straightforward.
      (For more advanced APIs, read the documentation.)

        stbir_resize_uint8():
          - call `stbir_resize_uint8_linear`, cast channel count to `stbir_pixel_layout`

        stbir_resize_float():
          - call `stbir_resize_float_linear`, cast channel count to `stbir_pixel_layout`

        stbir_resize_uint8_srgb():
          - function name is unchanged
          - cast channel count to `stbir_pixel_layout`
          - above is sufficient unless your image has alpha and it's not RGBA/BGRA
            - in that case, follow the below instructions for stbir_resize_uint8_srgb_edgemode

        stbir_resize_uint8_srgb_edgemode()
          - switch to the "medium complexity" API
          - stbir_resize(), very similar API but a few more parameters:
            - pixel_layout: cast channel count to `stbir_pixel_layout`
            - data_type:    STBIR_TYPE_UINT8_SRGB
            - edge:         unchanged (STBIR_EDGE_WRAP, etc.)
            - filter:       STBIR_FILTER_DEFAULT
          - which channel is alpha is specified in stbir_pixel_layout, see enum for details

   EASY API CALLS:
     Easy API downsamples w/Mitchell filter, upsamples w/cubic interpolation, clamps to edge.

     stbir_resize_uint8_srgb( input_pixels,  input_w,  input_h,  input_stride_in_bytes,
                              output_pixels, output_w, output_h, output_stride_in_bytes,
                              pixel_layout_enum )

     stbir_resize_uint8_linear( input_pixels,  input_w,  input_h,  input_stride_in_bytes,
                                output_pixels, output_w, output_h, output_stride_in_bytes,
                                pixel_layout_enum )

     stbir_resize_float_linear( input_pixels,  input_w,  input_h,  input_stride_in_bytes,
                                output_pixels, output_w, output_h, output_stride_in_bytes,
                                pixel_layout_enum )

     If you pass NULL or zero for the output_pixels, we will allocate the output buffer
     for you and return it from the function (free with free() or STBIR_FREE).
     As a special case, XX_stride_in_bytes of 0 means packed continuously in memory.

   API LEVELS
      There are three levels of API - easy-to-use, medium-complexity and extended-complexity.

      See the "header file" section of the source for API documentation.

   ADDITIONAL DOCUMENTATION

      MEMORY ALLOCATION
         By default, we use malloc and free for memory allocation.  To override the
         memory allocation, before the implementation #include, add a:

            #define STBIR_MALLOC(size,user_data) ...
            #define STBIR_FREE(ptr,user_data)   ...

         Each resize makes exactly one call to malloc/free (unless you use the
         extended API where you can do one allocation for many resizes). Under
         address sanitizer, we do separate allocations to find overread/writes.

      PERFORMANCE
         This library was written with an emphasis on performance. When testing
         stb_image_resize with RGBA, the fastest mode is STBIR_4CHANNEL with
         STBIR_TYPE_UINT8 pixels and CLAMPed edges (which is what many other resize
         libs do by default). Also, make sure SIMD is turned on of course (default
         for 64-bit targets). Avoid WRAP edge mode if you want the fastest speed.

         This library also comes with profiling built-in. If you define STBIR_PROFILE,
         you can use the advanced API and get low-level profiling information by
         calling stbir_resize_extended_profile_info() or stbir_resize_split_profile_info()
         after a resize.

      SIMD
         Most of the routines have optimized SSE2, AVX, NEON and WASM versions.

         On Microsoft compilers, we automatically turn on SIMD for 64-bit x64 and
         ARM; for 32-bit x86 and ARM, you select SIMD mode by defining STBIR_SSE2 or
         STBIR_NEON. For AVX and AVX2, we auto-select it by detecting the /arch:AVX
         or /arch:AVX2 switches. You can also always manually turn SSE2, AVX or AVX2
         support on by defining STBIR_SSE2, STBIR_AVX or STBIR_AVX2.

         On Linux, SSE2 and Neon is on by default for 64-bit x64 or ARM64. For 32-bit,
         we select x86 SIMD mode by whether you have -msse2, -mavx or -mavx2 enabled
         on the command line. For 32-bit ARM, you must pass -mfpu=neon-vfpv4 for both
         clang and GCC, but GCC also requires an additional -mfp16-format=ieee to
         automatically enable NEON.

         On x86 platforms, you can also define STBIR_FP16C to turn on FP16C instructions
         for converting back and forth to half-floats. This is autoselected when we
         are using AVX2. Clang and GCC also require the -mf16c switch. ARM always uses
         the built-in half float hardware NEON instructions.

         You can also tell us to use multiply-add instructions with STBIR_USE_FMA.
         Because x86 doesn't always have fma, we turn it off by default to maintain
         determinism across all platforms. If you don't care about non-FMA determinism
         and are willing to restrict yourself to more recent x86 CPUs (around the AVX
         timeframe), then fma will give you around a 15% speedup.

         You can force off SIMD in all cases by defining STBIR_NO_SIMD. You can turn
         off AVX or AVX2 specifically with STBIR_NO_AVX or STBIR_NO_AVX2. AVX is 10%
         to 40% faster, and AVX2 is generally another 12%.

      ALPHA CHANNEL
         Most of the resizing functions provide the ability to control how the alpha
         channel of an image is processed.

         When alpha represents transparency, it is important that when combining
         colors with filtering, the pixels should not be treated equally; they
         should use a weighted average based on their alpha values. For example,
         if a pixel is 1% opaque bright green and another pixel is 99% opaque
         black and you average them, the average will be 50% opaque, but the
         unweighted average and will be a middling green color, while the weighted
         average will be nearly black. This means the unweighted version introduced
         green energy that didn't exist in the source image.

         (If you want to know why this makes sense, you can work out the math for
         the following: consider what happens if you alpha composite a source image
         over a fixed color and then average the output, vs. if you average the
         source image pixels and then composite that over the same fixed color.
         Only the weighted average produces the same result as the ground truth
         composite-then-average result.)

         Therefore, it is in general best to "alpha weight" the pixels when applying
         filters to them. This essentially means multiplying the colors by the alpha
         values before combining them, and then dividing by the alpha value at the
         end.

         The computer graphics industry introduced a technique called "premultiplied
         alpha" or "associated alpha" in which image colors are stored in image files
         already multiplied by their alpha. This saves some math when compositing,
         and also avoids the need to divide by the alpha at the end (which is quite
         inefficient). However, while premultiplied alpha is common in the movie CGI
         industry, it is not commonplace in other industries like videogames, and most
         consumer file formats are generally expected to contain not-premultiplied
         colors. For example, Photoshop saves PNG files "unpremultiplied", and web
         browsers like Chrome and Firefox expect PNG images to be unpremultiplied.

         Note that there are three possibilities that might describe your image
         and resize expectation:

             1. images are not premultiplied, alpha weighting is desired
             2. images are not premultiplied, alpha weighting is not desired
             3. images are premultiplied

         Both case #2 and case #3 require the exact same math: no alpha weighting
         should be applied or removed. Only case 1 requires extra math operations;
         the other two cases can be handled identically.

         stb_image_resize expects case #1 by default, applying alpha weighting to
         images, expecting the input images to be unpremultiplied. This is what the
         COLOR+ALPHA buffer types tell the resizer to do.

         When you use the pixel layouts STBIR_RGBA, STBIR_BGRA, STBIR_ARGB,
         STBIR_ABGR, STBIR_RX, or STBIR_XR you are telling us that the pixels are
         non-premultiplied. In these cases, the resizer will alpha weight the colors
         (effectively creating the premultiplied image), do the filtering, and then
         convert back to non-premult on exit.

         When you use the pixel layouts STBIR_RGBA_PM, STBIR_RGBA_PM, STBIR_RGBA_PM,
         STBIR_RGBA_PM, STBIR_RX_PM or STBIR_XR_PM, you are telling that the pixels
         ARE premultiplied. In this case, the resizer doesn't have to do the
         premultipling - it can filter directly on the input. This about twice as
         fast as the non-premultiplied case, so it's the right option if your data is
         already setup correctly.

         When you use the pixel layout STBIR_4CHANNEL or STBIR_2CHANNEL, you are
         telling us that there is no channel that represents transparency; it may be
         RGB and some unrelated fourth channel that has been stored in the alpha
         channel, but it is actually not alpha. No special processing will be
         performed.

         The difference between the generic 4 or 2 channel layouts, and the
         specialized _PM versions is with the _PM versions you are telling us that
         the data *is* alpha, just don't premultiply it. That's important when
         using SRGB pixel formats, we need to know where the alpha is, because
         it is converted linearly (rather than with the SRGB converters).

         Because alpha weighting produces the same effect as premultiplying, you
         even have the option with non-premultiplied inputs to let the resizer
         produce a premultiplied output. Because the intially computed alpha-weighted
         output image is effectively premultiplied, this is actually more performant
         than the normal path which un-premultiplies the output image as a final step.

         Finally, when converting both in and out of non-premulitplied space (for
         example, when using STBIR_RGBA), we go to somewhat heroic measures to
         ensure that areas with zero alpha value pixels get something reasonable
         in the RGB values. If you don't care about the RGB values of zero alpha
         pixels, you can call the stbir_set_non_pm_alpha_speed_over_quality()
         function - this runs a premultiplied resize about 25% faster. That said,
         when you really care about speed, using premultiplied pixels for both in
         and out (STBIR_RGBA_PM, etc) much faster than both of these premultiplied
         options.

      PIXEL LAYOUT CONVERSION
         The resizer can convert from some pixel layouts to others. When using the
         stbir_set_pixel_layouts(), you can, for example, specify STBIR_RGBA
         on input, and STBIR_ARGB on output, and it will re-organize the channels
         during the resize. Currently, you can only convert between two pixel
         layouts with the same number of channels.

      DETERMINISM
         We commit to being deterministic (from x64 to ARM to scalar to SIMD, etc).
         This requires compiling with fast-math off (using at least /fp:precise).
         Also, you must turn off fp-contracting (which turns mult+adds into fmas)!
         We attempt to do this with pragmas, but with Clang, you usually want to add
         -ffp-contract=off to the command line as well.

         For 32-bit x86, you must use SSE and SSE2 codegen for determinism. That is,
         if the scalar x87 unit gets used at all, we immediately lose determinism.
         On Microsoft Visual Studio 2008 and earlier, from what we can tell there is
         no way to be deterministic in 32-bit x86 (some x87 always leaks in, even
         with fp:strict). On 32-bit x86 GCC, determinism requires both -msse2 and
         -fpmath=sse.

         Note that we will not be deterministic with float data containing NaNs -
         the NaNs will propagate differently on different SIMD and platforms.

         If you turn on STBIR_USE_FMA, then we will be deterministic with other
         fma targets, but we will differ from non-fma targets (this is unavoidable,
         because a fma isn't simply an add with a mult - it also introduces a
         rounding difference compared to non-fma instruction sequences.

      FLOAT PIXEL FORMAT RANGE
         Any range of values can be used for the non-alpha float data that you pass
         in (0 to 1, -1 to 1, whatever). However, if you are inputting float values
         but *outputting* bytes or shorts, you must use a range of 0 to 1 so that we
         scale back properly. The alpha channel must also be 0 to 1 for any format
         that does premultiplication prior to resizing.

         Note also that with float output, using filters with negative lobes, the
         output filtered values might go slightly out of range. You can define
         STBIR_FLOAT_LOW_CLAMP and/or STBIR_FLOAT_HIGH_CLAMP to specify the range
         to clamp to on output, if that's important.

      MAX/MIN SCALE FACTORS
         The input pixel resolutions are in integers, and we do the internal pointer
         resolution in size_t sized integers. However, the scale ratio from input
         resolution to output resolution is calculated in float form. This means
         the effective possible scale ratio is limited to 24 bits (or 16 million
         to 1). As you get close to the size of the float resolution (again, 16
         million pixels wide or high), you might start seeing float inaccuracy
         issues in general in the pipeline. If you have to do extreme resizes,
         you can usually do this is multiple stages (using float intermediate
         buffers).

      FLIPPED IMAGES
         Stride is just the delta from one scanline to the next. This means you can
         use a negative stride to handle inverted images (point to the final
         scanline and use a negative stride). You can invert the input or output,
         using negative strides.

      DEFAULT FILTERS
         For functions which don't provide explicit control over what filters to
         use, you can change the compile-time defaults with:

            #define STBIR_DEFAULT_FILTER_UPSAMPLE     STBIR_FILTER_something
            #define STBIR_DEFAULT_FILTER_DOWNSAMPLE   STBIR_FILTER_something

         See stbir_filter in the header-file section for the list of filters.

      NEW FILTERS
         A number of 1D filter kernels are supplied. For a list of supported
         filters, see the stbir_filter enum. You can install your own filters by
         using the stbir_set_filter_callbacks function.

      PROGRESS
         For interactive use with slow resize operations, you can use the the
         scanline callbacks in the extended API. It would have to be a *very* large
         image resample to need progress though - we're very fast.

      CEIL and FLOOR
         In scalar mode, the only functions we use from math.h are ceilf and floorf,
         but if you have your own versions, you can define the STBIR_CEILF(v) and
         STBIR_FLOORF(v) macros and we'll use them instead. In SIMD, we just use
         our own versions.

      ASSERT
         Define assert(boolval) to override assert() and not use assert.h

      FUTURE TODOS
        *  For polyphase integral filters, we just memcpy the coeffs to dupe
           them, but we should indirect and use the same coeff memory.
        *  Add pixel layout conversions for sensible different channel counts
           (maybe, 1.3/4, 3.4, 4.1, 3.1).
         * For SIMD encode and decode scanline routines, do any pre-aligning
           for bad input/output buffer alignments and pitch?
         * For very wide scanlines, we should we do vertical strips to stay within
           L2 cache. Maybe do chunks of 1K pixels at a time. There would be
           some pixel reconversion, but probably dwarfed by things falling out
           of cache. Probably also something possible with alternating between
           scattering and gathering at high resize scales?
         * Rewrite the coefficient generator to do many at once.
         * AVX-512 vertical kernels - worried about downclocking here.
         * Convert the reincludes to macros when we know they aren't changing.
         * Experiment with pivoting the horizontal and always using the
           vertical filters (which are faster, but perhaps not enough to overcome
           the pivot cost and the extra memory touches). Need to buffer the whole
           image so have to balance memory use.
         * Most of our code is internally function pointers, should we compile
           all the SIMD stuff always and dynamically dispatch?

   CONTRIBUTORS
      Jeff Roberts: 2.0 implementation, optimizations, SIMD
      Martins Mozeiko: NEON simd, WASM simd, clang and GCC whisperer.
      Fabian Giesen: half float and srgb converters
      Sean Barrett: API design, optimizations
      Jorge L Rodriguez: Original 1.0 implementation
      Aras Pranckevicius: bugfixes
      Nathan Reed: warning fixes for 1.0

   REVISIONS
      2.07 (2024-05-24) fix for slow final split during threaded conversions of very 
                          wide scanlines when downsampling (caused by extra input 
                          converting), fix for wide scanline resamples with many 
                          splits (int overflow), fix GCC warning.
      2.06 (2024-02-10) fix for identical width/height 3x or more down-scaling 
                          undersampling a single row on rare resize ratios (about 1%)
      2.05 (2024-02-07) fix for 2 pixel to 1 pixel resizes with wrap (thanks Aras)
                        fix for output callback (thanks Julien Koenen)
      2.04 (2023-11-17) fix for rare AVX bug, shadowed symbol (thanks Nikola Smiljanic).
      2.03 (2023-11-01) ASAN and TSAN warnings fixed, minor tweaks.
      2.00 (2023-10-10) mostly new source: new api, optimizations, simd, vertical-first, etc
                          (2x-5x faster without simd, 4x-12x faster with simd)
                          (in some cases, 20x to 40x faster - resizing to very small for example)
      0.96 (2019-03-04) fixed warnings
      0.95 (2017-07-23) fixed warnings
      0.94 (2017-03-18) fixed warnings
      0.93 (2017-03-03) fixed bug with certain combinations of heights
      0.92 (2017-01-02) fix integer overflow on large (>2GB) images
      0.91 (2016-04-02) fix warnings; fix handling of subpixel regions
      0.90 (2014-09-17) first released version

   LICENSE
     See end of file for license information.
*/


// PERF: our translation uses AVX2 intrinsics, since intel-intrinsics is portable
// I'm not sure if it's faster than translating with SSE intrinsics.

import inteli.avx2intrin;
import core.stdc.string: memcpy;
import core.stdc.stdlib: malloc, free;
public import stb_image_resize2.types;
import stb_image_resize2.simd;
import stb_image_resize2.horizontals;
import stb_image_resize2.verticals;
import stb_image_resize2.coders;

static if (__VERSION__ >= 2098)
    import core.attribute: restrict;
else
    enum restrict = 0;

//////////////////////////////////////////////////////////////////////////////
////   start "header file" ///////////////////////////////////////////////////
//
// Easy-to-use API:
//
//     * stride is the offset between successive rows of image data
//        in memory, in bytes. specify 0 for packed continuously in memory
//     * colorspace is linear or sRGB as specified by function name
//     * Uses the default filters
//     * Uses edge mode clamped
//     * returned result is 1 for success or 0 in case of an error.
//===============================================================
//  Simple-complexity API
//
//    If output_pixels is NULL (0), then we will allocate the buffer and return it to you.
//--------------------------------
version(none)
{
    char* stbir_resize_uint8_srgb( const(char)*input_pixels , int input_w , int input_h, int input_stride_in_bytes,
                                   char *output_pixels, int output_w, int output_h, int output_stride_in_bytes,
                                   stbir_pixel_layout pixel_type );

    char * stbir_resize_uint8_linear( const(char)*input_pixels , int input_w , int input_h, int input_stride_in_bytes,
                                      char *output_pixels, int output_w, int output_h, int output_stride_in_bytes,
                                      stbir_pixel_layout pixel_type );

    float * stbir_resize_float_linear( const(float)* input_pixels , int input_w , int input_h, int input_stride_in_bytes,
                                       float *output_pixels, int output_w, int output_h, int output_stride_in_bytes,
                                       stbir_pixel_layout pixel_type );
}

//===============================================================
// Medium-complexity API
//
// This extends the easy-to-use API as follows:
//
//     * Can specify the datatype - U8, U8_SRGB, U16, FLOAT, HALF_FLOAT
//     * Edge wrap can selected explicitly
//     * Filter can be selected explicitly
//--------------------------------


// medium api
version(none)
{
     void *  stbir_resize( const void *input_pixels , int input_w , int input_h, int input_stride_in_bytes,
                           void *output_pixels, int output_w, int output_h, int output_stride_in_bytes,
                           stbir_pixel_layout pixel_layout, stbir_datatype data_type,
                           stbir_edge edge, stbir_filter filter );
}

//===============================================================
// Extended-complexity API
//
// This API exposes all resize functionality.
//
//     * Separate filter types for each axis
//     * Separate edge modes for each axis
//     * Separate input and output data types
//     * Can specify regions with subpixel correctness
//     * Can specify alpha flags
//     * Can specify a memory callback
//     * Can specify a callback data type for pixel input and output
//     * Can be threaded for a single resize
//     * Can be used to resize many frames without recalculating the sampler info
//
//  Use this API as follows:
//     1) Call the stbir_resize_init function on a local STBIR_RESIZE structure
//     2) Call any of the stbir_set functions
//     3) Optionally call stbir_build_samplers() if you are going to resample multiple times
//        with the same input and output dimensions (like resizing video frames)
//     4) Resample by calling stbir_resize_extended().
//     5) Call stbir_free_samplers() if you called stbir_build_samplers()
//--------------------------------

version(none)
{

    // First off, you must ALWAYS call stbir_resize_init on your resize structure before any of the other calls!
    void stbir_resize_init( STBIR_RESIZE * resize,
                            const(void)*input_pixels,  int input_w,  int input_h, int input_stride_in_bytes, // stride can be zero
                            void *output_pixels, int output_w, int output_h, int output_stride_in_bytes, // stride can be zero
                            stbir_pixel_layout pixel_layout, stbir_datatype data_type );

    //===============================================================
    // You can update these parameters any time after resize_init and there is no cost
    //--------------------------------
    void stbir_set_datatypes( STBIR_RESIZE * resize, stbir_datatype input_type, stbir_datatype output_type );
    void stbir_set_pixel_callbacks( STBIR_RESIZE * resize, stbir_input_callback input_cb, stbir_output_callback output_cb );   // no callbacks by default
    void stbir_set_user_data( STBIR_RESIZE * resize, void * user_data );                                               // pass back STBIR_RESIZE* by default
    void stbir_set_buffer_ptrs( STBIR_RESIZE * resize, const void * input_pixels, int input_stride_in_bytes, void * output_pixels, int output_stride_in_bytes );

    //===============================================================


    //===============================================================
    // If you call any of these functions, you will trigger a sampler rebuild!
    //--------------------------------


    int stbir_set_pixel_layouts( STBIR_RESIZE * resize, stbir_pixel_layout input_pixel_layout, stbir_pixel_layout output_pixel_layout );  // sets new buffer layouts
    int stbir_set_edgemodes( STBIR_RESIZE * resize, stbir_edge horizontal_edge, stbir_edge vertical_edge );       // CLAMP by default

    int stbir_set_filters( STBIR_RESIZE * resize, stbir_filter horizontal_filter, stbir_filter vertical_filter ); // STBIR_DEFAULT_FILTER_UPSAMPLE/DOWNSAMPLE by default
    int stbir_set_filter_callbacks( STBIR_RESIZE * resize, stbir__kernel_callback horizontal_filter, stbir__support_callback horizontal_support, stbir__kernel_callback vertical_filter, stbir__support_callback vertical_support );

    int stbir_set_pixel_subrect( STBIR_RESIZE * resize, int subx, int suby, int subw, int subh );        // sets both sub-regions (full regions by default)
    int stbir_set_input_subrect( STBIR_RESIZE * resize, double s0, double t0, double s1, double t1 );    // sets input sub-region (full region by default)
    int stbir_set_output_pixel_subrect( STBIR_RESIZE * resize, int subx, int suby, int subw, int subh ); // sets output sub-region (full region by default)

    // when inputting AND outputting non-premultiplied alpha pixels, we use a slower but higher quality technique
    //   that fills the zero alpha pixel's RGB values with something plausible.  If you don't care about areas of
    //   zero alpha, you can call this function to get about a 25% speed improvement for STBIR_RGBA to STBIR_RGBA
    //   types of resizes.
    int stbir_set_non_pm_alpha_speed_over_quality( STBIR_RESIZE * resize, int non_pma_alpha_speed_over_quality );
    //===============================================================


    //===============================================================
    // You can call build_samplers to prebuild all the internal data we need to resample.
    //   Then, if you call resize_extended many times with the same resize, you only pay the
    //   cost once.
    // If you do call build_samplers, you MUST call free_samplers eventually.
    //--------------------------------

    // This builds the samplers and does one allocation
    int stbir_build_samplers( STBIR_RESIZE * resize );

    // You MUST call this, if you call stbir_build_samplers or stbir_build_samplers_with_splits
    void stbir_free_samplers( STBIR_RESIZE * resize );
    //===============================================================


    // And this is the main function to perform the resize synchronously on one thread.
    int stbir_resize_extended( STBIR_RESIZE * resize );

    //===============================================================
    // Use these functions for multithreading.
    //   1) You call stbir_build_samplers_with_splits first on the main thread
    //   2) Then stbir_resize_with_split on each thread
    //   3) stbir_free_samplers when done on the main thread
    //--------------------------------

    // This will build samplers for threading.
    //   You can pass in the number of threads you'd like to use (try_splits).
    //   It returns the number of splits (threads) that you can call it with.
    ///  It might be less if the image resize can't be split up that many ways.

    int stbir_build_samplers_with_splits( STBIR_RESIZE * resize, int try_splits );

    // This function does a split of the resizing (you call this fuction for each
    // split, on multiple threads). A split is a piece of the output resize pixel space.

    // Note that you MUST call stbir_build_samplers_with_splits before stbir_resize_extended_split!

    // Usually, you will always call stbir_resize_split with split_start as the thread_index
    //   and "1" for the split_count.
    // But, if you have a weird situation where you MIGHT want 8 threads, but sometimes
    //   only 4 threads, you can use 0,2,4,6 for the split_start's and use "2" for the
    //   split_count each time to turn in into a 4 thread resize. (This is unusual).

    int stbir_resize_extended_split( STBIR_RESIZE * resize, int split_start, int split_count );
    //===============================================================

    //===============================================================
    // Pixel Callbacks info:
    //--------------------------------

    //   The input callback is super flexible - it calls you with the input address
    //   (based on the stride and base pointer), it gives you an optional_output
    //   pointer that you can fill, or you can just return your own pointer into
    //   your own data.
    //
    //   You can also do conversion from non-supported data types if necessary - in
    //   this case, you ignore the input_ptr and just use the x and y parameters to
    //   calculate your own input_ptr based on the size of each non-supported pixel.
    //   (Something like the third example below.)
    //
    //   You can also install just an input or just an output callback by setting the
    //   callback that you don't want to zero.
    //
    //     First example, progress: (getting a callback that you can monitor the progress):
    //        void const * my_callback( void * optional_output, void const * input_ptr, int num_pixels, int x, int y, void * context )
    //        {
    //           percentage_done = y / input_height;
    //           return input_ptr;  // use buffer from call
    //        }
    //
    //     Next example, copying: (copy from some other buffer or stream):
    //        void const * my_callback( void * optional_output, void const * input_ptr, int num_pixels, int x, int y, void * context )
    //        {
    //           CopyOrStreamData( optional_output, other_data_src, num_pixels * pixel_width_in_bytes );
    //           return optional_output;  // return the optional buffer that we filled
    //        }
    //
    //     Third example, input another buffer without copying: (zero-copy from other buffer):
    //        void const * my_callback( void * optional_output, void const * input_ptr, int num_pixels, int x, int y, void * context )
    //        {
    //           void * pixels = ( cast(char*) other_image_base ) + ( y * other_image_stride ) + ( x * other_pixel_width_in_bytes );
    //           return pixels;       // return pointer to your data without copying
    //        }
    //
    //
    //   The output callback is considerably simpler - it just calls you so that you can dump
    //   out each scanline. You could even directly copy out to disk if you have a simple format
    //   like TGA or BMP. You can also convert to other output types here if you want.
    //
    //   Simple example:
    //        void const * my_output( void * output_ptr, int num_pixels, int y, void * context )
    //        {
    //           percentage_done = y / output_height;
    //           fwrite( output_ptr, pixel_width_in_bytes, num_pixels, output_file );
    //        }
    //===============================================================

}

////   end header file   /////////////////////////////////////////////////////

private:

void* STBIR_MALLOC(size_t size, void* user_data) @system
{
    return malloc(size);
}

void STBIR_FREE(void* p, void* user_data) @system
{
    free(p);
}

// Note: didn't port micro-profiler, was all removed.
// Note: STBIR__SEPARATE_ALLOCATIONS wasn't ported, only the merged allocation.
enum STBIR_DEFAULT_FILTER_UPSAMPLE = STBIR_FILTER_CATMULLROM;
enum STBIR_DEFAULT_FILTER_DOWNSAMPLE = STBIR_FILTER_MITCHELL;





enum float stbir__small_float = (cast(float)1 / (1 << 20) / (1 << 20) / (1 << 20) / (1 << 20) / (1 << 20) / (1 << 20));



union stbir__FP32
{
  uint u;
  float f;
}


enum STBIR_FORCE_GATHER_FILTER_SCANLINES_AMOUNT = 32; // when downsampling and <= 32 scanlines of buffering, use gather. gather used down to 1/8th scaling for 25% win.
enum STBIR_FORCE_MINIMUM_SCANLINES_FOR_SPLITS = 4; // when threading, what is the minimum number of scanlines for a split?







static float stbir__filter_trapezoid(float x, float scale, void * user_data)
{
  float halfscale = scale / 2;
  float t = 0.5f + halfscale;
  assert(scale <= 1);

  if ( x < 0.0f ) x = -x;

  if (x >= t)
    return 0.0f;
  else
  {
    float r = 0.5f - halfscale;
    if (x <= r)
      return 1.0f;
    else
      return (t - x) / scale;
  }
}

static float stbir__support_trapezoid(float scale, void * user_data)
{
  return 0.5f + scale / 2.0f;
}

static float stbir__filter_triangle(float x, float s, void * user_data)
{
  if ( x < 0.0f ) x = -x;

  if (x <= 1.0f)
    return 1.0f - x;
  else
    return 0.0f;
}

static float stbir__filter_point(float x, float s, void * user_data)
{
  return 1.0f;
}

static float stbir__filter_cubic(float x, float s, void * user_data)
{
  if ( x < 0.0f ) x = -x;

  if (x < 1.0f)
    return (4.0f + x*x*(3.0f*x - 6.0f))/6.0f;
  else if (x < 2.0f)
    return (8.0f + x*(-12.0f + x*(6.0f - x)))/6.0f;

  return (0.0f);
}

static float stbir__filter_catmullrom(float x, float s, void * user_data)
{
  if ( x < 0.0f ) x = -x;

  if (x < 1.0f)
    return 1.0f - x*x*(2.5f - 1.5f*x);
  else if (x < 2.0f)
    return 2.0f - x*(4.0f + x*(0.5f*x - 2.5f));

  return (0.0f);
}

static float stbir__filter_mitchell(float x, float s, void * user_data)
{
  if ( x < 0.0f ) x = -x;

  if (x < 1.0f)
    return (16.0f + x*x*(21.0f * x - 36.0f))/18.0f;
  else if (x < 2.0f)
    return (32.0f + x*(-60.0f + x*(36.0f - 7.0f*x)))/18.0f;

  return (0.0f);
}

static float stbir__support_zero(float s, void * user_data)
{
  return 0;
}

static float stbir__support_zeropoint5(float s, void * user_data)
{
  return 0.5f;
}

static float stbir__support_one(float s, void * user_data)
{
  return 1;
}

static float stbir__support_two(float s, void * user_data)
{
  return 2;
}

// This is the maximum number of input samples that can affect an output sample
// with the given filter from the output pixel's perspective
static int stbir__get_filter_pixel_width(stbir__support_callback support, float scale, void * user_data)
{
  if ( scale >= ( 1.0f-stbir__small_float ) ) // upscale
    return cast(int)STBIR_CEILF(support(1.0f/scale,user_data) * 2.0f);
  else
    return cast(int)STBIR_CEILF(support(scale,user_data) * 2.0f / scale);
}

// this is how many coefficents per run of the filter (which is different
//   from the filter_pixel_width depending on if we are scattering or gathering)
static int stbir__get_coefficient_width(stbir__sampler * samp, int is_gather, void * user_data)
{
  float scale = samp.scale_info.scale;
  stbir__support_callback support = samp.filter_support;

  switch( is_gather )
  {
    case 1:
      return cast(int)STBIR_CEILF(support(1.0f / scale, user_data) * 2.0f);
    case 2:
      return cast(int)STBIR_CEILF(support(scale, user_data) * 2.0f / scale);
    case 0:
      return cast(int)STBIR_CEILF(support(scale, user_data) * 2.0f);
    default:
      assert( (is_gather >= 0 ) && (is_gather <= 2 ) );
      return 0;
  }
}

static int stbir__get_contributors(stbir__sampler * samp, int is_gather)
{
  if (is_gather)
      return samp.scale_info.output_sub_size;
  else
      return (samp.scale_info.input_full_size + samp.filter_pixel_margin * 2);
}

static int stbir__edge_zero_full( int n, int max )
{
  return 0; // NOTREACHED
}

static int stbir__edge_clamp_full( int n, int max )
{
  if (n < 0)
    return 0;

  if (n >= max)
    return max - 1;

  return n; // NOTREACHED
}

static int stbir__edge_reflect_full( int n, int max )
{
  if (n < 0)
  {
    if (n > -max)
      return -n;
    else
      return max - 1;
  }

  if (n >= max)
  {
    int max2 = max * 2;
    if (n >= max2)
      return 0;
    else
      return max2 - n - 1;
  }

  return n; // NOTREACHED
}

static int stbir__edge_wrap_full( int n, int max )
{
  if (n >= 0)
    return (n % max);
  else
  {
    int m = (-n) % max;

    if (m != 0)
      m = max - m;

    return (m);
  }
}

alias stbir__edge_wrap_func = int function( int n, int max );

static immutable stbir__edge_wrap_func[4] stbir__edge_wrap_slow =
[
    &stbir__edge_clamp_full,    // STBIR_EDGE_CLAMP
    &stbir__edge_reflect_full,  // STBIR_EDGE_REFLECT
    &stbir__edge_wrap_full,     // STBIR_EDGE_WRAP
    &stbir__edge_zero_full,     // STBIR_EDGE_ZERO
];

static int stbir__edge_wrap(stbir_edge edge, int n, int max)
{
    // avoid per-pixel switch
    if (n >= 0 && n < max)
        return n;
    return stbir__edge_wrap_slow[edge]( n, max );
}

enum STBIR__MERGE_RUNS_PIXEL_THRESHOLD = 16;

// get information on the extents of a sampler
static void stbir__get_extents( stbir__sampler * samp, stbir__extents * scanline_extents ) @system
{
  int j, stop;
  int left_margin, right_margin;
  int min_n = 0x7fffffff, max_n = -0x7fffffff;
  int min_left = 0x7fffffff, max_left = -0x7fffffff;
  int min_right = 0x7fffffff, max_right = -0x7fffffff;
  stbir_edge edge = samp.edge;
  stbir__contributors* contributors = samp.contributors;
  int output_sub_size = samp.scale_info.output_sub_size;
  int input_full_size = samp.scale_info.input_full_size;
  int filter_pixel_margin = samp.filter_pixel_margin;

  assert( samp.is_gather );

  stop = output_sub_size;
  for (j = 0; j < stop; j++ )
  {
    assert( contributors[j].n1 >= contributors[j].n0 );
    if ( contributors[j].n0 < min_n )
    {
      min_n = contributors[j].n0;
      stop = j + filter_pixel_margin;  // if we find a new min, only scan another filter width
      if ( stop > output_sub_size ) stop = output_sub_size;
    }
  }

  stop = 0;
  for (j = output_sub_size - 1; j >= stop; j-- )
  {
    assert( contributors[j].n1 >= contributors[j].n0 );
    if ( contributors[j].n1 > max_n )
    {
      max_n = contributors[j].n1;
      stop = j - filter_pixel_margin;  // if we find a new max, only scan another filter width
      if (stop<0) stop = 0;
    }
  }

  assert( scanline_extents.conservative.n0 <= min_n );
  assert( scanline_extents.conservative.n1 >= max_n );

  // now calculate how much into the margins we really read
  left_margin = 0;
  if ( min_n < 0 )
  {
    left_margin = -min_n;
    min_n = 0;
  }

  right_margin = 0;
  if ( max_n >= input_full_size )
  {
    right_margin = max_n - input_full_size + 1;
    max_n = input_full_size - 1;
  }

  // index 1 is margin pixel extents (how many pixels we hang over the edge)
  scanline_extents.edge_sizes[0] = left_margin;
  scanline_extents.edge_sizes[1] = right_margin;

  // index 2 is pixels read from the input
  scanline_extents.spans[0].n0 = min_n;
  scanline_extents.spans[0].n1 = max_n;
  scanline_extents.spans[0].pixel_offset_for_input = min_n;

  // default to no other input range
  scanline_extents.spans[1].n0 = 0;
  scanline_extents.spans[1].n1 = -1;
  scanline_extents.spans[1].pixel_offset_for_input = 0;

  // don't have to do edge calc for zero clamp
  if ( edge == STBIR_EDGE_ZERO )
    return;

  // convert margin pixels to the pixels within the input (min and max)
  for( j = -left_margin ; j < 0 ; j++ )
  {
      int p = stbir__edge_wrap( edge, j, input_full_size );
      if ( p < min_left )
        min_left = p;
      if ( p > max_left )
        max_left = p;
  }

  for( j = input_full_size ; j < (input_full_size + right_margin) ; j++ )
  {
      int p = stbir__edge_wrap( edge, j, input_full_size );
      if ( p < min_right )
        min_right = p;
      if ( p > max_right )
        max_right = p;
  }

  // merge the left margin pixel region if it connects within 4 pixels of main pixel region
  if ( min_left != 0x7fffffff )
  {
    if ( ( ( min_left <= min_n ) && ( ( max_left  + STBIR__MERGE_RUNS_PIXEL_THRESHOLD ) >= min_n ) ) ||
         ( ( min_n <= min_left ) && ( ( max_n  + STBIR__MERGE_RUNS_PIXEL_THRESHOLD ) >= max_left ) ) )
    {
      scanline_extents.spans[0].n0 = min_n = stbir__min( min_n, min_left );
      scanline_extents.spans[0].n1 = max_n = stbir__max( max_n, max_left );
      scanline_extents.spans[0].pixel_offset_for_input = min_n;
      left_margin = 0;
    }
  }

  // merge the right margin pixel region if it connects within 4 pixels of main pixel region
  if ( min_right != 0x7fffffff )
  {
    if ( ( ( min_right <= min_n ) && ( ( max_right  + STBIR__MERGE_RUNS_PIXEL_THRESHOLD ) >= min_n ) ) ||
         ( ( min_n <= min_right ) && ( ( max_n  + STBIR__MERGE_RUNS_PIXEL_THRESHOLD ) >= max_right ) ) )
    {
      scanline_extents.spans[0].n0 = min_n = stbir__min( min_n, min_right );
      scanline_extents.spans[0].n1 = max_n = stbir__max( max_n, max_right );
      scanline_extents.spans[0].pixel_offset_for_input = min_n;
      right_margin = 0;
    }
  }

  assert( scanline_extents.conservative.n0 <= min_n );
  assert( scanline_extents.conservative.n1 >= max_n );

  // you get two ranges when you have the WRAP edge mode and you are doing just the a piece of the resize
  //   so you need to get a second run of pixels from the opposite side of the scanline (which you
  //   wouldn't need except for WRAP)


  // if we can't merge the min_left range, add it as a second range
  if ( ( left_margin ) && ( min_left != 0x7fffffff ) )
  {
    stbir__span * newspan = scanline_extents.spans.ptr + 1;
    assert( right_margin == 0 );
    if ( min_left < scanline_extents.spans[0].n0 )
    {
      scanline_extents.spans[1].pixel_offset_for_input = scanline_extents.spans[0].n0;
      scanline_extents.spans[1].n0 = scanline_extents.spans[0].n0;
      scanline_extents.spans[1].n1 = scanline_extents.spans[0].n1;
      --newspan;
    }
    newspan.pixel_offset_for_input = min_left;
    newspan.n0 = -left_margin;
    newspan.n1 = ( max_left - min_left ) - left_margin;
    scanline_extents.edge_sizes[0] = 0;  // don't need to copy the left margin, since we are directly decoding into the margin
    return;
  }

  // if we can't merge the min_left range, add it as a second range
  if ( ( right_margin ) && ( min_right != 0x7fffffff ) )
  {
    stbir__span * newspan = scanline_extents.spans.ptr + 1;
    if ( min_right < scanline_extents.spans[0].n0 )
    {
      scanline_extents.spans[1].pixel_offset_for_input = scanline_extents.spans[0].n0;
      scanline_extents.spans[1].n0 = scanline_extents.spans[0].n0;
      scanline_extents.spans[1].n1 = scanline_extents.spans[0].n1;
      --newspan;
    }
    newspan.pixel_offset_for_input = min_right;
    newspan.n0 = scanline_extents.spans[1].n1 + 1;
    newspan.n1 = scanline_extents.spans[1].n1 + 1 + ( max_right - min_right );
    scanline_extents.edge_sizes[1] = 0;  // don't need to copy the right margin, since we are directly decoding into the margin
    return;
  }
}

static void stbir__calculate_in_pixel_range( int * first_pixel, int * last_pixel, float out_pixel_center, float out_filter_radius, float inv_scale, float out_shift, int input_size, stbir_edge edge )
{
  int first, last;
  float out_pixel_influence_lowerbound = out_pixel_center - out_filter_radius;
  float out_pixel_influence_upperbound = out_pixel_center + out_filter_radius;

  float in_pixel_influence_lowerbound = (out_pixel_influence_lowerbound + out_shift) * inv_scale;
  float in_pixel_influence_upperbound = (out_pixel_influence_upperbound + out_shift) * inv_scale;

  first = cast(int)(STBIR_FLOORF(in_pixel_influence_lowerbound + 0.5f));
  last = cast(int)(STBIR_FLOORF(in_pixel_influence_upperbound - 0.5f));

  if ( edge == STBIR_EDGE_WRAP )
  {
    if ( first < -input_size )
      first = -input_size;
    if ( last >= (input_size*2))
      last = (input_size*2) - 1;
  }

  *first_pixel = first;
  *last_pixel = last;
}

void stbir__calculate_coefficients_for_gather_upsample( float out_filter_radius, 
                                                        stbir__kernel_callback kernel, 
                                                        stbir__scale_info * scale_info, 
                                                        int num_contributors, 
                                                        stbir__contributors* contributors, 
                                                        float* coefficient_group, int coefficient_width, 
                                                        stbir_edge edge, void * user_data ) @system
{
  int n, end;
  float inv_scale = scale_info.inv_scale;
  float out_shift = scale_info.pixel_shift;
  int input_size  = scale_info.input_full_size;
  int numerator = scale_info.scale_numerator;
  int polyphase = ( ( scale_info.scale_is_rational ) && ( numerator < num_contributors ) );

  // Looping through out pixels
  end = num_contributors; if ( polyphase ) end = numerator;
  for (n = 0; n < end; n++)
  {
    int i;
    int last_non_zero;
    float out_pixel_center = cast(float)n + 0.5f;
    float in_center_of_out = (out_pixel_center + out_shift) * inv_scale;

    int in_first_pixel, in_last_pixel;

    stbir__calculate_in_pixel_range( &in_first_pixel, &in_last_pixel, 
                                     out_pixel_center, out_filter_radius, 
                                     inv_scale, out_shift, input_size, edge );

    last_non_zero = -1;
    for (i = 0; i <= in_last_pixel - in_first_pixel; i++)
    {
      float in_pixel_center = cast(float)(i + in_first_pixel) + 0.5f;
      float coeff = kernel(in_center_of_out - in_pixel_center, inv_scale, user_data);

      // kill denormals
      if ( ( ( coeff < stbir__small_float ) && ( coeff > -stbir__small_float ) ) )
      {
        if ( i == 0 )  // if we're at the front, just eat zero contributors
        {
          assert ( ( in_last_pixel - in_first_pixel ) != 0 ); // there should be at least one contrib
          ++in_first_pixel;
          i--;
          continue;
        }
        coeff = 0;  // make sure is fully zero (should keep denormals away)
      }
      else
        last_non_zero = i;

      coefficient_group[i] = coeff;
    }

    in_last_pixel = last_non_zero+in_first_pixel; // kills trailing zeros
    contributors.n0 = in_first_pixel;
    contributors.n1 = in_last_pixel;

    assert(contributors.n1 >= contributors.n0);

    ++contributors;
    coefficient_group += coefficient_width;
  }
}

void stbir__insert_coeff( stbir__contributors * contribs, float * coeffs, int new_pixel, float new_coeff ) @system
{
  if ( new_pixel <= contribs.n1 )  // before the end
  {
    if ( new_pixel < contribs.n0 ) // before the front?
    {
      int j, o = contribs.n0 - new_pixel;
      for ( j = contribs.n1 - contribs.n0 ; j <= 0 ; j-- )
        coeffs[ j + o ] = coeffs[ j ];
      for ( j = 1 ; j < o ; j-- )
        coeffs[ j ] = coeffs[ 0 ];
      coeffs[ 0 ] = new_coeff;
      contribs.n0 = new_pixel;
    }
    else
    {
      coeffs[ new_pixel - contribs.n0 ] += new_coeff;
    }
  }
  else
  {
    int j, e = new_pixel - contribs.n0;
    for( j = ( contribs.n1 - contribs.n0 ) + 1 ; j < e ; j++ ) // clear in-betweens coeffs if there are any
      coeffs[j] = 0;

    coeffs[ e ] = new_coeff;
    contribs.n1 = new_pixel;
  }
}

static void stbir__calculate_out_pixel_range( int * first_pixel, int * last_pixel, float in_pixel_center, float in_pixels_radius, float scale, float out_shift, int out_size )
{
  float in_pixel_influence_lowerbound = in_pixel_center - in_pixels_radius;
  float in_pixel_influence_upperbound = in_pixel_center + in_pixels_radius;
  float out_pixel_influence_lowerbound = in_pixel_influence_lowerbound * scale - out_shift;
  float out_pixel_influence_upperbound = in_pixel_influence_upperbound * scale - out_shift;
  int out_first_pixel = cast(int)(STBIR_FLOORF(out_pixel_influence_lowerbound + 0.5f));
  int out_last_pixel = cast(int)(STBIR_FLOORF(out_pixel_influence_upperbound - 0.5f));

  if ( out_first_pixel < 0 )
    out_first_pixel = 0;
  if ( out_last_pixel >= out_size )
    out_last_pixel = out_size - 1;
  *first_pixel = out_first_pixel;
  *last_pixel = out_last_pixel;
}

void stbir__calculate_coefficients_for_gather_downsample( int start, int end, 
    float in_pixels_radius, stbir__kernel_callback kernel, stbir__scale_info * scale_info, 
    int coefficient_width, int num_contributors, stbir__contributors * contributors, 
    float * coefficient_group, void * user_data ) @system
{
  int in_pixel;
  int i;
  int first_out_inited = -1;
  float scale = scale_info.scale;
  float out_shift = scale_info.pixel_shift;
  int out_size = scale_info.output_sub_size;
  int numerator = scale_info.scale_numerator;
  int polyphase = ( ( scale_info.scale_is_rational ) && ( numerator < out_size ) );

  // Loop through the input pixels
  for (in_pixel = start; in_pixel < end; in_pixel++)
  {
    float in_pixel_center = cast(float)in_pixel + 0.5f;
    float out_center_of_in = in_pixel_center * scale - out_shift;
    int out_first_pixel, out_last_pixel;

    stbir__calculate_out_pixel_range( &out_first_pixel, &out_last_pixel, 
                                      in_pixel_center, in_pixels_radius, 
                                      scale, out_shift, out_size );

    if ( out_first_pixel > out_last_pixel )
      continue;

    // clamp or exit if we are using polyphase filtering, and the limit is up
    if ( polyphase )
    {
      // when polyphase, you only have to do coeffs up to the numerator count
      if ( out_first_pixel == numerator )
        break;

      // don't do any extra work, clamp last pixel at numerator too
      if ( out_last_pixel >= numerator )
        out_last_pixel = numerator - 1;
    }

    for (i = 0; i <= out_last_pixel - out_first_pixel; i++)
    {
      float out_pixel_center = cast(float)(i + out_first_pixel) + 0.5f;
      float x = out_pixel_center - out_center_of_in;
      float coeff = kernel(x, scale, user_data) * scale;

      // kill the coeff if it's too small (avoid denormals)
      if ( ( ( coeff < stbir__small_float ) && ( coeff > -stbir__small_float ) ) )
        coeff = 0.0f;

      {
        int out_ = i + out_first_pixel;
        float * coeffs = coefficient_group + out_ * coefficient_width;
        stbir__contributors * contribs = contributors + out_;

        // is this the first time this output pixel has been seen?  Init it.
        if ( out_ > first_out_inited )
        {
          assert( out_ == ( first_out_inited + 1 ) ); // ensure we have only advanced one at time
          first_out_inited = out_;
          contribs.n0 = in_pixel;
          contribs.n1 = in_pixel;
          coeffs[0]  = coeff;
        }
        else
        {
          // insert on end (always in order)
          if ( coeffs[0] == 0.0f )  // if the first coefficent is zero, then zap it for this coeffs
          {
            assert( ( in_pixel - contribs.n0 ) == 1 ); // ensure that when we zap, we're at the 2nd pos
            contribs.n0 = in_pixel;
          }
          contribs.n1 = in_pixel;
          assert( ( in_pixel - contribs.n0 ) < coefficient_width );
          coeffs[in_pixel - contribs.n0]  = coeff;
        }
      }
    }
  }
}

// TODO: which value?
enum bool STBIR_RENORMALIZE_IN_FLOAT = false;

static if (STBIR_RENORMALIZE_IN_FLOAT)
    alias STBIR_RENORM_TYPE = float;
else
    alias STBIR_RENORM_TYPE = double;

void stbir__cleanup_gathered_coefficients( stbir_edge edge, stbir__filter_extent_info* filter_info, 
                                           stbir__scale_info * scale_info, int num_contributors, 
                                           stbir__contributors* contributors, float * coefficient_group, 
                                           int coefficient_width ) @system
{
  int input_size = scale_info.input_full_size;
  int input_last_n1 = input_size - 1;
  int n, end;
  int lowest = 0x7fffffff;
  int highest = -0x7fffffff;
  int widest = -1;
  int numerator = scale_info.scale_numerator;
  int denominator = scale_info.scale_denominator;
  int polyphase = ( ( scale_info.scale_is_rational ) && ( numerator < num_contributors ) );
  float * coeffs;
  stbir__contributors * contribs;

  // weight all the coeffs for each sample
  coeffs = coefficient_group;
  contribs = contributors;
  end = num_contributors; if ( polyphase ) end = numerator;
  for (n = 0; n < end; n++)
  {
    int i;
    STBIR_RENORM_TYPE filter_scale, total_filter = 0;
    int e;

    // add all contribs
    e = contribs.n1 - contribs.n0;
    for( i = 0 ; i <= e ; i++ )
    {
      total_filter += cast(STBIR_RENORM_TYPE) coeffs[i];
      assert( ( coeffs[i] >= -2.0f ) && ( coeffs[i] <= 2.0f )  ); // check for wonky weights
    }

    // rescale
    if ( ( total_filter < stbir__small_float ) && ( total_filter > -stbir__small_float ) )
    {
      // all coeffs are extremely small, just zero it
      contribs.n1 = contribs.n0;
      coeffs[0] = 0.0f;
    }
    else
    {
      // if the total isn't 1.0, rescale everything
      if ( ( total_filter < (1.0f-stbir__small_float) ) || ( total_filter > (1.0f+stbir__small_float) ) )
      {
        filter_scale = (cast(STBIR_RENORM_TYPE)1.0) / total_filter;

        // scale them all
        for (i = 0; i <= e; i++)
          coeffs[i] = cast(float) ( coeffs[i] * filter_scale );
      }
    }
    ++contribs;
    coeffs += coefficient_width;
  }

  // if we have a rational for the scale, we can exploit the polyphaseness to not calculate
  //   most of the coefficients, so we copy them here
  if ( polyphase )
  {
    stbir__contributors * prev_contribs = contributors;
    stbir__contributors * cur_contribs = contributors + numerator;

    for( n = numerator ; n < num_contributors ; n++ )
    {
      cur_contribs.n0 = prev_contribs.n0 + denominator;
      cur_contribs.n1 = prev_contribs.n1 + denominator;
      ++cur_contribs;
      ++prev_contribs;
    }
    stbir_overlapping_memcpy( coefficient_group + numerator * coefficient_width, 
                              coefficient_group, 
                              ( num_contributors - numerator ) * coefficient_width * ( coeffs[ 0 ] ).sizeof );
  }

  coeffs = coefficient_group;
  contribs = contributors;
  for (n = 0; n < num_contributors; n++)
  {
    int i;

    // in zero edge mode, just remove out of bounds contribs completely (since their weights are accounted for now)
    if ( edge == STBIR_EDGE_ZERO )
    {
      // shrink the right side if necessary
      if ( contribs.n1 > input_last_n1 )
        contribs.n1 = input_last_n1;

      // shrink the left side
      if ( contribs.n0 < 0 )
      {
        int j, left, skips = 0;

        skips = -contribs.n0;
        contribs.n0 = 0;

        // now move down the weights
        left = contribs.n1 - contribs.n0 + 1;
        if ( left > 0 )
        {
          for( j = 0 ; j < left ; j++ )
            coeffs[ j ] = coeffs[ j + skips ];
        }
      }
    }
    else if ( ( edge == STBIR_EDGE_CLAMP ) || ( edge == STBIR_EDGE_REFLECT ) )
    {
      // for clamp and reflect, calculate the true inbounds position (based on edge type) and just add that to the existing weight

      // right hand side first
      if ( contribs.n1 > input_last_n1 )
      {
        int start = contribs.n0;
        int endi = contribs.n1;
        contribs.n1 = input_last_n1;
        for( i = input_size; i <= endi; i++ )
          stbir__insert_coeff( contribs, coeffs, stbir__edge_wrap_slow[edge]( i, input_size ), coeffs[i-start] );
      }

      // now check left hand edge
      if ( contribs.n0 < 0 )
      {
        int save_n0;
        float save_n0_coeff;
        float * c = coeffs - ( contribs.n0 + 1 );

        // reinsert the coeffs with it reflected or clamped (insert accumulates, if the coeffs exist)
        for( i = -1 ; i > contribs.n0 ; i-- )
          stbir__insert_coeff( contribs, coeffs, stbir__edge_wrap_slow[edge]( i, input_size ), *c-- );
        save_n0 = contribs.n0;
        save_n0_coeff = c[0]; // save it, since we didn't do the final one (i==n0), because there might be too many coeffs to hold (before we resize)!

        // now slide all the coeffs down (since we have accumulated them in the positive contribs) and reset the first contrib
        contribs.n0 = 0;
        for(i = 0 ; i <= contribs.n1 ; i++ )
          coeffs[i] = coeffs[i-save_n0];

        // now that we have shrunk down the contribs, we insert the first one safely
        stbir__insert_coeff( contribs, coeffs, stbir__edge_wrap_slow[edge]( save_n0, input_size ), save_n0_coeff );
      }
    }

    if ( contribs.n0 <= contribs.n1 )
    {
      int diff = contribs.n1 - contribs.n0 + 1;
      while ( diff && ( coeffs[ diff-1 ] == 0.0f ) )
        --diff;
      contribs.n1 = contribs.n0 + diff - 1;

      if ( contribs.n0 <= contribs.n1 )
      {
        if ( contribs.n0 < lowest )
          lowest = contribs.n0;
        if ( contribs.n1 > highest )
          highest = contribs.n1;
        if ( diff > widest )
          widest = diff;
      }

      // re-zero out unused coefficients (if any)
      for( i = diff ; i < coefficient_width ; i++ )
        coeffs[i] = 0.0f;
    }

    ++contribs;
    coeffs += coefficient_width;
  }
  filter_info.lowest = lowest;
  filter_info.highest = highest;
  filter_info.widest = widest;
}

int stbir__pack_coefficients( int num_contributors, stbir__contributors* contributors, 
                              float * coefficents, int coefficient_width, 
                              int widest, int row0, int row1 ) @system
{
    int row_end = row1 + 1;

    if ( coefficient_width != widest )
    {
        float * pc = coefficents;
        float * coeffs = coefficents;
        float * pc_end = coefficents + num_contributors * widest;
        switch( widest )
        {
        case 1:
            do {
                { STBIR_NO_UNROLL(pc); (cast(stbir_uint32*)(pc))[0] = (cast(stbir_uint32*)(coeffs))[0]; }
                ++pc;
                coeffs += coefficient_width;
            } while ( pc < pc_end );
            break;
        case 2:
            do {
                { STBIR_NO_UNROLL(pc); (cast(stbir_uint64*)(pc))[0] = (cast(stbir_uint64*)(coeffs))[0]; }
                pc += 2;
                coeffs += coefficient_width;
            } while ( pc < pc_end );
            break;
        case 3:
            do {
                { STBIR_NO_UNROLL(pc); (cast(stbir_uint64*)(pc))[0] = (cast(stbir_uint64*)(coeffs))[0]; }
                { STBIR_NO_UNROLL(pc+2); (cast(stbir_uint32*)(pc+2))[0] = (cast(stbir_uint32*)(coeffs+2))[0]; }
                pc += 3;
                coeffs += coefficient_width;
            } while ( pc < pc_end );
            break;
        case 4:
            do {
                { STBIR_NO_UNROLL(pc); (cast(stbir_uint64*)(pc))[0] = (cast(stbir_uint64*)(coeffs))[0]; (cast(stbir_uint64*)(pc))[1] = (cast(stbir_uint64*)(coeffs))[1]; }
                pc += 4;
                coeffs += coefficient_width;
            } while ( pc < pc_end );
            break;
        case 5:
            do {
                { STBIR_NO_UNROLL(pc); (cast(stbir_uint64*)(pc))[0] = (cast(stbir_uint64*)(coeffs))[0]; (cast(stbir_uint64*)(pc))[1] = (cast(stbir_uint64*)(coeffs))[1]; }
                { STBIR_NO_UNROLL(pc+4); (cast(stbir_uint32*)(pc+4))[0] = (cast(stbir_uint32*)(coeffs+4))[0]; }
                pc += 5;
                coeffs += coefficient_width;
            } while ( pc < pc_end );
            break;
        case 6:
            do {
                { STBIR_NO_UNROLL(pc); (cast(stbir_uint64*)(pc))[0] = (cast(stbir_uint64*)(coeffs))[0]; (cast(stbir_uint64*)(pc))[1] = (cast(stbir_uint64*)(coeffs))[1]; }
                { STBIR_NO_UNROLL(pc+4); (cast(stbir_uint64*)(pc+4))[0] = (cast(stbir_uint64*)(coeffs+4))[0]; }
                pc += 6;
                coeffs += coefficient_width;
            } while ( pc < pc_end );
            break;
        case 7:
            do {
                { STBIR_NO_UNROLL(pc); (cast(stbir_uint64*)(pc))[0] = (cast(stbir_uint64*)(coeffs))[0]; (cast(stbir_uint64*)(pc))[1] = (cast(stbir_uint64*)(coeffs))[1]; }
                { STBIR_NO_UNROLL(pc+4); (cast(stbir_uint64*)(pc+4))[0] = (cast(stbir_uint64*)(coeffs+4))[0]; }
                { STBIR_NO_UNROLL(pc+6); (cast(stbir_uint32*)(pc+6))[0] = (cast(stbir_uint32*)(coeffs+6))[0]; }
                pc += 7;
                coeffs += coefficient_width;
            } while ( pc < pc_end );
            break;
        case 8:
            do {
                { STBIR_NO_UNROLL(pc); (cast(stbir_uint64*)(pc))[0] = (cast(stbir_uint64*)(coeffs))[0]; (cast(stbir_uint64*)(pc))[1] = (cast(stbir_uint64*)(coeffs))[1]; }
                { STBIR_NO_UNROLL(pc+4); (cast(stbir_uint64*)(pc+4))[0] = (cast(stbir_uint64*)(coeffs+4))[0]; (cast(stbir_uint64*)(pc+4))[1] = (cast(stbir_uint64*)(coeffs+4))[1]; }
                pc += 8;
                coeffs += coefficient_width;
            } while ( pc < pc_end );
            break;
        case 9:
            do {
                { STBIR_NO_UNROLL(pc); (cast(stbir_uint64*)(pc))[0] = (cast(stbir_uint64*)(coeffs))[0]; (cast(stbir_uint64*)(pc))[1] = (cast(stbir_uint64*)(coeffs))[1]; }
                { STBIR_NO_UNROLL(pc+4); (cast(stbir_uint64*)(pc+4))[0] = (cast(stbir_uint64*)(coeffs+4))[0]; (cast(stbir_uint64*)(pc+4))[1] = (cast(stbir_uint64*)(coeffs+4))[1]; }
                { STBIR_NO_UNROLL(pc+8); (cast(stbir_uint32*)(pc+8))[0] = (cast(stbir_uint32*)(coeffs+8))[0]; }
                pc += 9;
                coeffs += coefficient_width;
            } while ( pc < pc_end );
            break;
        case 10:
            do {
                { STBIR_NO_UNROLL(pc); (cast(stbir_uint64*)(pc))[0] = (cast(stbir_uint64*)(coeffs))[0]; (cast(stbir_uint64*)(pc))[1] = (cast(stbir_uint64*)(coeffs))[1]; }
                { STBIR_NO_UNROLL(pc+4); (cast(stbir_uint64*)(pc+4))[0] = (cast(stbir_uint64*)(coeffs+4))[0]; (cast(stbir_uint64*)(pc+4))[1] = (cast(stbir_uint64*)(coeffs+4))[1]; }
                { STBIR_NO_UNROLL(pc+8); (cast(stbir_uint64*)(pc+8))[0] = (cast(stbir_uint64*)(coeffs+8))[0]; }
                pc += 10;
                coeffs += coefficient_width;
            } while ( pc < pc_end );
            break;
        case 11:
            do {
                { STBIR_NO_UNROLL(pc); (cast(stbir_uint64*)(pc))[0] = (cast(stbir_uint64*)(coeffs))[0]; (cast(stbir_uint64*)(pc))[1] = (cast(stbir_uint64*)(coeffs))[1]; }
                { STBIR_NO_UNROLL(pc+4); (cast(stbir_uint64*)(pc+4))[0] = (cast(stbir_uint64*)(coeffs+4))[0]; (cast(stbir_uint64*)(pc+4))[1] = (cast(stbir_uint64*)(coeffs+4))[1]; }
                { STBIR_NO_UNROLL(pc+8); (cast(stbir_uint64*)(pc+8))[0] = (cast(stbir_uint64*)(coeffs+8))[0]; }
                { STBIR_NO_UNROLL(pc+10); (cast(stbir_uint32*)(pc+10))[0] = (cast(stbir_uint32*)(coeffs+10))[0]; }
                pc += 11;
                coeffs += coefficient_width;
            } while ( pc < pc_end );
            break;
        case 12:
            do {
                { STBIR_NO_UNROLL(pc); (cast(stbir_uint64*)(pc))[0] = (cast(stbir_uint64*)(coeffs))[0]; (cast(stbir_uint64*)(pc))[1] = (cast(stbir_uint64*)(coeffs))[1]; }
                { STBIR_NO_UNROLL(pc+4); (cast(stbir_uint64*)(pc+4))[0] = (cast(stbir_uint64*)(coeffs+4))[0]; (cast(stbir_uint64*)(pc+4))[1] = (cast(stbir_uint64*)(coeffs+4))[1]; }
                { STBIR_NO_UNROLL(pc+8); (cast(stbir_uint64*)(pc+8))[0] = (cast(stbir_uint64*)(coeffs+8))[0]; (cast(stbir_uint64*)(pc+8))[1] = (cast(stbir_uint64*)(coeffs+8))[1]; }
                pc += 12;
                coeffs += coefficient_width;
            } while ( pc < pc_end );
            break;
        default:
            do {
                float * copy_end = pc + widest - 4;
                float * c = coeffs;
                do {
                    STBIR_NO_UNROLL( pc );
                    { STBIR_NO_UNROLL(pc); (cast(stbir_uint64*)(pc))[0] = (cast(stbir_uint64*)(c))[0]; (cast(stbir_uint64*)(pc))[1] = (cast(stbir_uint64*)(c))[1]; }
                    pc += 4;
                    c += 4;
                } while ( pc <= copy_end );
                copy_end += 4;
                while ( pc < copy_end )
                {
                    { STBIR_NO_UNROLL(pc); (cast(stbir_uint32*)(pc))[0] = (cast(stbir_uint32*)(c))[0]; }
                    ++pc; ++c;
                }
                coeffs += coefficient_width;
            } while ( pc < pc_end );
            break;
    }
}

  // some horizontal routines read one float off the end (which is then masked off), so put in a sentinal so we don't read an snan or denormal
  coefficents[ widest * num_contributors ] = 8888.0f;

  // the minimum we might read for unrolled filters widths is 12. So, we need to
  //   make sure we never read outside the decode buffer, by possibly moving
  //   the sample area back into the scanline, and putting zeros weights first.
  // we start on the right edge and check until we're well past the possible
  //   clip area (2*widest).
  {
    stbir__contributors * contribs = contributors + num_contributors - 1;
    float * coeffs = coefficents + widest * ( num_contributors - 1 );

    // go until no chance of clipping (this is usually less than 8 lops)
    while ( ( contribs >= contributors ) && ( ( contribs.n0 + widest*2 ) >= row_end ) )
    {
      // might we clip??
      if ( ( contribs.n0 + widest ) > row_end )
      {
        int stop_range = widest;

        // if range is larger than 12, it will be handled by generic loops that can terminate on the exact length
        //   of this contrib n1, instead of a fixed widest amount - so calculate this
        if ( widest > 12 )
        {
          int mod;

          // how far will be read in the n_coeff loop (which depends on the widest count mod4);
          mod = widest & 3;
          stop_range = ( ( ( contribs.n1 - contribs.n0 + 1 ) - mod + 3 ) & ~3 ) + mod;

          // the n_coeff loops do a minimum amount of coeffs, so factor that in!
          if ( stop_range < ( 8 + mod ) ) stop_range = 8 + mod;
        }

        // now see if we still clip with the refined range
        if ( ( contribs.n0 + stop_range ) > row_end )
        {
          int new_n0 = row_end - stop_range;
          int num = contribs.n1 - contribs.n0 + 1;
          int backup = contribs.n0 - new_n0;
          float * from_co = coeffs + num - 1;
          float * to_co = from_co + backup;

          assert( ( new_n0 >= row0 ) && ( new_n0 < contribs.n0 ) );

          // move the coeffs over
          while( num )
          {
            *to_co-- = *from_co--;
            --num;
          }
          // zero new positions
          while ( to_co >= coeffs )
            *to_co-- = 0;
          // set new start point
          contribs.n0 = new_n0;
          if ( widest > 12 )
          {
            int mod;

            // how far will be read in the n_coeff loop (which depends on the widest count mod4);
            mod = widest & 3;
            stop_range = ( ( ( contribs.n1 - contribs.n0 + 1 ) - mod + 3 ) & ~3 ) + mod;

            // the n_coeff loops do a minimum amount of coeffs, so factor that in!
            if ( stop_range < ( 8 + mod ) ) stop_range = 8 + mod;
          }
        }
      }
      --contribs;
      coeffs -= widest;
    }
  }

  return widest;
}

void stbir__calculate_filters( stbir__sampler * samp, stbir__sampler * other_axis_for_pivot, void * user_data)
@system
{
  int n;
  float scale = samp.scale_info.scale;
  stbir__kernel_callback kernel = samp.filter_kernel;
  stbir__support_callback support = samp.filter_support;
  float inv_scale = samp.scale_info.inv_scale;
  int input_full_size = samp.scale_info.input_full_size;
  int gather_num_contributors = samp.num_contributors;
  stbir__contributors* gather_contributors = samp.contributors;
  float * gather_coeffs = samp.coefficients;
  int gather_coefficient_width = samp.coefficient_width;

  // if this is a scatter (vertical only), then we need to pivot the coeffs
  stbir__contributors * scatter_contributors;

  switch ( samp.is_gather )
  {
    case 1: // gather upsample
    {
      float out_pixels_radius = support(inv_scale,user_data) * scale;

      stbir__calculate_coefficients_for_gather_upsample( out_pixels_radius, kernel, &samp.scale_info, gather_num_contributors, gather_contributors, gather_coeffs, gather_coefficient_width, samp.edge, user_data );

      stbir__cleanup_gathered_coefficients( samp.edge, &samp.extent_info, &samp.scale_info, gather_num_contributors, gather_contributors, gather_coeffs, gather_coefficient_width );
    }
    break;

    case 0: // scatter downsample (only on vertical)
    case 2: // gather downsample
    {
      float in_pixels_radius = support(scale,user_data) * inv_scale;
      int filter_pixel_margin = samp.filter_pixel_margin;
      int input_end = input_full_size + filter_pixel_margin;

      // if this is a scatter, we do a downsample gather to get the coeffs, and then pivot after
      if ( !samp.is_gather )
      {
        // check if we are using the same gather downsample on the horizontal as this vertical,
        //   if so, then we don't have to generate them, we can just pivot from the horizontal.
        if ( other_axis_for_pivot )
        {
          gather_contributors = other_axis_for_pivot.contributors;
          gather_coeffs = other_axis_for_pivot.coefficients;
          gather_coefficient_width = other_axis_for_pivot.coefficient_width;
          gather_num_contributors = other_axis_for_pivot.num_contributors;
          samp.extent_info.lowest = other_axis_for_pivot.extent_info.lowest;
          samp.extent_info.highest = other_axis_for_pivot.extent_info.highest;
          samp.extent_info.widest = other_axis_for_pivot.extent_info.widest;
          goto jump_right_to_pivot;
        }

        gather_contributors = samp.gather_prescatter_contributors;
        gather_coeffs = samp.gather_prescatter_coefficients;
        gather_coefficient_width = samp.gather_prescatter_coefficient_width;
        gather_num_contributors = samp.gather_prescatter_num_contributors;
      }

      stbir__calculate_coefficients_for_gather_downsample( -filter_pixel_margin, input_end, in_pixels_radius, kernel, &samp.scale_info, gather_coefficient_width, gather_num_contributors, gather_contributors, gather_coeffs, user_data );

      stbir__cleanup_gathered_coefficients( samp.edge, &samp.extent_info, &samp.scale_info, gather_num_contributors, gather_contributors, gather_coeffs, gather_coefficient_width );

      if ( !samp.is_gather )
      {
        
        jump_right_to_pivot:

        int highest_set;

        highest_set = (-filter_pixel_margin) - 1;
        for (n = 0; n < gather_num_contributors; n++)
        {
          int k;
          int gn0 = gather_contributors.n0, gn1 = gather_contributors.n1;
          int scatter_coefficient_width = samp.coefficient_width;
          float * scatter_coeffs = samp.coefficients + ( gn0 + filter_pixel_margin ) * scatter_coefficient_width;
          float * g_coeffs = gather_coeffs;
          scatter_contributors = samp.contributors + ( gn0 + filter_pixel_margin );

          for (k = gn0 ; k <= gn1 ; k++ )
          {
            float gc = *g_coeffs++;
            
            // skip zero and denormals - must skip zeros to avoid adding coeffs beyond scatter_coefficient_width
            //   (which happens when pivoting from horizontal, which might have dummy zeros)
            if ( ( ( gc >= stbir__small_float ) || ( gc <= -stbir__small_float ) ) )
            {
              if ( ( k > highest_set ) || ( scatter_contributors.n0 > scatter_contributors.n1 ) )
              {
                {
                  // if we are skipping over several contributors, we need to clear the skipped ones
                  stbir__contributors * clear_contributors = samp.contributors + ( highest_set + filter_pixel_margin + 1);
                  while ( clear_contributors < scatter_contributors )
                  {
                    clear_contributors.n0 = 0;
                    clear_contributors.n1 = -1;
                    ++clear_contributors;
                  }
                }
                scatter_contributors.n0 = n;
                scatter_contributors.n1 = n;
                scatter_coeffs[0]  = gc;
                highest_set = k;
              }
              else
              {
                stbir__insert_coeff( scatter_contributors, scatter_coeffs, n, gc );
              }
              assert( ( scatter_contributors.n1 - scatter_contributors.n0 + 1 ) <= scatter_coefficient_width );
            }
            ++scatter_contributors;
            scatter_coeffs += scatter_coefficient_width;
          }

          ++gather_contributors;
          gather_coeffs += gather_coefficient_width;
        }

        // now clear any unset contribs
        {
          stbir__contributors * clear_contributors = samp.contributors + ( highest_set + filter_pixel_margin + 1);
          stbir__contributors * end_contributors = samp.contributors + samp.num_contributors;
          while ( clear_contributors < end_contributors )
          {
            clear_contributors.n0 = 0;
            clear_contributors.n1 = -1;
            ++clear_contributors;
          }
        }
      }
    }
    break;
    default:
  }
}



// fancy alpha means we expand to keep both premultipied and non-premultiplied color channels
void stbir__fancy_alpha_weight_4ch(float * out_buffer, int width_times_channels )
@system
{
  @restrict float* out_ = out_buffer;
  const(float)* end_decode = out_buffer + ( width_times_channels / 4 ) * 7;  // decode buffer aligned to end of out_buffer
  @restrict float* decode = cast(float*)end_decode - width_times_channels;

  // fancy alpha is stored internally as R G B A Rpm Gpm Bpm

  static if (STBIR_SIMD8)
  {
      decode += 16;
      while ( decode <= end_decode )
      {
        stbir__simdf8 d0,d1,a0,a1,p0,p1;
        STBIR_NO_UNROLL(decode);
        stbir__simdf8_load( d0, decode-16 );
        stbir__simdf8_load( d1, decode-16+8 );
        stbir__simdf8_0123to33333333( a0, d0 );
        stbir__simdf8_0123to33333333( a1, d1 );
        stbir__simdf8_mult( p0, a0, d0 );
        stbir__simdf8_mult( p1, a1, d1 );
        stbir__simdf8_bot4s( a0, d0, p0 );
        stbir__simdf8_bot4s( a1, d1, p1 );
        stbir__simdf8_top4s( d0, d0, p0 );
        stbir__simdf8_top4s( d1, d1, p1 );
        stbir__simdf8_store ( out_, a0 );
        stbir__simdf8_store ( out_+7, d0 );
        stbir__simdf8_store ( out_+14, a1 );
        stbir__simdf8_store ( out_+21, d1 );
        decode += 16;
        out_ += 28;
      }
      decode -= 16;
  }

  decode += 8;
  while ( decode <= end_decode )
  {
    stbir__simdf d0,a0,d1,a1,p0,p1;
    STBIR_NO_UNROLL(decode);
    stbir__simdf_load( d0, decode-8 );
    stbir__simdf_load( d1, decode-8+4 );
    stbir__simdf_0123to3333( a0, d0 );
    stbir__simdf_0123to3333( a1, d1 );
    stbir__simdf_mult( p0, a0, d0 );
    stbir__simdf_mult( p1, a1, d1 );
    stbir__simdf_store ( out_, d0 );
    stbir__simdf_store ( out_+4, p0 );
    stbir__simdf_store ( out_+7, d1 );
    stbir__simdf_store ( out_+7+4, p1 );
    decode += 8;
    out_ += 14;
  }
  decode -= 8;

  // might be one last odd pixel
  while ( decode < end_decode )
  {
    stbir__simdf d,a,p;
    stbir__simdf_load( d, decode );
    stbir__simdf_0123to3333( a, d );
    stbir__simdf_mult( p, a, d );
    stbir__simdf_store ( out_, d );
    stbir__simdf_store ( out_+4, p );
    decode += 4;
    out_ += 7;
  }
}

static void stbir__fancy_alpha_weight_2ch( float * out_buffer, int width_times_channels )
@system
{
  @restrict float* out_ = out_buffer;
  const(float)* end_decode = out_buffer + ( width_times_channels / 2 ) * 3;
  @restrict float* decode = cast(float*)end_decode - width_times_channels;

  //  for fancy alpha, turns into: [X A Xpm][X A Xpm],etc

  /* TODO
  #ifdef STBIR_SIMD

  decode += 8;
  if ( decode <= end_decode )
  {
    do {
      #ifdef STBIR_SIMD8
      stbir__simdf8 d0,a0,p0;
      STBIR_NO_UNROLL(decode);
      stbir__simdf8_load( d0, decode-8 );
      stbir__simdf8_0123to11331133( p0, d0 );
      stbir__simdf8_0123to00220022( a0, d0 );
      stbir__simdf8_mult( p0, p0, a0 );

      stbir__simdf_store2( out, stbir__if_simdf8_cast_to_simdf4( d0 ) );
      stbir__simdf_store( out+2, stbir__if_simdf8_cast_to_simdf4( p0 ) );
      stbir__simdf_store2h( out+3, stbir__if_simdf8_cast_to_simdf4( d0 ) );

      stbir__simdf_store2( out+6, stbir__simdf8_gettop4( d0 ) );
      stbir__simdf_store( out+8, stbir__simdf8_gettop4( p0 ) );
      stbir__simdf_store2h( out+9, stbir__simdf8_gettop4( d0 ) );
      #else
      stbir__simdf d0,a0,d1,a1,p0,p1;
      STBIR_NO_UNROLL(decode);
      stbir__simdf_load( d0, decode-8 );
      stbir__simdf_load( d1, decode-8+4 );
      stbir__simdf_0123to1133( p0, d0 );
      stbir__simdf_0123to1133( p1, d1 );
      stbir__simdf_0123to0022( a0, d0 );
      stbir__simdf_0123to0022( a1, d1 );
      stbir__simdf_mult( p0, p0, a0 );
      stbir__simdf_mult( p1, p1, a1 );

      stbir__simdf_store2( out, d0 );
      stbir__simdf_store( out+2, p0 );
      stbir__simdf_store2h( out+3, d0 );

      stbir__simdf_store2( out+6, d1 );
      stbir__simdf_store( out+8, p1 );
      stbir__simdf_store2h( out+9, d1 );
      #endif
      decode += 8;
      out += 12;
    } while ( decode <= end_decode );
  }
  decode -= 8;
  #endif*/

  while( decode < end_decode )
  {
    float x = decode[0], y = decode[1];
    STBIR_SIMD_NO_UNROLL(decode);
    out_[0] = x;
    out_[1] = y;
    out_[2] = x * y;
    out_ += 3;
    decode += 2;
  }
}

static void stbir__fancy_alpha_unweight_4ch( float * encode_buffer, int width_times_channels )
@system
{
    @restrict float* encode = encode_buffer;
    @restrict float* input = encode_buffer;
    const(float)* end_output = encode_buffer + width_times_channels;
    // fancy RGBA is stored internally as R G B A Rpm Gpm Bpm
    do {
        float alpha = input[3];
        stbir__simdf i,ia;
        STBIR_SIMD_NO_UNROLL(encode);
        if ( alpha < stbir__small_float )
        {
            stbir__simdf_load( i, input );
            stbir__simdf_store( encode, i );
        }
        else
        {
            stbir__simdf_load1frep4( ia, 1.0f / alpha );
            stbir__simdf_load( i, input+4 );
            stbir__simdf_mult( i, i, ia );
            stbir__simdf_store( encode, i );
            encode[3] = alpha;
        }

        input += 7;
        encode += 4;
    } while ( encode < end_output );
}

//  format: [X A Xpm][X A Xpm] etc
void stbir__fancy_alpha_unweight_2ch( float * encode_buffer, int width_times_channels )
@system
{
    @restrict float* encode = encode_buffer;
    @restrict float* input = encode_buffer;
    const(float)* end_output = encode_buffer + width_times_channels;

    do {
        float alpha = input[1];
        encode[0] = input[0];
        if ( alpha >= stbir__small_float )
            encode[0] = input[2] / alpha;
        encode[1] = alpha;

        input += 3;
        encode += 2;
    } while ( encode < end_output );
}

void stbir__simple_alpha_weight_4ch( float * decode_buffer, int width_times_channels )
@system
{
  @restrict float* decode = decode_buffer;
  const(float)* end_decode = decode_buffer + width_times_channels;

  {
    decode += 2 * stbir__simdfX_float_count;
    while ( decode <= end_decode )
    {
      stbir__simdfX d0,a0,d1,a1;
      STBIR_NO_UNROLL(decode);
      stbir__simdfX_load( d0, decode-2*stbir__simdfX_float_count );
      stbir__simdfX_load( d1, decode-2*stbir__simdfX_float_count+stbir__simdfX_float_count );
      stbir__simdfX_aaa1( a0, d0, STBIR_onesX );
      stbir__simdfX_aaa1( a1, d1, STBIR_onesX );
      stbir__simdfX_mult( d0, d0, a0 );
      stbir__simdfX_mult( d1, d1, a1 );
      stbir__simdfX_store ( decode-2*stbir__simdfX_float_count, d0 );
      stbir__simdfX_store ( decode-2*stbir__simdfX_float_count+stbir__simdfX_float_count, d1 );
      decode += 2 * stbir__simdfX_float_count;
    }
    decode -= 2 * stbir__simdfX_float_count;

    while ( decode < end_decode )
    {
      stbir__simdf d,a;
      stbir__simdf_load( d, decode );
      stbir__simdf_aaa1( a, d, STBIR_ones );
      stbir__simdf_mult( d, d, a );
      stbir__simdf_store ( decode, d );
      decode += 4;
    }
  }
}

void stbir__simple_alpha_weight_2ch( float * decode_buffer, int width_times_channels ) 
@system
{
  @restrict float* decode = decode_buffer;
  const(float)* end_decode = decode_buffer + width_times_channels;

  decode += 2 * stbir__simdfX_float_count;
  while ( decode <= end_decode )
  {
    stbir__simdfX d0,a0,d1,a1;
    STBIR_NO_UNROLL(decode);
    stbir__simdfX_load( d0, decode-2*stbir__simdfX_float_count );
    stbir__simdfX_load( d1, decode-2*stbir__simdfX_float_count+stbir__simdfX_float_count );
    stbir__simdfX_a1a1( a0, d0, STBIR_onesX );
    stbir__simdfX_a1a1( a1, d1, STBIR_onesX );
    stbir__simdfX_mult( d0, d0, a0 );
    stbir__simdfX_mult( d1, d1, a1 );
    stbir__simdfX_store ( decode-2*stbir__simdfX_float_count, d0 );
    stbir__simdfX_store ( decode-2*stbir__simdfX_float_count+stbir__simdfX_float_count, d1 );
    decode += 2 * stbir__simdfX_float_count;
  }
  decode -= 2 * stbir__simdfX_float_count;

  while( decode < end_decode )
  {
    float alpha = decode[1];
    STBIR_SIMD_NO_UNROLL(decode);
    decode[0] *= alpha;
    decode += 2;
  }
}

static void stbir__simple_alpha_unweight_4ch(float * encode_buffer, int width_times_channels )
@system
{
  @restrict float* encode = encode_buffer;
  const(float)* end_output = encode_buffer + width_times_channels;

  do {
    float alpha = encode[3];
    stbir__simdf i,ia;
    STBIR_SIMD_NO_UNROLL(encode);
    if ( alpha >= stbir__small_float )
    {
      stbir__simdf_load1frep4( ia, 1.0f / alpha );
      stbir__simdf_load( i, encode );
      stbir__simdf_mult( i, i, ia );
      stbir__simdf_store( encode, i );
      encode[3] = alpha;
    }
    encode += 4;
  } while ( encode < end_output );
}

static void stbir__simple_alpha_unweight_2ch( float * encode_buffer, int width_times_channels )
@system
{
  @restrict float* encode = encode_buffer;
  const(float)* end_output = encode_buffer + width_times_channels;

  do {
    float alpha = encode[1];
    if ( alpha >= stbir__small_float )
      encode[0] /= alpha;
    encode += 2;
  } while ( encode < end_output );
}


// only used in RGB.BGR or BGR.RGB
static void stbir__simple_flip_3ch( float * decode_buffer, int width_times_channels )
@system
{
  @restrict float*  decode = decode_buffer;
  const(float)* end_decode = decode_buffer + width_times_channels;

  decode += 12;
  while( decode <= end_decode )
  {
    float t0,t1,t2,t3;
    STBIR_NO_UNROLL(decode);
    t0 = decode[0]; t1 = decode[3]; t2 = decode[6]; t3 = decode[9];
    decode[0] = decode[2]; decode[3] = decode[5]; decode[6] = decode[8]; decode[9] = decode[11];
    decode[2] = t0; decode[5] = t1; decode[8] = t2; decode[11] = t3;
    decode += 12;
  }
  decode -= 12;

  while( decode < end_decode )
  {
    float t = decode[0];
    STBIR_NO_UNROLL(decode);
    decode[0] = decode[2];
    decode[2] = t;
    decode += 3;
  }
}

void stbir__decode_scanline(const(stbir__info)* stbir_info, int n, float * output_buffer)
@system
{
  int channels = stbir_info.channels;
  int effective_channels = stbir_info.effective_channels;
  int input_sample_in_bytes = stbir__type_size[stbir_info.input_type] * channels;
  stbir_edge edge_horizontal = stbir_info.horizontal.edge;
  stbir_edge edge_vertical = stbir_info.vertical.edge;
  int row = stbir__edge_wrap(edge_vertical, n, stbir_info.vertical.scale_info.input_full_size);
  void* input_plane_data = ( cast(char *) stbir_info.input_data ) + cast(size_t)row * cast(size_t) stbir_info.input_stride_bytes;
  const(stbir__span)* spans = stbir_info.scanline_extents.spans.ptr;
  float* full_decode_buffer = output_buffer - stbir_info.scanline_extents.conservative.n0 * effective_channels;

  // if we are on edge_zero, and we get in here with an out of bounds n, then the calculate filters has failed
  assert( !(edge_vertical == STBIR_EDGE_ZERO && (n < 0 || n >= stbir_info.vertical.scale_info.input_full_size)) );

  do
  {
    float * decode_buffer;
    const(void)* input_data;
    float * end_decode;
    int width_times_channels;
    int width;

    if ( spans.n1 < spans.n0 )
      break;

    width = spans.n1 + 1 - spans.n0;
    decode_buffer = full_decode_buffer + spans.n0 * effective_channels;
    end_decode = full_decode_buffer + ( spans.n1 + 1 ) * effective_channels;
    width_times_channels = width * channels;

    // read directly out of input plane by default
    input_data = ( cast(char*)input_plane_data ) + spans.pixel_offset_for_input * input_sample_in_bytes;

    // if we have an input callback, call it to get the input data
    if ( stbir_info.in_pixels_cb )
    {
      // call the callback with a temp buffer (that they can choose to use or not).  the temp is just right aligned memory in the decode_buffer itself
        void* optional_output = cast(void*)( ( cast(char*) end_decode ) - ( width * input_sample_in_bytes ) );
        input_data = stbir_info.in_pixels_cb(optional_output, input_plane_data, width, spans.pixel_offset_for_input, row, cast(void*) stbir_info.user_data );
    }

    // convert the pixels info the float decode_buffer, (we index from end_decode, so that when channels<effective_channels, we are right justified in the buffer)
    stbir_info.decode_pixels( cast(float*)end_decode - width_times_channels, width_times_channels, cast(void*)input_data );

    if (stbir_info.alpha_weight)
    {
      stbir_info.alpha_weight( decode_buffer, width_times_channels );
    }

    ++spans;
  } while ( spans <= ( &stbir_info.scanline_extents.spans[1] ) );

  // handle the edge_wrap filter (all other types are handled back out at the calculate_filter stage)
  // basically the idea here is that if we have the whole scanline in memory, we don't redecode the
  //   wrapped edge pixels, and instead just memcpy them from the scanline into the edge positions
  if ( ( edge_horizontal == STBIR_EDGE_WRAP ) && ( stbir_info.scanline_extents.edge_sizes[0] | stbir_info.scanline_extents.edge_sizes[1] ) )
  {
    // this code only runs if we're in edge_wrap, and we're doing the entire scanline
    int e;
    int[2] start_x;
    int input_full_size = stbir_info.horizontal.scale_info.input_full_size;

    start_x[0] = -stbir_info.scanline_extents.edge_sizes[0];  // left edge start x
    start_x[1] =  input_full_size;                             // right edge

    for( e = 0; e < 2 ; e++ )
    {
      // do each margin
      int margin = stbir_info.scanline_extents.edge_sizes[e];
      if ( margin )
      {
        int x = start_x[e];
        float * marg = full_decode_buffer + x * effective_channels;
        const(float) * src = full_decode_buffer + stbir__edge_wrap(edge_horizontal, x, input_full_size) * effective_channels;
        STBIR_MEMCPY( marg, src, margin * effective_channels * float.sizeof );
      }
    }
  }
}






void stbir__encode_scanline( const(stbir__info)* stbir_info, void *output_buffer_data, float * encode_buffer, int row )
@system
{
  int num_pixels = stbir_info.horizontal.scale_info.output_sub_size;
  int channels = stbir_info.channels;
  int width_times_channels = num_pixels * channels;
  void * output_buffer;

  // un-alpha weight if we need to
  if ( stbir_info.alpha_unweight )
  {
    stbir_info.alpha_unweight( encode_buffer, width_times_channels );
  }

  // write directly into output by default
  output_buffer = output_buffer_data;

  // if we have an output callback, we first convert the decode buffer in place (and then hand that to the callback)
  if ( stbir_info.out_pixels_cb )
    output_buffer = encode_buffer;

  // convert into the output buffer
  stbir_info.encode_pixels( output_buffer, width_times_channels, encode_buffer );

  // if we have an output callback, call it to send the data
  if ( stbir_info.out_pixels_cb )
    stbir_info.out_pixels_cb( output_buffer, num_pixels, row, cast(void*) stbir_info.user_data );
}


// Get the ring buffer pointer for an index
float* stbir__get_ring_buffer_entry(const(stbir__info)* stbir_info, const(stbir__per_split_info)* split_info, int index )
@system
{
  assert( index < stbir_info.ring_buffer_num_entries );
  return cast(float*) ( ( cast(char*) split_info.ring_buffer ) + ( index * stbir_info.ring_buffer_length_bytes ) );
}

// Get the specified scan line from the ring buffer
float* stbir__get_ring_buffer_scanline(const(stbir__info)* stbir_info, const(stbir__per_split_info)* split_info, int get_scanline)
@system
{
    int ring_buffer_index = (split_info.ring_buffer_begin_index + (get_scanline - split_info.ring_buffer_first_scanline)) % stbir_info.ring_buffer_num_entries;
    return stbir__get_ring_buffer_entry( stbir_info, split_info, ring_buffer_index );
}

void stbir__resample_horizontal_gather(const(stbir__info)* stbir_info, float* output_buffer, const(float)* input_buffer)
@system
{
  const(float)* decode_buffer = input_buffer - ( stbir_info.scanline_extents.conservative.n0 * stbir_info.effective_channels );

  if ( ( stbir_info.horizontal.filter_enum == STBIR_FILTER_POINT_SAMPLE ) && ( stbir_info.horizontal.scale_info.scale == 1.0f ) )
    STBIR_MEMCPY( output_buffer, input_buffer, stbir_info.horizontal.scale_info.output_sub_size * float.sizeof * stbir_info.effective_channels );
  else
    stbir_info.horizontal_gather_channels( output_buffer, 
                                           stbir_info.horizontal.scale_info.output_sub_size, 
                                           cast(float*) decode_buffer, 
                                           cast(stbir__contributors*) stbir_info.horizontal.contributors, 
                                           cast(float*) stbir_info.horizontal.coefficients, 
                                           stbir_info.horizontal.coefficient_width );
}

void stbir__resample_vertical_gather(const(stbir__info)* stbir_info, stbir__per_split_info* split_info, int n, int contrib_n0, int contrib_n1, const(float)* vertical_coefficients )
@system
{
  float* encode_buffer = split_info.vertical_buffer;
  float* decode_buffer = split_info.decode_buffer;
  int vertical_first = stbir_info.vertical_first;
  int width = (vertical_first) ? ( stbir_info.scanline_extents.conservative.n1-stbir_info.scanline_extents.conservative.n0+1 ) : stbir_info.horizontal.scale_info.output_sub_size;
  int width_times_channels = stbir_info.effective_channels * width;

  assert( stbir_info.vertical.is_gather );

  // loop over the contributing scanlines and scale into the buffer
  {
    int k = 0, total = contrib_n1 - contrib_n0 + 1;
    assert( total > 0 );
    do {
      const(float)*[8] inputs;
      int i, cnt = total; if ( cnt > 8 ) cnt = 8;
      for( i = 0 ; i < cnt ; i++ )
        inputs[ i ] = stbir__get_ring_buffer_scanline(stbir_info, split_info, k+i+contrib_n0 );

      // call the N scanlines at a time function (up to 8 scanlines of blending at once)
      STBIR_VERTICAL_GATHERFUNC fun = ((k==0)?stbir__vertical_gathers:stbir__vertical_gathers_continues)[cnt-1];
      fun( (vertical_first) ? decode_buffer : encode_buffer, vertical_coefficients + k, inputs.ptr, inputs[0] + width_times_channels );
      k += cnt;
      total -= cnt;
    } while ( total );
  }

  if ( vertical_first )
  {
    // Now resample the gathered vertical data in the horizontal axis into the encode buffer
    stbir__resample_horizontal_gather(stbir_info, encode_buffer, decode_buffer);
  }

  stbir__encode_scanline( stbir_info, ( cast(char *) stbir_info.output_data ) + (cast(size_t)n * cast(size_t)stbir_info.output_stride_bytes),
                          encode_buffer, n);
}

void stbir__decode_and_resample_for_vertical_gather_loop(const(stbir__info)* stbir_info, stbir__per_split_info* split_info, int n)
@system
{
  int ring_buffer_index;
  float* ring_buffer;

  // Decode the nth scanline from the source image into the decode buffer.
  stbir__decode_scanline( stbir_info, n, split_info.decode_buffer);

  // update new end scanline
  split_info.ring_buffer_last_scanline = n;

  // get ring buffer
  ring_buffer_index = (split_info.ring_buffer_begin_index + (split_info.ring_buffer_last_scanline - split_info.ring_buffer_first_scanline)) % stbir_info.ring_buffer_num_entries;
  ring_buffer = stbir__get_ring_buffer_entry(stbir_info, split_info, ring_buffer_index);

  // Now resample it into the ring buffer.
  stbir__resample_horizontal_gather( stbir_info, ring_buffer, split_info.decode_buffer);

  // Now it's sitting in the ring buffer ready to be used as source for the vertical sampling.
}

void stbir__vertical_gather_loop( const(stbir__info)* stbir_info, stbir__per_split_info* split_info, int split_count )
@system
{
  int y, start_output_y, end_output_y;
 const(stbir__contributors)* vertical_contributors = stbir_info.vertical.contributors;
  const(float)* vertical_coefficients = stbir_info.vertical.coefficients;

  assert( stbir_info.vertical.is_gather );

  start_output_y = split_info.start_output_y;
  end_output_y = split_info[split_count-1].end_output_y;

  vertical_contributors += start_output_y;
  vertical_coefficients += start_output_y * stbir_info.vertical.coefficient_width;

  // initialize the ring buffer for gathering
  split_info.ring_buffer_begin_index = 0;
  split_info.ring_buffer_first_scanline = vertical_contributors.n0;
  split_info.ring_buffer_last_scanline = split_info.ring_buffer_first_scanline - 1; // means "empty"

  for (y = start_output_y; y < end_output_y; y++)
  {
    int in_first_scanline, in_last_scanline;

    in_first_scanline = vertical_contributors.n0;
    in_last_scanline = vertical_contributors.n1;

    // make sure the indexing hasn't broken
    assert( in_first_scanline >= split_info.ring_buffer_first_scanline );

    // Load in new scanlines
    while (in_last_scanline > split_info.ring_buffer_last_scanline)
    {
      assert( ( split_info.ring_buffer_last_scanline - split_info.ring_buffer_first_scanline + 1 ) <= stbir_info.ring_buffer_num_entries );

      // make sure there was room in the ring buffer when we add new scanlines
      if ( ( split_info.ring_buffer_last_scanline - split_info.ring_buffer_first_scanline + 1 ) == stbir_info.ring_buffer_num_entries )
      {
        split_info.ring_buffer_first_scanline++;
        split_info.ring_buffer_begin_index++;
      }

      if ( stbir_info.vertical_first )
      {
        float * ring_buffer = stbir__get_ring_buffer_scanline( stbir_info, split_info, ++split_info.ring_buffer_last_scanline );
        // Decode the nth scanline from the source image into the decode buffer.
        stbir__decode_scanline( stbir_info, split_info.ring_buffer_last_scanline, ring_buffer);
      }
      else
      {
        stbir__decode_and_resample_for_vertical_gather_loop(stbir_info, split_info, split_info.ring_buffer_last_scanline + 1);
      }
    }

    // Now all buffers should be ready to write a row of vertical sampling, so do it.
    stbir__resample_vertical_gather(stbir_info, split_info, y, in_first_scanline, in_last_scanline, vertical_coefficients );

    ++vertical_contributors;
    vertical_coefficients += stbir_info.vertical.coefficient_width;
  }
}

enum STBIR__FLOAT_EMPTY_MARKER = 3.0e+38F;
bool STBIR__FLOAT_BUFFER_IS_EMPTY(float* ptr)
{
    return ptr[0] == STBIR__FLOAT_EMPTY_MARKER;
}

static void stbir__encode_first_scanline_from_scatter(const(stbir__info)* stbir_info, stbir__per_split_info* split_info)
@system
{
  // evict a scanline out into the output buffer
  float* ring_buffer_entry = stbir__get_ring_buffer_entry(stbir_info, split_info, split_info.ring_buffer_begin_index );

  // dump the scanline out
  stbir__encode_scanline( stbir_info, ( cast(char *)stbir_info.output_data ) + ( cast(size_t)split_info.ring_buffer_first_scanline * cast(size_t)stbir_info.output_stride_bytes ), ring_buffer_entry, split_info.ring_buffer_first_scanline);

  // mark it as empty
  ring_buffer_entry[ 0 ] = STBIR__FLOAT_EMPTY_MARKER;

  // advance the first scanline
  split_info.ring_buffer_first_scanline++;
  if ( ++split_info.ring_buffer_begin_index == stbir_info.ring_buffer_num_entries )
    split_info.ring_buffer_begin_index = 0;
}

void stbir__horizontal_resample_and_encode_first_scanline_from_scatter(const(stbir__info)* stbir_info, stbir__per_split_info* split_info)
@system
{
  // evict a scanline out into the output buffer

  float* ring_buffer_entry = stbir__get_ring_buffer_entry(stbir_info, split_info, split_info.ring_buffer_begin_index );

  // Now resample it into the buffer.
  stbir__resample_horizontal_gather( stbir_info, split_info.vertical_buffer, ring_buffer_entry);

  // dump the scanline out
  stbir__encode_scanline( stbir_info, ( cast(char *)stbir_info.output_data ) + ( cast(size_t)split_info.ring_buffer_first_scanline * cast(size_t)stbir_info.output_stride_bytes ), split_info.vertical_buffer, split_info.ring_buffer_first_scanline);

  // mark it as empty
  ring_buffer_entry[ 0 ] = STBIR__FLOAT_EMPTY_MARKER;

  // advance the first scanline
  split_info.ring_buffer_first_scanline++;
  if ( ++split_info.ring_buffer_begin_index == stbir_info.ring_buffer_num_entries )
    split_info.ring_buffer_begin_index = 0;
}

void stbir__resample_vertical_scatter(const(stbir__info)* stbir_info, 
                                      stbir__per_split_info* split_info, int n0, int n1, 
                                      const(float)* vertical_coefficients, 
                                      const(float)* vertical_buffer, 
                                      const(float)* vertical_buffer_end )
@system
{
  assert( !stbir_info.vertical.is_gather );

  {
    int k = 0, total = n1 - n0 + 1;
    assert( total > 0 );
    do {
      float*[8] outputs;
      int i, n = total; if ( n > 8 ) n = 8;
      for( i = 0 ; i < n ; i++ )
      {
        outputs[ i ] = stbir__get_ring_buffer_scanline(stbir_info, split_info, k+i+n0 );
        if ( ( i ) && ( STBIR__FLOAT_BUFFER_IS_EMPTY( outputs[i] ) != STBIR__FLOAT_BUFFER_IS_EMPTY( outputs[0] ) ) ) // make sure runs are of the same type
        {
          n = i;
          break;
        }
      }
      // call the scatter to N scanlines at a time function (up to 8 scanlines of scattering at once)

      STBIR_VERTICAL_SCATTERFUNC fun = ((STBIR__FLOAT_BUFFER_IS_EMPTY( outputs[0] ))?stbir__vertical_scatter_sets:stbir__vertical_scatter_blends)[n-1];
      fun( outputs.ptr, vertical_coefficients + k, vertical_buffer, vertical_buffer_end );
      k += n;
      total -= n;
    } while ( total );
  }

}

@system
{
    alias stbir__handle_scanline_for_scatter_func = void function(const(stbir__info)* stbir_info, stbir__per_split_info* split_info);
}

void stbir__vertical_scatter_loop( const(stbir__info)* stbir_info, stbir__per_split_info* split_info, int split_count )
@system
{
  int y, start_output_y, end_output_y, start_input_y, end_input_y;
  const(stbir__contributors)* vertical_contributors = stbir_info.vertical.contributors;
  const(float)* vertical_coefficients = stbir_info.vertical.coefficients;
  stbir__handle_scanline_for_scatter_func handle_scanline_for_scatter;
  void * scanline_scatter_buffer;
  void * scanline_scatter_buffer_end;
  int on_first_input_y, last_input_y;

  assert( !stbir_info.vertical.is_gather );

  start_output_y = split_info.start_output_y;
  end_output_y = split_info[split_count-1].end_output_y;  // may do multiple split counts

  start_input_y = split_info.start_input_y;
  end_input_y = split_info[split_count-1].end_input_y;

  // adjust for starting offset start_input_y
  y = start_input_y + stbir_info.vertical.filter_pixel_margin;
  vertical_contributors += y ;
  vertical_coefficients += stbir_info.vertical.coefficient_width * y;

  if ( stbir_info.vertical_first )
  {
    handle_scanline_for_scatter = &stbir__horizontal_resample_and_encode_first_scanline_from_scatter;
    scanline_scatter_buffer = split_info.decode_buffer;
    scanline_scatter_buffer_end = ( cast(char*) scanline_scatter_buffer ) + float.sizeof * stbir_info.effective_channels * (stbir_info.scanline_extents.conservative.n1-stbir_info.scanline_extents.conservative.n0+1);
  }
  else
  {
    handle_scanline_for_scatter = &stbir__encode_first_scanline_from_scatter;
    scanline_scatter_buffer = split_info.vertical_buffer;
    scanline_scatter_buffer_end = ( cast(char*) scanline_scatter_buffer ) + float.sizeof * stbir_info.effective_channels * stbir_info.horizontal.scale_info.output_sub_size;
  }

  // initialize the ring buffer for scattering
  split_info.ring_buffer_first_scanline = start_output_y;
  split_info.ring_buffer_last_scanline = -1;
  split_info.ring_buffer_begin_index = -1;

  // mark all the buffers as empty to start
  for( y = 0 ; y < stbir_info.ring_buffer_num_entries ; y++ )
    stbir__get_ring_buffer_entry( stbir_info, split_info, y )[0] = STBIR__FLOAT_EMPTY_MARKER; // only used on scatter

  // do the loop in input space
  on_first_input_y = 1; last_input_y = start_input_y;
  for (y = start_input_y ; y < end_input_y; y++)
  {
    int out_first_scanline, out_last_scanline;

    out_first_scanline = vertical_contributors.n0;
    out_last_scanline = vertical_contributors.n1;

    assert(out_last_scanline - out_first_scanline + 1 <= stbir_info.ring_buffer_num_entries);

    if ( ( out_last_scanline >= out_first_scanline ) && ( ( ( out_first_scanline >= start_output_y ) && ( out_first_scanline < end_output_y ) ) || ( ( out_last_scanline >= start_output_y ) && ( out_last_scanline < end_output_y ) ) ) )
    {
      const(float)* vc = vertical_coefficients;

      // keep track of the range actually seen for the next resize
      last_input_y = y;
      if ( ( on_first_input_y ) && ( y > start_input_y ) )
        split_info.start_input_y = y;
      on_first_input_y = 0;

      // clip the region
      if ( out_first_scanline < start_output_y )
      {
        vc += start_output_y - out_first_scanline;
        out_first_scanline = start_output_y;
      }

      if ( out_last_scanline >= end_output_y )
        out_last_scanline = end_output_y - 1;

      // if very first scanline, init the index
      if (split_info.ring_buffer_begin_index < 0)
        split_info.ring_buffer_begin_index = out_first_scanline - start_output_y;

      assert( split_info.ring_buffer_begin_index <= out_first_scanline );

      // Decode the nth scanline from the source image into the decode buffer.
      stbir__decode_scanline( stbir_info, y, split_info.decode_buffer);

      // When horizontal first, we resample horizontally into the vertical buffer before we scatter it out
      if ( !stbir_info.vertical_first )
        stbir__resample_horizontal_gather( stbir_info, split_info.vertical_buffer, split_info.decode_buffer);

      // Now it's sitting in the buffer ready to be distributed into the ring buffers.

      // evict from the ringbuffer, if we need are full
      if ( ( ( split_info.ring_buffer_last_scanline - split_info.ring_buffer_first_scanline + 1 ) == stbir_info.ring_buffer_num_entries ) &&
           ( out_last_scanline > split_info.ring_buffer_last_scanline ) )
        handle_scanline_for_scatter( stbir_info, split_info );

      // Now the horizontal buffer is ready to write to all ring buffer rows, so do it.
      stbir__resample_vertical_scatter(stbir_info, split_info, out_first_scanline, out_last_scanline, vc, cast(float*)scanline_scatter_buffer, cast(float*)scanline_scatter_buffer_end );

      // update the end of the buffer
      if ( out_last_scanline > split_info.ring_buffer_last_scanline )
        split_info.ring_buffer_last_scanline = out_last_scanline;
    }
    ++vertical_contributors;
    vertical_coefficients += stbir_info.vertical.coefficient_width;
  }

  // now evict the scanlines that are left over in the ring buffer
  while ( split_info.ring_buffer_first_scanline < end_output_y )
    handle_scanline_for_scatter(stbir_info, split_info);

  // update the end_input_y if we do multiple resizes with the same data
  ++last_input_y;
  for( y = 0 ; y < split_count; y++ )
    if ( split_info[y].end_input_y > last_input_y )
      split_info[y].end_input_y = last_input_y;
}

static immutable stbir__kernel_callback[7] stbir__builtin_kernels =
[
    null,
    &stbir__filter_trapezoid,  
    &stbir__filter_triangle, 
    &stbir__filter_cubic, 
    &stbir__filter_catmullrom, 
    &stbir__filter_mitchell, 
    &stbir__filter_point 
];

static immutable stbir__support_callback[7] stbir__builtin_supports =
[
    null,
    &stbir__support_trapezoid, 
    &stbir__support_one,     
    &stbir__support_two,  
    &stbir__support_two,       
    &stbir__support_two,     
    &stbir__support_zeropoint5
];

void stbir__set_sampler(stbir__sampler * samp, stbir_filter filter, stbir__kernel_callback kernel, stbir__support_callback support, stbir_edge edge, stbir__scale_info * scale_info, int always_gather, void * user_data )
@system
{
  // set filter
  if (filter == 0)
  {
    filter = STBIR_DEFAULT_FILTER_DOWNSAMPLE; // default to downsample
    if (scale_info.scale >= ( 1.0f - stbir__small_float ) )
    {
      if ( (scale_info.scale <= ( 1.0f + stbir__small_float ) ) && ( STBIR_CEILF(scale_info.pixel_shift) == scale_info.pixel_shift ) )
        filter = STBIR_FILTER_POINT_SAMPLE;
      else
        filter = STBIR_DEFAULT_FILTER_UPSAMPLE;
    }
  }
  samp.filter_enum = filter;

  assert(samp.filter_enum != 0);
  assert(cast(uint)samp.filter_enum < STBIR_FILTER_OTHER);
  samp.filter_kernel = stbir__builtin_kernels[ filter ];
  samp.filter_support = stbir__builtin_supports[ filter ];

  if ( kernel && support )
  {
    samp.filter_kernel = kernel;
    samp.filter_support = support;
    samp.filter_enum = STBIR_FILTER_OTHER;
  }

  samp.edge = edge;
  samp.filter_pixel_width  = stbir__get_filter_pixel_width (samp.filter_support, scale_info.scale, user_data );
  // Gather is always better, but in extreme downsamples, you have to most or all of the data in memory
  //    For horizontal, we always have all the pixels, so we always use gather here (always_gather==1).
  //    For vertical, we use gather if scaling up (which means we will have samp.filter_pixel_width
  //    scanlines in memory at once).
  samp.is_gather = 0;
  if ( scale_info.scale >= ( 1.0f - stbir__small_float ) )
    samp.is_gather = 1;
  else if ( ( always_gather ) || ( samp.filter_pixel_width <= STBIR_FORCE_GATHER_FILTER_SCANLINES_AMOUNT ) )
    samp.is_gather = 2;

  // pre calculate stuff based on the above
  samp.coefficient_width = stbir__get_coefficient_width(samp, samp.is_gather, user_data);

  // filter_pixel_width is the conservative size in pixels of input that affect an output pixel.
  //   In rare cases (only with 2 pix to 1 pix with the default filters), it's possible that the 
  //   filter will extend before or after the scanline beyond just one extra entire copy of the 
  //   scanline (we would hit the edge twice). We don't let you do that, so we clamp the total 
  //   width to 3x the total of input pixel (once for the scanline, once for the left side 
  //   overhang, and once for the right side). We only do this for edge mode, since the other 
  //   modes can just re-edge clamp back in again.
  if ( edge == STBIR_EDGE_WRAP )
    if ( samp.filter_pixel_width > ( scale_info.input_full_size * 3 ) )
      samp.filter_pixel_width = scale_info.input_full_size * 3;

  // This is how much to expand buffers to account for filters seeking outside
  // the image boundaries.
  samp.filter_pixel_margin = samp.filter_pixel_width / 2;
  
  // filter_pixel_margin is the amount that this filter can overhang on just one side of either 
  //   end of the scanline (left or the right). Since we only allow you to overhang 1 scanline's 
  //   worth of pixels, we clamp this one side of overhang to the input scanline size. Again, 
  //   this clamping only happens in rare cases with the default filters (2 pix to 1 pix). 
  if ( edge == STBIR_EDGE_WRAP )
    if ( samp.filter_pixel_margin > scale_info.input_full_size )
      samp.filter_pixel_margin = scale_info.input_full_size;

  samp.num_contributors = stbir__get_contributors(samp, samp.is_gather);

  samp.contributors_size = cast(int)(samp.num_contributors * stbir__contributors.sizeof);
  samp.coefficients_size = cast(int)(samp.num_contributors * samp.coefficient_width * float.sizeof + float.sizeof); // extra float.sizeof is padding

  samp.gather_prescatter_contributors = null;
  samp.gather_prescatter_coefficients = null;
  if ( samp.is_gather == 0 )
  {
    samp.gather_prescatter_coefficient_width = samp.filter_pixel_width;
    samp.gather_prescatter_num_contributors  = stbir__get_contributors(samp, 2);
    samp.gather_prescatter_contributors_size = cast(int)(samp.gather_prescatter_num_contributors * stbir__contributors.sizeof);
    samp.gather_prescatter_coefficients_size = cast(int)(samp.gather_prescatter_num_contributors * samp.gather_prescatter_coefficient_width * float.sizeof);
  }
}

static void stbir__get_conservative_extents( stbir__sampler * samp, stbir__contributors * range, void * user_data )
@system
{
  float scale = samp.scale_info.scale;
  float out_shift = samp.scale_info.pixel_shift;
  stbir__support_callback support = samp.filter_support;
  int input_full_size = samp.scale_info.input_full_size;
  stbir_edge edge = samp.edge;
  float inv_scale = samp.scale_info.inv_scale;

  assert( samp.is_gather != 0 );

  if ( samp.is_gather == 1 )
  {
    int in_first_pixel, in_last_pixel;
    float out_filter_radius = support(inv_scale, user_data) * scale;

    stbir__calculate_in_pixel_range( &in_first_pixel, &in_last_pixel, 0.5, out_filter_radius, inv_scale, out_shift, input_full_size, edge );
    range.n0 = in_first_pixel;
    stbir__calculate_in_pixel_range( &in_first_pixel, &in_last_pixel, ( cast(float)(samp.scale_info.output_sub_size-1) ) + 0.5f, out_filter_radius, inv_scale, out_shift, input_full_size, edge );
    range.n1 = in_last_pixel;
  }
  else if ( samp.is_gather == 2 ) // downsample gather, refine
  {
    float in_pixels_radius = support(scale, user_data) * inv_scale;
    int filter_pixel_margin = samp.filter_pixel_margin;
    int output_sub_size = samp.scale_info.output_sub_size;
    int input_end;
    int n;
    int in_first_pixel, in_last_pixel;

    // get a conservative area of the input range
    stbir__calculate_in_pixel_range( &in_first_pixel, &in_last_pixel, 0, 0, inv_scale, out_shift, input_full_size, edge );
    range.n0 = in_first_pixel;
    stbir__calculate_in_pixel_range( &in_first_pixel, &in_last_pixel, cast(float)output_sub_size, 0, inv_scale, out_shift, input_full_size, edge );
    range.n1 = in_last_pixel;

    // now go through the margin to the start of area to find bottom
    n = range.n0 + 1;
    input_end = -filter_pixel_margin;
    while( n >= input_end )
    {
      int out_first_pixel, out_last_pixel;
      stbir__calculate_out_pixel_range( &out_first_pixel, &out_last_pixel, (cast(float)n)+0.5f, in_pixels_radius, scale, out_shift, output_sub_size );
      if ( out_first_pixel > out_last_pixel )
        break;

      if ( ( out_first_pixel < output_sub_size ) || ( out_last_pixel >= 0 ) )
        range.n0 = n;
      --n;
    }

    // now go through the end of the area through the margin to find top
    n = range.n1 - 1;
    input_end = n + 1 + filter_pixel_margin;
    while( n <= input_end )
    {
      int out_first_pixel, out_last_pixel;
      stbir__calculate_out_pixel_range( &out_first_pixel, &out_last_pixel, (cast(float)n)+0.5f, in_pixels_radius, scale, out_shift, output_sub_size );
      if ( out_first_pixel > out_last_pixel )
        break;
      if ( ( out_first_pixel < output_sub_size ) || ( out_last_pixel >= 0 ) )
        range.n1 = n;
      ++n;
    }
  }

  if ( samp.edge == STBIR_EDGE_WRAP )
  {
    // if we are wrapping, and we are very close to the image size (so the edges might merge), just use the scanline up to the edge
    if ( ( range.n0 > 0 ) && ( range.n1 >= input_full_size ) )
    {
      int marg = range.n1 - input_full_size + 1;
      if ( ( marg + STBIR__MERGE_RUNS_PIXEL_THRESHOLD ) >= range.n0 )
        range.n0 = 0;
    }
    if ( ( range.n0 < 0 ) && ( range.n1 < (input_full_size-1) ) )
    {
      int marg = -range.n0;
      if ( ( input_full_size - marg - STBIR__MERGE_RUNS_PIXEL_THRESHOLD - 1 ) <= range.n1 )
        range.n1 = input_full_size - 1;
    }
  }
  else
  {
    // for non-edge-wrap modes, we never read over the edge, so clamp
    if ( range.n0 < 0 )
      range.n0 = 0;
    if ( range.n1 >= input_full_size )
      range.n1 = input_full_size - 1;
  }
}

static void stbir__get_split_info( stbir__per_split_info* split_info, int splits, int output_height, int vertical_pixel_margin, int input_full_height )
{
  int i, cur;
  int left = output_height;

  cur = 0;
  for( i = 0 ; i < splits ; i++ )
  {
    int each;
    split_info[i].start_output_y = cur;
    each = left / ( splits - i );
    split_info[i].end_output_y = cur + each;
    cur += each;
    left -= each;

    // scatter range (updated to minimum as you run it)
    split_info[i].start_input_y = -vertical_pixel_margin;
    split_info[i].end_input_y = input_full_height + vertical_pixel_margin;
  }
}

static void stbir__free_internal_mem( stbir__info *info )
{
    if ( info )
    {
        if ( info.alloced_mem )  
        { 
            void * p = info.alloced_mem; 
            info.alloced_mem  = null;
            STBIR_FREE(info.alloced_mem, info.user_data);
        }
    }
}

static int stbir__get_max_split( int splits, int height )
{
  int i;
  int max = 0;

  for( i = 0 ; i < splits ; i++ )
  {
    int each = height / ( splits - i );
    if ( each > max )
      max = each;
    height -= each;
  }
  return max;
}



// there are six resize classifications: 
// 0 == vertical scatter, 
// 1 == vertical gather < 1x scale, 
// 2 == vertical gather 1x-2x scale, 
// 4 == vertical gather < 3x scale, 4 == vertical gather > 3x scale, 
// 5 == <=4 pixel height, 
// 6 == <=4 pixel wide column
enum STBIR_RESIZE_CLASSIFICATIONS = 8;

static immutable float[4][STBIR_RESIZE_CLASSIFICATIONS][5] stbir__compute_weights =  // 5 = 0 = 1chan, 1 = 2chan, 2 = 3chan, 3 = 4chan, 4 = 7chan
[
  [
    [ 1.00000f, 1.00000f, 0.31250f, 1.00000f ],
    [ 0.56250f, 0.59375f, 0.00000f, 0.96875f ],
    [ 1.00000f, 0.06250f, 0.00000f, 1.00000f ],
    [ 0.00000f, 0.09375f, 1.00000f, 1.00000f ],
    [ 1.00000f, 1.00000f, 1.00000f, 1.00000f ],
    [ 0.03125f, 0.12500f, 1.00000f, 1.00000f ],
    [ 0.06250f, 0.12500f, 0.00000f, 1.00000f ],
    [ 0.00000f, 1.00000f, 0.00000f, 0.03125f ],
  ], [
    [ 0.00000f, 0.84375f, 0.00000f, 0.03125f ],
    [ 0.09375f, 0.93750f, 0.00000f, 0.78125f ],
    [ 0.87500f, 0.21875f, 0.00000f, 0.96875f ],
    [ 0.09375f, 0.09375f, 1.00000f, 1.00000f ],
    [ 1.00000f, 1.00000f, 1.00000f, 1.00000f ],
    [ 0.03125f, 0.12500f, 1.00000f, 1.00000f ],
    [ 0.06250f, 0.12500f, 0.00000f, 1.00000f ],
    [ 0.00000f, 1.00000f, 0.00000f, 0.53125f ],
  ], [
    [ 0.00000f, 0.53125f, 0.00000f, 0.03125f ],
    [ 0.06250f, 0.96875f, 0.00000f, 0.53125f ],
    [ 0.87500f, 0.18750f, 0.00000f, 0.93750f ],
    [ 0.00000f, 0.09375f, 1.00000f, 1.00000f ],
    [ 1.00000f, 1.00000f, 1.00000f, 1.00000f ],
    [ 0.03125f, 0.12500f, 1.00000f, 1.00000f ],
    [ 0.06250f, 0.12500f, 0.00000f, 1.00000f ],
    [ 0.00000f, 1.00000f, 0.00000f, 0.56250f ],
  ], [
    [ 0.00000f, 0.50000f, 0.00000f, 0.71875f ],
    [ 0.06250f, 0.84375f, 0.00000f, 0.87500f ],
    [ 1.00000f, 0.50000f, 0.50000f, 0.96875f ],
    [ 1.00000f, 0.09375f, 0.31250f, 0.50000f ],
    [ 1.00000f, 1.00000f, 1.00000f, 1.00000f ],
    [ 1.00000f, 0.03125f, 0.03125f, 0.53125f ],
    [ 0.18750f, 0.12500f, 0.00000f, 1.00000f ],
    [ 0.00000f, 1.00000f, 0.03125f, 0.18750f ],
  ], [
    [ 0.00000f, 0.59375f, 0.00000f, 0.96875f ],
    [ 0.06250f, 0.81250f, 0.06250f, 0.59375f ],
    [ 0.75000f, 0.43750f, 0.12500f, 0.96875f ],
    [ 0.87500f, 0.06250f, 0.18750f, 0.43750f ],
    [ 1.00000f, 1.00000f, 1.00000f, 1.00000f ],
    [ 0.15625f, 0.12500f, 1.00000f, 1.00000f ],
    [ 0.06250f, 0.12500f, 0.00000f, 1.00000f ],
    [ 0.00000f, 1.00000f, 0.03125f, 0.34375f ],
  ]
];

// structure that allow us to query and override info for training the costs
struct STBIR__V_FIRST_INFO
{
   double v_cost, h_cost;
   int control_v_first; // 0 = no control, 1 = force hori, 2 = force vert
   int v_first;
   int v_resize_classification;
   int is_gather;
}

enum bool STBIR__V_FIRST_INFO_BUFFER = false;
enum STBIR__V_FIRST_INFO* STBIR__V_FIRST_INFO_POINTER = null;

// Figure out whether to scale along the horizontal or vertical first.
//   This only *super* important when you are scaling by a massively
//   different amount in the vertical vs the horizontal (for example, if
//   you are scaling by 2x in the width, and 0.5x in the height, then you
//   want to do the vertical scale first, because it's around 3x faster
//   in that order.
//
//   In more normal circumstances, this makes a 20-40% differences, so
//     it's good to get right, but not critical. The normal way that you
//     decide which direction goes first is just figuring out which
//     direction does more multiplies. But with modern CPUs with their
//     fancy caches and SIMD and high IPC abilities, so there's just a lot
//     more that goes into it.
//
//   My handwavy sort of solution is to have an app that does a whole
//     bunch of timing for both vertical and horizontal first modes,
//     and then another app that can read lots of these timing files
//     and try to search for the best weights to use. Dotimings.c
//     is the app that does a bunch of timings, and vf_train.c is the
//     app that solves for the best weights (and shows how well it
//     does currently).

int stbir__should_do_vertical_first( float[4][STBIR_RESIZE_CLASSIFICATIONS] weights_table, 
                                     int horizontal_filter_pixel_width, 
                                     float horizontal_scale, 
                                     int horizontal_output_size, 
                                     int vertical_filter_pixel_width, 
                                     float vertical_scale, 
                                     int vertical_output_size, 
                                     int is_gather, 
                                     STBIR__V_FIRST_INFO * info )
{
  double v_cost, h_cost;
  float * weights;
  int vertical_first;
  int v_classification;

  // categorize the resize into buckets
  if ( ( vertical_output_size <= 4 ) || ( horizontal_output_size <= 4 ) )
    v_classification = ( vertical_output_size < horizontal_output_size ) ? 6 : 7;
  else if ( vertical_scale <= 1.0f )
    v_classification = ( is_gather ) ? 1 : 0;
  else if ( vertical_scale <= 2.0f)
    v_classification = 2;
  else if ( vertical_scale <= 3.0f)
    v_classification = 3;
  else if ( vertical_scale <= 4.0f)
    v_classification = 5;
  else
    v_classification = 6;

  // use the right weights
  weights = weights_table[ v_classification ].ptr;

  // this is the costs when you don't take into account modern CPUs with high ipc and simd and caches - wish we had a better estimate
  h_cost = cast(float)horizontal_filter_pixel_width * weights[0] + horizontal_scale * cast(float)vertical_filter_pixel_width * weights[1];
  v_cost = cast(float)vertical_filter_pixel_width  * weights[2] + vertical_scale * cast(float)horizontal_filter_pixel_width * weights[3];

  // use computation estimate to decide vertical first or not
  vertical_first = ( v_cost <= h_cost ) ? 1 : 0;

  // save these, if requested
  if ( info )
  {
    info.h_cost = h_cost;
    info.v_cost = v_cost;
    info.v_resize_classification = v_classification;
    info.v_first = vertical_first;
    info.is_gather = is_gather;
  }

  // and this allows us to override everything for testing (see dotiming.c)
  if ( ( info ) && ( info.control_v_first ) )
    vertical_first = ( info.control_v_first == 2 ) ? 1 : 0;

  return vertical_first;
}



stbir__info * stbir__alloc_internal_mem_and_build_samplers( stbir__sampler * horizontal, 
                                                            stbir__sampler * vertical, 
                                                            stbir__contributors * conservative, 
                                                            stbir_pixel_layout input_pixel_layout_public, 
                                                            stbir_pixel_layout output_pixel_layout_public, 
                                                            int splits, int new_x, int new_y, int fast_alpha, 
                                                            void * user_data)
{
  static immutable ubyte[8] stbir_channel_count_index = [ 9,0,1,2, 3,9,9,4 ];

  stbir__info * info = null;
  void * alloced = null;
  size_t alloced_total = 0;
  int vertical_first;
  int decode_buffer_size, ring_buffer_length_bytes, ring_buffer_size, vertical_buffer_size, alloc_ring_buffer_num_entries;

  int alpha_weighting_type = 0; // 0=none, 1=simple, 2=fancy
  int conservative_split_output_size = stbir__get_max_split( splits, vertical.scale_info.output_sub_size );
  stbir_internal_pixel_layout input_pixel_layout = stbir__pixel_layout_convert_public_to_internal[ input_pixel_layout_public ];
  stbir_internal_pixel_layout output_pixel_layout = stbir__pixel_layout_convert_public_to_internal[ output_pixel_layout_public ];
  int channels = stbir__pixel_channels[ input_pixel_layout ];
  int effective_channels = channels;

  // first figure out what type of alpha weighting to use (if any)
  if ( ( horizontal.filter_enum != STBIR_FILTER_POINT_SAMPLE ) || ( vertical.filter_enum != STBIR_FILTER_POINT_SAMPLE ) ) // no alpha weighting on point sampling
  {
    if ( ( input_pixel_layout >= STBIRI_RGBA ) && ( input_pixel_layout <= STBIRI_AR ) && ( output_pixel_layout >= STBIRI_RGBA ) && ( output_pixel_layout <= STBIRI_AR ) )
    {
      if ( fast_alpha )
      {
        alpha_weighting_type = 4;
      }
      else
      {
        static immutable int[6] fancy_alpha_effective_cnts = [ 7, 7, 7, 7, 3, 3 ];
        alpha_weighting_type = 2;
        effective_channels = fancy_alpha_effective_cnts[ input_pixel_layout - STBIRI_RGBA ];
      }
    }
    else if ( ( input_pixel_layout >= STBIRI_RGBA_PM ) && ( input_pixel_layout <= STBIRI_AR_PM ) && ( output_pixel_layout >= STBIRI_RGBA ) && ( output_pixel_layout <= STBIRI_AR ) )
    {
      // input premult, output non-premult
      alpha_weighting_type = 3;
    }
    else if ( ( input_pixel_layout >= STBIRI_RGBA ) && ( input_pixel_layout <= STBIRI_AR ) && ( output_pixel_layout >= STBIRI_RGBA_PM ) && ( output_pixel_layout <= STBIRI_AR_PM ) )
    {
      // input non-premult, output premult
      alpha_weighting_type = 1;
    }
  }

  // channel in and out count must match currently
  if ( channels != stbir__pixel_channels[ output_pixel_layout ] )
    return null;

  // get vertical first
  vertical_first = stbir__should_do_vertical_first( stbir__compute_weights[ cast(int)stbir_channel_count_index[ effective_channels ] ], 
                                                    horizontal.filter_pixel_width, 
                                                    horizontal.scale_info.scale, 
                                                    horizontal.scale_info.output_sub_size, 
                                                    vertical.filter_pixel_width, 
                                                    vertical.scale_info.scale, 
                                                    vertical.scale_info.output_sub_size, 
                                                    vertical.is_gather, STBIR__V_FIRST_INFO_POINTER );

  // sometimes read one float off in some of the unrolled loops (with a weight of zero coeff, so it doesn't have an effect)
  decode_buffer_size = cast(int) ( ( conservative.n1 - conservative.n0 + 1 ) * effective_channels * (float.sizeof) + (float.sizeof) ); // extra float for padding

  ring_buffer_length_bytes = cast(int) ( horizontal.scale_info.output_sub_size * effective_channels * (float.sizeof) + (float.sizeof) ); // extra float for padding

  // if we do vertical first, the ring buffer holds a whole decoded line
  if ( vertical_first )
    ring_buffer_length_bytes = ( decode_buffer_size + 15 ) & ~15;

  if ( ( ring_buffer_length_bytes & 4095 ) == 0 ) ring_buffer_length_bytes += 64*3; // avoid 4k alias

  // One extra entry because floating point precision problems sometimes cause an extra to be necessary.
  alloc_ring_buffer_num_entries = vertical.filter_pixel_width + 1;

  // we never need more ring buffer entries than the scanlines we're outputting when in scatter mode
  if ( ( !vertical.is_gather ) && ( alloc_ring_buffer_num_entries > conservative_split_output_size ) )
    alloc_ring_buffer_num_entries = conservative_split_output_size;

  ring_buffer_size = alloc_ring_buffer_num_entries * ring_buffer_length_bytes;

  // The vertical buffer is used differently, depending on whether we are scattering
  //   the vertical scanlines, or gathering them.
  //   If scattering, it's used at the temp buffer to accumulate each output.
  //   If gathering, it's just the output buffer.
  vertical_buffer_size = cast(int)( horizontal.scale_info.output_sub_size * effective_channels * float.sizeof + float.sizeof );  // extra float for padding

  // we make two passes through this loop, 1st to add everything up, 2nd to allocate and init
  for(;;)
  {
    int i;
    void * advance_mem = alloced;
    int copy_horizontal = 0;
    stbir__sampler* possibly_use_horizontal_for_pivot = null;

    // technically the ptr expression is "lazy" since being a C macro
    void STBIR__NEXT_PTR(T)(ref T* ptr, size_t size_in_bytes) nothrow @nogc
    {
        // align to 16 bytes
        advance_mem = cast(void*) ( ( (cast(size_t)advance_mem) + 15 ) & ~15 ); 

        if ( alloced )
            ptr = cast(T*)advance_mem; 
        advance_mem = (cast(char*)advance_mem) + size_in_bytes;
    }

    STBIR__NEXT_PTR!stbir__info( info, stbir__info.sizeof);

    {
        stbir__per_split_info* p;
        STBIR__NEXT_PTR!stbir__per_split_info(p, stbir__per_split_info.sizeof * splits);
        if (alloced) info.split_info = p;
    }

    if ( info )
    {
      static immutable stbir__alpha_weight_func[6] fancy_alpha_weights  = 
      [
        &stbir__fancy_alpha_weight_4ch,   
        &stbir__fancy_alpha_weight_4ch,   
        &stbir__fancy_alpha_weight_4ch,   
        &stbir__fancy_alpha_weight_4ch,   
        &stbir__fancy_alpha_weight_2ch,   
        &stbir__fancy_alpha_weight_2ch 
      ];
      static immutable stbir__alpha_unweight_func[6] fancy_alpha_unweights = 
      [ 
        &stbir__fancy_alpha_unweight_4ch, 
        &stbir__fancy_alpha_unweight_4ch, 
        &stbir__fancy_alpha_unweight_4ch, 
        &stbir__fancy_alpha_unweight_4ch, 
        &stbir__fancy_alpha_unweight_2ch, 
        &stbir__fancy_alpha_unweight_2ch 
      ];
      static immutable stbir__alpha_weight_func[6] simple_alpha_weights = 
      [ 
        &stbir__simple_alpha_weight_4ch, 
        &stbir__simple_alpha_weight_4ch, 
        &stbir__simple_alpha_weight_4ch, 
        &stbir__simple_alpha_weight_4ch, 
        &stbir__simple_alpha_weight_2ch, 
        &stbir__simple_alpha_weight_2ch 
      ];
      static immutable stbir__alpha_unweight_func[6] simple_alpha_unweights = 
      [
        &stbir__simple_alpha_unweight_4ch, 
        &stbir__simple_alpha_unweight_4ch, 
        &stbir__simple_alpha_unweight_4ch, 
        &stbir__simple_alpha_unweight_4ch, 
        &stbir__simple_alpha_unweight_2ch, 
        &stbir__simple_alpha_unweight_2ch 
      ];

      // initialize info fields
      info.alloced_mem = alloced;
      info.alloced_total = alloced_total;

      info.channels = channels;
      info.effective_channels = effective_channels;

      info.offset_x = new_x;
      info.offset_y = new_y;
      info.alloc_ring_buffer_num_entries = alloc_ring_buffer_num_entries;
      info.ring_buffer_num_entries = 0;
      info.ring_buffer_length_bytes = ring_buffer_length_bytes;
      info.splits = splits;
      info.vertical_first = vertical_first;

      info.input_pixel_layout_internal = input_pixel_layout;
      info.output_pixel_layout_internal = output_pixel_layout;

      // setup alpha weight functions
      info.alpha_weight = null;
      info.alpha_unweight = null;

      // handle alpha weighting functions and overrides
      if ( alpha_weighting_type == 2 )
      {
        // high quality alpha multiplying on the way in, dividing on the way out
        info.alpha_weight = fancy_alpha_weights[ input_pixel_layout - STBIRI_RGBA ];
        info.alpha_unweight = fancy_alpha_unweights[ output_pixel_layout - STBIRI_RGBA ];
      }
      else if ( alpha_weighting_type == 4 )
      {
        // fast alpha multiplying on the way in, dividing on the way out
        info.alpha_weight = simple_alpha_weights[ input_pixel_layout - STBIRI_RGBA ];
        info.alpha_unweight = simple_alpha_unweights[ output_pixel_layout - STBIRI_RGBA ];
      }
      else if ( alpha_weighting_type == 1 )
      {
        // fast alpha on the way in, leave in premultiplied form on way out
        info.alpha_weight = simple_alpha_weights[ input_pixel_layout - STBIRI_RGBA ];
      }
      else if ( alpha_weighting_type == 3 )
      {
        // incoming is premultiplied, fast alpha dividing on the way out - non-premultiplied output
        info.alpha_unweight = simple_alpha_unweights[ output_pixel_layout - STBIRI_RGBA ];
      }

      // handle 3-chan color flipping, using the alpha weight path
      if ( ( ( input_pixel_layout == STBIRI_RGB ) && ( output_pixel_layout == STBIRI_BGR ) ) ||
           ( ( input_pixel_layout == STBIRI_BGR ) && ( output_pixel_layout == STBIRI_RGB ) ) )
      {
        // do the flipping on the smaller of the two ends
        if ( horizontal.scale_info.scale < 1.0f )
          info.alpha_unweight = &stbir__simple_flip_3ch;
        else
          info.alpha_weight = &stbir__simple_flip_3ch;
      }

    }

    // get all the per-split buffers
    for( i = 0 ; i < splits ; i++ )
    {
        float* p = null;
        STBIR__NEXT_PTR!float( p, decode_buffer_size );
        if (alloced) info.split_info[i].decode_buffer = p;

        STBIR__NEXT_PTR!float( p, ring_buffer_size );
        if (alloced) info.split_info[i].ring_buffer = p;
      
        STBIR__NEXT_PTR!float( p, vertical_buffer_size );
        if (alloced) info.split_info[i].vertical_buffer = p;
    }

    // alloc memory for to-be-pivoted coeffs (if necessary)
    if ( vertical.is_gather == 0 )
    {
      int both;
      int temp_mem_amt;

      // when in vertical scatter mode, we first build the coefficients in gather mode, and then pivot after,
      //   that means we need two buffers, so we try to use the decode buffer and ring buffer for this. if that
      //   is too small, we just allocate extra memory to use as this temp.

      both = vertical.gather_prescatter_contributors_size + vertical.gather_prescatter_coefficients_size;

      temp_mem_amt = ( decode_buffer_size + ring_buffer_size + vertical_buffer_size ) * splits;

      if ( temp_mem_amt >= both )
      {
        if ( info )
        {
          vertical.gather_prescatter_contributors = cast(stbir__contributors*)info.split_info[0].decode_buffer;
          vertical.gather_prescatter_coefficients = cast(float*) ( ( cast(char*)info.split_info[0].decode_buffer ) + vertical.gather_prescatter_contributors_size );
        }
      }
      else
      {
        // ring+decode memory is too small, so allocate temp memory
        {
            stbir__contributors* p;
            STBIR__NEXT_PTR!stbir__contributors(p, vertical.gather_prescatter_contributors_size );
            if (alloced) vertical.gather_prescatter_contributors = p;
        }
        {
            float* p;
            STBIR__NEXT_PTR!float(p, vertical.gather_prescatter_coefficients_size );
            if (alloced) vertical.gather_prescatter_coefficients = p;
        }
      }
    }

    {
        stbir__contributors* p;
        STBIR__NEXT_PTR!stbir__contributors( p, horizontal.contributors_size  );
        if (alloced) horizontal.contributors = p;
    }
    {
        float* p;
        STBIR__NEXT_PTR!float( p, horizontal.coefficients_size );
        if (alloced) horizontal.coefficients = p;
    }

    // are the two filters identical?? (happens a lot with mipmap generation)
    if ( ( horizontal.filter_kernel == vertical.filter_kernel ) && ( horizontal.filter_support == vertical.filter_support ) && ( horizontal.edge == vertical.edge ) && ( horizontal.scale_info.output_sub_size == vertical.scale_info.output_sub_size ) )
    {
      float diff_scale = horizontal.scale_info.scale - vertical.scale_info.scale;
      float diff_shift = horizontal.scale_info.pixel_shift - vertical.scale_info.pixel_shift;
      if ( diff_scale < 0.0f ) diff_scale = -diff_scale;
      if ( diff_shift < 0.0f ) diff_shift = -diff_shift;
      if ( ( diff_scale <= stbir__small_float ) && ( diff_shift <= stbir__small_float ) )
      {
        if ( horizontal.is_gather == vertical.is_gather )
        {
          copy_horizontal = 1;
          goto no_vert_alloc;
        }
        // everything matches, but vertical is scatter, horizontal is gather, use horizontal coeffs for vertical pivot coeffs
        possibly_use_horizontal_for_pivot = horizontal;
      }
    }

    {
        stbir__contributors* p;
        STBIR__NEXT_PTR!stbir__contributors( p, vertical.contributors_size );
        if (alloced) vertical.contributors = p;
    }
    {
        float* p;
        STBIR__NEXT_PTR!float( p, vertical.coefficients_size);
        if (alloced) vertical.coefficients = p;
    }

   no_vert_alloc:

    if ( info )
    {
      stbir__calculate_filters( horizontal, null, user_data );

      // setup the horizontal gather functions
      // start with defaulting to the n_coeffs functions (specialized on channels and remnant leftover)
      info.horizontal_gather_channels = stbir__horizontal_gather_n_coeffs_funcs[ effective_channels ][ horizontal.extent_info.widest & 3 ];
      // but if the number of coeffs <= 12, use another set of special cases. <=12 coeffs is any enlarging resize, or shrinking resize down to about 1/3 size
      if ( horizontal.extent_info.widest <= 12 )
        info.horizontal_gather_channels = stbir__horizontal_gather_channels_funcs[ effective_channels ][ horizontal.extent_info.widest - 1 ];

      info.scanline_extents.conservative.n0 = conservative.n0;
      info.scanline_extents.conservative.n1 = conservative.n1;

      // get exact extents
      stbir__get_extents( horizontal, &info.scanline_extents );

      // pack the horizontal coeffs
      horizontal.coefficient_width = stbir__pack_coefficients(horizontal.num_contributors, horizontal.contributors, horizontal.coefficients, horizontal.coefficient_width, horizontal.extent_info.widest, info.scanline_extents.conservative.n0, info.scanline_extents.conservative.n1 );

      STBIR_MEMCPY( &info.horizontal, horizontal, stbir__sampler.sizeof);

      if ( copy_horizontal )
      {
        STBIR_MEMCPY( &info.vertical, horizontal, stbir__sampler.sizeof);
      }
      else
      {
        stbir__calculate_filters( vertical, possibly_use_horizontal_for_pivot, user_data );
        STBIR_MEMCPY( &info.vertical, vertical, stbir__sampler.sizeof);
      }

      // setup the vertical split ranges
      stbir__get_split_info( info.split_info, info.splits, info.vertical.scale_info.output_sub_size, info.vertical.filter_pixel_margin, info.vertical.scale_info.input_full_size );

      // now we know precisely how many entries we need
      info.ring_buffer_num_entries = info.vertical.extent_info.widest;

      // we never need more ring buffer entries than the scanlines we're outputting
      if ( ( !info.vertical.is_gather ) && ( info.ring_buffer_num_entries > conservative_split_output_size ) )
        info.ring_buffer_num_entries = conservative_split_output_size;
      assert( info.ring_buffer_num_entries <= info.alloc_ring_buffer_num_entries );

      // a few of the horizontal gather functions read one dword past the end (but mask it out), so put in a normal value so no snans or denormals accidentally sneak in
      for( i = 0 ; i < splits ; i++ )
      {
        int width, ofs;

        // find the right most span
        if ( info.scanline_extents.spans[0].n1 > info.scanline_extents.spans[1].n1 )
          width = info.scanline_extents.spans[0].n1 - info.scanline_extents.spans[0].n0;
        else
          width = info.scanline_extents.spans[1].n1 - info.scanline_extents.spans[1].n0;

        // this calc finds the exact end of the decoded scanline for all filter modes.
        //   usually this is just the width * effective channels.  But we have to account
        //   for the area to the left of the scanline for wrap filtering and alignment, this
        //   is stored as a negative value in info.scanline_extents.conservative.n0. Next,
        //   we need to skip the exact size of the right hand size filter area (again for
        //   wrap mode), this is in info.scanline_extents.edge_sizes[1]).
        ofs = ( width + 1 - info.scanline_extents.conservative.n0 + info.scanline_extents.edge_sizes[1] ) * effective_channels;

        // place a known, but numerically valid value in the decode buffer
        info.split_info[i].decode_buffer[ ofs ] = 9999.0f;

        // if vertical filtering first, place a known, but numerically valid value in the all
        //   of the ring buffer accumulators
        if ( vertical_first )
        {
          int j;
          for( j = 0; j < info.ring_buffer_num_entries ; j++ )
          {
            stbir__get_ring_buffer_entry( info, info.split_info + i, j )[ ofs ] = 9999.0f;
          }
        }
      }
    }

    // is this the first time through loop?
    if ( info == null )
    {
      alloced_total = ( 15 + cast(size_t)advance_mem );
      alloced = STBIR_MALLOC( alloced_total, user_data );
      if ( alloced == null )
        return null;      
    }
    else
      return info;  // success
  }

  // we will never arrive there
  assert(false);
}

int stbir__perform_resize( const(stbir__info)* info, int split_start, int split_count )
{
  stbir__per_split_info* split_info = cast(stbir__per_split_info*)(info.split_info) + split_start;

  if (info.vertical.is_gather)
    stbir__vertical_gather_loop( info, split_info, split_count );
  else
    stbir__vertical_scatter_loop( info, split_info, split_count );

  return 1;
}

static void stbir__update_info_from_resize( stbir__info * info, STBIR_RESIZE * resize )
{
  static immutable stbir__decode_pixels_func[STBIR_TYPE_HALF_FLOAT-STBIR_TYPE_UINT8_SRGB+1] decode_simple =
  [
    /* 1ch-4ch */ 
    &stbir__decode_uint8_srgb!CODER_RGBA, 
    &stbir__decode_uint8_srgb!CODER_RGBA, 
    null, 
    &stbir__decode_float_linear!CODER_RGBA, 
    &stbir__decode_half_float_linear!CODER_RGBA,
  ];

  static immutable stbir__decode_pixels_func[STBIR_TYPE_HALF_FLOAT-STBIR_TYPE_UINT8_SRGB+1][STBIRI_AR-STBIRI_RGBA+1] decode_alphas =
  [
    [ /* RGBA */ &stbir__decode_uint8_srgb4_linearalpha!CODER_RGBA, &stbir__decode_uint8_srgb!CODER_RGBA, null, &stbir__decode_float_linear!CODER_RGBA, &stbir__decode_half_float_linear!CODER_RGBA ],
    [ /* BGRA */ &stbir__decode_uint8_srgb4_linearalpha!CODER_BGRA, &stbir__decode_uint8_srgb!CODER_BGRA, null, &stbir__decode_float_linear!CODER_BGRA, &stbir__decode_half_float_linear!CODER_BGRA ],
    [ /* ARGB */ &stbir__decode_uint8_srgb4_linearalpha!CODER_ARGB, &stbir__decode_uint8_srgb!CODER_ARGB, null, &stbir__decode_float_linear!CODER_ARGB, &stbir__decode_half_float_linear!CODER_ARGB ],
    [ /* ABGR */ &stbir__decode_uint8_srgb4_linearalpha!CODER_ABGR, &stbir__decode_uint8_srgb!CODER_ABGR, null, &stbir__decode_float_linear!CODER_ABGR, &stbir__decode_half_float_linear!CODER_ABGR ],
    [ /* RA   */ &stbir__decode_uint8_srgb2_linearalpha!CODER_RGBA, &stbir__decode_uint8_srgb!CODER_RGBA, null, &stbir__decode_float_linear!CODER_RGBA, &stbir__decode_half_float_linear!CODER_RGBA ],
    [ /* AR   */ &stbir__decode_uint8_srgb2_linearalpha!CODER_AR,   &stbir__decode_uint8_srgb!CODER_AR  , null, &stbir__decode_float_linear!CODER_AR  , &stbir__decode_half_float_linear!CODER_AR   ],
  ];

  static immutable stbir__decode_pixels_func[2][2] decode_simple_scaled_or_not =
  [
    [  &stbir__decode_uint8_linear_scaled!CODER_RGBA, &stbir__decode_uint8_linear!CODER_RGBA  ], 
    [ &stbir__decode_uint16_linear_scaled!CODER_RGBA, &stbir__decode_uint16_linear!CODER_RGBA ],
  ];

  static immutable stbir__decode_pixels_func[2][2][STBIRI_AR-STBIRI_RGBA+1] decode_alphas_scaled_or_not =
  [
    [ /* RGBA */ [ &stbir__decode_uint8_linear_scaled!CODER_RGBA , &stbir__decode_uint8_linear!CODER_RGBA ] , [ &stbir__decode_uint16_linear_scaled!CODER_RGBA, &stbir__decode_uint16_linear!CODER_RGBA ] ],
    [ /* BGRA */ [ &stbir__decode_uint8_linear_scaled!CODER_BGRA , &stbir__decode_uint8_linear!CODER_BGRA ] , [ &stbir__decode_uint16_linear_scaled!CODER_BGRA, &stbir__decode_uint16_linear!CODER_BGRA ] ],
    [ /* ARGB */ [ &stbir__decode_uint8_linear_scaled!CODER_ARGB , &stbir__decode_uint8_linear!CODER_ARGB ] , [ &stbir__decode_uint16_linear_scaled!CODER_ARGB, &stbir__decode_uint16_linear!CODER_ARGB ] ],
    [ /* ABGR */ [ &stbir__decode_uint8_linear_scaled!CODER_ABGR , &stbir__decode_uint8_linear!CODER_ABGR ] , [ &stbir__decode_uint16_linear_scaled!CODER_ABGR, &stbir__decode_uint16_linear!CODER_ABGR ] ],
    [ /* RA   */ [ &stbir__decode_uint8_linear_scaled!CODER_RGBA , &stbir__decode_uint8_linear!CODER_RGBA ] , [ &stbir__decode_uint16_linear_scaled!CODER_RGBA, &stbir__decode_uint16_linear!CODER_RGBA ] ],
    [ /* AR   */ [ &stbir__decode_uint8_linear_scaled!CODER_AR   , &stbir__decode_uint8_linear!CODER_AR   ] , [ &stbir__decode_uint16_linear_scaled!CODER_AR  , &stbir__decode_uint16_linear!CODER_AR   ] ],
  ];

  static immutable stbir__encode_pixels_func[STBIR_TYPE_HALF_FLOAT - STBIR_TYPE_UINT8_SRGB + 1] encode_simple =
  [
    /* 1ch-4ch */ 
    &stbir__encode_uint8_srgb!CODER_RGBA, 
    &stbir__encode_uint8_srgb!CODER_RGBA, 
    null, 
    &stbir__encode_float_linear!CODER_RGBA, 
    &stbir__encode_half_float_linear!CODER_RGBA,
  ];

  static immutable stbir__encode_pixels_func[STBIR_TYPE_HALF_FLOAT - STBIR_TYPE_UINT8_SRGB + 1][STBIRI_AR-STBIRI_RGBA+1] encode_alphas =
  [
    [ /* RGBA */ &stbir__encode_uint8_srgb4_linearalpha!CODER_RGBA, &stbir__encode_uint8_srgb!CODER_RGBA, null, &stbir__encode_float_linear!CODER_RGBA, &stbir__encode_half_float_linear!CODER_RGBA],
    [ /* BGRA */ &stbir__encode_uint8_srgb4_linearalpha!CODER_BGRA, &stbir__encode_uint8_srgb!CODER_BGRA, null, &stbir__encode_float_linear!CODER_BGRA, &stbir__encode_half_float_linear!CODER_BGRA],
    [ /* ARGB */ &stbir__encode_uint8_srgb4_linearalpha!CODER_ARGB, &stbir__encode_uint8_srgb!CODER_ARGB, null, &stbir__encode_float_linear!CODER_ARGB, &stbir__encode_half_float_linear!CODER_ARGB],
    [ /* ABGR */ &stbir__encode_uint8_srgb4_linearalpha!CODER_ABGR, &stbir__encode_uint8_srgb!CODER_ABGR, null, &stbir__encode_float_linear!CODER_ABGR, &stbir__encode_half_float_linear!CODER_ABGR],
    [ /* RA   */ &stbir__encode_uint8_srgb2_linearalpha!CODER_RGBA, &stbir__encode_uint8_srgb!CODER_RGBA, null, &stbir__encode_float_linear!CODER_RGBA, &stbir__encode_half_float_linear!CODER_RGBA],
    [ /* AR   */ &stbir__encode_uint8_srgb2_linearalpha!CODER_AR  , &stbir__encode_uint8_srgb!CODER_AR  , null, &stbir__encode_float_linear!CODER_AR  , &stbir__encode_half_float_linear!CODER_AR  ]
  ];

  static immutable stbir__encode_pixels_func[2][2] encode_simple_scaled_or_not=
  [
    [ &stbir__encode_uint8_linear_scaled!CODER_RGBA , &stbir__encode_uint8_linear!CODER_RGBA ], 
    [ &stbir__encode_uint16_linear_scaled!CODER_RGBA, &stbir__encode_uint16_linear!CODER_RGBA ],
  ];

  static immutable stbir__encode_pixels_func[2][2][STBIRI_AR-STBIRI_RGBA+1] encode_alphas_scaled_or_not =
  [
    [ /* RGBA */ [ &stbir__encode_uint8_linear_scaled!CODER_RGBA, &stbir__encode_uint8_linear!CODER_RGBA], [ &stbir__encode_uint16_linear_scaled!CODER_RGBA , &stbir__encode_uint16_linear!CODER_RGBA ] ],
    [ /* BGRA */ [ &stbir__encode_uint8_linear_scaled!CODER_BGRA, &stbir__encode_uint8_linear!CODER_BGRA], [ &stbir__encode_uint16_linear_scaled!CODER_BGRA , &stbir__encode_uint16_linear!CODER_BGRA ] ],
    [ /* ARGB */ [ &stbir__encode_uint8_linear_scaled!CODER_ARGB, &stbir__encode_uint8_linear!CODER_ARGB], [ &stbir__encode_uint16_linear_scaled!CODER_ARGB , &stbir__encode_uint16_linear!CODER_ARGB ] ],
    [ /* ABGR */ [ &stbir__encode_uint8_linear_scaled!CODER_ABGR, &stbir__encode_uint8_linear!CODER_ABGR], [ &stbir__encode_uint16_linear_scaled!CODER_ABGR , &stbir__encode_uint16_linear!CODER_ABGR ] ],
    [ /* RA   */ [ &stbir__encode_uint8_linear_scaled!CODER_RGBA, &stbir__encode_uint8_linear!CODER_RGBA], [ &stbir__encode_uint16_linear_scaled!CODER_RGBA , &stbir__encode_uint16_linear!CODER_RGBA ] ],
    [ /* AR   */ [ &stbir__encode_uint8_linear_scaled!CODER_AR  , &stbir__encode_uint8_linear!CODER_AR  ], [ &stbir__encode_uint16_linear_scaled!CODER_AR   , &stbir__encode_uint16_linear!CODER_AR   ] ]
  ];

  stbir__decode_pixels_func decode_pixels = null;
  stbir__encode_pixels_func encode_pixels = null;
  stbir_datatype input_type, output_type;

  input_type = resize.input_data_type;
  output_type = resize.output_data_type;
  info.input_data = resize.input_pixels;
  info.input_stride_bytes = resize.input_stride_in_bytes;
  info.output_stride_bytes = resize.output_stride_in_bytes;

  // if we're completely point sampling, then we can turn off SRGB
  if ( ( info.horizontal.filter_enum == STBIR_FILTER_POINT_SAMPLE ) && ( info.vertical.filter_enum == STBIR_FILTER_POINT_SAMPLE ) )
  {
    if ( ( ( input_type  == STBIR_TYPE_UINT8_SRGB ) || ( input_type  == STBIR_TYPE_UINT8_SRGB_ALPHA ) ) &&
         ( ( output_type == STBIR_TYPE_UINT8_SRGB ) || ( output_type == STBIR_TYPE_UINT8_SRGB_ALPHA ) ) )
    {
      input_type = STBIR_TYPE_UINT8;
      output_type = STBIR_TYPE_UINT8;
    }
  }

  // recalc the output and input strides
  if ( info.input_stride_bytes == 0 )
    info.input_stride_bytes = info.channels * info.horizontal.scale_info.input_full_size * stbir__type_size[input_type];

  if ( info.output_stride_bytes == 0 )
    info.output_stride_bytes = info.channels * info.horizontal.scale_info.output_sub_size * stbir__type_size[output_type];

  // calc offset
  info.output_data = ( cast(char*) resize.output_pixels ) + ( cast(size_t) info.offset_y * cast(size_t) resize.output_stride_in_bytes ) + ( info.offset_x * info.channels * stbir__type_size[output_type] );

  info.in_pixels_cb = resize.input_cb;
  info.user_data = resize.user_data;
  info.out_pixels_cb = resize.output_cb;

  // setup the input format converters
  if ( ( input_type == STBIR_TYPE_UINT8 ) || ( input_type == STBIR_TYPE_UINT16 ) )
  {
    int non_scaled = 0;

    // check if we can run unscaled - 0-255.0/0-65535.0 instead of 0-1.0 (which is a tiny bit faster when doing linear 8.8 or 16.16)
    if ( ( !info.alpha_weight ) && ( !info.alpha_unweight )  ) // don't short circuit when alpha weighting (get everything to 0-1.0 as usual)
      if ( ( ( input_type == STBIR_TYPE_UINT8 ) && ( output_type == STBIR_TYPE_UINT8 ) ) || ( ( input_type == STBIR_TYPE_UINT16 ) && ( output_type == STBIR_TYPE_UINT16 ) ) )
        non_scaled = 1;

    if ( info.input_pixel_layout_internal <= STBIRI_4CHANNEL )
      decode_pixels = decode_simple_scaled_or_not[ input_type == STBIR_TYPE_UINT16 ][ non_scaled ];
    else
      decode_pixels = decode_alphas_scaled_or_not[ ( info.input_pixel_layout_internal - STBIRI_RGBA ) % ( STBIRI_AR-STBIRI_RGBA+1 ) ][ input_type == STBIR_TYPE_UINT16 ][ non_scaled ];
  }
  else
  {
    if ( info.input_pixel_layout_internal <= STBIRI_4CHANNEL )
      decode_pixels = decode_simple[ input_type - STBIR_TYPE_UINT8_SRGB ];
    else
      decode_pixels = decode_alphas[ ( info.input_pixel_layout_internal - STBIRI_RGBA ) % ( STBIRI_AR-STBIRI_RGBA+1 ) ][ input_type - STBIR_TYPE_UINT8_SRGB ];
  }

  // setup the output format converters
  if ( ( output_type == STBIR_TYPE_UINT8 ) || ( output_type == STBIR_TYPE_UINT16 ) )
  {
    int non_scaled = 0;

    // check if we can run unscaled - 0-255.0/0-65535.0 instead of 0-1.0 (which is a tiny bit faster when doing linear 8.8 or 16.16)
    if ( ( !info.alpha_weight ) && ( !info.alpha_unweight ) ) // don't short circuit when alpha weighting (get everything to 0-1.0 as usual)
      if ( ( ( input_type == STBIR_TYPE_UINT8 ) && ( output_type == STBIR_TYPE_UINT8 ) ) || ( ( input_type == STBIR_TYPE_UINT16 ) && ( output_type == STBIR_TYPE_UINT16 ) ) )
        non_scaled = 1;

    if ( info.output_pixel_layout_internal <= STBIRI_4CHANNEL )
      encode_pixels = encode_simple_scaled_or_not[ output_type == STBIR_TYPE_UINT16 ][ non_scaled ];
    else
      encode_pixels = encode_alphas_scaled_or_not[ ( info.output_pixel_layout_internal - STBIRI_RGBA ) % ( STBIRI_AR-STBIRI_RGBA+1 ) ][ output_type == STBIR_TYPE_UINT16 ][ non_scaled ];
  }
  else
  {
    if ( info.output_pixel_layout_internal <= STBIRI_4CHANNEL )
      encode_pixels = encode_simple[ output_type - STBIR_TYPE_UINT8_SRGB ];
    else
      encode_pixels = encode_alphas[ ( info.output_pixel_layout_internal - STBIRI_RGBA ) % ( STBIRI_AR-STBIRI_RGBA+1 ) ][ output_type - STBIR_TYPE_UINT8_SRGB ];
  }

  info.input_type = input_type;
  info.output_type = output_type;
  info.decode_pixels = decode_pixels;
  info.encode_pixels = encode_pixels;
}

static void stbir__clip( int * outx, int * outsubw, int outw, double * u0, double * u1 )
{
  double per, adj;
  int over;

  // do left/top edge
  if ( *outx < 0 )
  {
    per = ( cast(double)*outx ) / ( cast(double)*outsubw ); // is negative
    adj = per * ( *u1 - *u0 );
    *u0 -= adj; // increases u0
    *outx = 0;
  }

  // do right/bot edge
  over = outw - ( *outx + *outsubw );
  if ( over < 0 )
  {
    per = ( cast(double)over ) / ( cast(double)*outsubw ); // is negative
    adj = per * ( *u1 - *u0 );
    *u1 += adj; // decrease u1
    *outsubw = outw - *outx;
  }
}

// converts a double to a rational that has less than one float bit of error (returns 0 if unable to do so)
static int stbir__double_to_rational(double f, stbir_uint32 limit, stbir_uint32 *numer, stbir_uint32 *denom, int limit_denom ) // limit_denom (1) or limit numer (0)
{
  double err;
  stbir_uint64 top, bot;
  stbir_uint64 numer_last = 0;
  stbir_uint64 denom_last = 1;
  stbir_uint64 numer_estimate = 1;
  stbir_uint64 denom_estimate = 0;

  // scale to past float error range
  top = cast(stbir_uint64)( f * cast(double)(1 << 25) );
  bot = 1 << 25;

  // keep refining, but usually stops in a few loops - usually 5 for bad cases
  for(;;)
  {
    stbir_uint64 est, temp;

    // hit limit, break out and do best full range estimate
    if ( ( ( limit_denom ) ? denom_estimate : numer_estimate ) >= limit )
      break;

    // is the current error less than 1 bit of a float? if so, we're done
    if ( denom_estimate )
    {
      err = ( cast(double)numer_estimate / cast(double)denom_estimate ) - f;
      if ( err < 0.0 ) err = -err;
      if ( err < ( 1.0 / cast(double)(1<<24) ) )
      {
        // yup, found it
        *numer = cast(stbir_uint32) numer_estimate;
        *denom = cast(stbir_uint32) denom_estimate;
        return 1;
      }
    }

    // no more refinement bits left? break out and do full range estimate
    if ( bot == 0 )
      break;

    // gcd the estimate bits
    est = top / bot;
    temp = top % bot;
    top = bot;
    bot = temp;

    // move remainders
    temp = est * denom_estimate + denom_last;
    denom_last = denom_estimate;
    denom_estimate = temp;

    // move remainders
    temp = est * numer_estimate + numer_last;
    numer_last = numer_estimate;
    numer_estimate = temp;
  }

  // we didn't fine anything good enough for float, use a full range estimate
  if ( limit_denom )
  {
    numer_estimate= cast(stbir_uint64)( f * cast(double)limit + 0.5 );
    denom_estimate = limit;
  }
  else
  {
    numer_estimate = limit;
    denom_estimate = cast(stbir_uint64)( ( cast(double)limit / f ) + 0.5 );
  }

  *numer = cast(stbir_uint32) numer_estimate;
  *denom = cast(stbir_uint32) denom_estimate;

  err = ( denom_estimate ) ? ( ( cast(double)cast(stbir_uint32)numer_estimate / cast(double)cast(stbir_uint32)denom_estimate ) - f ) : 1.0;
  if ( err < 0.0 ) err = -err;
  return ( err < ( 1.0 / cast(double)(1<<24) ) ) ? 1 : 0;
}

static int stbir__calculate_region_transform( stbir__scale_info * scale_info, int output_full_range, int * output_offset, int output_sub_range, int input_full_range, double input_s0, double input_s1 )
{
  double output_range, input_range, output_s, input_s, ratio, scale;

  input_s = input_s1 - input_s0;

  // null area
  if ( ( output_full_range == 0 ) || ( input_full_range == 0 ) ||
       ( output_sub_range == 0 ) || ( input_s <= stbir__small_float ) )
    return 0;

  // are either of the ranges completely out of bounds?
  if ( ( *output_offset >= output_full_range ) || ( ( *output_offset + output_sub_range ) <= 0 ) || ( input_s0 >= (1.0f-stbir__small_float) ) || ( input_s1 <= stbir__small_float ) )
    return 0;

  output_range = cast(double)output_full_range;
  input_range = cast(double)input_full_range;

  output_s = ( cast(double)output_sub_range) / output_range;

  // figure out the scaling to use
  ratio = output_s / input_s;

  // save scale before clipping
  scale = ( output_range / input_range ) * ratio;
  scale_info.scale = cast(float)scale;
  scale_info.inv_scale = cast(float)( 1.0 / scale );

  // clip output area to left/right output edges (and adjust input area)
  stbir__clip( output_offset, &output_sub_range, output_full_range, &input_s0, &input_s1 );

  // recalc input area
  input_s = input_s1 - input_s0;

  // after clipping do we have zero input area?
  if ( input_s <= stbir__small_float )
    return 0;

  // calculate and store the starting source offsets in output pixel space
  scale_info.pixel_shift = cast(float) ( input_s0 * ratio * output_range );

  scale_info.scale_is_rational = stbir__double_to_rational( scale, ( scale <= 1.0 ) ? output_full_range : input_full_range, &scale_info.scale_numerator, &scale_info.scale_denominator, ( scale >= 1.0 ) );

  scale_info.input_full_size = input_full_range;
  scale_info.output_sub_size = output_sub_range;

  return 1;
}


static void stbir__init_and_set_layout( STBIR_RESIZE * resize, stbir_pixel_layout pixel_layout, stbir_datatype data_type )
{
  resize.input_cb = null;
  resize.output_cb = null;
  resize.user_data = resize;
  resize.samplers = null;
  resize.called_alloc = 0;
  resize.horizontal_filter = STBIR_FILTER_DEFAULT;
  resize.horizontal_filter_kernel = null; 
  resize.horizontal_filter_support = null;
  resize.vertical_filter = STBIR_FILTER_DEFAULT;
  resize.vertical_filter_kernel = null; 
  resize.vertical_filter_support = null;
  resize.horizontal_edge = STBIR_EDGE_CLAMP;
  resize.vertical_edge = STBIR_EDGE_CLAMP;
  resize.input_s0 = 0; resize.input_t0 = 0; resize.input_s1 = 1; resize.input_t1 = 1;
  resize.output_subx = 0; resize.output_suby = 0; resize.output_subw = resize.output_w; resize.output_subh = resize.output_h;
  resize.input_data_type = data_type;
  resize.output_data_type = data_type;
  resize.input_pixel_layout_public = pixel_layout;
  resize.output_pixel_layout_public = pixel_layout;
  resize.needs_rebuild = 1;
}

public void stbir_resize_init( STBIR_RESIZE * resize,
                                 const(void)* input_pixels,  int input_w,  int input_h, int input_stride_in_bytes, // stride can be zero
                                       void *output_pixels, int output_w, int output_h, int output_stride_in_bytes, // stride can be zero
                                 stbir_pixel_layout pixel_layout, stbir_datatype data_type )
{
  resize.input_pixels = cast(void*) input_pixels; // const_cast
  resize.input_w = input_w;
  resize.input_h = input_h;
  resize.input_stride_in_bytes = input_stride_in_bytes;
  resize.output_pixels = output_pixels;
  resize.output_w = output_w;
  resize.output_h = output_h;
  resize.output_stride_in_bytes = output_stride_in_bytes;
  resize.fast_alpha = 0;

  stbir__init_and_set_layout( resize, pixel_layout, data_type );
}

// You can update parameters any time after resize_init
public void stbir_set_datatypes( STBIR_RESIZE * resize, stbir_datatype input_type, stbir_datatype output_type )  // by default, datatype from resize_init
{
  resize.input_data_type = input_type;
  resize.output_data_type = output_type;
  if ( ( resize.samplers ) && ( !resize.needs_rebuild ) )
    stbir__update_info_from_resize( resize.samplers, resize );
}

public void stbir_set_pixel_callbacks( STBIR_RESIZE * resize, stbir_input_callback input_cb, stbir_output_callback output_cb )   // no callbacks by default
{
  resize.input_cb = input_cb;
  resize.output_cb = output_cb;

  if ( ( resize.samplers ) && ( !resize.needs_rebuild ) )
  {
    resize.samplers.in_pixels_cb = input_cb;
    resize.samplers.out_pixels_cb = output_cb;
  }
}

public void stbir_set_user_data( STBIR_RESIZE * resize, void * user_data )                                     // pass back STBIR_RESIZE* by default
{
  resize.user_data = user_data;
  if ( ( resize.samplers ) && ( !resize.needs_rebuild ) )
    resize.samplers.user_data = user_data;
}

public void stbir_set_buffer_ptrs( STBIR_RESIZE * resize, 
                                   const(void)* input_pixels, 
                                   int input_stride_in_bytes, 
                                   void* output_pixels, 
                                   int output_stride_in_bytes )
{
    resize.input_pixels = cast(void*) input_pixels; // const_cast
    resize.input_stride_in_bytes = input_stride_in_bytes;
    resize.output_pixels = output_pixels;
    resize.output_stride_in_bytes = output_stride_in_bytes;
    if ( ( resize.samplers ) && ( !resize.needs_rebuild ) )
        stbir__update_info_from_resize( resize.samplers, resize );
}


public int stbir_set_edgemodes( STBIR_RESIZE * resize, stbir_edge horizontal_edge, stbir_edge vertical_edge )       // CLAMP by default
{
  resize.horizontal_edge = horizontal_edge;
  resize.vertical_edge = vertical_edge;
  resize.needs_rebuild = 1;
  return 1;
}

public int stbir_set_filters( STBIR_RESIZE * resize, stbir_filter horizontal_filter, stbir_filter vertical_filter ) // STBIR_DEFAULT_FILTER_UPSAMPLE/DOWNSAMPLE by default
{
  resize.horizontal_filter = horizontal_filter;
  resize.vertical_filter = vertical_filter;
  resize.needs_rebuild = 1;
  return 1;
}

public int stbir_set_filter_callbacks( STBIR_RESIZE * resize, stbir__kernel_callback horizontal_filter, stbir__support_callback horizontal_support, stbir__kernel_callback vertical_filter, stbir__support_callback vertical_support )
{
  resize.horizontal_filter_kernel = horizontal_filter; resize.horizontal_filter_support = horizontal_support;
  resize.vertical_filter_kernel = vertical_filter; resize.vertical_filter_support = vertical_support;
  resize.needs_rebuild = 1;
  return 1;
}

public int stbir_set_pixel_layouts( STBIR_RESIZE * resize, stbir_pixel_layout input_pixel_layout, stbir_pixel_layout output_pixel_layout )   // sets new pixel layouts
{
  resize.input_pixel_layout_public = input_pixel_layout;
  resize.output_pixel_layout_public = output_pixel_layout;
  resize.needs_rebuild = 1;
  return 1;
}


public int stbir_set_non_pm_alpha_speed_over_quality( STBIR_RESIZE * resize, int non_pma_alpha_speed_over_quality )   // sets alpha speed
{
  resize.fast_alpha = non_pma_alpha_speed_over_quality;
  resize.needs_rebuild = 1;
  return 1;
}

public int stbir_set_input_subrect( STBIR_RESIZE * resize, double s0, double t0, double s1, double t1 )                 // sets input region (full region by default)
{
  resize.input_s0 = s0;
  resize.input_t0 = t0;
  resize.input_s1 = s1;
  resize.input_t1 = t1;
  resize.needs_rebuild = 1;

  // are we inbounds?
  if ( ( s1 < stbir__small_float ) || ( (s1-s0) < stbir__small_float ) ||
       ( t1 < stbir__small_float ) || ( (t1-t0) < stbir__small_float ) ||
       ( s0 > (1.0f-stbir__small_float) ) ||
       ( t0 > (1.0f-stbir__small_float) ) )
    return 0;

  return 1;
}

public int stbir_set_output_pixel_subrect( STBIR_RESIZE * resize, int subx, int suby, int subw, int subh )          // sets input region (full region by default)
{
  resize.output_subx = subx;
  resize.output_suby = suby;
  resize.output_subw = subw;
  resize.output_subh = subh;
  resize.needs_rebuild = 1;

  // are we inbounds?
  if ( ( subx >= resize.output_w ) || ( ( subx + subw ) <= 0 ) || ( suby >= resize.output_h ) || ( ( suby + subh ) <= 0 ) || ( subw == 0 ) || ( subh == 0 ) )
    return 0;

  return 1;
}

public int stbir_set_pixel_subrect( STBIR_RESIZE * resize, int subx, int suby, int subw, int subh )                 // sets both regions (full regions by default)
{
  double s0, t0, s1, t1;

  s0 = ( cast(double)subx ) / ( cast(double)resize.output_w );
  t0 = ( cast(double)suby ) / ( cast(double)resize.output_h );
  s1 = ( cast(double)(subx+subw) ) / ( cast(double)resize.output_w );
  t1 = ( cast(double)(suby+subh) ) / ( cast(double)resize.output_h );

  resize.input_s0 = s0;
  resize.input_t0 = t0;
  resize.input_s1 = s1;
  resize.input_t1 = t1;
  resize.output_subx = subx;
  resize.output_suby = suby;
  resize.output_subw = subw;
  resize.output_subh = subh;
  resize.needs_rebuild = 1;

  // are we inbounds?
  if ( ( subx >= resize.output_w ) || ( ( subx + subw ) <= 0 ) || ( suby >= resize.output_h ) || ( ( suby + subh ) <= 0 ) || ( subw == 0 ) || ( subh == 0 ) )
    return 0;

  return 1;
}

static int stbir__perform_build( STBIR_RESIZE * resize, int splits )
{
  stbir__contributors conservative = { 0, 0 };
  stbir__sampler horizontal, vertical;
  int new_output_subx, new_output_suby;
  stbir__info * out_info;
  
  // have we already built the samplers?
  if ( resize.samplers )
    return 0;

  assert( cast(uint)resize.horizontal_filter < STBIR_FILTER_OTHER);
  if (cast(uint)resize.horizontal_filter >= STBIR_FILTER_OTHER) 
      return 0;

  assert( cast(uint)resize.vertical_filter < STBIR_FILTER_OTHER);
  if (cast(uint)resize.vertical_filter >= STBIR_FILTER_OTHER) 
      return 0;

  if ( splits <= 0 )
    return 0;

  new_output_subx = resize.output_subx;
  new_output_suby = resize.output_suby;

  // do horizontal clip and scale calcs
  if ( !stbir__calculate_region_transform( &horizontal.scale_info, resize.output_w, &new_output_subx, resize.output_subw, resize.input_w, resize.input_s0, resize.input_s1 ) )
    return 0;

  // do vertical clip and scale calcs
  if ( !stbir__calculate_region_transform( &vertical.scale_info, resize.output_h, &new_output_suby, resize.output_subh, resize.input_h, resize.input_t0, resize.input_t1 ) )
    return 0;

  // if nothing to do, just return
  if ( ( horizontal.scale_info.output_sub_size == 0 ) || ( vertical.scale_info.output_sub_size == 0 ) )
    return 0;

  stbir__set_sampler(&horizontal, resize.horizontal_filter, resize.horizontal_filter_kernel, resize.horizontal_filter_support, resize.horizontal_edge, &horizontal.scale_info, 1, resize.user_data );
  stbir__get_conservative_extents( &horizontal, &conservative, resize.user_data );
  stbir__set_sampler(&vertical, resize.vertical_filter, resize.horizontal_filter_kernel, resize.vertical_filter_support, resize.vertical_edge, &vertical.scale_info, 0, resize.user_data );

  if ( ( vertical.scale_info.output_sub_size / splits ) < STBIR_FORCE_MINIMUM_SCANLINES_FOR_SPLITS ) // each split should be a minimum of 4 scanlines (handwavey choice)
  {
    splits = vertical.scale_info.output_sub_size / STBIR_FORCE_MINIMUM_SCANLINES_FOR_SPLITS;
    if ( splits == 0 ) splits = 1;
  }

  out_info = stbir__alloc_internal_mem_and_build_samplers( &horizontal, &vertical, &conservative, resize.input_pixel_layout_public, resize.output_pixel_layout_public, splits, new_output_subx, new_output_suby, resize.fast_alpha, resize.user_data );

  if ( out_info )
  {
    resize.splits = splits;
    resize.samplers = out_info;
    resize.needs_rebuild = 0;

    // update anything that can be changed without recalcing samplers
    stbir__update_info_from_resize( out_info, resize );

    return splits;
  }

  return 0;
}

void stbir_free_samplers( STBIR_RESIZE * resize )
{
  if ( resize.samplers )
  {
    stbir__free_internal_mem( resize.samplers );
    resize.samplers = null;
    resize.called_alloc = 0;
  }
}

public int stbir_build_samplers_with_splits( STBIR_RESIZE * resize, int splits )
{
  if ( ( resize.samplers == null ) || ( resize.needs_rebuild ) )
  {
    if ( resize.samplers )
      stbir_free_samplers( resize );

    resize.called_alloc = 1;
    return stbir__perform_build( resize, splits );
  }

  return 1;
}

public int stbir_build_samplers( STBIR_RESIZE * resize )
{
  return stbir_build_samplers_with_splits( resize, 1 );
}

public int stbir_resize_extended( STBIR_RESIZE * resize )
{
  int result;

  if ( ( resize.samplers == null ) || ( resize.needs_rebuild ) )
  {
    int alloc_state = resize.called_alloc;  // remember allocated state

    if ( resize.samplers )
    {
      stbir__free_internal_mem( resize.samplers );
      resize.samplers = null;
    }

    if ( !stbir_build_samplers( resize ) )
      return 0;

    resize.called_alloc = alloc_state;

    // if build_samplers succeeded (above), but there are no samplers set, then
    //   the area to stretch into was zero pixels, so don't do anything and return
    //   success
    if ( resize.samplers == null )
      return 1;
  }
  
  // do resize
  result = stbir__perform_resize( resize.samplers, 0, resize.splits );

  // if we alloced, then free
  if ( !resize.called_alloc )
  {
    stbir_free_samplers( resize );
    resize.samplers = null;
  }

  return result;
}

public int stbir_resize_extended_split( STBIR_RESIZE * resize, int split_start, int split_count )
{
  assert( resize.samplers );

  // if we're just doing the whole thing, call full
  if ( ( split_start == -1 ) || ( ( split_start == 0 ) && ( split_count == resize.splits ) ) )
    return stbir_resize_extended( resize );

  // you **must** build samplers first when using split resize
  if ( ( resize.samplers == null ) || ( resize.needs_rebuild ) )
    return 0;

  if ( ( split_start >= resize.splits ) || ( split_start < 0 ) || ( ( split_start + split_count ) > resize.splits ) || ( split_count <= 0 ) )
    return 0;

  // do resize
  return stbir__perform_resize( resize.samplers, split_start, split_count );
}

static int stbir__check_output_stuff( void ** ret_ptr, int * ret_pitch, void * output_pixels, int type_size, int output_w, int output_h, int output_stride_in_bytes, stbir_internal_pixel_layout pixel_layout )
{
  size_t size;
  int pitch;
  void * ptr;

  pitch = output_w * type_size * stbir__pixel_channels[ pixel_layout ];
  if ( pitch == 0 )
    return 0;

  if ( output_stride_in_bytes == 0 )
    output_stride_in_bytes = pitch;

  if ( output_stride_in_bytes < pitch )
    return 0;

  size = cast(size_t)output_stride_in_bytes * cast(size_t)output_h;
  if ( size == 0 )
    return 0;

  *ret_ptr = null;
  *ret_pitch = output_stride_in_bytes;

  if ( output_pixels == null )
  {
    ptr = STBIR_MALLOC( size, null );
    if ( ptr == null )
      return 0;

    *ret_ptr = ptr;
    *ret_pitch = pitch;
  }

  return 1;
}


public char * stbir_resize_uint8_linear( const char *input_pixels , int input_w , int input_h, int input_stride_in_bytes,
                                                          char *output_pixels, int output_w, int output_h, int output_stride_in_bytes,
                                                          stbir_pixel_layout pixel_layout )
{
  STBIR_RESIZE resize;
  char * optr;
  int opitch;

  if ( !stbir__check_output_stuff( cast(void**)&optr, &opitch, output_pixels, char.sizeof, output_w, output_h, output_stride_in_bytes, stbir__pixel_layout_convert_public_to_internal[ pixel_layout ] ) )
    return null;

  stbir_resize_init( &resize,
                     input_pixels,  input_w,  input_h,  input_stride_in_bytes,
                     (optr) ? optr : output_pixels, output_w, output_h, opitch,
                     pixel_layout, STBIR_TYPE_UINT8 );

  if ( !stbir_resize_extended( &resize ) )
  {
    if ( optr )
      STBIR_FREE( optr, null );
    return null;
  }

  return (optr) ? optr : output_pixels;
}

public char * stbir_resize_uint8_srgb( const char *input_pixels , int input_w , int input_h, int input_stride_in_bytes,
                                                        char *output_pixels, int output_w, int output_h, int output_stride_in_bytes,
                                                        stbir_pixel_layout pixel_layout )
{
  STBIR_RESIZE resize;
  char * optr;
  int opitch;

  if ( !stbir__check_output_stuff( cast(void**)&optr, &opitch, output_pixels, char.sizeof, output_w, output_h, output_stride_in_bytes, stbir__pixel_layout_convert_public_to_internal[ pixel_layout ] ) )
    return null;

  stbir_resize_init( &resize,
                     input_pixels,  input_w,  input_h,  input_stride_in_bytes,
                     (optr) ? optr : output_pixels, output_w, output_h, opitch,
                     pixel_layout, STBIR_TYPE_UINT8_SRGB );

  if ( !stbir_resize_extended( &resize ) )
  {
    if ( optr )
      STBIR_FREE( optr, null );
    return null;
  }

  return (optr) ? optr : output_pixels;
}


public float * stbir_resize_float_linear( const float *input_pixels , int input_w , int input_h, int input_stride_in_bytes,
                                                  float *output_pixels, int output_w, int output_h, int output_stride_in_bytes,
                                                  stbir_pixel_layout pixel_layout )
{
  STBIR_RESIZE resize;
  float * optr;
  int opitch;

  if ( !stbir__check_output_stuff( cast(void**)&optr, &opitch, output_pixels, float.sizeof, output_w, output_h, output_stride_in_bytes, stbir__pixel_layout_convert_public_to_internal[ pixel_layout ] ) )
    return null;

  stbir_resize_init( &resize,
                     input_pixels,  input_w,  input_h,  input_stride_in_bytes,
                     (optr) ? optr : output_pixels, output_w, output_h, opitch,
                     pixel_layout, STBIR_TYPE_FLOAT );

  if ( !stbir_resize_extended( &resize ) )
  {
    if ( optr )
      STBIR_FREE( optr, null );
    return null;
  }

  return (optr) ? optr : output_pixels;
}


public void * stbir_resize( const void *input_pixels , int input_w , int input_h, int input_stride_in_bytes,
                                    void *output_pixels, int output_w, int output_h, int output_stride_in_bytes,
                              stbir_pixel_layout pixel_layout, stbir_datatype data_type,
                              stbir_edge edge, stbir_filter filter )
{
  STBIR_RESIZE resize;
  float * optr;
  int opitch;

  if ( !stbir__check_output_stuff( cast(void**)&optr, &opitch, output_pixels, stbir__type_size[data_type], output_w, output_h, output_stride_in_bytes, stbir__pixel_layout_convert_public_to_internal[ pixel_layout ] ) )
    return null;

  stbir_resize_init( &resize,
                     input_pixels,  input_w,  input_h,  input_stride_in_bytes,
                     (optr) ? optr : output_pixels, output_w, output_h, output_stride_in_bytes,
                     pixel_layout, data_type );

  resize.horizontal_edge = edge;
  resize.vertical_edge = edge;
  resize.horizontal_filter = filter;
  resize.vertical_filter = filter;

  if ( !stbir_resize_extended( &resize ) )
  {
    if ( optr )
      STBIR_FREE( optr, null );
    return null;
  }

  return (optr) ? optr : output_pixels;
}




/*
------------------------------------------------------------------------------
This software is available under 2 licenses -- choose whichever you prefer.
------------------------------------------------------------------------------
ALTERNATIVE A - MIT License
Copyright (c) 2017 Sean Barrett
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
------------------------------------------------------------------------------
ALTERNATIVE B - Public Domain (www.unlicense.org)
This is free and unencumbered software released into the public domain.
Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
software, either in source code form or as a compiled binary, for any purpose,
commercial or non-commercial, and by any means.
In jurisdictions that recognize copyright laws, the author or authors of this
software dedicate any and all copyright interest in the software to the public
domain. We make this dedication for the benefit of the public at large and to
the detriment of our heirs and successors. We intend this dedication to be an
overt act of relinquishment in perpetuity of all present and future rights to
this software under copyright law.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
------------------------------------------------------------------------------
*/
