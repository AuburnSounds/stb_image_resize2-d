module stb_image_resize2.types;

nothrow @nogc @system:

public
{
    alias stbir_uint8  = ubyte;
    alias stbir_uint16 = ushort;
    alias stbir_uint32 = uint;
    alias stbir_uint64 = ulong;


    // Easy API

    // stbir_pixel_layout specifies:
    //   number of channels
    //   order of channels
    //   whether color is premultiplied by alpha
    // for back compatibility, you can cast the old channel count to an stbir_pixel_layout
    alias stbir_pixel_layout = int;
    enum : stbir_pixel_layout
    {
        STBIR_1CHANNEL = 1,
        STBIR_2CHANNEL = 2,
        STBIR_RGB      = 3,               // 3-chan, with order specified (for channel flipping)
        STBIR_BGR      = 0,               // 3-chan, with order specified (for channel flipping)
        STBIR_4CHANNEL = 5,

        STBIR_RGBA = 4,                   // alpha formats, where alpha is NOT premultiplied into color channels
        STBIR_BGRA = 6,
        STBIR_ARGB = 7,
        STBIR_ABGR = 8,
        STBIR_RA   = 9,
        STBIR_AR   = 10,

        STBIR_RGBA_PM = 11,               // alpha formats, where alpha is premultiplied into color channels
        STBIR_BGRA_PM = 12,
        STBIR_ARGB_PM = 13,
        STBIR_ABGR_PM = 14,
        STBIR_RA_PM   = 15,
        STBIR_AR_PM   = 16,

        STBIR_RGBA_NO_AW = 11,            // alpha formats, where NO alpha weighting is applied at all!
        STBIR_BGRA_NO_AW = 12,            //   these are just synonyms for the _PM flags (which also do
        STBIR_ARGB_NO_AW = 13,            //   no alpha weighting). These names just make it more clear
        STBIR_ABGR_NO_AW = 14,            //   for some folks).
        STBIR_RA_NO_AW   = 15,
        STBIR_AR_NO_AW   = 16,
    }


    // Medium API

    alias stbir_edge = int;
    enum : stbir_edge
    {
        STBIR_EDGE_CLAMP   = 0,
        STBIR_EDGE_REFLECT = 1,
        STBIR_EDGE_WRAP    = 2,  // this edge mode is slower and uses more memory
        STBIR_EDGE_ZERO    = 3,
    }

    alias stbir_filter = int;
    enum : stbir_filter
    {
        STBIR_FILTER_DEFAULT      = 0,  // use same filter type that easy-to-use API chooses
        STBIR_FILTER_BOX          = 1,  // A trapezoid w/1-pixel wide ramps, same result as box for integer scale ratios
        STBIR_FILTER_TRIANGLE     = 2,  // On upsampling, produces same results as bilinear texture filtering
        STBIR_FILTER_CUBICBSPLINE = 3,  // The cubic b-spline (aka Mitchell-Netrevalli with B=1,C=0), gaussian-esque
        STBIR_FILTER_CATMULLROM   = 4,  // An interpolating cubic spline
        STBIR_FILTER_MITCHELL     = 5,  // Mitchell-Netrevalli filter with B=1/3, C=1/3
        STBIR_FILTER_POINT_SAMPLE = 6,  // Simple point sampling
        STBIR_FILTER_OTHER        = 7,  // User callback specified
    }

    alias stbir_datatype = int;
    enum : stbir_datatype
    {
        STBIR_TYPE_UINT8            = 0,
        STBIR_TYPE_UINT8_SRGB       = 1,
        STBIR_TYPE_UINT8_SRGB_ALPHA = 2,  // alpha channel, when present, should also be SRGB (this is very unusual)
        STBIR_TYPE_UINT16           = 3,
        STBIR_TYPE_FLOAT            = 4,
        STBIR_TYPE_HALF_FLOAT       = 5
    }



    // Advanced API


    // INPUT CALLBACK: this callback is used for input scanlines
    alias stbir_input_callback = void* function( void* optional_output, 
                                                 void* input_ptr, 
                                                 int num_pixels, 
                                                 int x, int y, void * context );

    // OUTPUT CALLBACK: this callback is used for output scanlines
    alias stbir_output_callback = void function( void* output_ptr, int num_pixels, int y, void * context );

    // callbacks for user installed filters
    alias stbir__kernel_callback = float function(float x, float scale, void * user_data ); // centered at zero
    alias stbir__support_callback = float function(float scale, void * user_data );

    struct STBIR_RESIZE  // use the stbir_resize_init and stbir_override functions to set these values for future compatibility
    {
        void* user_data;
        void* input_pixels;
        int input_w, input_h;
        double input_s0, input_t0, input_s1, input_t1;
        stbir_input_callback input_cb;
        void* output_pixels;
        int output_w, output_h;
        int output_subx, output_suby, output_subw, output_subh;
        stbir_output_callback output_cb;
        int input_stride_in_bytes;
        int output_stride_in_bytes;
        int splits;
        int fast_alpha;
        int needs_rebuild;
        int called_alloc;
        stbir_pixel_layout input_pixel_layout_public;
        stbir_pixel_layout output_pixel_layout_public;
        stbir_datatype input_data_type;
        stbir_datatype output_data_type;
        stbir_filter horizontal_filter, vertical_filter;
        stbir_edge horizontal_edge, vertical_edge;
        stbir__kernel_callback horizontal_filter_kernel; 
        stbir__support_callback horizontal_filter_support;
        stbir__kernel_callback vertical_filter_kernel; 
        stbir__support_callback vertical_filter_support;
        stbir__info * samplers;
    }
}


