if (interactive() && Sys.getenv("TERM_PROGRAM") == "vscode") {
	options(vsc.str.max.level = 2 )
  if ("httpgd" %in% .packages(all.available = TRUE)) {
    options(vsc.plot = FALSE)
    options(device = function(...) {
      httpgd::hgd(silent = TRUE)
      .vsc.browser(httpgd::hgd_url(), viewer = "Beside")
    })
  }
}