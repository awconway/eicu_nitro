 tar_target(
    workflowBoost,
    workflow()|>
    add_recipe(recBoost)|>
    add_model(specBoost)
  )
