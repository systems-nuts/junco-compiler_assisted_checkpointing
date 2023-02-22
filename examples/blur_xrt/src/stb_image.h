#ifndef STB_IMAGE_H
#define STB_IMAGE_H

typedef unsigned char stbi_uc;
typedef unsigned short stbi_us;

extern "C" stbi_uc *stbi_load            (char const *filename, int *x, int *y, int *channels_in_file, int desired_channels);

extern "C" void     stbi_image_free      (void *retval_from_stbi_load);


#endif
