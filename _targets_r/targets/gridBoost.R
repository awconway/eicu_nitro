tar_target(gridBoost,
  grid_max_entropy(
    tree_depth(c(8, 15)),
    min_n(c(20L, 40L)),
    mtry(c(4L, 6L)),
    loss_reduction(),
    sample_size = sample_prop(c(0.5,1.0)),
    learn_rate(c(-3,-2)),
    trees(c(500, 5000)),
    size = 50
    )
  )