// internal types and constants

enum float stbir__max_uint8_as_float = 255.0f;
enum float stbir__max_uint16_as_float = 65535.0f;
enum float stbir__max_uint8_as_float_inverted = (1.0f/255.0f);
enum float stbir__max_uint16_as_float_inverted = (1.0f/65535.0f);


// the internal pixel layout enums are in a different order, so we can easily do range comparisons of types
//   the public pixel layout is ordered in a way that if you cast num_channels (1-4) to the enum, you get something sensible
alias stbir_internal_pixel_layout = int;
enum : stbir_internal_pixel_layout
{
    STBIRI_1CHANNEL = 0,
    STBIRI_2CHANNEL = 1,
    STBIRI_RGB      = 2,
    STBIRI_BGR      = 3,
    STBIRI_4CHANNEL = 4,

    STBIRI_RGBA = 5,
    STBIRI_BGRA = 6,
    STBIRI_ARGB = 7,
    STBIRI_ABGR = 8,
    STBIRI_RA   = 9,
    STBIRI_AR   = 10,

    STBIRI_RGBA_PM = 11,
    STBIRI_BGRA_PM = 12,
    STBIRI_ARGB_PM = 13,
    STBIRI_ABGR_PM = 14,
    STBIRI_RA_PM   = 15,
    STBIRI_AR_PM   = 16,
}

// layout lookups - must match stbir_internal_pixel_layout
static immutable ubyte[17] stbir__pixel_channels = 
[
    1,2,3,3,4,   // 1ch, 2ch, rgb, bgr, 4ch
    4,4,4,4,2,2, // RGBA,BGRA,ARGB,ABGR,RA,AR
    4,4,4,4,2,2, // RGBA_PM,BGRA_PM,ARGB_PM,ABGR_PM,RA_PM,AR_PM
];

// the internal pixel layout enums are in a different order, so we can easily do range comparisons of types
//   the public pixel layout is ordered in a way that if you cast num_channels (1-4) to the enum, you get something sensible
static immutable stbir_internal_pixel_layout[17] stbir__pixel_layout_convert_public_to_internal = 
[
    STBIRI_BGR, STBIRI_1CHANNEL, STBIRI_2CHANNEL, STBIRI_RGB, STBIRI_RGBA,
    STBIRI_4CHANNEL, STBIRI_BGRA, STBIRI_ARGB, STBIRI_ABGR, STBIRI_RA, STBIRI_AR,
    STBIRI_RGBA_PM, STBIRI_BGRA_PM, STBIRI_ARGB_PM, STBIRI_ABGR_PM, STBIRI_RA_PM, STBIRI_AR_PM,
];

// must match stbir_datatype
static immutable ubyte[] stbir__type_size = 
[
    1,1,1,2,4,2 // STBIR_TYPE_UINT8,STBIR_TYPE_UINT8_SRGB,STBIR_TYPE_UINT8_SRGB_ALPHA,STBIR_TYPE_UINT16,STBIR_TYPE_FLOAT,STBIR_TYPE_HALF_FLOAT
];

// When gathering, the contributors are which source pixels contribute.
// When scattering, the contributors are which destination pixels are contributed to.
struct stbir__contributors
{
    int n0; // First contributing pixel
    int n1; // Last contributing pixel
}

struct stbir__filter_extent_info
{
    int lowest;    // First sample index for whole filter
    int highest;   // Last sample index for whole filter
    int widest;    // widest single set of samples for an output
}

struct stbir__span
{
    int n0; // First pixel of decode buffer to write to
    int n1; // Last pixel of decode that will be written to
    int pixel_offset_for_input;  // Pixel offset into input_scanline
}

