import std;
import core.memory;
import dplug.graphics;
import gamut;
import stb_image_resize2;

// Note: put input images in input/

// Resize to MUL/DIV times the pixels
enum MUL = 1;
enum DIV = 2;

void main()
{
    getCurrentThreadHandle();
    {
        auto entries = dirEntries("./input/",SpanMode.shallow);
        auto pngRange = filter!`endsWith(a.name,".png")`(entries);
        auto pngs = pngRange.array; // crash here
        testDplug(pngs);
    }   
}

void testDplug(DirEntry[] pngs)
{
    ImageResizer resizer;
    ImageResizer2 resizer2;

    writeln;
    writeln("Testing with dplug.graphics");
    {
        OwnedImage!RGBA[] images = new OwnedImage!RGBA[pngs.length];
        OwnedImage!RGBA[] resized = new OwnedImage!RGBA[pngs.length];

        foreach(size_t i, pngfile; pngs)
        {
            writefln("Loading %s", pngfile);
            ubyte[] content = cast(ubyte[]) std.file.read(pngfile);
            Image image;
            image.loadFromMemory(content, LOAD_RGB | LOAD_ALPHA | LOAD_8BIT | LOAD_NO_PREMUL);

            images[i] = convertImageToOwnedImage_rgba8(image);
            resized[i] = new OwnedImage!RGBA;
            resized[i].size( (images[i].w * MUL)/DIV, (images[i].h * MUL)/DIV);
        }

        if (!images.length)
            throw new Exception("No .png images found in input/ directory. Put PNG images there.");

        string[] resizerNames = ["stb_image_resize2-d", "dplug:graphics", "arsd imageresize.d"];
        for(int VER = 0; VER < 3; ++VER)
        {
            writefln("*** Resize using method %s", resizerNames[VER]);
            foreach(size_t i, OwnedImage!RGBA src; images)
            {
                int NTIMES = 10;
                int NTRY = 3;
                long timeUs = long.max;
                for (int k = 0; k < NTRY; ++k)
                {
                    long timeA = getTickUs(false);
                    for (int n = 0; n < NTIMES; ++n)
                    {
                        if (VER == 0)
                            resizer2.resizeImage_sRGBWithAlpha(images[i].toRef, resized[i].toRef);
                        else if (VER == 1)
                            resizer.resizeImage_sRGBWithAlpha(images[i].toRef, resized[i].toRef);
                        else if (VER == 2)
                        {
                            arsdImageResize(images[i].toRef, resized[i].toRef);
                        }
                    }
                    long timeB = getTickUs(false);
                    if (timeB - timeA < timeUs)
                        timeUs = timeB - timeA;
                }
                double secs = timeUs * 1e-6 / NTIMES;

                std.file.write("output" ~ to!string(VER) ~ ".png", convertImageRefToPNG(resized[i].toRef));

                int w = images[i].w > resized[i].w ?  images[i].w : resized[i].w;
                int h = images[i].h > resized[i].h ?  images[i].h : resized[i].h;
                float mpps = (cast(long)w * h * 1e-6) / secs;
                writefln("Resized %s in %s, mpps = %s", pngs[i], convertMicroSecondsToDisplay(timeUs), mpps);
            }
        }
    }
    // wait
    GC.collect();
}


// Returns: "0.1 ms" when given 100 us
string convertMicroSecondsToDisplay(double us)
{
    double ms = (us / 1000.0);
    return format("%.1f ms", ms);
}


version(Windows)
{
    import core.sys.windows.windows;
    __gshared HANDLE hThread;

    extern(Windows) BOOL QueryThreadCycleTime(HANDLE   ThreadHandle, PULONG64 CycleTime) nothrow @nogc;
    long qpcFrequency;
    void getCurrentThreadHandle()
    {
        hThread = GetCurrentThread();    
        QueryPerformanceFrequency(&qpcFrequency);
    }
}
else
{
    void getCurrentThreadHandle()
    {
    }
}

static long getTickUs(bool precise) nothrow @nogc
{
    version(Windows)
    {
        if (precise)
        {
            // Note about -precise measurement
            // We use the undocumented fact that QueryThreadCycleTime
            // seem to return a counter in QPC units.
            // That may not be the case everywhere, so -precise is not reliable and should
            // never be the default.
            import core.sys.windows.windows;
            ulong cycles;
            BOOL res = QueryThreadCycleTime(hThread, &cycles);
            assert(res != 0);
            real us = 1000.0 * cast(real)(cycles) / cast(real)(qpcFrequency);
            return cast(long)(0.5 + us);
        }
        else
        {
            import core.time;
            return convClockFreq(MonoTime.currTime.ticks, MonoTime.ticksPerSecond, 1_000_000);
        }
    }
    else
    {
        import core.time;
        return convClockFreq(MonoTime.currTime.ticks, MonoTime.ticksPerSecond, 1_000_000);
    }
}

// fake the dplug:graphics helper construct
struct ImageResizer2
{
    ///ditto
    void resizeImage_sRGBWithAlpha(ImageRef!RGBA input, ImageRef!RGBA output)
    {
        import stb_image_resize2;

        char* pels = stbir_resize_uint8_srgb( cast(const(char)*)  input.pixels,  input.w ,  input.h, cast(int)input.pitch,
                                 cast(      char* )output.pixels, output.w, output.h, cast(int)output.pitch,
                                 STBIR_RGBA);
        assert(pels);
    }
}

void arsdImageResize(ImageRef!RGBA input, ImageRef!RGBA output)
{
    import arsd.color;
    import arsd.imageresize;

    void* pI = input.pixels;
    void* pO = output.pixels;

    ubyte[] cI = (cast(ubyte*)pI)[0..input.w * input.h*4];
  //  Color[] cO = (cast(Color*)pO)[0..output.w * output.h];

    TrueColorImage I = new TrueColorImage(input.w, input.h, cI);
   // TrueColorImage O = new TrueColorImage(input.w, input.h, cO);

    // Create TrueColorImage for source and dest, cause it just needs to point somewhere
    imageResize!4(I, output.w, output.h);
}