#' Account details
#' get details about your stability.ai account
#' @param token either the stability.ai API key or NULL to read it from .Renviron
#' @return data frame with account details
#' @export
#' @examples
#' \dontrun{
#' get_account_details()
#' }
get_account_details <- function(token = NULL) {
    make_request(path = "v1/user/account", token = token)
}

#' Account balance
#' get balance from your stability.ai account
#' @inheritParams get_account_details
#' @return account balance
#' @export
#' @examples
#' \dontrun{
#' get_account_balance()
#' }
get_account_balance <- function(token = NULL) {
    res <- make_request(path = "v1/user/balance", token = token)
    balance <- httr2::resp_body_json(res)
    rlang::inform(paste0("You have a balance of ", balance$credits, " credits"))
}

#' Engines list
#' get a list of engines to use
#' @inheritParams get_account_details
#' @return data.frame containing engines
#' @export
#' @examples
#' \dontrun{
#' get_eninges_list()
#' }
get_engines_list <- function(token = NULL) {
    res <- make_request(path = "v1/engines/list", token = token)
    as.data.frame(do.call("rbind", httr2::resp_body_json(res)))
}
#' Text to Image
#' Create an image from a text prompt
#' @inheritParams get_account_details
#' @param text_prompts string.
#' @param engine_id string.
#' @param Accept string. One of "application/json" "image/png".
#' @param ... further parameters to pass to the API
#' @return png image as base64. can be saved with [base64_to_img]
#' @details for a detailed list of supported parameters see <https://platform.stability.ai/docs/api-reference#tag/v1generation/operation/textToImage>
#' @export
#' @examples
#' \dontrun{
#' generate_txt2img(text_prompts = "A lighthouse on a cliff")
#' }
generate_txt2img <- function(
    text_prompts = "",
    engine_id = "stable-diffusion-xl-1024-v0-9",
    Accept = "application/json",
    token = NULL, ...) {
    params <- list(
        ...,
        text_prompts = data.frame(text = text_prompts) # c(text = text_prompts, weight = 1)
    )
    header <- list(
        Accept = Accept,
        `Stability-Client-ID` = engine_id
    )
    params <- modify_params(params = params)

    resp <- make_request(
        path = paste0("v1/generation/", engine_id, "/text-to-image"),
        params = params,
        header = header,
        token = token
    )
    img <- httr2::resp_body_json(resp)$artifacts[[1]]$base64
    img
}