struct stbir__scale_info
{
    int input_full_size;
    int output_sub_size;
    float scale;
    float inv_scale;
    float pixel_shift; // starting shift in output pixel space (in pixels)
    int scale_is_rational;
    stbir_uint32 scale_numerator, scale_denominator;
}

struct stbir__sampler
{
    stbir__contributors * contributors;
    float* coefficients;
    stbir__contributors * gather_prescatter_contributors;
    float * gather_prescatter_coefficients;
    stbir__scale_info scale_info;
    float support;
    stbir_filter filter_enum;
    stbir__kernel_callback filter_kernel;
    stbir__support_callback filter_support;
    stbir_edge edge;
    int coefficient_width;
    int filter_pixel_width;
    int filter_pixel_margin;
    int num_contributors;
    int contributors_size;
    int coefficients_size;
    stbir__filter_extent_info extent_info;
    int is_gather;  // 0 = scatter, 1 = gather with scale >= 1, 2 = gather with scale < 1
    int gather_prescatter_num_contributors;
    int gather_prescatter_coefficient_width;
    int gather_prescatter_contributors_size;
    int gather_prescatter_coefficients_size;
}

struct stbir__extents
{
    stbir__contributors conservative;
    int[2] edge_sizes;    // this can be less than filter_pixel_margin, if the filter and scaling falls off
    stbir__span[2] spans; // can be two spans, if doing input subrect with clamp mode WRAP
}

struct stbir__per_split_info
{
    float* decode_buffer;

    int ring_buffer_first_scanline;
    int ring_buffer_last_scanline;
    int ring_buffer_begin_index;    // first_scanline is at this index in the ring buffer
    int start_output_y, end_output_y;
    int start_input_y, end_input_y;  // used in scatter only

    float* ring_buffer;  // one big buffer that we index into

    float* vertical_buffer;

    char[64] no_cache_straddle;
}

@system
{
    alias stbir__decode_pixels_func = void function( float * decode, int width_times_channels, const(void)* input );
    alias stbir__alpha_weight_func = void function( float * decode_buffer, int width_times_channels );
    alias stbir__horizontal_gather_channels_func = void function( float * output_buffer, uint output_sub_size, float * decode_buffer, 
                                                                  stbir__contributors * horizontal_contributors, float * horizontal_coefficients, int coefficient_width );
    alias stbir__alpha_unweight_func = void function(float * encode_buffer, int width_times_channels );
    alias stbir__encode_pixels_func = void function( void * output, int width_times_channels, float * encode );
}

struct stbir__info
{
    stbir__sampler horizontal;
    stbir__sampler vertical;

    void * input_data;
    void * output_data;

    int input_stride_bytes;
    int output_stride_bytes;
    int ring_buffer_length_bytes;   // The length of an individual entry in the ring buffer. The total number of ring buffers is stbir__get_filter_pixel_width(filter)
    int ring_buffer_num_entries;    // Total number of entries in the ring buffer.

    stbir_datatype input_type;
    stbir_datatype output_type;

    stbir_input_callback in_pixels_cb;
    void * user_data;
    stbir_output_callback out_pixels_cb;

    stbir__extents scanline_extents;

    void * alloced_mem;
    stbir__per_split_info * split_info;  // by default 1, but there will be N of these allocated based on the thread init you did

    stbir__decode_pixels_func decode_pixels;
    stbir__alpha_weight_func alpha_weight;
    stbir__horizontal_gather_channels_func horizontal_gather_channels;
    stbir__alpha_unweight_func alpha_unweight;
    stbir__encode_pixels_func encode_pixels;

    int alloc_ring_buffer_num_entries;    // Number of entries in the ring buffer that will be allocated
    int splits; // count of splits

    stbir_internal_pixel_layout input_pixel_layout_internal;
    stbir_internal_pixel_layout output_pixel_layout_internal;

    int input_color_and_type;
    int offset_x, offset_y; // offset within output_data
    int vertical_first;
    int channels;
    int effective_channels; // same as channels, except on RGBA/ARGB (7), or XA/AX (3)
    size_t alloced_total;
}

// min/max friendly
float STBIR_CLAMP(float x, float xmin, float xmax)
{
    if ( (x) < (xmin) ) (x) = (xmin);
    if ( (x) > (xmax) ) (x) = (xmax);
    return x;
}

int stbir__min(int a, int b)
{
    return a < b ? a : b;
}

int stbir__max(int a, int b)
{
    return a > b ? a : b;
}

union stbir__FP32
{
    uint u;
    float f;
}
