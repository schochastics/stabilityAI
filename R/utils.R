default_params <- list(
    height = 1024,
    width = 1024,
    cfg_scale = 8,
    clip_guidance_preset = "NONE",
    sampler = "",
    samples = 1,
    seed = 0,
    steps = 50,
    style_preset = ""
)

clip_guidance_preset <- c("FAST_BLUE", "FAST_GREEN", "NONE", "SIMPLE", "SLOW", "SLOWER", "SLOWEST")
style_preset <- c("", "3d-model", "analog-film", "anime", "cinematic", "comic-book", "digital-art", "enhance", "fantasy-art", "isometric", "line-art", "low-poly", "modeling-compound", "neon-punk", "origami", "photographic", "pixel-art", "tile-texture")

modify_params <- function(params) {
    params <- utils::modifyList(default_params, params)

    if (params[["cfg_scale"]] < 0 || params[["cfg_scale"]] > 35) {
        rlang::abort("parameter cfg_scale must be in [0 .. 35]")
    }

    if (!params[["clip_guidance_preset"]] %in% clip_guidance_preset) {
        rlang::abort(paste0("clip_guidance_preset must be one of ", paste0(clip_guidance_preset, collapse = ", ")))
    }
    if (params[["samples"]] < 1 || params[["samples"]] > 10) {
        rlang::abort("parameter samples must be in [1 .. 10]")
    }

    if (params[["steps"]] < 10 || params[["steps"]] > 150) {
        rlang::abort("parameter steps must be in [10 .. 150]")
    }

    if (!params[["style_preset"]] %in% style_preset) {
        rlang::abort(paste0("style_preset must be one of ", paste0(style_preset, collapse = ", ")))
    }

    if (params[["style_preset"]] == "") {
        params[["style_preset"]] <- NULL
    }

    if (params[["sampler"]] == "") {
        params[["sampler"]] <- NULL
    }
    params
}

check_token <- function(token) {
    if (is.null(token)) {
        token <- Sys.getenv("STABILITYAI_TOKEN")
    }
    if (token == "") {
        rlang::abort("STABILITYAI_TOKEN token not found in .Renviron")
    }
    token
}

make_request <- function(path = "v1/user/account", params = list(), header = list(), init_image = NULL, token = NULL) {
    token <- check_token(token)
    req <- httr2::request("https://api.stability.ai")
    req <- httr2::req_url_path_append(req, path)
    req <- httr2::req_headers(req, "Authorization" = token)
    if (length(params) != 0) {
        # req <- httr2::req_url_query(req, !!!params)
        req <- httr2::req_body_json(req, params, simplifyVector = FALSE)
    }
    if (!is.null(init_image)) {
        if (!file.exists(init_image)) {
            rlang::abort("image file does not exist")
        }
        req <- httr2::req_body_file(req, init_image)
    }
    if (length(header) != 0) {
        req <- httr2::req_headers(req, !!!header)
    }
    req <- httr2::req_user_agent(req, "stability.ai R package (http://github.com/schochastics/stabilityAI)")
    # httr2::req_dry_run(req)
    resp <- httr2::req_perform(req)
    resp
}

#' Image data uri to file
#'
#' Convert a data uri to an image in the correct format and save it to a file.
#'
#' @param img64 charachter, base64 image string as returned by [generate_txt2img]
#' @param slug character, name of file to export image to. WITHOUT extension
#'
#' @return nothing, called for side effects
#' @export
base64_to_img <- function(img64, slug) {
    img_type <- "png"
    img_file <- paste0(slug, ".", img_type)
    conn <- file(img_file, "wb")
    base64enc::base64decode(what = img64, output = conn)
    close(conn)
    invisible(img64)
}
