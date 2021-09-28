tar_target(gridLasso, {
    dials::grid_regular(dials::penalty(),
      levels = 100
    )
})
