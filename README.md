# stb_image_resize2-d


A port of stb_image_resize2.h in D.
  
Original: https://github.com/nothings/stb/blob/master/stb_image_resize2.h

## Resize an image using the "medium-complexity" API

Easiest way to use `stb_image_resize2-d` is probably the following function:
```d
import stb_image_resize2;

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

## Example with a `gamut` image with type `PixelType.rgba8`

```d
    import gamut;
    import stb_image_resize2;

    // input, output are of type gamut.Image
    stbir_resize(input.scanptr(0), input.width, input.height, input.pitchInBytes,
                 output.scanptr(0), output.width, output.height, output.pitchInBytes,
                 STBIR_RGBA,
                 STBIR_TYPE_UINT8_SRGB,
                 STBIR_EDGE_CLAMP,
                 STBIR_FILTER_DEFAULT);
```

## Changes

- There are more resize kernels in the port:
  - `STBIR_FILTER_LANCZOS2`
  - `STBIR_FILTER_LANCZOS2_5`
  - `STBIR_FILTER_LANCZOS3`
  - `STBIR_FILTER_LANCZOS4`
  - `STBIR_FILTER_MK_2013`
  - `STBIR_FILTER_MKS_2013_86`
  - `STBIR_FILTER_MKS_2013`
  - `STBIR_FILTER_MKS_2021`

- The port use portable intrinsics in `intel-intrinsics` so that the AVX2 path is used for everything.
