tar_target(gridLassoResponse, {
    dials::grid_regular(dials::penalty(),
      levels = 100
    )
})
