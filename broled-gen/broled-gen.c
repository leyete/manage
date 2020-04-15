/*
 * This program generates an ICC profile that emulates brightness control for OLED screens.
 *
 * Based on the tool icc-brightness by Udi Fuchs (https://github.com/udifuchs/icc-brightness)
 *
 *     Copyright 2017 - 2019, Udi Fuchs
 *     SPDX-License-Identifier: MIT
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <lcms2.h>

#define MAX_DESC_LEN        20

#define FILENAME            argv[1]      /* profile save file (argv) */
#define BRIGHTNESS          argv[2]      /* brightness     (argv) */
#define MAX_BRIGHTNESS      argv[3]      /* max brightness (argv) */

#define DIGITS_ONLY(s)      (strspn((s), "0123456789") == strlen((s)))
#define RATIO(x, y)         (double) atoi((x)) / atoi((y))

#define PARAMETRIC_CURVE_ID    2               /* Y = (aX + b)^(gamma) for (X >= -b/a) */
#define PARAMETRIC_CURVE_N     3               /* number of paramters : a, b, gamma */
#define PARAMETRIC_CURVE(b)    {1.0, (b), 0.0} /* {gamma, a, b} : parametric curve Y = (aX + b)^(gamma) */

#define SUCCESS             0
#define ERR_INVALID_OPTIONS 1
#define CMS_DESC_ERROR      2
#define CMS_CURVE_ERROR     3
#define CMS_VCGT_ERROR      4

#define SAFE_FREE_MLU(mlu) do {                   \
    if ((mlu) != NULL)                            \
        cmsMLUfree((mlu));                        \
    (mlu) = NULL;                                 \
} while (0)

#define SAFE_FREE_CURVES(crv, n) do {             \
    for (int i = 0; i < (n); i++) {               \
        if ((crv)[i] != NULL)                     \
            cmsFreeToneCurve((crv)[i]);           \
        (crv)[i] = NULL;                          \
    }                                             \
} while (0)


static int create_srgb_profile (cmsHPROFILE profile, double brightness)
{
    cmsMLU        *mlu       = NULL;
    cmsContext    ctx;
    cmsToneCurve  *curves[3] = {0};

    int      ret                             = SUCCESS;
    char     desc[MAX_DESC_LEN]              = {0};
    double   curve_param[PARAMETRIC_CURVE_N] = PARAMETRIC_CURVE(brightness);

    /* set the profile description (localization en_US) */
    mlu   = cmsMLUalloc(NULL, 1);
    snprintf(desc, MAX_DESC_LEN, "Brightness %.2f", brightness);
    cmsMLUsetASCII(mlu, "en", "US", desc);

    if (!cmsWriteTag(profile, cmsSigProfileDescriptionTag, mlu)) {
        ret = CMS_DESC_ERROR;
        goto cleanup;
    }

    ctx = cmsCreateContext(NULL, NULL);
    for (int i = 0; i < 3; i++) {
        curves[i] = cmsBuildParametricToneCurve(ctx, PARAMETRIC_CURVE_ID, curve_param);
        if (curves[i] == NULL) {
            ret = CMS_CURVE_ERROR;
            goto cleanup;
        }
    }

    if (!cmsWriteTag(profile, cmsSigVcgtTag, curves)) {
        ret = CMS_VCGT_ERROR;
    }

cleanup:
    SAFE_FREE_MLU(mlu);
    SAFE_FREE_CURVES(curves, 3);

    return ret;
}

static void usage (const char *pname)
{
    fprintf(stderr, "usage: %s profile brightness max_brightness\n", pname);
    fprintf(stderr, "\n");
    fprintf(stderr, "ICC color profile generator (powered by liblcms2). This program will generate an ICC profile\n");
    fprintf(stderr, "that emulates the brightness level computed as the ratio (brightness / max_brightness)\n");
    fprintf(stderr, "\n");
    fprintf(stderr, "OPTIONS:\n");
    fprintf(stderr, "    profile         (string)   file to save the generated profile on.\n");
    fprintf(stderr, "    brightness      (integer)  brightness level (relative to max_brightness).\n");
    fprintf(stderr, "    max_brightness  (integer)  maximum brightness level.\n");
}

int main (int argc, const char *argv[])
{
    int         ret     = SUCCESS;
    cmsHPROFILE profile = cmsCreate_sRGBProfile();

    if (argc != 4 || !DIGITS_ONLY(BRIGHTNESS) || !DIGITS_ONLY(MAX_BRIGHTNESS)) {
        usage(argv[0]);
        return ERR_INVALID_OPTIONS;
    }

    if ((ret = create_srgb_profile(profile, RATIO(BRIGHTNESS, MAX_BRIGHTNESS))) == SUCCESS)
        cmsSaveProfileToFile(profile, FILENAME);

    return ret;
}
