tar_target(workflowRidge, {
  workflow()|>
      add_recipe(recLasso)|>
      add_model(specLasso)
})
