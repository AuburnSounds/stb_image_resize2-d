# stb_image_resize2-d


A port of stb_image_resize2.h in D.
  
Original: https://github.com/nothings/stb/blob/master/stb_image_resize2.h



## Resize an image using the "medium-complexity" API

Easiest way to use `stb_image_resize2-d` is probably the following function:
```d
void* stbir_resize(const(void)* input_pixels,  // input image
                   int input_w,                // input width
                   int input_h,                // input height
                   int input_stride_in_bytes,  // can be negative
                   
                   void *output_pixels,        // output image
                   int output_w,               // output width
                   int output_h,               // output height
                   int output_stride_in_bytes, // can be negative

                   stbir_pixel_layout pixel_layout, // Channel count eg. STBIR_RGBA
                   stbir_datatype data_type,   // precision and power curve eg. STBIR_TYPE_UINT8_SRGB
                   stbir_edge edge,            // edge mode  eg. STBIR_EDGE_CLAMP
                   stbir_filter filter);       // kernel     eg. STBIR_FILTER_DEFAULT

```


## Changes

- There are more resize kernels in the port.
- The port use portable intrinsics in `intel-intrinsics` so that the AVX2 path is used for everything.