# stabilityAI <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->
<!-- badges: end -->

`stabilityAI` implements functions to connect with the API of stability.ai

## Installation

You can install the development version of stabilityAI like so:

``` r
remotes::install_github("schochastics/stabilityAI")
```

## Authentication

After signing up at <stability.ai>, obtain an API key from
<https://platform.stability.ai/account/keys> and save it in your `.Renviron`
file (for example using `usethis::edit_r_environ()`) as "STABILITYAI_TOKEN".

## Create an image

```r
# this prompt generated the logo and describes how the package was implemented... 
img <- generate_txt2img(
    text_prompts = "A dude with no hair and a beard sitting in front of his laptop in a dark room",
    style_preset = "pixel-art"
)

#API returns the image base64 encoded. Save it as png with
base64_to_img(img,"logo")

```
